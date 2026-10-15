import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/enums/enums.dart';
import '../../../domain/models/models.dart';
import '../../../shared/providers/database_provider.dart';
import '../../tasks/providers/task_providers.dart';

// =============================================================================
// Dashboard Stats
// =============================================================================

/// Summary statistics for user's daily dashboard.
class DashboardStats {
  final int scheduledTasks;
  final int completedTasks;
  final int remainingTasks;
  final double completionRate;
  final int streakDays;

  const DashboardStats({
    this.scheduledTasks = 0,
    this.completedTasks = 0,
    this.remainingTasks = 0,
    this.completionRate = 0.0,
    this.streakDays = 0,
  });

  DashboardStats copyWith({
    int? scheduledTasks,
    int? completedTasks,
    int? remainingTasks,
    double? completionRate,
    int? streakDays,
  }) {
    return DashboardStats(
      scheduledTasks: scheduledTasks ?? this.scheduledTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      remainingTasks: remainingTasks ?? this.remainingTasks,
      completionRate: completionRate ?? this.completionRate,
      streakDays: streakDays ?? this.streakDays,
    );
  }
}

/// Provides daily dashboard metrics and calculates consecutive consistency streak.
final dashboardStatsProvider = Provider<AsyncValue<DashboardStats>>((ref) {
  final todayTasksAsync = ref.watch(todayTasksStreamProvider);
  final streakAsync = ref.watch(streakDaysProvider);

  return todayTasksAsync.whenData((tasks) {
    final scheduled = tasks.length;
    final completed = tasks.where((t) => t.status == TaskStatus.done).length;
    final remaining = (scheduled - completed).clamp(0, scheduled);
    final rate = scheduled > 0 ? (completed / scheduled) : 0.0;
    final streak = streakAsync.valueOrNull ?? (completed > 0 ? 1 : 0);

    return DashboardStats(
      scheduledTasks: scheduled,
      completedTasks: completed,
      remainingTasks: remaining,
      completionRate: rate,
      streakDays: streak,
    );
  });
});

/// Future provider calculating multi-day consecutive completion streak.
final streakDaysProvider = FutureProvider<int>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final database = ref.watch(appDatabaseProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Look back up to 365 days
  final lookbackStart = today.subtract(const Duration(days: 365));

  final completedOccurrences = await (database.select(database.taskOccurrences)
        ..where(
          (tbl) =>
              tbl.userId.equals(userId) &
              tbl.status.equals(TaskStatus.done.name) &
              tbl.isDeleted.equals(false) &
              tbl.occurrenceDate.isBiggerOrEqualValue(lookbackStart),
        ))
      .get();

  final daysWithCompletion = <String>{};
  for (final occ in completedOccurrences) {
    final d = occ.occurrenceDate;
    daysWithCompletion.add('${d.year}-${d.month}-${d.day}');
  }

  // Check today
  final todayKey = '${today.year}-${today.month}-${today.day}';
  var checkDate = today;
  var streak = 0;

  if (daysWithCompletion.contains(todayKey)) {
    streak++;
    checkDate = checkDate.subtract(const Duration(days: 1));
  } else {
    // If today is not completed yet, streak might still be intact from yesterday
    checkDate = checkDate.subtract(const Duration(days: 1));
  }

  while (true) {
    final key = '${checkDate.year}-${checkDate.month}-${checkDate.day}';
    if (daysWithCompletion.contains(key)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }

  return streak;
});

// =============================================================================
// KPI Summaries
// =============================================================================

/// Summary of a single KPI definition and its current evaluated progress.
class LabelKpiSummary {
  final KpiDefinition kpi;
  final double currentValue;
  final double targetValue;
  final double progressPercentage;
  final bool isAchieved;

  const LabelKpiSummary({
    required this.kpi,
    required this.currentValue,
    required this.targetValue,
    required this.progressPercentage,
    required this.isAchieved,
  });
}

