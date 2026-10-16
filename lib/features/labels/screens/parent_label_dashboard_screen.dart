import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/models/models.dart';
import '../../analytics/providers/analytics_providers.dart';
import '../../tasks/providers/task_providers.dart';
import '../../tasks/widgets/task_card.dart';

/// Comprehensive dashboard screen for a parent focus area category,
/// aggregating child label performances, comparative KPI cards, breakdown charts,
/// and directly assigned tasks.
class ParentLabelDashboardScreen extends ConsumerStatefulWidget {
  final String labelId;

  const ParentLabelDashboardScreen({
    super.key,
    required this.labelId,
  });

  @override
  ConsumerState<ParentLabelDashboardScreen> createState() =>
      _ParentLabelDashboardScreenState();
}

class _ParentLabelDashboardScreenState
    extends ConsumerState<ParentLabelDashboardScreen> {
  int _touchedPieIndex = -1;
  String? _selectedFilterId; // null = all platform tasks, or parent.id, or specific child.id

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summaryAsync = ref.watch(parentLabelSummaryProvider(widget.labelId));
    final allTasks = ref.watch(allTasksStreamProvider).valueOrNull ?? [];

    return Scaffold(
      body: summaryAsync.when(
        data: (summary) {
          if (summary == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Focus Area not found')),
            );
          }

          final parent = summary.parentLabel;
          final parentColor =
              _colorFromHex(parent.color, theme.colorScheme.primary);
          final childMap = {
            for (final cm in summary.childMetrics) cm.label.id: cm.label,
          };
          final childIds = childMap.keys.toSet();
          final platformTasks = allTasks
              .where((t) =>
                  t.labelId == parent.id ||
                  (t.labelId != null && childIds.contains(t.labelId)))
              .toList();
          final directTasks =
              allTasks.where((t) => t.labelId == parent.id).toList();

          final List<Task> displayedTasks;
          if (_selectedFilterId == null) {
            displayedTasks = platformTasks;
          } else if (_selectedFilterId == parent.id) {
            displayedTasks = directTasks;
          } else {
            displayedTasks = platformTasks
                .where((t) => t.labelId == _selectedFilterId)
                .toList();
          }

          return CustomScrollView(
            slivers: [
              // Header SliverAppBar
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: parentColor,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppIcons.fromName(parent.iconName),
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          parent.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          parentColor,
                          parentColor.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Opacity(
                        opacity: 0.15,
                        child: Icon(
                          AppIcons.fromName(parent.iconName),
                          size: 130,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add_task),
                    tooltip: 'Add Task to Focus Area',
                    onPressed: () {
                      context.push(
                        '/tasks/new',
                        extra: {'parentLabelId': parent.id},
                      );
                    },
                  ),
                ],
              ),

              // Content Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Consolidated KPI Metrics Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Consolidated Metrics',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      AppSpacing.vGapSm,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildConsolidatedKpiRow(context, summary),
                      ),

                      AppSpacing.vGapLg,

                      // Comparison Cards for Child Labels
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Child Projects / Channels',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${summary.childMetrics.length} total',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.vGapSm,
                      if (summary.childMetrics.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            elevation: 0,
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.4),
                            child: const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'No child labels created yet under this focus area. Add sub-labels in Manage Labels.',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 155,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: summary.childMetrics.length,
                            itemBuilder: (context, index) {
                              final cm = summary.childMetrics[index];
                              return _buildChildComparisonCard(context, cm);
                            },
                          ),
                        ),

                      AppSpacing.vGapLg,

                      // Activity Breakdown Chart
                      if (summary.childMetrics.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Task Distribution Breakdown',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        AppSpacing.vGapSm,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                              side: BorderSide(
                                color: theme.dividerColor.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: _buildBreakdownChart(context, summary),
                            ),
                          ),
                        ),
                        AppSpacing.vGapLg,
                      ],

                      // Platform & Sub-Project Tasks
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Focus Tasks (${platformTasks.length})',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            FilledButton.tonalIcon(
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Task'),
                              onPressed: () {
                                context.push(
                                  '/tasks/new',
                                  extra: {
                                    'parentLabelId': parent.id,
                                    if (_selectedFilterId != null &&
                                        _selectedFilterId != parent.id)
                                      'subLabelId': _selectedFilterId,
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      if (summary.childMetrics.isNotEmpty) ...[
                        AppSpacing.vGapXs,
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              FilterChip(
                                label: Text('All (${platformTasks.length})'),
                                selected: _selectedFilterId == null,
                                onSelected: (_) {
                                  setState(() => _selectedFilterId = null);
                                },
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: Text('Direct (${directTasks.length})'),
                                selected: _selectedFilterId == parent.id,
                                onSelected: (_) {
                                  setState(() => _selectedFilterId = parent.id);
                                },
                              ),
                              for (final cm in summary.childMetrics) ...[
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: Text(
                                    '${cm.label.name} (${platformTasks.where((t) => t.labelId == cm.label.id).length})',
                                  ),
                                  selected: _selectedFilterId == cm.label.id,
                                  onSelected: (_) {
                                    setState(
                                      () => _selectedFilterId = cm.label.id,
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      AppSpacing.vGapSm,
                      if (displayedTasks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Card(
                            elevation: 0,
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: Text(
                                  _selectedFilterId == null
                                      ? 'No tasks logged yet for ${parent.name}. Create one to get started!'
                                      : 'No tasks found for this selected sub-project.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayedTasks.length,
                          itemBuilder: (context, index) {
                            final task = displayedTasks[index];
                            return TaskCard(
                              task: task,
                              showLabel: task.labelId != parent.id,
                              onEdit: () =>
                                  context.push('/tasks/edit/${task.id}'),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('Error loading parent dashboard: $err')),
        ),
      ),
    );
  }

  Widget _buildConsolidatedKpiRow(
    BuildContext context,
    ConsolidatedLabelMetrics summary,
  ) {
    final theme = Theme.of(context);
    final ratePercent = (summary.completionRate * 100).toInt();
    final timeFormatted = AppDateUtils.formatDuration(
      Duration(seconds: summary.totalTimeSeconds),
    );

    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            context,
            title: 'Completion',
            value: '$ratePercent%',
            subtitle: '${summary.completedTasks}/${summary.totalTasks} tasks',
            icon: Icons.check_circle_outline,
            color: AppColors.statusDone,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            context,
            title: 'Time Spent',
            value: timeFormatted,
            subtitle: 'This month',
            icon: Icons.timer_outlined,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
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
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildComparisonCard(
    BuildContext context,
    ChildLabelMetrics child,
  ) {
    final theme = Theme.of(context);
    final childColor =
        _colorFromHex(child.label.color, theme.colorScheme.secondary);
    final percent = (child.completionRate * 100).toInt();

    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: childColor.withValues(alpha: 0.35)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => context.push('/labels/sub/${child.label.id}'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: childColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        AppIcons.fromName(child.label.iconName),
                        color: childColor,
                        size: 16,
                      ),
                    ),
                    const Icon(Icons.arrow_forward, size: 14),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.label.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: child.totalTasks > 0 ? child.completionRate : 0.0,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      color: childColor,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${child.completedTasks}/${child.totalTasks} ($percent%)',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownChart(
    BuildContext context,
    ConsolidatedLabelMetrics summary,
  ) {
    final theme = Theme.of(context);
    final items = summary.childMetrics.where((m) => m.totalTasks > 0).toList();

    if (items.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'No tasks logged yet under child projects.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      );
    }

    final totalTasks =
        items.fold<int>(0, (acc, item) => acc + item.totalTasks);

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedPieIndex = -1;
                      return;
                    }
                    _touchedPieIndex = pieTouchResponse
                        .touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: items.asMap().entries.map((entry) {
                final idx = entry.key;
                final cm = entry.value;
                final isTouched = idx == _touchedPieIndex;
                final fontSize = isTouched ? 14.0 : 11.0;
                final radius = isTouched ? 55.0 : 45.0;
                final color = _colorFromHex(
                  cm.label.color,
                  AppColors.chartColorAt(idx),
                );

                return PieChartSectionData(
                  color: color,
                  value: cm.totalTasks.toDouble(),
                  title: '${cm.totalTasks}',
                  radius: radius,
                  titleStyle: TextStyle(
                    fontSize: fontSize,
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
          children: items.asMap().entries.map((entry) {
            final idx = entry.key;
            final cm = entry.value;
            final color = _colorFromHex(
              cm.label.color,
              AppColors.chartColorAt(idx),
            );
            final percent = ((cm.totalTasks / totalTasks) * 100).toStringAsFixed(0);

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${cm.label.name} ($percent%)',
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
