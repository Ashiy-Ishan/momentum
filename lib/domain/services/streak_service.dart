import '../../core/utils/date_utils.dart';
import '../enums/enums.dart';
import '../models/task_occurrence.dart';

/// Criterion for determining whether a scheduled day is considered "completed".
enum StreakCriterion {
  /// All eligible scheduled tasks on that day must be completed.
  allTasksCompleted,

  /// At least one eligible scheduled task on that day must be completed.
  atLeastOneCompleted,
}

/// Mode for evaluating consecutive days in a streak.
enum StreakMode {
  /// Streaks are measured across consecutive days that had scheduled tasks.
  /// Days with no scheduled tasks do not break the streak.
  scheduledDaysOnly,

  /// Streaks are measured across consecutive calendar days.
  consecutiveCalendarDays,
}

/// Status of an individual day in the streak evaluation.
enum DayStreakStatus {
  /// The day had scheduled tasks and was successfully completed.
  completed,

  /// The day had scheduled tasks and was missed, but was forgiven by a grace day.
  grace,

  /// The day had scheduled tasks and was missed, breaking the streak.
  missed,

  /// Today, has scheduled tasks that are not yet completed (still pending).
  pendingToday,

  /// No eligible tasks were scheduled on this day.
  empty,
}

/// Result of streak evaluation.
class StreakResult {
  /// Current consecutive streak of completed scheduled days up to today.
  /// If today has tasks and none completed yet, the streak from yesterday is still valid until end of today.
  final int currentStreak;

  /// Longest historical consecutive streak.
  final int longestStreak;

  /// Total days where eligible tasks were scheduled.
  final int eligibleScheduledDays;

  /// Total days where scheduled tasks were completed according to [StreakCriterion].
  final int completedDays;

  /// Whether today's streak is active/maintained (either completed today, or pending today, or no tasks today).
  final bool isMaintainedToday;

  /// Whether today itself was completed.
  final bool completedToday;

  /// Number of grace days currently active in preserving the [currentStreak].
  final int graceDaysUsedInCurrentStreak;

  /// Map of date (normalized to midnight) to its streak evaluation status.
  final Map<DateTime, DayStreakStatus> dayStatuses;

  const StreakResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.eligibleScheduledDays,
    required this.completedDays,
    required this.isMaintainedToday,
    required this.completedToday,
    required this.graceDaysUsedInCurrentStreak,
    required this.dayStatuses,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakResult &&
          runtimeType == other.runtimeType &&
          currentStreak == other.currentStreak &&
          longestStreak == other.longestStreak &&
          eligibleScheduledDays == other.eligibleScheduledDays &&
          completedDays == other.completedDays &&
          isMaintainedToday == other.isMaintainedToday &&
          completedToday == other.completedToday &&
          graceDaysUsedInCurrentStreak == other.graceDaysUsedInCurrentStreak;

  @override
  int get hashCode => Object.hash(
    currentStreak,
    longestStreak,
    eligibleScheduledDays,
    completedDays,
    isMaintainedToday,
    completedToday,
    graceDaysUsedInCurrentStreak,
  );

  @override
  String toString() =>
      'StreakResult(current: $currentStreak, longest: $longestStreak, '
      'eligibleDays: $eligibleScheduledDays, completedDays: $completedDays, '
      'maintainedToday: $isMaintainedToday, completedToday: $completedToday, '
      'graceUsed: $graceDaysUsedInCurrentStreak)';
}

/// Domain service for calculating current streaks, longest historical streaks,
/// eligible scheduled days, and grace day buffers.
class StreakService {
  const StreakService();

