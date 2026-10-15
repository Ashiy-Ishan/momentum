import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/models.dart';
import '../../tasks/providers/task_providers.dart';
import '../../tasks/widgets/task_card.dart';

/// Interactive month calendar view visualizing task densities and completion rates,
/// with per-day drilldown and occurrence inspector.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _viewMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _viewMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  void _previousMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 1);
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _viewMonth = DateTime(now.year, now.month, 1);
      _selectedDay = DateTime(now.year, now.month, now.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allTasks = ref.watch(allTasksStreamProvider).valueOrNull ?? [];

    // Group tasks by date key 'yyyy-MM-dd'
    final taskMap = <String, List<Task>>{};
    for (final task in allTasks) {
      if (task.scheduledDate != null) {
        final key = DateFormat('yyyy-MM-dd').format(task.scheduledDate!);
        taskMap.putIfAbsent(key, () => []).add(task);
      }
    }

    final selectedKey = DateFormat('yyyy-MM-dd').format(_selectedDay);
    final tasksForSelected = taskMap[selectedKey] ?? [];

    final completedForSelected =
        tasksForSelected.where((t) => t.status == TaskStatus.done).length;
    final skippedForSelected =
        tasksForSelected.where((t) => t.status == TaskStatus.skipped).length;
    final pendingForSelected =
        tasksForSelected.where((t) => t.status == TaskStatus.pending).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Jump to Today',
            onPressed: _goToToday,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Task for Selected Day',
            onPressed: () {
              context.push(
                '/tasks/new',
                extra: {'defaultScheduledDate': _selectedDay},
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Header Bar
          _buildMonthHeader(context),

          // Days of week row
          _buildWeekdaysHeader(context),

          // Calendar Days Grid
          _buildMonthGrid(context, taskMap),

          const Divider(height: 1),

          // Selected Day Overview Panel Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedDay.relativeFormatted,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, MMMM d, y').format(_selectedDay),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                // Task counts pill
                Row(
                  children: [
                    if (tasksForSelected.isNotEmpty) ...[
                      _buildSmallCountPill(
                        '$completedForSelected done',
                        AppColors.statusDone,
                      ),
                      const SizedBox(width: 4),
                      _buildSmallCountPill(
                        '$pendingForSelected pend',
                        AppColors.statusPending,
                      ),
                      if (skippedForSelected > 0) ...[
                        const SizedBox(width: 4),
                        _buildSmallCountPill(
                          '$skippedForSelected skip',
                          AppColors.statusSkipped,
                        ),
                      ],
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Tasks for selected day
          Expanded(
            child: tasksForSelected.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_available_outlined,
                            size: 48,
                            color: Colors.grey.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No tasks scheduled for ${_selectedDay.relativeFormatted.toLowerCase()}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          FilledButton.tonalIcon(
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Schedule Task'),
                            onPressed: () {
                              context.push(
                                '/tasks/new',
                                extra: {'defaultScheduledDate': _selectedDay},
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: tasksForSelected.length,
                    itemBuilder: (context, index) {
                      final task = tasksForSelected[index];
                      return TaskCard(
                        task: task,
                        occurrenceDate: _selectedDay,
                        onEdit: () =>
                            context.push('/tasks/edit/${task.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(BuildContext context) {
    final theme = Theme.of(context);
    final monthStr = DateFormat('MMMM y').format(_viewMonth);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton.filledTonal(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: _previousMonth,
          ),
          Text(
            monthStr,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          IconButton.filledTonal(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdaysHeader(BuildContext context) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthGrid(
    BuildContext context,
    Map<String, List<Task>> taskMap,
  ) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final daysInCurrentMonth =
        AppDateUtils.daysInMonth(_viewMonth.year, _viewMonth.month);
    final firstDayWeekday = _viewMonth.weekday; // 1 = Mon, 7 = Sun

    // Previous month filler days
    final prevMonth = DateTime(_viewMonth.year, _viewMonth.month - 1, 1);
    final daysInPrevMonth =
        AppDateUtils.daysInMonth(prevMonth.year, prevMonth.month);

    final fillerDaysBefore = firstDayWeekday - 1;
    final totalCells =
        ((fillerDaysBefore + daysInCurrentMonth + 6) ~/ 7) * 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 1.15,
        ),
        itemCount: totalCells,
        itemBuilder: (context, index) {
          DateTime cellDate;
          bool isCurrentMonth = true;

          if (index < fillerDaysBefore) {
            // Day from previous month
            final dayNum = daysInPrevMonth - fillerDaysBefore + index + 1;
            cellDate = DateTime(prevMonth.year, prevMonth.month, dayNum);
            isCurrentMonth = false;
          } else if (index < fillerDaysBefore + daysInCurrentMonth) {
            // Day in current month
            final dayNum = index - fillerDaysBefore + 1;
            cellDate = DateTime(_viewMonth.year, _viewMonth.month, dayNum);
          } else {
            // Day in next month
            final dayNum = index - (fillerDaysBefore + daysInCurrentMonth) + 1;
            final nextMonth =
                DateTime(_viewMonth.year, _viewMonth.month + 1, 1);
            cellDate = DateTime(nextMonth.year, nextMonth.month, dayNum);
            isCurrentMonth = false;
          }

          final isSelected = AppDateUtils.isSameDay(cellDate, _selectedDay);
          final isCellToday = AppDateUtils.isSameDay(cellDate, today);

          final dateKey = DateFormat('yyyy-MM-dd').format(cellDate);
          final dayTasks = taskMap[dateKey] ?? [];

          final hasCompleted =
              dayTasks.any((t) => t.status == TaskStatus.done);
          final hasPending =
              dayTasks.any((t) => t.status == TaskStatus.pending || t.status == TaskStatus.doing);

          return InkWell(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            onTap: () {
              setState(() {
                _selectedDay = cellDate;
                if (!isCurrentMonth) {
                  _viewMonth = DateTime(cellDate.year, cellDate.month, 1);
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                color: isSelected
                    ? theme.colorScheme.primaryContainer
                    : isCellToday
                        ? theme.colorScheme.primary.withValues(alpha: 0.08)
                        : null,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : isCellToday
                          ? theme.colorScheme.primary.withValues(alpha: 0.5)
                          : Colors.transparent,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${cellDate.day}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isCellToday || isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isCurrentMonth
                          ? (isSelected
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Dots indicator
                  if (dayTasks.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (hasCompleted)
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: const BoxDecoration(
                              color: AppColors.statusDone,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (hasPending)
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: const BoxDecoration(
                              color: AppColors.statusPending,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    )
                  else
                    const SizedBox(height: 5),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSmallCountPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