/// Watches KPI definitions for [labelId] and evaluates each against task/time records.
final labelKpisProvider =
    StreamProvider.family<List<LabelKpiSummary>, String>((ref, labelId) {
  final kpiRepo = ref.watch(kpiRepositoryProvider);
  final timerRepo = ref.watch(timerRepositoryProvider);
  final taskRepo = ref.watch(taskRepositoryProvider);

  return kpiRepo.watchKpisForLabel(labelId).asyncMap((kpis) async {
    final summaries = <LabelKpiSummary>[];

    final now = DateTime.now();
    for (final kpi in kpis) {
      DateTime periodStart;
      switch (kpi.period) {
        case KpiPeriod.daily:
          periodStart = DateTime(now.year, now.month, now.day);
          break;
        case KpiPeriod.weekly:
          periodStart = now.subtract(Duration(days: now.weekday - 1));
          periodStart = DateTime(
            periodStart.year,
            periodStart.month,
            periodStart.day,
          );
          break;
        case KpiPeriod.monthly:
          periodStart = DateTime(now.year, now.month, 1);
          break;
        case KpiPeriod.custom:
          periodStart = kpi.startDate;
          break;
      }

      double currentValue = kpi.currentValue;

      if (currentValue == 0.0) {
        if (kpi.kpiType == KpiType.time) {
          final totalSeconds = await timerRepo.getTotalTimeForLabel(
            labelId,
            periodStart,
            now,
          );
          currentValue = totalSeconds / 60.0; // In minutes
        } else if (kpi.kpiType == KpiType.count) {
          final tasks = await taskRepo.getTasksByLabel(labelId);
          final completed =
              tasks.where((t) => t.status == TaskStatus.done).length;
          currentValue = completed.toDouble();
        } else if (kpi.kpiType == KpiType.rate) {
          final tasks = await taskRepo.getTasksByLabel(labelId);
          if (tasks.isNotEmpty) {
            final completed =
                tasks.where((t) => t.status == TaskStatus.done).length;
            currentValue = (completed / tasks.length) * 100.0;
          }
        }
      }

      final target = kpi.targetValue;
      final progress = target > 0 ? (currentValue / target).clamp(0.0, 1.0) : 0.0;
      final achieved = target > 0 && currentValue >= target;

      summaries.add(
        LabelKpiSummary(
          kpi: kpi,
          currentValue: currentValue,
          targetValue: target,
          progressPercentage: progress,
          isAchieved: achieved,
        ),
      );
    }

    return summaries;
  });
});

/// Watches all KPI definitions across all labels and platforms for the user.
final allKpisStreamProvider = StreamProvider<List<KpiDefinition>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final kpiRepo = ref.watch(kpiRepositoryProvider);
  return kpiRepo.watchAllKpis(userId);
});

// =============================================================================
// Parent & Sub-Label Consolidated Metrics
// =============================================================================

/// Individual metrics for a sub-label.
class ChildLabelMetrics {
  final Label label;
  final int totalTasks;
  final int completedTasks;
  final int totalTimeSeconds;
  final double completionRate;

  const ChildLabelMetrics({
    required this.label,
    required this.totalTasks,
    required this.completedTasks,
    required this.totalTimeSeconds,
    required this.completionRate,
  });
}

/// Consolidated metrics grouping a parent category and all its children.
class ConsolidatedLabelMetrics {
  final Label parentLabel;
  final int totalTasks;
  final int completedTasks;
  final int totalTimeSeconds;
  final double completionRate;
  final List<ChildLabelMetrics> childMetrics;

  const ConsolidatedLabelMetrics({
    required this.parentLabel,
    required this.totalTasks,
    required this.completedTasks,
    required this.totalTimeSeconds,
    required this.completionRate,
    required this.childMetrics,
  });
}

/// Computes consolidated metrics combining parent category and all child labels.
final parentLabelSummaryProvider =
    FutureProvider.family<ConsolidatedLabelMetrics?, String>(
  (ref, parentLabelId) async {
    final labelRepo = ref.watch(labelRepositoryProvider);
    final taskRepo = ref.watch(taskRepositoryProvider);
    final timerRepo = ref.watch(timerRepositoryProvider);
    final userId = ref.watch(currentUserIdProvider);

    final allLabels = await labelRepo.getAllLabels(userId);
    final parent = allLabels.cast<Label?>().firstWhere(
          (l) => l?.id == parentLabelId,
          orElse: () => null,
        );
    if (parent == null) return null;

    final children = allLabels.where((l) => l.parentId == parentLabelId).toList();
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    // Parent direct tasks & time
    final parentTasks = await taskRepo.getTasksByLabel(parent.id);
    final parentCompleted =
        parentTasks.where((t) => t.status == TaskStatus.done).length;
    final parentTime = await timerRepo.getTotalTimeForLabel(
      parent.id,
      monthStart,
      now,
    );

    var aggTotalTasks = parentTasks.length;
    var aggCompletedTasks = parentCompleted;
    var aggTimeSeconds = parentTime;

    final childSummaries = <ChildLabelMetrics>[];

    for (final child in children) {
      final cTasks = await taskRepo.getTasksByLabel(child.id);
      final cCompleted =
          cTasks.where((t) => t.status == TaskStatus.done).length;
      final cTime = await timerRepo.getTotalTimeForLabel(
        child.id,
        monthStart,
        now,
      );

      aggTotalTasks += cTasks.length;
      aggCompletedTasks += cCompleted;
      aggTimeSeconds += cTime;

      final cRate = cTasks.isNotEmpty ? (cCompleted / cTasks.length) : 0.0;
      childSummaries.add(
        ChildLabelMetrics(
          label: child,
          totalTasks: cTasks.length,
          completedTasks: cCompleted,
          totalTimeSeconds: cTime,
          completionRate: cRate,
        ),
      );
    }

    final aggRate =
        aggTotalTasks > 0 ? (aggCompletedTasks / aggTotalTasks) : 0.0;

    return ConsolidatedLabelMetrics(
      parentLabel: parent,
      totalTasks: aggTotalTasks,
      completedTasks: aggCompletedTasks,
      totalTimeSeconds: aggTimeSeconds,
      completionRate: aggRate,
      childMetrics: childSummaries,
    );
  },
);