  /// Calculates complete streak metrics from a collection of task occurrences.
  ///
  /// Key rules:
  /// - Future dates are NEVER counted as missed or failures.
  /// - If today has scheduled tasks and none are completed yet, the streak from
  ///   the previous completed day remains active until the end of today.
  /// - Optional grace day support ([enableGraceDay], default: true, buffer of [graceDaysAllowed] days).
  /// - Configurable completion criteria: [allTasksCompleted] or [atLeastOneCompleted].
  /// - Configurable streak mode: [scheduledDaysOnly] (default) or [consecutiveCalendarDays].
  StreakResult calculateStreak({
    required Iterable<TaskOccurrence> occurrences,
    DateTime? asOfDate,
    StreakCriterion criterion = StreakCriterion.allTasksCompleted,
    StreakMode mode = StreakMode.scheduledDaysOnly,
    bool enableGraceDay = true,
    int graceDaysAllowed = 1,
    bool includeSkipped = false,
  }) {
    final today = AppDateUtils.startOfDay(asOfDate ?? DateTime.now());

    // 1. Group occurrences by normalized date, filtering out invalid or future incomplete tasks
    final occurrencesByDate = <DateTime, List<TaskOccurrence>>{};

    for (final occ in occurrences) {
      if (occ.isDeleted) continue;
      if (occ.status == TaskStatus.cancelled) continue;
      if (occ.status == TaskStatus.skipped && !includeSkipped) continue;

      final occDate = AppDateUtils.startOfDay(occ.occurrenceDate);

      // Must NOT count future dates as missed: ignore all future dates (> today)
      if (occDate.isAfter(today)) {
        continue;
      }

      occurrencesByDate.putIfAbsent(occDate, () => []).add(occ);
    }

    if (occurrencesByDate.isEmpty) {
      return const StreakResult(
        currentStreak: 0,
        longestStreak: 0,
        eligibleScheduledDays: 0,
        completedDays: 0,
        isMaintainedToday: false,
        completedToday: false,
        graceDaysUsedInCurrentStreak: 0,
        dayStatuses: {},
      );
    }

    // 2. Evaluate each scheduled date's completion status
    final dayStatuses = <DateTime, DayStreakStatus>{};
    var completedDaysCount = 0;

    for (final entry in occurrencesByDate.entries) {
      final date = entry.key;
      final dayOccurrences = entry.value;

      final bool isCompleted;
      switch (criterion) {
        case StreakCriterion.allTasksCompleted:
          isCompleted = dayOccurrences.every(
            (o) => o.status == TaskStatus.done,
          );
          break;
        case StreakCriterion.atLeastOneCompleted:
          isCompleted = dayOccurrences.any((o) => o.status == TaskStatus.done);
          break;
      }

      if (isCompleted) {
        dayStatuses[date] = DayStreakStatus.completed;
        completedDaysCount++;
      } else {
        if (AppDateUtils.isSameDay(date, today)) {
          dayStatuses[date] = DayStreakStatus.pendingToday;
        } else {
          dayStatuses[date] = DayStreakStatus.missed;
        }
      }
    }

    final eligibleScheduledDays = occurrencesByDate.length;

    // 3. Check today's status
    final hasTasksToday = occurrencesByDate.containsKey(today);
    final completedToday = dayStatuses[today] == DayStreakStatus.completed;
    final isPendingToday = dayStatuses[today] == DayStreakStatus.pendingToday;

    // 4. Calculate longest streak historically
    final longestStreak = _calculateLongestStreak(
      dayStatuses: dayStatuses,
      occurrencesByDate: occurrencesByDate,
      today: today,
      mode: mode,
      enableGraceDay: enableGraceDay,
      graceDaysAllowed: graceDaysAllowed,
    );

    // 5. Calculate current streak (backward from today)
    final currentStreakResult = _calculateCurrentStreak(
      dayStatuses: dayStatuses,
      occurrencesByDate: occurrencesByDate,
      today: today,
      mode: mode,
      enableGraceDay: enableGraceDay,
      graceDaysAllowed: graceDaysAllowed,
      hasTasksToday: hasTasksToday,
      completedToday: completedToday,
      isPendingToday: isPendingToday,
    );

    // Ensure longestStreak is at least currentStreak
    final finalLongest = currentStreakResult.currentStreak > longestStreak
        ? currentStreakResult.currentStreak
        : longestStreak;

    return StreakResult(
      currentStreak: currentStreakResult.currentStreak,
      longestStreak: finalLongest,
      eligibleScheduledDays: eligibleScheduledDays,
      completedDays: completedDaysCount,
      isMaintainedToday: currentStreakResult.isMaintainedToday,
      completedToday: completedToday,
      graceDaysUsedInCurrentStreak: currentStreakResult.graceDaysUsed,
      dayStatuses: dayStatuses,
    );
  }

  /// Calculates the longest consecutive streak historically.
  int _calculateLongestStreak({
    required Map<DateTime, DayStreakStatus> dayStatuses,
    required Map<DateTime, List<TaskOccurrence>> occurrencesByDate,
    required DateTime today,
    required StreakMode mode,
    required bool enableGraceDay,
    required int graceDaysAllowed,
  }) {
    final dates = _buildChronologicalDateList(
      occurrencesByDate: occurrencesByDate,
      today: today,
      mode: mode,
    );

    var maxStreak = 0;
    var currentRun = 0;
    var consecutiveGraceUsed = 0;

    for (final date in dates) {
      final status = dayStatuses[date] ?? DayStreakStatus.empty;

      if (status == DayStreakStatus.completed) {
        currentRun++;
        consecutiveGraceUsed = 0;
        if (currentRun > maxStreak) {
          maxStreak = currentRun;
        }
      } else if (status == DayStreakStatus.pendingToday) {
        // Today is pending: does not add to count, but does not reset streak
      } else {
        // Missed day or empty day (in calendar mode)
        if (mode == StreakMode.scheduledDaysOnly &&
            !occurrencesByDate.containsKey(date)) {
          // In scheduled-days mode, unscheduled days are skipped
          continue;
        }

        if (enableGraceDay && consecutiveGraceUsed < graceDaysAllowed) {
          consecutiveGraceUsed++;
          // Grace day buffer preserves currentRun without incrementing it
        } else {
          currentRun = 0;
          consecutiveGraceUsed = 0;
        }
      }
    }

    return maxStreak;
  }

