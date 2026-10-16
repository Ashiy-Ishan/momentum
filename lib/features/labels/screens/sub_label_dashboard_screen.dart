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
import '../../../shared/widgets/kpi_card.dart';
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
      final val = int.tryParse('FF$clean', radix: 16);
      if (val != null) return Color(val);
    } else if (clean.length == 8) {
      final val = int.tryParse(clean, radix: 16);
      if (val != null) return Color(val);
    }
    return fallback;
  }

  Future<void> _showAddKpiDialog() async {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final currentCtrl = TextEditingController();
    final longTermCtrl = TextEditingController();
    final unitCtrl = TextEditingController();
    String selectedPlatform = 'general';
    String selectedCategory = 'output';
    KpiType selectedType = KpiType.count;
    KpiPeriod selectedPeriod = KpiPeriod.weekly;

    String? nameError;
    String? targetError;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Add Creator KPI Target'),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'KPI Goal Name *',
                        hintText: 'e.g. Weekly Video Uploads, Subscribers',
                        errorText: nameError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      onChanged: (_) {
                        if (nameError != null) {
                          setDialogState(() => nameError = null);
                        }
                      },
                    ),
                    AppSpacing.vGapMd,
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedPlatform,
                            decoration: InputDecoration(
                              labelText: 'Platform',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'youtube',
                                child: Text('YouTube'),
                              ),
                              DropdownMenuItem(
                                value: 'instagram',
                                child: Text('Instagram'),
                              ),
                              DropdownMenuItem(
                                value: 'twitter',
                                child: Text('X / Twitter'),
                              ),
                              DropdownMenuItem(
                                value: 'blog',
                                child: Text('Blog / Writing'),
                              ),
                              DropdownMenuItem(
                                value: 'linkedin',
                                child: Text('LinkedIn'),
                              ),
                              DropdownMenuItem(
                                value: 'tiktok',
                                child: Text('TikTok'),
                              ),
                              DropdownMenuItem(
                                value: 'general',
                                child: Text('General Focus'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() {
                                  selectedPlatform = val;
                                });
                              }
                            },
                          ),
                        ),
                        AppSpacing.hGapSm,
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedCategory,
                            decoration: InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'video_generation',
                                child: Text('Video Prod.'),
                              ),
                              DropdownMenuItem(
                                value: 'post_publication',
                                child: Text('Post Cadence'),
                              ),
                              DropdownMenuItem(
                                value: 'blog_publication',
                                child: Text('Articles'),
                              ),
                              DropdownMenuItem(
                                value: 'subscriber_growth',
                                child: Text('Subscribers'),
                              ),
                              DropdownMenuItem(
                                value: 'follower_growth',
                                child: Text('Followers'),
                              ),
                              DropdownMenuItem(
                                value: 'output',
                                child: Text('Output Tasks'),
                              ),
                              DropdownMenuItem(
                                value: 'time_invested',
                                child: Text('Time Invested'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() {
                                  selectedCategory = val;
                                  if (val == 'time_invested') {
                                    selectedType = KpiType.time;
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vGapMd,
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: targetCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Cadence Target *',
                              hintText: 'e.g. 2',
                              errorText: targetError,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            onChanged: (_) {
                              if (targetError != null) {
                                setDialogState(() => targetError = null);
                              }
                            },
                          ),
                        ),
                        AppSpacing.hGapSm,
                        Expanded(
                          child: TextField(
                            controller: unitCtrl,
                            decoration: InputDecoration(
                              labelText: 'Unit',
                              hintText: 'videos, subs, etc.',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vGapMd,
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: currentCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Current Value',
                              hintText: 'e.g. 0 or 1250',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                          ),
                        ),
                        AppSpacing.hGapSm,
                        Expanded(
                          child: TextField(
                            controller: longTermCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Long-term Milestone',
                              hintText: 'e.g. 10000',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vGapMd,
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<KpiPeriod>(
                            initialValue: selectedPeriod,
                            decoration: InputDecoration(
                              labelText: 'Cadence Reset',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
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
                        ),
                        AppSpacing.hGapSm,
                        Expanded(
                          child: DropdownButtonFormField<KpiType>(
                            initialValue: selectedType,
                            decoration: InputDecoration(
                              labelText: 'Metric Type',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: KpiType.count,
                                child: Text('Count'),
                              ),
                              DropdownMenuItem(
                                value: KpiType.time,
                                child: Text('Time'),
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
                  ],
                ),
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
                  final currentVal = double.tryParse(currentCtrl.text.trim()) ?? 0.0;
                  final longTarget = double.tryParse(longTermCtrl.text.trim());
                  final unit = unitCtrl.text.trim();

                  bool hasError = false;
                  if (name.isEmpty) {
                    setDialogState(() => nameError = 'Goal name is required');
                    hasError = true;
                  }
                  if (target <= 0) {
                    setDialogState(() => targetError = 'Cadence target must be > 0');
                    hasError = true;
                  }
                  if (hasError) return;

                  final userId = ref.read(currentUserIdProvider);
                  final now = DateTime.now();

                  final kpi = KpiDefinition(
                    id: _uuid.v4(),
                    userId: userId,
                    labelId: widget.labelId,
                    name: name,
                    kpiType: selectedType,
                    targetValue: target,
                    currentValue: currentVal,
                    longTermTarget: longTarget,
                    unit: unit.isEmpty ? 'count' : unit,
                    platform: selectedPlatform,
                    metricCategory: selectedCategory,
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
                    context.showSnackBar('Creator KPI target added');
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
                  return KpiCard(
                    kpi: summary.kpi,
                    currentValue: summary.currentValue,
                    onIncrement: () {
                      ref
                          .read(kpiRepositoryProvider)
                          .incrementCurrentValue(summary.kpi.id, 1.0);
                    },
                    onUpdateValue: (val) {
                      ref
                          .read(kpiRepositoryProvider)
                          .updateCurrentValue(summary.kpi.id, val);
                    },
                    onDelete: () {
                      ref
                          .read(kpiRepositoryProvider)
                          .deleteKpi(summary.kpi.id);
                    },
                  );
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
}
