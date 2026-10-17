import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/enums/enums.dart';
import '../../../domain/models/models.dart';
import '../../../shared/providers/database_provider.dart';
import '../../labels/providers/label_providers.dart';
import '../../tasks/providers/task_providers.dart';

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

final streakDaysProvider = FutureProvider<int>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final database = ref.watch(appDatabaseProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

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

  final todayKey = '${today.year}-${today.month}-${today.day}';
  var checkDate = today;
  var streak = 0;

  if (daysWithCompletion.contains(todayKey)) {
    streak++;
    checkDate = checkDate.subtract(const Duration(days: 1));
  } else {
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

final labelKpisProvider =
    StreamProvider.family<List<LabelKpiSummary>, String>((ref, labelId) {
  final kpiRepo = ref.watch(kpiRepositoryProvider);
  final timerRepo = ref.watch(timerRepositoryProvider);
  final taskRepo = ref.watch(taskRepositoryProvider);
  ref.watch(allTasksStreamProvider);

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
          currentValue = totalSeconds / 60.0;
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

final allKpisStreamProvider = StreamProvider<List<KpiDefinition>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final kpiRepo = ref.watch(kpiRepositoryProvider);
  return kpiRepo.watchAllKpis(userId);
});

class AggregateMetricItem {
  final String id;
  final String platform;
  final String name;
  final double currentValue;
  final double targetValue;
  final double? longTermTarget;
  final String unit;
  final String metricCategory;
  final KpiPeriod period;

  const AggregateMetricItem({
    required this.id,
    required this.platform,
    required this.name,
    required this.currentValue,
    required this.targetValue,
    this.longTermTarget,
    required this.unit,
    required this.metricCategory,
    required this.period,
  });

  bool get isAchieved => targetValue > 0 && currentValue >= targetValue;
  double get shortTermProgress =>
      targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
  double get longTermProgress =>
      (longTermTarget != null && longTermTarget! > 0)
          ? (currentValue / longTermTarget!).clamp(0.0, 1.0)
          : 0.0;
}

class TotalKpiMetrics {
  final int totalKpisCount;
  final int achievedCount;
  final double overallCompletionRate;

  final double totalVideosCurrent;
  final double totalVideosTarget;
  final double? totalVideosLongTerm;

  final double totalShortsCurrent;
  final double totalShortsTarget;
  final double? totalShortsLongTerm;

  final double totalPostsCurrent;
  final double totalPostsTarget;
  final double? totalPostsLongTerm;

  final double totalArticlesCurrent;
  final double totalArticlesTarget;
  final double? totalArticlesLongTerm;

  final double totalCommitsCurrent;
  final double totalCommitsTarget;
  final double? totalCommitsLongTerm;

  final double totalAudienceCurrent;
  final double totalAudienceShortTermTarget;
  final double totalAudienceLongTermTarget;

  final List<AggregateMetricItem> outputMetrics;
  final List<AggregateMetricItem> audienceMetrics;
  final List<AggregateMetricItem> allMetrics;

  const TotalKpiMetrics({
    this.totalKpisCount = 0,
    this.achievedCount = 0,
    this.overallCompletionRate = 0.0,
    this.totalVideosCurrent = 0.0,
    this.totalVideosTarget = 0.0,
    this.totalVideosLongTerm,
    this.totalShortsCurrent = 0.0,
    this.totalShortsTarget = 0.0,
    this.totalShortsLongTerm,
    this.totalPostsCurrent = 0.0,
    this.totalPostsTarget = 0.0,
    this.totalPostsLongTerm,
    this.totalArticlesCurrent = 0.0,
    this.totalArticlesTarget = 0.0,
    this.totalArticlesLongTerm,
    this.totalCommitsCurrent = 0.0,
    this.totalCommitsTarget = 0.0,
    this.totalCommitsLongTerm,
    this.totalAudienceCurrent = 0.0,
    this.totalAudienceShortTermTarget = 0.0,
    this.totalAudienceLongTermTarget = 0.0,
    this.outputMetrics = const [],
    this.audienceMetrics = const [],
    this.allMetrics = const [],
  });

  double get audienceShortTermProgress => totalAudienceShortTermTarget > 0
      ? (totalAudienceCurrent / totalAudienceShortTermTarget).clamp(0.0, 1.0)
      : 0.0;

  double get audienceLongTermProgress => totalAudienceLongTermTarget > 0
      ? (totalAudienceCurrent / totalAudienceLongTermTarget).clamp(0.0, 1.0)
      : 0.0;
}

final totalKpiMetricsProvider = Provider<AsyncValue<TotalKpiMetrics>>((ref) {
  final allKpisAsync = ref.watch(allKpisStreamProvider);
  final allTasks = ref.watch(allTasksStreamProvider).valueOrNull ?? [];

  return allKpisAsync.whenData((kpis) {
    if (kpis.isEmpty) return const TotalKpiMetrics();

    final totalCount = kpis.length;
    int achievedCount = 0;
    double progressSum = 0.0;

    double videosCurrent = 0.0;
    double videosTarget = 0.0;
    double? videosLongTerm;

    double shortsCurrent = 0.0;
    double shortsTarget = 0.0;
    double? shortsLongTerm;

    double postsCurrent = 0.0;
    double postsTarget = 0.0;
    double? postsLongTerm;

    double articlesCurrent = 0.0;
    double articlesTarget = 0.0;
    double? articlesLongTerm;

    double commitsCurrent = 0.0;
    double commitsTarget = 0.0;
    double? commitsLongTerm;

    double audienceCurrent = 0.0;
    double audienceShortTarget = 0.0;
    double audienceLongTarget = 0.0;

    final outputItems = <AggregateMetricItem>[];
    final audienceItems = <AggregateMetricItem>[];
    final allItems = <AggregateMetricItem>[];

    for (final kpi in kpis) {
      double effectiveCurrent = kpi.currentValue;
      if (effectiveCurrent == 0.0 && allTasks.isNotEmpty) {
        final cat = kpi.metricCategory.toLowerCase();
        final platform = kpi.platform.toLowerCase();
        final matchingTasks = allTasks.where((t) {
          if (kpi.labelId != null && t.labelId == kpi.labelId) return true;
          final tcat = (t.category ?? '').toLowerCase();
          if (tcat.isNotEmpty &&
              (tcat == cat || tcat == platform || tcat.contains(cat))) {
            return true;
          }
          return false;
        });
        final completed =
            matchingTasks.where((t) => t.status == TaskStatus.done).length;
        if (completed > 0) {
          effectiveCurrent = completed.toDouble();
        }
      }

      final isAchieved =
          kpi.targetValue > 0 && effectiveCurrent >= kpi.targetValue;
      if (isAchieved) achievedCount++;

      final prog = kpi.targetValue > 0
          ? (effectiveCurrent / kpi.targetValue).clamp(0.0, 1.0)
          : 0.0;
      progressSum += prog;

      final item = AggregateMetricItem(
        id: kpi.id,
        platform: kpi.platform,
        name: kpi.name,
        currentValue: effectiveCurrent,
        targetValue: kpi.targetValue,
        longTermTarget: kpi.longTermTarget,
        unit: kpi.unit,
        metricCategory: kpi.metricCategory,
        period: kpi.period,
      );
      allItems.add(item);

      final cat = kpi.metricCategory.toLowerCase();
      final unit = kpi.unit.toLowerCase();
      final name = kpi.name.toLowerCase();

      final isAudience = cat == 'subscriber_growth' ||
          cat == 'follower_growth' ||
          unit == 'subs' ||
          unit == 'followers' ||
          unit == 'readers' ||
          unit == 'connections' ||
          unit == 'stars';

      if (isAudience) {
        audienceCurrent += effectiveCurrent;
        audienceShortTarget += kpi.targetValue;
        if (kpi.longTermTarget != null) {
          audienceLongTarget += kpi.longTermTarget!;
        }
        audienceItems.add(item);
      } else {
        outputItems.add(item);

        if (unit.contains('video') ||
            (cat == 'video_generation' && !unit.contains('short'))) {
          videosCurrent += effectiveCurrent;
          videosTarget += kpi.targetValue;
          if (kpi.longTermTarget != null) {
            videosLongTerm = (videosLongTerm ?? 0) + kpi.longTermTarget!;
          }
        } else if (unit.contains('short')) {
          shortsCurrent += effectiveCurrent;
          shortsTarget += kpi.targetValue;
          if (kpi.longTermTarget != null) {
            shortsLongTerm = (shortsLongTerm ?? 0) + kpi.longTermTarget!;
          }
        } else if (cat == 'post_publication' || unit.contains('post')) {
          postsCurrent += effectiveCurrent;
          postsTarget += kpi.targetValue;
          if (kpi.longTermTarget != null) {
            postsLongTerm = (postsLongTerm ?? 0) + kpi.longTermTarget!;
          }
        } else if (cat == 'blog_publication' || unit.contains('article')) {
          articlesCurrent += effectiveCurrent;
          articlesTarget += kpi.targetValue;
          if (kpi.longTermTarget != null) {
            articlesLongTerm = (articlesLongTerm ?? 0) + kpi.longTermTarget!;
          }
        } else if (unit.contains('commit') || name.contains('commit')) {
          commitsCurrent += effectiveCurrent;
          commitsTarget += kpi.targetValue;
          if (kpi.longTermTarget != null) {
            commitsLongTerm = (commitsLongTerm ?? 0) + kpi.longTermTarget!;
          }
        }
      }
    }

    final avgRate = totalCount > 0 ? (progressSum / totalCount) : 0.0;

    return TotalKpiMetrics(
      totalKpisCount: totalCount,
      achievedCount: achievedCount,
      overallCompletionRate: avgRate,
      totalVideosCurrent: videosCurrent,
      totalVideosTarget: videosTarget,
      totalVideosLongTerm: videosLongTerm,
      totalShortsCurrent: shortsCurrent,
      totalShortsTarget: shortsTarget,
      totalShortsLongTerm: shortsLongTerm,
      totalPostsCurrent: postsCurrent,
      totalPostsTarget: postsTarget,
      totalPostsLongTerm: postsLongTerm,
      totalArticlesCurrent: articlesCurrent,
      totalArticlesTarget: articlesTarget,
      totalArticlesLongTerm: articlesLongTerm,
      totalCommitsCurrent: commitsCurrent,
      totalCommitsTarget: commitsTarget,
      totalCommitsLongTerm: commitsLongTerm,
      totalAudienceCurrent: audienceCurrent,
      totalAudienceShortTermTarget: audienceShortTarget,
      totalAudienceLongTermTarget: audienceLongTarget,
      outputMetrics: outputItems,
      audienceMetrics: audienceItems,
      allMetrics: allItems,
    );
  });
});

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

final parentLabelSummaryProvider =
    FutureProvider.family<ConsolidatedLabelMetrics?, String>(
  (ref, parentLabelId) async {
    ref.watch(allTasksStreamProvider);
    ref.watch(allLabelsStreamProvider);
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
