import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/theme.dart';
import '../../../data/sync/sync_engine.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/models.dart';
import '../../../shared/providers/database_provider.dart';
import '../../analytics/providers/analytics_providers.dart';
import '../../labels/providers/label_providers.dart';
import '../../motivation/domain/motivation_quote.dart';
import '../../motivation/providers/motivation_providers.dart';
import '../../settings/providers/connected_accounts_provider.dart';
import '../../tasks/providers/task_providers.dart';
import '../../tasks/widgets/task_card.dart';

/// Central dashboard screen displaying user greeting, daily progress summary,
/// focus area KPI cards, and today's task list.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  TaskStatus? _selectedStatusFilter;

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
    final greeting = ref.watch(currentGreetingProvider);
    final quoteAsync = ref.watch(currentQuoteProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final todayTasksAsync = ref.watch(todayTasksStreamProvider);
    final rootLabelsAsync = ref.watch(rootLabelsStreamProvider);
    final allLabels = ref.watch(allLabelsStreamProvider).valueOrNull ?? [];
    final allKpisAsync = ref.watch(allKpisStreamProvider);
    final syncStatus = ref.watch(syncStatusStreamProvider).valueOrNull ??
        ref.watch(syncStatusProvider);

    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d').format(now);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, User',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              formattedDate,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          // Sync indicator badge
          _buildSyncIndicator(syncStatus ?? SyncEngineStatus.offline),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(refreshQuoteProvider)();
          await ref.read(syncEngineProvider).triggerSync();
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            AppSpacing.vGapSm,

            // Motivational Quote Card
            quoteAsync.when(
              data: (quote) => quote != null
                  ? _buildQuoteCard(context, quote)
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),

            // Daily Progress Summary Card
            statsAsync.when(
              data: (stats) => _buildProgressSummaryCard(context, stats),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading progress: $err'),
              ),
            ),

            AppSpacing.vGapMd,

            // Platform Output & Creator Cadence
            allKpisAsync.when(
              data: (kpis) => _buildPlatformOutputSection(context, kpis),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),

            // Focus Areas (Parent Labels Overview)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Focus Areas',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.tune, size: 16),
                    label: const Text('Manage'),
                    onPressed: () => context.push('/labels'),
                  ),
                ],
              ),
            ),
            AppSpacing.vGapXs,

            // Parent Labels Carousel / Grid
            rootLabelsAsync.when(
              data: (labels) {
                if (labels.isEmpty) {
                  return _buildEmptyFocusAreas(context);
                }
                return SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: labels.length,
                    itemBuilder: (context, index) {
                      final label = labels[index];
                      final childCount =
                          allLabels.where((l) => l.parentId == label.id).length;
                      return _buildParentLabelCard(
                        context,
                        label: label,
                        subLabelCount: childCount,
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => const SizedBox.shrink(),
            ),

            AppSpacing.vGapLg,

            // Today's Tasks Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "Today's Tasks",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.hGapSm,
                      todayTasksAsync.maybeWhen(
                        data: (tasks) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            '${tasks.where((t) => t.status == TaskStatus.done).length}/${tasks.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Quick Add'),
                    onPressed: () => context.push('/tasks/new'),
                  ),
                ],
              ),
            ),

            // Status Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedStatusFilter == null,
                      onSelected: (_) =>
                          setState(() => _selectedStatusFilter = null),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Pending'),
                      selected: _selectedStatusFilter == TaskStatus.pending,
                      avatar: const Icon(Icons.hourglass_empty, size: 14),
                      onSelected: (_) => setState(
                          () => _selectedStatusFilter = TaskStatus.pending),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Doing'),
                      selected: _selectedStatusFilter == TaskStatus.doing,
                      avatar: const Icon(Icons.play_arrow, size: 14),
                      onSelected: (_) => setState(
                          () => _selectedStatusFilter = TaskStatus.doing),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Done'),
                      selected: _selectedStatusFilter == TaskStatus.done,
                      avatar: const Icon(Icons.check, size: 14),
                      onSelected: (_) => setState(
                          () => _selectedStatusFilter = TaskStatus.done),
                    ),
                  ],
                ),
              ),
            ),

            // Today's Task List
            todayTasksAsync.when(
              data: (tasks) {
                var filtered = tasks;
                if (_selectedStatusFilter != null) {
                  filtered = tasks
                      .where((t) => t.status == _selectedStatusFilter)
                      .toList();
                }

                if (tasks.isEmpty) {
                  return _buildEmptyState(
                    title: 'No tasks for today',
                    message:
                        'Tap Quick Add to schedule a new task or take a well-deserved break!',
                    icon: Icons.wb_sunny_outlined,
                  );
                }

                if (filtered.isEmpty) {
                  return _buildEmptyState(
                    title: 'No matching tasks',
                    message: 'No tasks found for the selected status filter.',
                    icon: Icons.filter_alt_off_outlined,
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final task = filtered[index];
                    return TaskCard(
                      task: task,
                      occurrenceDate: now,
                      onEdit: () => context.push('/tasks/edit/${task.id}'),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Center(
                child: Text('Error loading tasks: $err'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: () => context.push('/tasks/new'),
        tooltip: 'Create Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSyncIndicator(SyncEngineStatus status) {
    IconData icon;
    Color color;
    String tooltip;

    switch (status) {
      case SyncEngineStatus.syncing:
        return const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      case SyncEngineStatus.idle:
        icon = Icons.cloud_done_outlined;
        color = AppColors.statusDone;
        tooltip = 'Synced with Cloud';
        break;
      case SyncEngineStatus.offline:
        icon = Icons.cloud_off_outlined;
        color = AppColors.priorityLow;
        tooltip = 'Offline Mode';
        break;
      case SyncEngineStatus.error:
        icon = Icons.sync_problem_outlined;
        color = AppColors.error;
        tooltip = 'Sync Error';
        break;
    }

    return IconButton(
      icon: Icon(icon, color: color, size: 20),
      tooltip: tooltip,
      onPressed: () async {
        await ref.read(syncEngineProvider).triggerSync();
      },
    );
  }

  Widget _buildQuoteCard(BuildContext context, MotivationQuote quote) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.format_quote_rounded,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quote.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '— ${quote.author ?? 'Unknown'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              tooltip: 'New quote',
              onPressed: () {
                ref.read(refreshQuoteProvider)();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSummaryCard(BuildContext context, DashboardStats stats) {
    final theme = Theme.of(context);
    final percentage = (stats.completionRate * 100).toInt();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Circular Progress Indicator
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: stats.scheduledTasks > 0
                            ? stats.completionRate
                            : 0.0,
                        strokeWidth: 6,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        color: percentage == 100
                            ? AppColors.statusDone
                            : theme.colorScheme.primary,
                      ),
                      Text(
                        '$percentage%',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Summary details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daily Momentum',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Consistency Streak Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.statusPending
                                  .withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                              border: Border.all(
                                color: AppColors.statusPending
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🔥', style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Text(
                                  '${stats.streakDays} days',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.statusPending,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${stats.completedTasks} completed of ${stats.scheduledTasks} planned',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),
            // Metrics row: Completed, Pending, Remaining
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatPill(
                  label: 'Completed',
                  value: '${stats.completedTasks}',
                  color: AppColors.statusDone,
                  icon: Icons.check_circle_outline,
                ),
                _buildStatPill(
                  label: 'Remaining',
                  value: '${stats.remainingTasks}',
                  color: AppColors.statusPending,
                  icon: Icons.hourglass_top_outlined,
                ),
                _buildStatPill(
                  label: 'Scheduled',
                  value: '${stats.scheduledTasks}',
                  color: theme.colorScheme.primary,
                  icon: Icons.assignment_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParentLabelCard(
    BuildContext context, {
    required Label label,
    required int subLabelCount,
  }) {
    final theme = Theme.of(context);
    final cardColor = _colorFromHex(label.color, AppColors.primary);

    return Container(
      width: 170,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: cardColor.withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        color: cardColor.withValues(alpha: 0.08),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => context.push('/labels/parent/${label.id}'),
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
                        color: cardColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        AppIcons.fromName(label.iconName),
                        color: cardColor,
                        size: 20,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$subLabelCount sub-labels',
                      style: theme.textTheme.bodySmall?.copyWith(
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

  Widget _buildEmptyFocusAreas(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Seed Default Focus Areas (YouTube, Learning, etc.)'),
        onPressed: () {
          ref.read(labelControllerProvider.notifier).seedDefaultLabels();
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String message,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: Colors.grey.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformOutputSection(
      BuildContext context, List<KpiDefinition> kpis) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (kpis.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: AppRadius.borderMd,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bolt_rounded,
                    color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Creator & Developer Cadence',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track weekly videos, posts, blogs, GitHub commits, LinkedIn insights, and audience milestones.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.tonal(
                onPressed: () async {
                  final userId = ref.read(currentUserIdProvider);
                  final labels =
                      ref.read(allLabelsStreamProvider).valueOrNull ?? [];
                  await ref
                      .read(kpiRepositoryProvider)
                      .seedDefaultPlatformKpis(userId, labels);
                },
                child: const Text('Initialize'),
              ),
            ],
          ),
        ),
      );
    }

    final connectedAccounts = ref.watch(connectedAccountsProvider);
    final activeAccounts = connectedAccounts.where((a) => a.isConnected).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt_rounded,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Creator Output & Cadence',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => context.push('/settings'),
                    icon: const Icon(Icons.link, size: 14),
                    label: Text(
                      activeAccounts.isEmpty
                          ? 'Connect Accounts'
                          : '${activeAccounts.length} Connected',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${kpis.length} tracked',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (activeAccounts.isNotEmpty) ...[
          const SizedBox(height: 6),
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: activeAccounts.length,
              itemBuilder: (context, idx) {
                final acc = activeAccounts[idx];
                final color = AppColors.forPlatform(acc.platform);
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_platformIcon(acc.platform), size: 13, color: color),
                      const SizedBox(width: 5),
                      Text(
                        acc.handle,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      if (acc.metricCount != null) ...[
                        const SizedBox(width: 5),
                        Text(
                          '• ${_formatMetric(acc.metricCount!)} ${acc.metricUnit}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
        AppSpacing.vGapXs,
        SizedBox(
          height: 135,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: kpis.length,
            itemBuilder: (context, index) {
              final kpi = kpis[index];
              final platformColor = AppColors.forPlatform(kpi.platform);
              final progress = kpi.targetValue > 0
                  ? (kpi.currentValue / kpi.targetValue).clamp(0.0, 1.0)
                  : 0.0;
              final isMet =
                  kpi.targetValue > 0 && kpi.currentValue >= kpi.targetValue;
              final isMilestone = kpi.metricCategory == 'subscriber_growth' ||
                  kpi.metricCategory == 'follower_growth';

              return Container(
                width: 230,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: AppRadius.borderMd,
                  border: Border.all(
                    color: isMet
                        ? AppColors.statusDone.withValues(alpha: 0.4)
                        : (isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight),
                    width: isMet ? 1.4 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: platformColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                _platformIcon(kpi.platform),
                                size: 14,
                                color: platformColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              kpi.platform.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: platformColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => _showEditKpiDialog(context, kpi),
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: (isDark
                                          ? AppColors.surfaceVariantDark
                                          : AppColors.surfaceVariantLight)
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(Icons.edit_outlined,
                                    size: 13,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight),
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () async {
                                await ref
                                    .read(kpiRepositoryProvider)
                                    .incrementCurrentValue(kpi.id, 1.0);
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: platformColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.add,
                                        size: 12, color: platformColor),
                                    Text(
                                      '1',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: platformColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      kpi.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isMilestone
                              ? '${_formatMetric(kpi.currentValue)} / ${_formatMetric(kpi.targetValue)} ${kpi.unit}'
                              : '${kpi.currentValue.toInt()} / ${kpi.targetValue.toInt()} ${kpi.unit}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        if (kpi.hasLongTermTarget)
                          Text(
                            'Goal: ${_formatMetric(kpi.longTermTarget!)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primaryDark,
                            ),
                          ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: isDark
                            ? AppColors.surfaceVariantDark
                            : AppColors.surfaceVariantLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isMet ? AppColors.statusDone : platformColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        AppSpacing.vGapLg,
      ],
    );
  }

  String _formatMetric(double val) {
    if (val >= 1000000) {
      final m = val / 1000000;
      return '${m.toStringAsFixed(m % 1 == 0 ? 0 : 1)}M';
    } else if (val >= 1000) {
      final k = val / 1000;
      return '${k.toStringAsFixed(k % 1 == 0 ? 0 : 1)}k';
    } else {
      return val.toInt().toString();
    }
  }

  Future<void> _showEditKpiDialog(
      BuildContext context, KpiDefinition kpi) async {
    final textCtrl = TextEditingController(
      text: kpi.currentValue.toInt().toString(),
    );

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update ${kpi.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your updated current count (${kpi.unit}):',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                suffixText: kpi.unit,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final val = double.tryParse(textCtrl.text.trim());
              if (val != null) {
                await ref
                    .read(kpiRepositoryProvider)
                    .updateCurrentValue(kpi.id, val);
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  IconData _platformIcon(String p) {
    switch (p.toLowerCase()) {
      case 'github':
        return Icons.code_rounded;
      case 'youtube':
        return Icons.play_circle_filled_rounded;
      case 'instagram':
        return Icons.camera_alt_rounded;
      case 'twitter':
      case 'x':
        return Icons.tag_rounded;
      case 'blog':
        return Icons.article_rounded;
      case 'linkedin':
        return Icons.business_center_rounded;
      default:
        return Icons.insights_rounded;
    }
  }
}

