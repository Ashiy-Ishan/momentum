import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/models.dart';
import '../../../shared/providers/database_provider.dart';
import '../../labels/providers/label_providers.dart';
import '../providers/task_providers.dart';
import '../widgets/task_card.dart';

/// Screen displaying tasks for a selected calendar date with quick navigation,
/// multi-dimensional filtering, and inline quick task creation.
class TodayTasksScreen extends ConsumerStatefulWidget {
  const TodayTasksScreen({super.key});

  @override
  ConsumerState<TodayTasksScreen> createState() => _TodayTasksScreenState();
}

class _TodayTasksScreenState extends ConsumerState<TodayTasksScreen> {
  final TextEditingController _quickTitleController = TextEditingController();
  static const _uuid = Uuid();

  TaskPriority _quickPriority = TaskPriority.medium;
  String? _quickLabelId;

  TaskStatus? _filterStatus;
  TaskPriority? _filterPriority;
  String? _filterLabelId;

  @override
  void dispose() {
    _quickTitleController.dispose();
    super.dispose();
  }

  void _previousDay() {
    final current = ref.read(selectedDateProvider);
    ref.read(selectedDateProvider.notifier).state =
        current.subtract(const Duration(days: 1));
  }

  void _nextDay() {
    final current = ref.read(selectedDateProvider);
    ref.read(selectedDateProvider.notifier).state =
        current.add(const Duration(days: 1));
  }

  void _goToToday() {
    ref.read(selectedDateProvider.notifier).state = DateTime.now();
  }

  Future<void> _pickDate() async {
    final current = ref.read(selectedDateProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      ref.read(selectedDateProvider.notifier).state = picked;
    }
  }

