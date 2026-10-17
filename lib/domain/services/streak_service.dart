import '../../core/utils/date_utils.dart';
import '../enums/enums.dart';
import '../models/task_occurrence.dart';

enum StreakCriterion {
  allTasksCompleted,

  atLeastOneCompleted,
}

enum StreakMode {
  scheduledDaysOnly,

  consecutiveCalendarDays,
}

enum DayStreakStatus {
  completed,

  grace,

  missed,

  pendingToday,

  empty,
}

class StreakResult {
  final int currentStreak;

  final int longestStreak;

  final int eligibleScheduledDays;

  final int completedDays;

  final bool isMaintainedToday;

  final bool completedToday;

  final int graceDaysUsedInCurrentStreak;

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

class StreakService {
  const StreakService();

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

    final occurrencesByDate = <DateTime, List<TaskOccurrence>>{};

    for (final occ in occurrences) {
      if (occ.isDeleted) continue;
      if (occ.status == TaskStatus.cancelled) continue;
      if (occ.status == TaskStatus.skipped && !includeSkipped) continue;

      final occDate = AppDateUtils.startOfDay(occ.occurrenceDate);

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

    final hasTasksToday = occurrencesByDate.containsKey(today);
    final completedToday = dayStatuses[today] == DayStreakStatus.completed;
    final isPendingToday = dayStatuses[today] == DayStreakStatus.pendingToday;

    final longestStreak = _calculateLongestStreak(
      dayStatuses: dayStatuses,
      occurrencesByDate: occurrencesByDate,
      today: today,
      mode: mode,
      enableGraceDay: enableGraceDay,
      graceDaysAllowed: graceDaysAllowed,
    );

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
      } else {
        if (mode == StreakMode.scheduledDaysOnly &&
            !occurrencesByDate.containsKey(date)) {
          continue;
        }

        if (enableGraceDay && consecutiveGraceUsed < graceDaysAllowed) {
          consecutiveGraceUsed++;
        } else {
          currentRun = 0;
          consecutiveGraceUsed = 0;
        }
      }
    }

    return maxStreak;
  }

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
      isMaintained = true;
    }

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
        consecutiveGraceUsed = 0;
      } else {
        if (mode == StreakMode.scheduledDaysOnly &&
            !occurrencesByDate.containsKey(date)) {
          continue;
        }

        if (enableGraceDay && consecutiveGraceUsed < graceDaysAllowed) {
          consecutiveGraceUsed++;
          totalGraceDaysUsed++;
          dayStatuses[date] = DayStreakStatus.grace;
        } else {
          if (!completedToday && !isPendingToday && streak == 0) {
            isMaintained = false;
          }
          break;
        }
      }
    }

    if (streak == 0) {
      isMaintained = false;
    }

    return _CurrentStreakComputation(
      currentStreak: streak,
      isMaintainedToday: isMaintained,
      graceDaysUsed: totalGraceDaysUsed,
    );
  }

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
      final sortedKeys = occurrencesByDate.keys.toList()
        ..sort((a, b) => a.compareTo(b));
      if (sortedKeys.isEmpty) return const [];
      final firstDate = sortedKeys.first;
      return AppDateUtils.dateRange(firstDate, today);
    }
  }

  List<DateTime> _buildReverseChronologicalDateList({
    required Map<DateTime, List<TaskOccurrence>> occurrencesByDate,
    required DateTime today,
    required StreakMode mode,
  }) {
    if (mode == StreakMode.scheduledDaysOnly) {
      final prior = occurrencesByDate.keys.where((d) => d.isBefore(today)).toList()
        ..sort((a, b) => b.compareTo(a));
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
