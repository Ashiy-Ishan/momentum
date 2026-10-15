import 'dart:async';

import '../enums/enums.dart';
import '../models/timer_session.dart';

/// Function signature for generating unique session identifiers.
typedef SessionIdGenerator = String Function();

/// Thrown when attempting to start or resume a timer session while another
/// session is already active.
class ActiveTimerException implements Exception {
  final String message;
  final TimerSession? activeSession;

  const ActiveTimerException(this.message, [this.activeSession]);

  @override
  String toString() => 'ActiveTimerException: $message';
}

/// Thrown when a timer operation is attempted in an invalid state
/// (e.g., pausing an already completed timer).
class InvalidTimerStateException implements Exception {
  final String message;
  final TimerSessionStatus currentStatus;

  const InvalidTimerStateException(this.message, this.currentStatus);

  @override
  String toString() =>
      'InvalidTimerStateException: $message (current status: $currentStatus)';
}

/// Domain service for tracking time and managing timer sessions.
///
/// Guarantees:
/// - Only ONE active (running or paused) timer session allowed at any given time.
/// - Calculates elapsed duration accounting for `running`, `paused`, and `completed` states.
/// - Calculates elapsed time from absolute timestamps (`DateTime.now().difference(startedAt)`
///   minus paused periods) rather than tick counters, ensuring 100% accuracy across
///   app backgrounding, system sleep, or app restarts.
class TimerService {
  final SessionIdGenerator _idGenerator;

  const TimerService({SessionIdGenerator? idGenerator})
      : _idGenerator = idGenerator ?? _defaultIdGenerator;

  static String _defaultIdGenerator() =>
      'session_${DateTime.now().microsecondsSinceEpoch}';

  /// Checks if a session is currently active (either running or paused and not deleted).
  bool isActive(TimerSession session) {
    if (session.isDeleted) return false;
    return session.status == TimerSessionStatus.running ||
        session.status == TimerSessionStatus.paused;
  }

  /// Checks if any session in the collection is currently active.
  bool hasActiveSession(Iterable<TimerSession> sessions) {
    return sessions.any(isActive);
  }

  /// Returns the first active session found in the collection, or null.
  TimerSession? findActiveSession(Iterable<TimerSession> sessions) {
    for (final s in sessions) {
      if (isActive(s)) return s;
    }
    return null;
  }

  /// Calculates elapsed duration for a given [session] as of [asOf] (defaults to `DateTime.now()`).
  ///
  /// Formula:
  /// - `completed` or `paused`: returns recorded [session.elapsedSeconds].
  /// - `running`: returns [session.elapsedSeconds] + `asOf.difference(session.startedAt)`.
  Duration calculateElapsed(TimerSession session, [DateTime? asOf]) {
    return Duration(seconds: calculateElapsedSeconds(session, asOf));
  }

  /// Calculates elapsed seconds for a given [session] as of [asOf].
  int calculateElapsedSeconds(TimerSession session, [DateTime? asOf]) {
    if (session.status == TimerSessionStatus.running) {
      final now = asOf ?? DateTime.now();
      final runningDiff = now.difference(session.startedAt).inSeconds;
      final runningSeconds = runningDiff > 0 ? runningDiff : 0;
      return session.elapsedSeconds + runningSeconds;
    }
    return session.elapsedSeconds;
  }

  /// Calculates the total duration summed across multiple sessions.
  Duration calculateTotalDuration(
    Iterable<TimerSession> sessions, [
    DateTime? asOf,
  ]) {
    var totalSeconds = 0;
    for (final session in sessions) {
      if (session.isDeleted) continue;
      totalSeconds += calculateElapsedSeconds(session, asOf);
    }
    return Duration(seconds: totalSeconds);
  }

  /// Calculates total tracked minutes summed across multiple sessions.
  int calculateTotalMinutes(Iterable<TimerSession> sessions, [DateTime? asOf]) {
    return calculateTotalDuration(sessions, asOf).inMinutes;
  }

  /// Groups and calculates elapsed duration by `taskId`.
  Map<String, Duration> calculateElapsedByTask(
    Iterable<TimerSession> sessions, [
    DateTime? asOf,
  ]) {
    final result = <String, int>{};
    for (final session in sessions) {
      if (session.isDeleted) continue;
      final sec = calculateElapsedSeconds(session, asOf);
      result[session.taskId] = (result[session.taskId] ?? 0) + sec;
    }
    return result.map((taskId, sec) => MapEntry(taskId, Duration(seconds: sec)));
  }

