import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/models.dart';
import '../../../shared/providers/database_provider.dart';
import '../../analytics/providers/analytics_providers.dart';
import '../../tasks/providers/task_providers.dart';
import '../../tasks/widgets/task_card.dart';
import '../providers/label_providers.dart';

/// Detailed dashboard screen for an individual child sub-label (e.g., Channel 1,
/// Instagram, Programming Project), featuring KPI targets, progress gauges,
/// target creation, specific tasks, and completion history.
class SubLabelDashboardScreen extends ConsumerStatefulWidget {
  final String labelId;

  const SubLabelDashboardScreen({
    super.key,
    required this.labelId,
  });

  @override
  ConsumerState<SubLabelDashboardScreen> createState() =>
      _SubLabelDashboardScreenState();
}

class _SubLabelDashboardScreenState
    extends ConsumerState<SubLabelDashboardScreen> {
  static const _uuid = Uuid();

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

  Future<void> _showAddKpiDialog() async {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '5');
    KpiType selectedType = KpiType.count;
    KpiPeriod selectedPeriod = KpiPeriod.weekly;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Add KPI Target'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'KPI Goal Name *',
                      hintText: 'e.g. Upload 3 Videos, 10h Programming',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                  AppSpacing.vGapMd,
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: targetCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Target Value *',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.hGapSm,
                      Expanded(
                        child: DropdownButtonFormField<KpiType>(
                          initialValue: selectedType,
                          decoration: InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: KpiType.count,
                              child: Text('Count (Tasks)'),
                            ),
                            DropdownMenuItem(
                              value: KpiType.time,
                              child: Text('Time (Minutes)'),
                            ),
                            DropdownMenuItem(
                              value: KpiType.rate,
                              child: Text('Rate (%)'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => selectedType = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vGapMd,
                  DropdownButtonFormField<KpiPeriod>(
                    initialValue: selectedPeriod,
                    decoration: InputDecoration(
                      labelText: 'Reset Period',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: KpiPeriod.daily,
                        child: Text('Daily'),
                      ),
                      DropdownMenuItem(
                        value: KpiPeriod.weekly,
                        child: Text('Weekly'),
                      ),
                      DropdownMenuItem(
                        value: KpiPeriod.monthly,
                        child: Text('Monthly'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedPeriod = val);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final target = double.tryParse(targetCtrl.text.trim()) ?? 0.0;
                  if (name.isEmpty || target <= 0) return;

                  final userId = ref.read(currentUserIdProvider);
                  final now = DateTime.now();

                  final kpi = KpiDefinition(
                    id: _uuid.v4(),
                    userId: userId,
                    labelId: widget.labelId,
                    name: name,
                    kpiType: selectedType,
                    targetValue: target,
                    period: selectedPeriod,
                    startDate: now,
                    createdAt: now,
                    updatedAt: now,
                  );

                  await ref.read(kpiRepositoryProvider).createKpi(kpi);

                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                  if (mounted) {
                    context.showSnackBar('KPI target added');
                  }
                },
                child: const Text('Add Target'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allLabels = ref.watch(allLabelsStreamProvider).valueOrNull ?? [];
    final currentLabel = allLabels.cast<Label?>().firstWhere(
          (l) => l?.id == widget.labelId,
          orElse: () => null,
        );

    final parentLabel = currentLabel?.parentId != null
        ? allLabels.cast<Label?>().firstWhere(
              (l) => l?.id == currentLabel!.parentId,
              orElse: () => null,
            )
        : null;

    final kpisAsync = ref.watch(labelKpisProvider(widget.labelId));
    final allTasks = ref.watch(allTasksStreamProvider).valueOrNull ?? [];
    final subTasks =
        allTasks.where((t) => t.labelId == widget.labelId).toList();

    if (currentLabel == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Sub-label not found')),
      );
    }

    final labelColor =
        _colorFromHex(currentLabel.color, theme.colorScheme.primary);
    final completedCount =
        subTasks.where((t) => t.status == TaskStatus.done).length;
    final totalCount = subTasks.length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb: Parent -> Sub-label
            if (parentLabel != null)
              InkWell(
                onTap: () =>
                    context.push('/labels/parent/${parentLabel.id}'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      parentLabel.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 14),
                  ],
                ),
              ),
            Text(currentLabel.name),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            tooltip: 'Add Task to Sub-Label',
            onPressed: () {
              context.push(
                '/tasks/new',
                extra: {
                  'parentLabelId': parentLabel?.id,
                  'subLabelId': currentLabel.id,
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Sub-Label Header Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: labelColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: labelColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: labelColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.fromName(currentLabel.iconName),
                    color: labelColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentLabel.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        parentLabel != null
                            ? 'Part of ${parentLabel.name}'
                            : 'Independent project',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Stats badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$completedCount / $totalCount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: labelColor,
                      ),
                    ),
                    const Text(
                      'Completed',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          AppSpacing.vGapLg,

          // KPI Targets Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KPI Targets & Goals',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Target'),
                onPressed: _showAddKpiDialog,
              ),
            ],
          ),
          AppSpacing.vGapSm,

          // KPI Cards
          kpisAsync.when(
            data: (kpiSummaries) {
              if (kpiSummaries.isEmpty) {
                return Card(
                  elevation: 0,
                  color:
                      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.flag_outlined,
                            size: 36, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text(
                          'No KPI targets configured yet',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Set measurable goals (e.g. 4 videos/week, 20 hours/month) to track your progress!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add First Target'),
                          onPressed: _showAddKpiDialog,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: kpiSummaries.map((summary) {
                  return _buildKpiCard(context, summary, labelColor);
                }).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error loading KPIs: $err'),
            ),
          ),

          AppSpacing.vGapLg,

          // Sub-Label Tasks Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tasks (${subTasks.length})',
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
                    extra: {'subLabelId': currentLabel.id},
                  );
                },
              ),
            ],
          ),
          AppSpacing.vGapSm,

          if (subTasks.isEmpty)
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              child: const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No tasks assigned to this sub-label yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subTasks.length,
              itemBuilder: (context, index) {
                final task = subTasks[index];
                return TaskCard(
                  task: task,
                  showLabel: false,
                  onEdit: () => context.push('/tasks/edit/${task.id}'),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(
    BuildContext context,
    LabelKpiSummary summary,
    Color accentColor,
  ) {
    final theme = Theme.of(context);
    final kpi = summary.kpi;
    final isAchieved = summary.isAchieved;
    final percent = (summary.progressPercentage * 100).toInt();

    String currentStr = summary.currentValue.toStringAsFixed(
        summary.currentValue.truncateToDouble() == summary.currentValue
            ? 0
            : 1);
    String targetStr = summary.targetValue.toStringAsFixed(
        summary.targetValue.truncateToDouble() == summary.targetValue ? 0 : 1);

    if (kpi.kpiType == KpiType.time) {
      currentStr = '${summary.currentValue.toInt()}m';
      targetStr = '${summary.targetValue.toInt()}m';
    } else if (kpi.kpiType == KpiType.rate) {
      currentStr = '$currentStr%';
      targetStr = '$targetStr%';
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: isAchieved
              ? AppColors.statusDone.withValues(alpha: 0.5)
              : theme.dividerColor.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        isAchieved
                            ? Icons.check_circle
                            : Icons.flag_outlined,
                        size: 18,
                        color: isAchieved
                            ? AppColors.statusDone
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          kpi.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    kpi.period.displayName,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16),
                  color: AppColors.error,
                  tooltip: 'Delete KPI',
                  onPressed: () {
                    ref.read(kpiRepositoryProvider).deleteKpi(kpi.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: summary.progressPercentage,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: isAchieved ? AppColors.statusDone : accentColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$currentStr / $targetStr',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isAchieved ? AppColors.statusDone : accentColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
