import '../../core/utils/date_utils.dart';
import '../enums/enums.dart';
import '../models/kpi_definition.dart';
import '../models/label.dart';
import '../models/task.dart';
import '../models/task_occurrence.dart';
import '../models/timer_session.dart';

class CompletionRateResult {
  final int totalScheduled;

  final int eligibleCount;

  final int completedCount;

  final int skippedCount;

  final int cancelledCount;

  final int futureExcludedCount;

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

class LabelKpiAggregation {
  final String parentLabelId;
  final String parentLabelName;
  final String parentColor;

  final int directEligible;
  final int directCompleted;
  final double directCompletionRate;

  final int totalEligible;
  final int totalCompleted;

  final double weightedCompletionRate;

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

class KpiService {
  const KpiService();

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

  LabelKpiAggregation aggregateParentLabelKpi({
    required Label parentLabel,
    required List<Label> allLabels,
    required List<Task> tasks,
    required List<TaskOccurrence> occurrences,
    DateTime? asOfDate,
    bool includeSkipped = false,
    double fallbackWhenZeroEligible = 0.0,
  }) {
    final taskMap = <String, Task>{
      for (final t in tasks)
        if (!t.isDeleted) t.id: t,
    };

    final processedOccurrenceIds = <String>{};

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

    final directChildLabels =
        allLabels
            .where((l) => !l.isDeleted && l.parentId == parentLabel.id)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final childBreakdown = <LabelChildProgress>[];
    var childEligibleSum = 0;
    var childCompletedSum = 0;

    for (final child in directChildLabels) {
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

  double calculateTargetProgressPercentage({
    required KpiType type,
    required double currentValue,
    required double targetValue,
  }) {
    if (targetValue <= 0) return 0.0;
    return (currentValue / targetValue) * 100.0;
  }

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

  KpiTargetProgress calculateKpiDefinitionProgress({
    required KpiDefinition definition,
    required List<Task> tasks,
    required List<TaskOccurrence> occurrences,
    List<TimerSession>? timerSessions,
    DateTime? asOfDate,
    bool includeSkipped = false,
  }) {
    final asOf = asOfDate ?? DateTime.now();

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

    final relevantTaskIds = <String>{};
    for (final task in tasks) {
      if (task.isDeleted) continue;
      if (definition.labelId == null || task.labelId == definition.labelId) {
        relevantTaskIds.add(task.id);
      }
    }

    final windowOccurrences = occurrences.where((occ) {
      if (occ.isDeleted) return false;
      if (!relevantTaskIds.contains(occ.taskId)) return false;
      final d = occ.occurrenceDate;
      return !d.isBefore(windowStart) && !d.isAfter(windowEnd);
    });

    double currentValue = 0.0;

    switch (definition.kpiType) {
      case KpiType.count:
        currentValue = windowOccurrences
            .where((occ) => occ.status == TaskStatus.done)
            .length
            .toDouble();
        break;

      case KpiType.rate:
        final rateResult = calculateCompletionRate(
          occurrences: windowOccurrences,
          asOfDate: asOf,
          includeSkipped: includeSkipped,
        );
        currentValue = rateResult.completionRate;
        break;

      case KpiType.time:
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
