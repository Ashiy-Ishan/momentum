import '../../core/utils/date_utils.dart';
import '../enums/enums.dart';
import '../models/kpi_definition.dart';
import '../models/label.dart';
import '../models/task.dart';
import '../models/task_occurrence.dart';
import '../models/timer_session.dart';

/// Detailed result of a completion rate calculation.
class CompletionRateResult {
  /// Total scheduled occurrences evaluated within the window.
  final int totalScheduled;

  /// Number of eligible scheduled occurrences (excluding cancelled, skipped unless enabled,
  /// and future incomplete occurrences).
  final int eligibleCount;

  /// Number of completed eligible occurrences.
  final int completedCount;

  /// Number of skipped occurrences encountered.
  final int skippedCount;

  /// Number of cancelled occurrences encountered.
  final int cancelledCount;

  /// Number of future incomplete occurrences excluded so they don't count as failures.
  final int futureExcludedCount;

  /// The resulting completion percentage (0.0 to 100.0).
  final double completionRate;

  const CompletionRateResult({
    required this.totalScheduled,
    required this.eligibleCount,
    required this.completedCount,
    required this.skippedCount,
    required this.cancelledCount,
    required this.futureExcludedCount,
    required this.completionRate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionRateResult &&
          runtimeType == other.runtimeType &&
          totalScheduled == other.totalScheduled &&
          eligibleCount == other.eligibleCount &&
          completedCount == other.completedCount &&
          skippedCount == other.skippedCount &&
          cancelledCount == other.cancelledCount &&
          futureExcludedCount == other.futureExcludedCount &&
          completionRate == other.completionRate;

  @override
  int get hashCode => Object.hash(
    totalScheduled,
    eligibleCount,
    completedCount,
    skippedCount,
    cancelledCount,
    futureExcludedCount,
    completionRate,
  );

  @override
  String toString() =>
      'CompletionRateResult(rate: ${completionRate.toStringAsFixed(1)}%, '
      'completed: $completedCount/$eligibleCount, '
      'skipped: $skippedCount, cancelled: $cancelledCount, futureExcluded: $futureExcludedCount)';
}

/// Completion progress metrics for an individual child label.
class LabelChildProgress {
  final String labelId;
  final String labelName;
  final String color;
  final int eligibleCount;
  final int completedCount;
  final double completionRate;

  const LabelChildProgress({
    required this.labelId,
    required this.labelName,
    required this.color,
    required this.eligibleCount,
    required this.completedCount,
    required this.completionRate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabelChildProgress &&
          runtimeType == other.runtimeType &&
          labelId == other.labelId &&
          labelName == other.labelName &&
          color == other.color &&
          eligibleCount == other.eligibleCount &&
          completedCount == other.completedCount &&
          completionRate == other.completionRate;

  @override
  int get hashCode => Object.hash(
    labelId,
    labelName,
    color,
    eligibleCount,
    completedCount,
    completionRate,
  );

  @override
  String toString() =>
      'LabelChildProgress($labelName: $completedCount/$eligibleCount, ${completionRate.toStringAsFixed(1)}%)';
}

/// Aggregated KPI progress for a parent label and its descendant labels.
class LabelKpiAggregation {
  final String parentLabelId;
  final String parentLabelName;
  final String parentColor;

  /// Direct metrics for tasks assigned directly to the parent label.
  final int directEligible;
  final int directCompleted;
  final double directCompletionRate;

  /// Total metrics across all child labels plus the direct parent tasks.
  final int totalEligible;
  final int totalCompleted;

  /// Weighted completion rate:
  /// (sum of completed across children + parent) / (sum of eligible across children + parent) * 100
  final double weightedCompletionRate;

  /// Breakdown of each direct child label's progress.
  final List<LabelChildProgress> childBreakdown;

  const LabelKpiAggregation({
    required this.parentLabelId,
    required this.parentLabelName,
    required this.parentColor,
    required this.directEligible,
    required this.directCompleted,
    required this.directCompletionRate,
    required this.totalEligible,
    required this.totalCompleted,
    required this.weightedCompletionRate,
    required this.childBreakdown,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabelKpiAggregation &&
          runtimeType == other.runtimeType &&
          parentLabelId == other.parentLabelId &&
          parentLabelName == other.parentLabelName &&
          parentColor == other.parentColor &&
          directEligible == other.directEligible &&
          directCompleted == other.directCompleted &&
          directCompletionRate == other.directCompletionRate &&
          totalEligible == other.totalEligible &&
          totalCompleted == other.totalCompleted &&
          weightedCompletionRate == other.weightedCompletionRate;

  @override
  int get hashCode => Object.hash(
    parentLabelId,
    parentLabelName,
    parentColor,
    directEligible,
    directCompleted,
    directCompletionRate,
    totalEligible,
    totalCompleted,
    weightedCompletionRate,
  );

  @override
  String toString() =>
      'LabelKpiAggregation($parentLabelName: weighted ${weightedCompletionRate.toStringAsFixed(1)}%, '
      'total: $totalCompleted/$totalEligible, direct: $directCompleted/$directEligible)';
}

/// Target progress result for a KPI definition.
class KpiTargetProgress {
  final String kpiId;
  final String name;
  final KpiType type;
  final double targetValue;
  final double currentValue;
  final double progressPercentage;
  final bool isAchieved;

  const KpiTargetProgress({
    required this.kpiId,
    required this.name,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.progressPercentage,
    required this.isAchieved,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KpiTargetProgress &&
          runtimeType == other.runtimeType &&
          kpiId == other.kpiId &&
          name == other.name &&
          type == other.type &&
          targetValue == other.targetValue &&
          currentValue == other.currentValue &&
          progressPercentage == other.progressPercentage &&
          isAchieved == other.isAchieved;

  @override
  int get hashCode => Object.hash(
    kpiId,
    name,
    type,
    targetValue,
    currentValue,
    progressPercentage,
    isAchieved,
  );

  @override
  String toString() =>
      'KpiTargetProgress($name ($type): ${currentValue.toStringAsFixed(1)}/${targetValue.toStringAsFixed(1)} '
      '(${progressPercentage.toStringAsFixed(1)}%), achieved: $isAchieved)';
}

/// Domain service for calculating completion rates, aggregating label KPIs,
/// and evaluating target metrics.
class KpiService {
  const KpiService();

  /// Calculates the completion rate for an arbitrary collection of occurrences.
  ///
  /// Rules:
  /// - `cancelled` tasks are excluded from eligible occurrences.
  /// - `skipped` tasks are excluded by default, unless [includeSkipped] is true.
  ///   When included, skipped occurrences count towards eligible count but not completed count.
  /// - Future tasks (`occurrenceDate > asOfDate`):
  ///   - Incomplete occurrences in the future are NOT counted as failures (excluded from eligible).
  ///   - Completed occurrences (done in advance) are included.
  /// - If `eligibleCount == 0`, returns [fallbackWhenZeroEligible] (default 0.0).
  CompletionRateResult calculateCompletionRate({
    required Iterable<TaskOccurrence> occurrences,
    DateTime? asOfDate,
    bool includeSkipped = false,
    double fallbackWhenZeroEligible = 0.0,
  }) {
    final asOf = AppDateUtils.startOfDay(asOfDate ?? DateTime.now());

    var totalScheduled = 0;
    var eligibleCount = 0;
    var completedCount = 0;
    var skippedCount = 0;
    var cancelledCount = 0;
    var futureExcludedCount = 0;

    for (final occ in occurrences) {
      if (occ.isDeleted) continue;
      totalScheduled++;

      final occDate = AppDateUtils.startOfDay(occ.occurrenceDate);
      final isFuture = occDate.isAfter(asOf);

      // Do NOT count future uncompleted tasks as failures
      if (isFuture && occ.status != TaskStatus.done) {
        futureExcludedCount++;
        continue;
      }

      if (occ.status == TaskStatus.cancelled) {
        cancelledCount++;
        continue;
      }

      if (occ.status == TaskStatus.skipped) {
        skippedCount++;
        if (!includeSkipped) {
          continue;
        }
      }

      eligibleCount++;
      if (occ.status == TaskStatus.done) {
        completedCount++;
      }
    }

    final double rate;
    if (eligibleCount == 0) {
      rate = fallbackWhenZeroEligible;
    } else {
      rate = (completedCount / eligibleCount) * 100.0;
    }

    return CompletionRateResult(
      totalScheduled: totalScheduled,
      eligibleCount: eligibleCount,
      completedCount: completedCount,
      skippedCount: skippedCount,
      cancelledCount: cancelledCount,
      futureExcludedCount: futureExcludedCount,
      completionRate: rate,
    );
  }

  /// Daily completion rate = completed eligible scheduled occurrences ÷ eligible scheduled occurrences × 100
  CompletionRateResult calculateDailyCompletionRate({
    required Iterable<TaskOccurrence> occurrences,
    required DateTime date,
    DateTime? asOfDate,
    bool includeSkipped = false,
    double fallbackWhenZeroEligible = 0.0,
  }) {
    final targetDay = AppDateUtils.startOfDay(date);
    final dailyOccurrences = occurrences.where((occ) {
      if (occ.isDeleted) return false;
      return AppDateUtils.isSameDay(occ.occurrenceDate, targetDay);
    });

    return calculateCompletionRate(
      occurrences: dailyOccurrences,
      asOfDate: asOfDate ?? date,
      includeSkipped: includeSkipped,
      fallbackWhenZeroEligible: fallbackWhenZeroEligible,
    );
  }

  /// Weekly completion rate = completed eligible scheduled occurrences in week ÷ eligible scheduled occurrences in week × 100
  CompletionRateResult calculateWeeklyCompletionRate({
    required Iterable<TaskOccurrence> occurrences,
    required DateTime weekDate,
    DateTime? asOfDate,
    bool includeSkipped = false,
    double fallbackWhenZeroEligible = 0.0,
    int weekStartDay = DateTime.monday,
  }) {
    final start = AppDateUtils.startOfWeek(weekDate, startDay: weekStartDay);
    final end = AppDateUtils.endOfWeek(weekDate, startDay: weekStartDay);

    final weeklyOccurrences = occurrences.where((occ) {
      if (occ.isDeleted) return false;
      final d = occ.occurrenceDate;
      return !d.isBefore(start) && !d.isAfter(end);
    });

    return calculateCompletionRate(
      occurrences: weeklyOccurrences,
      asOfDate: asOfDate,
      includeSkipped: includeSkipped,
      fallbackWhenZeroEligible: fallbackWhenZeroEligible,
    );
  }

  /// Monthly completion rate = completed eligible scheduled occurrences in month ÷ eligible scheduled occurrences in month × 100
  CompletionRateResult calculateMonthlyCompletionRate({
    required Iterable<TaskOccurrence> occurrences,
    required DateTime monthDate,
    DateTime? asOfDate,
    bool includeSkipped = false,
    double fallbackWhenZeroEligible = 0.0,
  }) {
    final start = AppDateUtils.startOfMonth(monthDate);
    final end = AppDateUtils.endOfMonth(monthDate);

    final monthlyOccurrences = occurrences.where((occ) {
      if (occ.isDeleted) return false;
      final d = occ.occurrenceDate;
      return !d.isBefore(start) && !d.isAfter(end);
    });

    return calculateCompletionRate(
      occurrences: monthlyOccurrences,
      asOfDate: asOfDate,
      includeSkipped: includeSkipped,
      fallbackWhenZeroEligible: fallbackWhenZeroEligible,
    );
  }

  /// Completion rate for an explicit date range `[startDate, endDate]`.
  CompletionRateResult calculateCompletionRateForRange({
    required Iterable<TaskOccurrence> occurrences,
    required DateTime startDate,
    required DateTime endDate,
    DateTime? asOfDate,
    bool includeSkipped = false,
    double fallbackWhenZeroEligible = 0.0,
  }) {
    final start = AppDateUtils.startOfDay(startDate);
    final end = AppDateUtils.endOfDay(endDate);

    final rangeOccurrences = occurrences.where((occ) {
      if (occ.isDeleted) return false;
      final d = occ.occurrenceDate;
      return !d.isBefore(start) && !d.isAfter(end);
    });

    return calculateCompletionRate(
      occurrences: rangeOccurrences,
      asOfDate: asOfDate,
      includeSkipped: includeSkipped,
      fallbackWhenZeroEligible: fallbackWhenZeroEligible,
    );
  }

  /// Aggregates KPI progress for a parent label and its children:
  /// - Direct parent tasks
  /// - Child labels and their descendant tasks
  /// - Summed counts (total completed, total planned/eligible)
  /// - Weighted completion rates:
  ///   (sum of completed across children + parent) / (sum of eligible across children + parent) * 100
  /// - Distinguishes direct parent progress vs individual child progress
  /// - Guarantees NO task occurrence is double-counted.
  LabelKpiAggregation aggregateParentLabelKpi({
    required Label parentLabel,
    required List<Label> allLabels,
    required List<Task> tasks,
    required List<TaskOccurrence> occurrences,
    DateTime? asOfDate,
    bool includeSkipped = false,
    double fallbackWhenZeroEligible = 0.0,
  }) {
    // Map taskId -> task
    final taskMap = <String, Task>{
      for (final t in tasks)
        if (!t.isDeleted) t.id: t,
    };

    // Track processed occurrence IDs to strictly prevent double-counting
    final processedOccurrenceIds = <String>{};

    // 1. Process direct parent tasks
    final directOccurrences = <TaskOccurrence>[];
    for (final occ in occurrences) {
      if (occ.isDeleted) continue;
      final task = taskMap[occ.taskId];
      if (task != null && task.labelId == parentLabel.id) {
        if (processedOccurrenceIds.add(occ.id)) {
          directOccurrences.add(occ);
        }
      }
    }

    final directResult = calculateCompletionRate(
      occurrences: directOccurrences,
      asOfDate: asOfDate,
      includeSkipped: includeSkipped,
      fallbackWhenZeroEligible: fallbackWhenZeroEligible,
    );

    // 2. Find direct children of the parent label
    final directChildLabels =
        allLabels
            .where((l) => !l.isDeleted && l.parentId == parentLabel.id)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final childBreakdown = <LabelChildProgress>[];
    var childEligibleSum = 0;
    var childCompletedSum = 0;

    for (final child in directChildLabels) {
      // Find all descendant label IDs under this direct child (including itself)
      final descendantLabelIds = _collectDescendantLabelIds(
        child.id,
        allLabels,
      );

      final childOccurrences = <TaskOccurrence>[];
      for (final occ in occurrences) {
        if (occ.isDeleted) continue;
        final task = taskMap[occ.taskId];
        if (task != null &&
            task.labelId != null &&
            descendantLabelIds.contains(task.labelId)) {
          // Strictly prevent double counting across labels
          if (processedOccurrenceIds.add(occ.id)) {
            childOccurrences.add(occ);
          }
        }
      }

      final childResult = calculateCompletionRate(
        occurrences: childOccurrences,
        asOfDate: asOfDate,
        includeSkipped: includeSkipped,
        fallbackWhenZeroEligible: fallbackWhenZeroEligible,
      );

      childEligibleSum += childResult.eligibleCount;
      childCompletedSum += childResult.completedCount;

      childBreakdown.add(
        LabelChildProgress(
          labelId: child.id,
          labelName: child.name,
          color: child.color,
          eligibleCount: childResult.eligibleCount,
          completedCount: childResult.completedCount,
          completionRate: childResult.completionRate,
        ),
      );
    }

    final totalEligible = directResult.eligibleCount + childEligibleSum;
    final totalCompleted = directResult.completedCount + childCompletedSum;

    final weightedCompletionRate = totalEligible > 0
        ? (totalCompleted / totalEligible) * 100.0
        : fallbackWhenZeroEligible;

    return LabelKpiAggregation(
      parentLabelId: parentLabel.id,
      parentLabelName: parentLabel.name,
      parentColor: parentLabel.color,
      directEligible: directResult.eligibleCount,
      directCompleted: directResult.completedCount,
      directCompletionRate: directResult.completionRate,
      totalEligible: totalEligible,
      totalCompleted: totalCompleted,
      weightedCompletionRate: weightedCompletionRate,
      childBreakdown: childBreakdown,
    );
  }

  /// Calculates target progress percentage based on KPI type:
  /// - Count-based: (current count / target value) * 100
  /// - Time-based: (total tracked minutes / target minutes) * 100
  /// - Rate-based: (actual rate / target rate) * 100
  double calculateTargetProgressPercentage({
    required KpiType type,
    required double currentValue,
    required double targetValue,
  }) {
    if (targetValue <= 0) return 0.0;
    return (currentValue / targetValue) * 100.0;
  }

  /// Evaluates progress for a specific [KpiDefinition] given a computed [currentValue].
  KpiTargetProgress evaluateTargetProgress({
    required KpiDefinition definition,
    required double currentValue,
  }) {
    final progress = calculateTargetProgressPercentage(
      type: definition.kpiType,
      currentValue: currentValue,
      targetValue: definition.targetValue,
    );

    return KpiTargetProgress(
      kpiId: definition.id,
      name: definition.name,
      type: definition.kpiType,
      targetValue: definition.targetValue,
      currentValue: currentValue,
      progressPercentage: progress,
      isAchieved: currentValue >= definition.targetValue,
    );
  }

  /// Computes full [KpiTargetProgress] from domain models for the given [definition].
  KpiTargetProgress calculateKpiDefinitionProgress({
    required KpiDefinition definition,
    required List<Task> tasks,
    required List<TaskOccurrence> occurrences,
    List<TimerSession>? timerSessions,
    DateTime? asOfDate,
    bool includeSkipped = false,
  }) {
    final asOf = asOfDate ?? DateTime.now();

    // Determine evaluation window from definition period
    final DateTime windowStart;
    final DateTime windowEnd;

    switch (definition.period) {
      case KpiPeriod.daily:
        windowStart = AppDateUtils.startOfDay(asOf);
        windowEnd = AppDateUtils.endOfDay(asOf);
        break;
      case KpiPeriod.weekly:
        windowStart = AppDateUtils.startOfWeek(asOf);
        windowEnd = AppDateUtils.endOfWeek(asOf);
        break;
      case KpiPeriod.monthly:
        windowStart = AppDateUtils.startOfMonth(asOf);
        windowEnd = AppDateUtils.endOfMonth(asOf);
        break;
      case KpiPeriod.custom:
        windowStart = AppDateUtils.startOfDay(definition.startDate);
        windowEnd = definition.endDate != null
            ? AppDateUtils.endOfDay(definition.endDate!)
            : AppDateUtils.endOfDay(asOf);
        break;
    }

    // Filter tasks if labelId is specified
    final relevantTaskIds = <String>{};
    for (final task in tasks) {
      if (task.isDeleted) continue;
      if (definition.labelId == null || task.labelId == definition.labelId) {
        relevantTaskIds.add(task.id);
      }
    }

    // Filter occurrences in window for relevant tasks
    final windowOccurrences = occurrences.where((occ) {
      if (occ.isDeleted) return false;
      if (!relevantTaskIds.contains(occ.taskId)) return false;
      final d = occ.occurrenceDate;
      return !d.isBefore(windowStart) && !d.isAfter(windowEnd);
    });

    double currentValue = 0.0;

    switch (definition.kpiType) {
      case KpiType.count:
        // Count of completed occurrences
        currentValue = windowOccurrences
            .where((occ) => occ.status == TaskStatus.done)
            .length
            .toDouble();
        break;

      case KpiType.rate:
        // Completion rate in %
        final rateResult = calculateCompletionRate(
          occurrences: windowOccurrences,
          asOfDate: asOf,
          includeSkipped: includeSkipped,
        );
        currentValue = rateResult.completionRate;
        break;

      case KpiType.time:
        // Total tracked time in minutes within window
        var totalSeconds = 0;
        if (timerSessions != null) {
          for (final session in timerSessions) {
            if (session.isDeleted) continue;
            if (!relevantTaskIds.contains(session.taskId)) continue;
            final sTime = session.startedAt;
            if (!sTime.isBefore(windowStart) && !sTime.isAfter(windowEnd)) {
              totalSeconds += session.elapsedSeconds;
            }
          }
        }
        currentValue = totalSeconds / 60.0;
        break;
    }

    return evaluateTargetProgress(
      definition: definition,
      currentValue: currentValue,
    );
  }

  /// Recursively collects a label ID and all its descendant label IDs.
  Set<String> _collectDescendantLabelIds(String rootId, List<Label> allLabels) {
    final result = <String>{rootId};
    final toExplore = <String>[rootId];

    while (toExplore.isNotEmpty) {
      final currentId = toExplore.removeLast();
      for (final label in allLabels) {
        if (!label.isDeleted && label.parentId == currentId) {
          if (result.add(label.id)) {
            toExplore.add(label.id);
          }
        }
      }
    }

    return result;
  }
}