  Future<void> _submitQuickTask() async {
    final text = _quickTitleController.text.trim();
    if (text.isEmpty) return;

    final userId = ref.read(currentUserIdProvider);
    final selectedDate = ref.read(selectedDateProvider);
    final now = DateTime.now();

    final newTask = Task(
      id: _uuid.v4(),
      userId: userId,
      title: text,
      priority: _quickPriority,
      labelId: _quickLabelId,
      scheduledDate: selectedDate,
      createdAt: now,
      updatedAt: now,
    );

    _quickTitleController.clear();
    await ref.read(taskControllerProvider.notifier).createTask(newTask);

    if (mounted) {
      context.showSnackBar('Task created');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final tasksAsync = ref.watch(tasksForSelectedDateProvider);
    final allLabels = ref.watch(allLabelsStreamProvider).valueOrNull ?? [];

    final isToday = selectedDate.isToday;

    return Scaffold(
      appBar: AppBar(
        title: Text(isToday ? "Today's Tasks" : selectedDate.formatted),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_outlined),
            tooltip: 'Go to Today',
            onPressed: isToday ? null : _goToToday,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Pick Date',
            onPressed: _pickDate,
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector Navigation Bar
          _buildDateNavigationBar(context, selectedDate),

          // Task Count Badges Bar
          tasksAsync.when(
            data: (tasks) => _buildTaskCountBadges(context, tasks),
            loading: () => const SizedBox(height: 48),
            error: (_, _) => const SizedBox.shrink(),
          ),

          // Filters Bar
          _buildFilterBar(context, allLabels),
          const Divider(height: 1),

          // Task List
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                var filtered = tasks;

                if (_filterStatus != null) {
                  filtered =
                      filtered.where((t) => t.status == _filterStatus).toList();
                }
                if (_filterPriority != null) {
                  filtered = filtered
                      .where((t) => t.priority == _filterPriority)
                      .toList();
                }
                if (_filterLabelId != null) {
                  filtered = filtered
                      .where((t) => t.labelId == _filterLabelId)
                      .toList();
                }

                if (tasks.isEmpty) {
                  return _buildEmptyState(
                    title: isToday
                        ? 'No tasks scheduled for today'
                        : 'No tasks for ${selectedDate.formatted}',
                    message:
                        'Use the quick task bar below to add your first task!',
                    icon: Icons.checklist_outlined,
                  );
                }

                if (filtered.isEmpty) {
                  return _buildEmptyState(
                    title: 'No matching tasks',
                    message: 'No tasks matched your active filter criteria.',
                    icon: Icons.filter_list_off_outlined,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final task = filtered[index];
                    return TaskCard(
                      task: task,
                      occurrenceDate: selectedDate,
                      onEdit: () => context.push('/tasks/edit/${task.id}'),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),

          // Quick Task Creation Bottom Bar
          _buildQuickTaskBottomBar(context, allLabels, selectedDate),
        ],
      ),
    );
  }

  Widget _buildDateNavigationBar(BuildContext context, DateTime selectedDate) {
    final theme = Theme.of(context);
    final dayLabel = selectedDate.relativeFormatted;
    final dateSub = DateFormat('EEEE, MMM d, y').format(selectedDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton.filledTonal(
            icon: const Icon(Icons.chevron_left, size: 20),
            tooltip: 'Previous Day',
            onPressed: _previousDay,
          ),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  Text(
                    dayLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dateSub,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton.filledTonal(
            icon: const Icon(Icons.chevron_right, size: 20),
            tooltip: 'Next Day',
            onPressed: _nextDay,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCountBadges(BuildContext context, List<Task> tasks) {
    final total = tasks.length;
    final done = tasks.where((t) => t.status == TaskStatus.done).length;
    final remaining = (total - done).clamp(0, total);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBadgeItem('Total', '$total', AppColors.primary),
          _buildBadgeItem('Done', '$done', AppColors.statusDone),
          _buildBadgeItem('Remaining', '$remaining', AppColors.statusPending),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, List<Label> allLabels) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Status Filter
          DropdownButton<TaskStatus?>(
            value: _filterStatus,
            hint: const Text('Status: All', style: TextStyle(fontSize: 12)),
            underline: const SizedBox.shrink(),
            items: [
              const DropdownMenuItem(value: null, child: Text('Status: All')),
              ...TaskStatus.values.map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Row(
                    children: [
                      Icon(s.icon, size: 14, color: s.color),
                      const SizedBox(width: 6),
                      Text(s.displayName),
                    ],
                  ),
                ),
              ),
            ],
            onChanged: (val) => setState(() => _filterStatus = val),
          ),
          const SizedBox(width: 12),

          // Priority Filter
          DropdownButton<TaskPriority?>(
            value: _filterPriority,
            hint: const Text('Priority: All', style: TextStyle(fontSize: 12)),
            underline: const SizedBox.shrink(),
            items: [
              const DropdownMenuItem(
                  value: null, child: Text('Priority: All')),
              ...TaskPriority.values.map(
                (p) => DropdownMenuItem(
                  value: p,
                  child: Row(
                    children: [
                      Icon(p.icon, size: 14, color: p.color),
                      const SizedBox(width: 6),
                      Text(p.displayName),
                    ],
                  ),
                ),
              ),
            ],
            onChanged: (val) => setState(() => _filterPriority = val),
          ),
          const SizedBox(width: 12),

          // Label Filter
          DropdownButton<String?>(
            value: _filterLabelId,
            hint: const Text('Label: All', style: TextStyle(fontSize: 12)),
            underline: const SizedBox.shrink(),
            items: [
              const DropdownMenuItem(value: null, child: Text('Label: All')),
              ...allLabels.map(
                (l) => DropdownMenuItem(
                  value: l.id,
                  child: Row(
                    children: [
                      Icon(AppIcons.fromName(l.iconName), size: 14),
                      const SizedBox(width: 6),
                      Text(l.name),
                    ],
                  ),
                ),
              ),
            ],
            onChanged: (val) => setState(() => _filterLabelId = val),
          ),

          // Clear Filters
          if (_filterStatus != null ||
              _filterPriority != null ||
              _filterLabelId != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.filter_alt_off, size: 18),
              tooltip: 'Clear filters',
              onPressed: () {
                setState(() {
                  _filterStatus = null;
                  _filterPriority = null;
                  _filterLabelId = null;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickTaskBottomBar(
    BuildContext context,
    List<Label> allLabels,
    DateTime selectedDate,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quickTitleController,
                    decoration: InputDecoration(
                      hintText: 'Add a task for ${selectedDate.relativeFormatted.toLowerCase()}...',
                      prefixIcon: const Icon(Icons.add_task, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (_) => _submitQuickTask(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  onPressed: _submitQuickTask,
                  child: const Icon(Icons.send_rounded, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Quick metadata row: Priority and Label selectors
            Row(
              children: [
                // Priority dropdown
                PopupMenuButton<TaskPriority>(
                  tooltip: 'Select Priority',
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _quickPriority.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_quickPriority.icon,
                            size: 14, color: _quickPriority.color),
                        const SizedBox(width: 4),
                        Text(
                          _quickPriority.displayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _quickPriority.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onSelected: (p) => setState(() => _quickPriority = p),
                  itemBuilder: (ctx) => TaskPriority.values.map((p) {
                    return PopupMenuItem(
                      value: p,
                      child: Row(
                        children: [
                          Icon(p.icon, size: 16, color: p.color),
                          const SizedBox(width: 8),
                          Text(p.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 8),
                // Label selector
                PopupMenuButton<String?>(
                  tooltip: 'Select Label',
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.label_outline, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          _quickLabelId != null
                              ? allLabels
                                  .firstWhere((l) => l.id == _quickLabelId,
                                      orElse: () => allLabels.first)
                                  .name
                              : 'No Label',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  onSelected: (l) => setState(() => _quickLabelId = l),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: null,
                      child: Text('No Label'),
                    ),
                    ...allLabels.map((l) {
                      return PopupMenuItem(
                        value: l.id,
                        child: Row(
                          children: [
                            Icon(AppIcons.fromName(l.iconName), size: 16),
                            const SizedBox(width: 8),
                            Text(l.name),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String message,
    required IconData icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: Colors.grey.withValues(alpha: 0.6)),
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
      ),
    );
  }
}
