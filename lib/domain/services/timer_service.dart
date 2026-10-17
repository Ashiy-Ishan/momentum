import 'dart:async';

import '../enums/enums.dart';
import '../models/timer_session.dart';

typedef SessionIdGenerator = String Function();

class ActiveTimerException implements Exception {
  final String message;
  final TimerSession? activeSession;

  const ActiveTimerException(this.message, [this.activeSession]);

  @override
  String toString() => 'ActiveTimerException: $message';
}

class InvalidTimerStateException implements Exception {
  final String message;
  final TimerSessionStatus currentStatus;

  const InvalidTimerStateException(this.message, this.currentStatus);

  @override
  String toString() =>
      'InvalidTimerStateException: $message (current status: $currentStatus)';
}

class TimerService {
  final SessionIdGenerator _idGenerator;

  const TimerService({SessionIdGenerator? idGenerator})
      : _idGenerator = idGenerator ?? _defaultIdGenerator;

  static String _defaultIdGenerator() =>
      'session_${DateTime.now().microsecondsSinceEpoch}';

  bool isActive(TimerSession session) {
    if (session.isDeleted) return false;
    return session.status == TimerSessionStatus.running ||
        session.status == TimerSessionStatus.paused;
  }

  bool hasActiveSession(Iterable<TimerSession> sessions) {
    return sessions.any(isActive);
  }

  TimerSession? findActiveSession(Iterable<TimerSession> sessions) {
    for (final s in sessions) {
      if (isActive(s)) return s;
    }
    return null;
  }

  Duration calculateElapsed(TimerSession session, [DateTime? asOf]) {
    return Duration(seconds: calculateElapsedSeconds(session, asOf));
  }

  int calculateElapsedSeconds(TimerSession session, [DateTime? asOf]) {
    if (session.status == TimerSessionStatus.running) {
      final now = asOf ?? DateTime.now();
      final runningDiff = now.difference(session.startedAt).inSeconds;
      final runningSeconds = runningDiff > 0 ? runningDiff : 0;
      return session.elapsedSeconds + runningSeconds;
    }
    return session.elapsedSeconds;
  }

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

  int calculateTotalMinutes(Iterable<TimerSession> sessions, [DateTime? asOf]) {
    return calculateTotalDuration(sessions, asOf).inMinutes;
  }

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

  TimerSession pauseTimer(TimerSession session, {DateTime? now}) {
    if (session.status == TimerSessionStatus.paused) {
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

  TimerSession resumeTimer(
    TimerSession session, {
    Iterable<TimerSession>? existingSessions,
    DateTime? now,
  }) {
    if (session.status == TimerSessionStatus.running) {
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

  TimerSession stopTimer(TimerSession session, {DateTime? now}) {
    if (session.status == TimerSessionStatus.completed) {
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

  TimerSession discardTimer(TimerSession session, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    return session.copyWith(isDeleted: true, updatedAt: currentTime);
  }

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
