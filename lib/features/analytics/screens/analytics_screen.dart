import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/models.dart';
import '../../labels/providers/label_providers.dart';
import '../../tasks/providers/task_providers.dart';
import '../providers/analytics_providers.dart';

enum AnalyticsDateRange {
  thisWeek,
  thisMonth,
  last30Days,
  custom;

  String get displayName {
    switch (this) {
      case AnalyticsDateRange.thisWeek:
        return 'This Week';
      case AnalyticsDateRange.thisMonth:
        return 'This Month';
      case AnalyticsDateRange.last30Days:
        return 'Last 30 Days';
      case AnalyticsDateRange.custom:
        return 'Custom';
    }
  }
}

/// Comprehensive analytics dashboard screen delivering interactive charts,
/// productivity trend lines, daily completion bar visualizations, and label distribution.
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  AnalyticsDateRange _selectedRange = AnalyticsDateRange.thisWeek;
  DateTimeRange? _customDateRange;
  int _touchedPieIndex = -1;

  Color _colorFromHex(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    } else if (clean.length == 8) {
      return Color(int.parse(clean, radix: 16));
    }
    return fallback;
  }

  DateTime get _startDate {
    final now = DateTime.now();
    switch (_selectedRange) {
      case AnalyticsDateRange.thisWeek:
        return AppDateUtils.startOfWeek(now);
      case AnalyticsDateRange.thisMonth:
        return AppDateUtils.startOfMonth(now);
      case AnalyticsDateRange.last30Days:
        return DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 29));
      case AnalyticsDateRange.custom:
        return _customDateRange?.start ??
            now.subtract(const Duration(days: 7));
    }
  }

  DateTime get _endDate {
    final now = DateTime.now();
    switch (_selectedRange) {
      case AnalyticsDateRange.thisWeek:
        return AppDateUtils.endOfWeek(now);
      case AnalyticsDateRange.thisMonth:
        return AppDateUtils.endOfMonth(now);
      case AnalyticsDateRange.last30Days:
        return AppDateUtils.endOfDay(now);
      case AnalyticsDateRange.custom:
        return _customDateRange?.end ?? now;
    }
  }

  Future<void> _pickCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: _customDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 14)),
            end: DateTime.now(),
          ),
    );
    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedRange = AnalyticsDateRange.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final streakAsync = ref.watch(streakDaysProvider);
    final allTasks = ref.watch(allTasksStreamProvider).valueOrNull ?? [];
    final allLabels = ref.watch(allLabelsStreamProvider).valueOrNull ?? [];

    final start = _startDate;
    final end = _endDate;
    final days = AppDateUtils.dateRange(start, end);

    // Calculate completion stats for the date range
    int totalScheduled = 0;
    int totalDone = 0;

    // Daily breakdown maps
    final dailyScheduled = <String, int>{};
    final dailyDone = <String, int>{};

    for (final day in days) {
      final key = DateFormat('yyyy-MM-dd').format(day);
      dailyScheduled[key] = 0;
      dailyDone[key] = 0;
    }

    for (final task in allTasks) {
      final taskDate = task.scheduledDate ?? task.createdAt;
      final key = DateFormat('yyyy-MM-dd').format(taskDate);
      if (dailyScheduled.containsKey(key)) {
        dailyScheduled[key] = (dailyScheduled[key] ?? 0) + 1;
        totalScheduled++;
        if (task.status == TaskStatus.done) {
          dailyDone[key] = (dailyDone[key] ?? 0) + 1;
          totalDone++;
        }
      }
    }

    final overallRate =
        totalScheduled > 0 ? (totalDone / totalScheduled) : 0.0;
    final currentStreak = streakAsync.valueOrNull ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Productivity'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Date Range Selector Chips
          _buildDateRangeSelector(context),
          AppSpacing.vGapMd,

          // Consistency & Streak Stat Cards
          _buildStatsCardsRow(
            context,
            streakDays: currentStreak,
            totalDone: totalDone,
            totalScheduled: totalScheduled,
            completionRate: overallRate,
          ),
          AppSpacing.vGapLg,

          // Chart 1: Daily Completion Bar Chart
          Text(
            'Daily Task Activity',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vGapXs,
          Text(
            'Completed tasks vs total planned per day',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.vGapSm,
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildDailyBarChart(context, days, dailyScheduled, dailyDone),
            ),
          ),
          AppSpacing.vGapLg,

          // Chart 2: Weekly / Trend Line Chart
          Text(
            'Productivity Trend',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vGapXs,
          Text(
            'Velocity curve of completed tasks over time',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.vGapSm,
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildTrendLineChart(context, days, dailyDone),
            ),
          ),
          AppSpacing.vGapLg,

          // Chart 3: Focus Distribution by Label (Pie Chart)
          Text(
            'Focus Distribution by Area',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vGapXs,
          Text(
            'Task distribution across focus areas and projects',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.vGapSm,
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildLabelDistributionChart(context, allTasks, allLabels),
            ),
          ),
          AppSpacing.vGapXl,
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...AnalyticsDateRange.values.map((range) {
            final isSelected = _selectedRange == range;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(range == AnalyticsDateRange.custom &&
                        _customDateRange != null
                    ? '${DateFormat('MMM d').format(_customDateRange!.start)} - ${DateFormat('MMM d').format(_customDateRange!.end)}'
                    : range.displayName),
                selected: isSelected,
                onSelected: (_) {
                  if (range == AnalyticsDateRange.custom) {
                    _pickCustomRange();
                  } else {
                    setState(() => _selectedRange = range);
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatsCardsRow(
    BuildContext context, {
    required int streakDays,
    required int totalDone,
    required int totalScheduled,
    required double completionRate,
  }) {
    final theme = Theme.of(context);
    final ratePercent = (completionRate * 100).toInt();

    return Row(
      children: [
        // Streak Card
        Expanded(
          child: _buildMetricSummaryCard(
            title: 'Streak',
            value: '$streakDays days',
            subtitle: 'Consistency 🔥',
            color: AppColors.statusPending,
            icon: Icons.local_fire_department,
          ),
        ),
        const SizedBox(width: 8),
        // Done Tasks Card
        Expanded(
          child: _buildMetricSummaryCard(
            title: 'Completed',
            value: '$totalDone',
            subtitle: 'of $totalScheduled tasks',
            color: AppColors.statusDone,
            icon: Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 8),
        // Rate Card
        Expanded(
          child: _buildMetricSummaryCard(
            title: 'Success Rate',
            value: '$ratePercent%',
            subtitle: 'Selected period',
            color: theme.colorScheme.primary,
            icon: Icons.trending_up,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyBarChart(
    BuildContext context,
    List<DateTime> days,
    Map<String, int> scheduledMap,
    Map<String, int> doneMap,
  ) {
    final theme = Theme.of(context);
    final displayDays = days.length > 14 ? days.sublist(days.length - 14) : days;

    double maxY = 5.0;
    for (final day in displayDays) {
      final key = DateFormat('yyyy-MM-dd').format(day);
      final count = (scheduledMap[key] ?? 0).toDouble();
      if (count > maxY) maxY = count + 2;
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final day = displayDays[group.x.toInt()];
                    final key = DateFormat('yyyy-MM-dd').format(day);
                    final done = doneMap[key] ?? 0;
                    final total = scheduledMap[key] ?? 0;
                    return BarTooltipItem(
                      '${DateFormat('MMM d').format(day)}\n$done/$total done',
                      const TextStyle(color: Colors.white, fontSize: 11),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (val, _) => Text(
                      '${val.toInt()}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, _) {
                      final idx = val.toInt();
                      if (idx < 0 || idx >= displayDays.length) {
                        return const SizedBox.shrink();
                      }
                      final day = displayDays[idx];
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          DateFormat('E').format(day).substring(0, 1),
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (maxY / 4).clamp(1.0, 10.0),
              ),
              borderData: FlBorderData(show: false),
              barGroups: displayDays.asMap().entries.map((entry) {
                final idx = entry.key;
                final day = entry.value;
                final key = DateFormat('yyyy-MM-dd').format(day);
                final done = (doneMap[key] ?? 0).toDouble();
                final total = (scheduledMap[key] ?? 0).toDouble();

                return BarChartGroupData(
                  x: idx,
                  barRods: [
                    BarChartRodData(
                      toY: total,
                      color: theme.colorScheme.surfaceContainerHighest,
                      width: 10,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      rodStackItems: [
                        BarChartRodStackItem(0, done, AppColors.statusDone),
                        BarChartRodStackItem(
                          done,
                          total,
                          theme.colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 10, height: 10, color: AppColors.statusDone),
            const SizedBox(width: 4),
            const Text('Completed', style: TextStyle(fontSize: 11)),
            const SizedBox(width: 16),
            Container(
              width: 10,
              height: 10,
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 4),
            const Text('Pending/Remaining', style: TextStyle(fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendLineChart(
    BuildContext context,
    List<DateTime> days,
    Map<String, int> doneMap,
  ) {
    final theme = Theme.of(context);
    final displayDays = days.length > 14 ? days.sublist(days.length - 14) : days;

    final spots = displayDays.asMap().entries.map((entry) {
      final idx = entry.key;
      final day = entry.value;
      final key = DateFormat('yyyy-MM-dd').format(day);
      final count = (doneMap[key] ?? 0).toDouble();
      return FlSpot(idx.toDouble(), count);
    }).toList();

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (val, _) => Text(
                  '${val.toInt()}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, _) {
                  final idx = val.toInt();
                  if (idx < 0 || idx >= displayDays.length) {
                    return const SizedBox.shrink();
                  }
                  if (idx % 2 != 0) return const SizedBox.shrink();
                  final day = displayDays[idx];
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('M/d').format(day),
                      style: const TextStyle(fontSize: 9),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelDistributionChart(
    BuildContext context,
    List<Task> allTasks,
    List<Label> allLabels,
  ) {
    final theme = Theme.of(context);
    final countByLabel = <String, int>{};

    for (final task in allTasks) {
      final labelId = task.labelId ?? 'unassigned';
      countByLabel[labelId] = (countByLabel[labelId] ?? 0) + 1;
    }

    if (countByLabel.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('No task distribution data available.')),
      );
    }

    final total = allTasks.length;

    final sections = countByLabel.entries.toList();

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 36,
              pieTouchData: PieTouchData(
                touchCallback: (event, res) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        res == null ||
                        res.touchedSection == null) {
                      _touchedPieIndex = -1;
                      return;
                    }
                    _touchedPieIndex =
                        res.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: sections.asMap().entries.map((entry) {
                final idx = entry.key;
                final e = entry.value;
                final isTouched = idx == _touchedPieIndex;
                final radius = isTouched ? 50.0 : 40.0;

                Label? label;
                if (e.key != 'unassigned') {
                  label = allLabels.cast<Label?>().firstWhere(
                        (l) => l?.id == e.key,
                        orElse: () => null,
                      );
                }

                final color = label != null
                    ? _colorFromHex(label.color, AppColors.chartColorAt(idx))
                    : Colors.grey;

                return PieChartSectionData(
                  color: color,
                  value: e.value.toDouble(),
                  title: '${e.value}',
                  radius: radius,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: sections.asMap().entries.map((entry) {
            final idx = entry.key;
            final e = entry.value;

            Label? label;
            if (e.key != 'unassigned') {
              label = allLabels.cast<Label?>().firstWhere(
                    (l) => l?.id == e.key,
                    orElse: () => null,
                  );
            }

            final color = label != null
                ? _colorFromHex(label.color, AppColors.chartColorAt(idx))
                : Colors.grey;
            final name = label?.name ?? 'General / Unlabeled';
            final percent = ((e.value / total) * 100).toStringAsFixed(0);

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(
                  '$name ($percent%)',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
