import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/models.dart';
import '../../labels/providers/label_providers.dart';
import '../../timer/providers/timer_providers.dart';
import '../providers/task_providers.dart';

/// Interactive card widget displaying a [Task] with full status controls,
/// time tracking controls, and metadata badges.
class TaskCard extends ConsumerWidget {
  final Task task;
  final DateTime? occurrenceDate;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final bool showLabel;

  const TaskCard({
    super.key,
    required this.task,
    this.occurrenceDate,
    this.onTap,
    this.onEdit,
    this.showLabel = true,
  });

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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDone = task.status == TaskStatus.done;
    final activeTimer = ref.watch(activeTimerStreamProvider).valueOrNull;
    final isTimerRunningForThis =
        activeTimer != null && activeTimer.taskId == task.id;
    final timerElapsed = isTimerRunningForThis
        ? ref.watch(timerCurrentDurationProvider).valueOrNull ?? Duration.zero
        : Duration.zero;

    // Resolve task label if assigned
    final allLabels = ref.watch(allLabelsStreamProvider).valueOrNull ?? [];
    Label? label;
    if (task.labelId != null && task.labelId!.isNotEmpty) {
      label = allLabels.cast<Label?>().firstWhere(
            (l) => l?.id == task.labelId,
            orElse: () => null,
          );
    }

    // Determine overdue status
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isOverdue = !isDone &&
        task.dueDate != null &&
        DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day)
            .isBefore(today);

    final targetDate = occurrenceDate ?? task.scheduledDate ?? DateTime.now();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: isDone
              ? AppColors.statusDone.withValues(alpha: 0.3)
              : isOverdue
                  ? AppColors.error.withValues(alpha: 0.4)
                  : theme.dividerColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      color: isDone
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25)
          : theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap ?? onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Completion checkbox, Title, and Context menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Completion Checkbox
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      onTap: () {
                        ref
                            .read(taskControllerProvider.notifier)
                            .toggleTaskCompletion(task, targetDate);
                      },
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? AppColors.statusDone
                              : Colors.transparent,
                          border: Border.all(
                            color: isDone
                                ? AppColors.statusDone
                                : task.priority.color,
                            width: 2,
                          ),
                        ),
                        child: isDone
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),

                  // Title & Description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration:
                                isDone ? TextDecoration.lineThrough : null,
                            color: isDone
                                ? theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5)
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        if (task.description != null &&
                            task.description!.trim().isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            task.description!.trim(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Actions popup
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 150),
                    onSelected: (val) {
                      switch (val) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'pending':
                          ref
                              .read(taskControllerProvider.notifier)
                              .setTaskStatus(task.id, TaskStatus.pending);
                          break;
                        case 'doing':
                          ref
                              .read(taskControllerProvider.notifier)
                              .setTaskStatus(task.id, TaskStatus.doing);
                          break;
                        case 'done':
                          ref
                              .read(taskControllerProvider.notifier)
                              .setTaskStatus(task.id, TaskStatus.done);
                          break;
                        case 'skipped':
                          ref
                              .read(taskControllerProvider.notifier)
                              .setTaskStatus(task.id, TaskStatus.skipped);
                          break;
                        case 'cancelled':
                          ref
                              .read(taskControllerProvider.notifier)
                              .setTaskStatus(task.id, TaskStatus.cancelled);
                          break;
                        case 'archive':
                          ref
                              .read(taskControllerProvider.notifier)
                              .archiveTask(task.id, !task.isArchived);
                          break;
                        case 'delete':
                          _confirmDelete(context, ref);
                          break;
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Edit Task'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'doing',
                        child: Row(
                          children: [
                            Icon(Icons.play_circle_outline,
                                size: 18, color: AppColors.statusDoing),
                            SizedBox(width: 8),
                            Text('In Progress'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'done',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 18, color: AppColors.statusDone),
                            SizedBox(width: 8),
                            Text('Mark Done'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'pending',
                        child: Row(
                          children: [
                            Icon(Icons.hourglass_empty,
                                size: 18, color: AppColors.statusPending),
                            SizedBox(width: 8),
                            Text('Mark Pending'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'skipped',
                        child: Row(
                          children: [
                            Icon(Icons.skip_next,
                                size: 18, color: AppColors.statusSkipped),
                            SizedBox(width: 8),
                            Text('Skip Occurrence'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'archive',
                        child: Row(
                          children: [
                            Icon(
                              task.isArchived
                                  ? Icons.unarchive_outlined
                                  : Icons.archive_outlined,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(task.isArchived ? 'Unarchive' : 'Archive'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Delete',
                                style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Row 2: Badges and Metadata
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Label Badge
                  if (showLabel && label != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _colorFromHex(
                                label.color, theme.colorScheme.primary)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: _colorFromHex(
                                  label.color, theme.colorScheme.primary)
                              .withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.fromName(label.iconName),
                            size: 12,
                            color: _colorFromHex(
                                label.color, theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            label.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _colorFromHex(
                                  label.color, theme.colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Priority Chip
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: task.priority.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(task.priority.icon,
                            size: 11, color: task.priority.color),
                        const SizedBox(width: 3),
                        Text(
                          task.priority.displayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: task.priority.color,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scheduled Date / Due Date Badge
                  if (task.dueDate != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: isOverdue
                            ? AppColors.error.withValues(alpha: 0.12)
                            : theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOverdue
                                ? Icons.warning_amber_rounded
                                : Icons.event_outlined,
                            size: 11,
                            color: isOverdue
                                ? AppColors.error
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            task.dueDate!.relativeFormatted,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isOverdue
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isOverdue
                                  ? AppColors.error
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (task.scheduledDate != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 11,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 3),
                          Text(
                            task.scheduledDate!.relativeFormatted,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Estimated minutes
                  if (task.estimatedMinutes != null &&
                      task.estimatedMinutes! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 11,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 3),
                          Text(
                            '${task.estimatedMinutes}m',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Recurring badge
                  if (task.recurrenceRuleId != null &&
                      task.recurrenceRuleId!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.repeat,
                              size: 11,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 3),
                          Text(
                            'Recurring',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Time Tracking Play / Stop Button
                  if (task.hasTimeTracking)
                    InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      onTap: () {
                        if (isTimerRunningForThis) {
                          ref
                              .read(timerControllerProvider.notifier)
                              .stopAndSave();
                        } else {
                          ref
                              .read(timerControllerProvider.notifier)
                              .start(task.id);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isTimerRunningForThis
                              ? AppColors.error.withValues(alpha: 0.15)
                              : AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: isTimerRunningForThis
                                ? AppColors.error
                                : AppColors.primary.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isTimerRunningForThis
                                  ? Icons.stop_circle_outlined
                                  : Icons.play_arrow_rounded,
                              size: 13,
                              color: isTimerRunningForThis
                                  ? AppColors.error
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isTimerRunningForThis
                                  ? _formatDuration(timerElapsed)
                                  : 'Track',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isTimerRunningForThis
                                  ? AppColors.error
                                  : AppColors.primary,
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
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final mins = d.inMinutes.remainder(60);
    final secs = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(taskControllerProvider.notifier).deleteTask(task.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