  /// Starts a new timer session for a task.
  ///
  /// Enforces single-active-session invariant:
  /// - If [existingSessions] contains an active session and [stopActiveFirst] is `false`,
  ///   throws [ActiveTimerException].
  /// - If [stopActiveFirst] is `true`, callers can pass the active session to [stopTimer]
  ///   before creating the new one.
  TimerSession startTimer({
    required String userId,
    required String taskId,
    String? occurrenceId,
    String? sessionId,
    Iterable<TimerSession>? existingSessions,
    bool stopActiveFirst = false,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();

    if (existingSessions != null) {
      final active = findActiveSession(existingSessions);
      if (active != null) {
        if (!stopActiveFirst) {
          throw ActiveTimerException(
            'Cannot start timer: another session (${active.id}) is currently ${active.status.displayName.toLowerCase()} for task ${active.taskId}.',
            active,
          );
        }
      }
    }

    return TimerSession(
      id: sessionId ?? _idGenerator(),
      userId: userId,
      taskId: taskId,
      occurrenceId: occurrenceId,
      startedAt: currentTime,
      pausedAt: null,
      endedAt: null,
      elapsedSeconds: 0,
      status: TimerSessionStatus.running,
      createdAt: currentTime,
      updatedAt: currentTime,
      version: 1,
      isDeleted: false,
    );
  }

  /// Pauses an active, running timer session.
  ///
  /// Accurately updates [session.elapsedSeconds] by adding the elapsed time
  /// since [session.startedAt]. Subsequent pause time does NOT accumulate.
  TimerSession pauseTimer(TimerSession session, {DateTime? now}) {
    if (session.status == TimerSessionStatus.paused) {
      // Idempotent: already paused
      return session;
    }

    if (session.status == TimerSessionStatus.completed) {
      throw InvalidTimerStateException(
        'Cannot pause a completed timer session',
        session.status,
      );
    }

    final currentTime = now ?? DateTime.now();
    final runningDiff = currentTime.difference(session.startedAt).inSeconds;
    final additionalSeconds = runningDiff > 0 ? runningDiff : 0;
    final totalElapsed = session.elapsedSeconds + additionalSeconds;

    return session.copyWith(
      status: TimerSessionStatus.paused,
      pausedAt: currentTime,
      elapsedSeconds: totalElapsed,
      updatedAt: currentTime,
    );
  }

  /// Resumes a paused timer session.
  ///
  /// Resets [startedAt] to [currentTime] to establish a new anchor for timestamp
  /// calculation. Previous [elapsedSeconds] are preserved.
  ///
  /// Enforces: only ONE active session allowed. If [existingSessions] contains
  /// an active session other than this one, throws [ActiveTimerException].
  TimerSession resumeTimer(
    TimerSession session, {
    Iterable<TimerSession>? existingSessions,
    DateTime? now,
  }) {
    if (session.status == TimerSessionStatus.running) {
      // Idempotent: already running
      return session;
    }

    if (session.status == TimerSessionStatus.completed) {
      throw InvalidTimerStateException(
        'Cannot resume a completed timer session',
        session.status,
      );
    }

    if (existingSessions != null) {
      final active = findActiveSession(existingSessions);
      if (active != null && active.id != session.id) {
        throw ActiveTimerException(
          'Cannot resume timer: another session (${active.id}) is already active.',
          active,
        );
      }
    }

    final currentTime = now ?? DateTime.now();

    return session.copyWith(
      status: TimerSessionStatus.running,
      startedAt: currentTime,
      clearPausedAt: true,
      updatedAt: currentTime,
    );
  }

  /// Stops and completes a timer session.
  ///
  /// Finalizes [elapsedSeconds] from the running timestamp difference if it was running.
  TimerSession stopTimer(TimerSession session, {DateTime? now}) {
    if (session.status == TimerSessionStatus.completed) {
      // Idempotent
      return session;
    }

    final currentTime = now ?? DateTime.now();
    var finalElapsedSeconds = session.elapsedSeconds;

    if (session.status == TimerSessionStatus.running) {
      final runningDiff = currentTime.difference(session.startedAt).inSeconds;
      if (runningDiff > 0) {
        finalElapsedSeconds += runningDiff;
      }
    }

    return session.copyWith(
      status: TimerSessionStatus.completed,
      endedAt: currentTime,
      elapsedSeconds: finalElapsedSeconds,
      updatedAt: currentTime,
    );
  }

  /// Discards a timer session by marking it deleted.
  TimerSession discardTimer(TimerSession session, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    return session.copyWith(isDeleted: true, updatedAt: currentTime);
  }

  /// Returns a stream of [Duration] emitting every [interval] (default: 1 second).
  ///
  /// The emitted duration is ALWAYS computed from timestamps via [calculateElapsed],
  /// guaranteeing that app sleep/backgrounding will not drift or lose accuracy.
  Stream<Duration> createTickStream(
    TimerSession Function() sessionProvider, {
    Duration interval = const Duration(seconds: 1),
  }) async* {
    yield calculateElapsed(sessionProvider());

    yield* Stream.periodic(interval, (_) {
      return calculateElapsed(sessionProvider());
    });
  }
}