  /// Calculates the current active streak tracing backward from today.
  _CurrentStreakComputation _calculateCurrentStreak({
    required Map<DateTime, DayStreakStatus> dayStatuses,
    required Map<DateTime, List<TaskOccurrence>> occurrencesByDate,
    required DateTime today,
    required StreakMode mode,
    required bool enableGraceDay,
    required int graceDaysAllowed,
    required bool hasTasksToday,
    required bool completedToday,
    required bool isPendingToday,
  }) {
    var streak = 0;
    var isMaintained = false;

    if (completedToday) {
      streak = 1;
      isMaintained = true;
    } else if (isPendingToday || !hasTasksToday) {
      // "If today has tasks and none completed yet, streak from yesterday is still valid until end of today."
      isMaintained = true;
    }

    // Get all dates prior to today in reverse chronological order
    final priorDates = _buildReverseChronologicalDateList(
      occurrencesByDate: occurrencesByDate,
      today: today,
      mode: mode,
    );

    var totalGraceDaysUsed = 0;
    var consecutiveGraceUsed = 0;

    for (final date in priorDates) {
      final status = dayStatuses[date] ?? DayStreakStatus.empty;

      if (status == DayStreakStatus.completed) {
        streak++;
        // A completed day resets the consecutive grace counter for earlier days
        consecutiveGraceUsed = 0;
      } else {
        // Date was missed (or empty in calendar mode)
        if (mode == StreakMode.scheduledDaysOnly &&
            !occurrencesByDate.containsKey(date)) {
          continue;
        }

        if (enableGraceDay && consecutiveGraceUsed < graceDaysAllowed) {
          consecutiveGraceUsed++;
          totalGraceDaysUsed++;
          dayStatuses[date] = DayStreakStatus.grace;
          // Grace day bridges the streak; continue checking further back
        } else {
          // Streak is broken
          if (!completedToday && !isPendingToday && streak == 0) {
            isMaintained = false;
          }
          break;
        }
      }
    }

    // If no past completed days and today is not completed, streak is 0
    if (streak == 0) {
      isMaintained = false;
    }

    return _CurrentStreakComputation(
      currentStreak: streak,
      isMaintainedToday: isMaintained,
      graceDaysUsed: totalGraceDaysUsed,
    );
  }

  /// Builds a sorted list of dates in ascending chronological order.
  List<DateTime> _buildChronologicalDateList({
    required Map<DateTime, List<TaskOccurrence>> occurrencesByDate,
    required DateTime today,
    required StreakMode mode,
  }) {
    if (mode == StreakMode.scheduledDaysOnly) {
      final sortedDates = occurrencesByDate.keys.toList()
        ..sort((a, b) => a.compareTo(b));
      return sortedDates;
    } else {
      // Consecutive calendar days from earliest scheduled day to today
      final sortedKeys = occurrencesByDate.keys.toList()
        ..sort((a, b) => a.compareTo(b));
      if (sortedKeys.isEmpty) return const [];
      final firstDate = sortedKeys.first;
      return AppDateUtils.dateRange(firstDate, today);
    }
  }

  /// Builds a sorted list of dates prior to today in reverse chronological order (yesterday, day before, ...).
  List<DateTime> _buildReverseChronologicalDateList({
    required Map<DateTime, List<TaskOccurrence>> occurrencesByDate,
    required DateTime today,
    required StreakMode mode,
  }) {
    if (mode == StreakMode.scheduledDaysOnly) {
      final prior = occurrencesByDate.keys.where((d) => d.isBefore(today)).toList()
        ..sort((a, b) => b.compareTo(a)); // Descending
      return prior;
    } else {
      final sortedKeys = occurrencesByDate.keys.toList()
        ..sort((a, b) => a.compareTo(b));
      if (sortedKeys.isEmpty) return const [];
      final firstDate = sortedKeys.first;
      if (firstDate.isAfter(today.subtract(const Duration(days: 1)))) {
        return const [];
      }
      final yesterday = today.subtract(const Duration(days: 1));
      final calendarDays = AppDateUtils.dateRange(firstDate, yesterday);
      return calendarDays.reversed.toList();
    }
  }
}

class _CurrentStreakComputation {
  final int currentStreak;
  final bool isMaintainedToday;
  final int graceDaysUsed;

  const _CurrentStreakComputation({
    required this.currentStreak,
    required this.isMaintainedToday,
    required this.graceDaysUsed,
  });
}
