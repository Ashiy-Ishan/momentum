import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/default_labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/enums/enums.dart';
import '../../domain/models/models.dart';
import '../../features/tasks/providers/task_providers.dart';
import '../../features/timer/providers/timer_providers.dart';

/// Reusable Task Card component for lists, dashboard, and calendars.
///
/// Fully accessible: uses icons, text labels, and color semantics.
///
/// Features:
/// - Status checkbox / circle to toggle Done / Pending
/// - Strikethrough title and subtle muted tone when completed
/// - Priority indicator badge (Low / Medium / High / Urgent) with icons & containers
/// - Label badge with color tag and icon
/// - Recurrence indicator icon for recurring tasks
/// - External URL link button
/// - Time tracking button with live timer integration (Play / Pause / Stop)
/// - Due date badge with overdue warning state
/// - Popup menu for Edit, Delete, Skip Occurrence, Add Notes, Archive
class TaskCard extends ConsumerWidget {
  final Task task;
  final Label? label;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggleComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSkip;
  final VoidCallback? onAddNotes;
  final VoidCallback? onToggleArchive;
  final ValueChanged<String>? onOpenUrl;
  final VoidCallback? onStartTimer;
  final VoidCallback? onPauseTimer;
  final VoidCallback? onResumeTimer;
  final VoidCallback? onStopTimer;

  const TaskCard({
    super.key,
    required this.task,
    this.label,
    this.onTap,
    this.onToggleComplete,
    this.onEdit,
    this.onDelete,
    this.onSkip,
    this.onAddNotes,
    this.onToggleArchive,
    this.onOpenUrl,
    this.onStartTimer,
    this.onPauseTimer,
    this.onResumeTimer,
    this.onStopTimer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isDone = task.status == TaskStatus.done;
    final isCancelled = task.status == TaskStatus.cancelled;
    final isSkipped = task.status == TaskStatus.skipped;

    // Active timer status for this task
    final activeSession = ref.watch(activeTimerStreamProvider).valueOrNull;
    final isTimerForThisTask = activeSession != null && activeSession.taskId == task.id;
    final isTimerRunning = isTimerForThisTask && activeSession.status == TimerSessionStatus.running;
    final isTimerPaused = isTimerForThisTask && activeSession.status == TimerSessionStatus.paused;

    // Overdue status
    final now = DateTime.now();
    final isOverdue = task.dueDate != null &&
        task.dueDate!.isBefore(now) &&
        !isDone &&
        !isCancelled &&
        !isSkipped;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
        side: BorderSide(
          color: isTimerRunning
              ? (isDark ? AppColors.primaryLight : AppColors.primary)
              : (isOverdue
                  ? (isDark
                      ? AppColors.error.withAlpha(150)
                      : AppColors.error.withAlpha(120))
                  : (isDark ? AppColors.borderDark : AppColors.borderLight)),
          width: (isTimerRunning || isOverdue) ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderMd,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------------------------------------------------
              // Row 1: Checkbox, Title, and Action Menu
              // ---------------------------------------------------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Checkbox Circle
                  _StatusCircleButton(
                    key: const ValueKey('task_status_button'),
                    isDone: isDone,
                    isSkipped: isSkipped,
                    isCancelled: isCancelled,
                    onTap: () {
                      if (onToggleComplete != null) {
                        onToggleComplete!(!isDone);
                      } else {
                        ref
                            .read(taskControllerProvider.notifier)
                            .toggleTaskCompletion(
                              task,
                              task.scheduledDate ?? DateTime.now(),
                            );
                      }
                    },
                  ),

                  AppSpacing.hGapSm,

                  // Task Title & Optional Description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: (isDone || isCancelled)
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: colorScheme.onSurfaceVariant,
                            color: isDone
                                ? colorScheme.onSurfaceVariant.withAlpha(160)
                                : colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (task.description != null &&
                            task.description!.trim().isNotEmpty) ...[
                          AppSpacing.vGapXxs,
                          Text(
                            task.description!.trim(),
                            style: AppTypography.bodySmall.copyWith(
                              color: isDone
                                  ? colorScheme.onSurfaceVariant.withAlpha(120)
                                  : colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Actions Popup Menu
                  _buildActionsMenu(context, ref),
                ],
              ),

              AppSpacing.vGapSm,

              // ---------------------------------------------------------------
              // Row 2: Badges & Attributes (Priority, Label, Recurrence, Due, Timer, URL)
              // ---------------------------------------------------------------
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // 1. Priority Indicator Badge
                  _PriorityBadge(priority: task.priority, isDark: isDark),

                  // 2. Label Badge (if associated)
                  if (label != null)
                    _LabelBadge(label: label!, isDark: isDark),

                  // 3. Recurrence Badge (if recurring)
                  if (task.recurrenceRuleId != null)
                    _RecurrenceBadge(isDark: isDark),

                  // 4. Due Date / Overdue Warning Badge
                  if (task.dueDate != null)
                    _DueDateBadge(
                      dueDate: task.dueDate!,
                      isOverdue: isOverdue,
                      isDone: isDone,
                      isDark: isDark,
                    ),

                  // 5. Estimated Time Badge
                  if (task.hasTimeTracking && task.estimatedMinutes != null)
                    _EstimatedMinutesBadge(
                      minutes: task.estimatedMinutes!,
                      isDark: isDark,
                    ),
                ],
              ),

              // ---------------------------------------------------------------
              // Row 3: Action Buttons (Timer Controls & External URL)
              // ---------------------------------------------------------------
              if (task.hasTimeTracking ||
                  (task.url != null && task.url!.trim().isNotEmpty)) ...[
                AppSpacing.vGapSm,
                Row(
                  children: [
                    // URL link action button
                    if (task.url != null && task.url!.trim().isNotEmpty)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 6,
                          ),
                          minimumSize: const Size(0, 32),
                          textStyle: AppTypography.labelSmall,
                        ),
                        icon: const Icon(Icons.link_rounded, size: 16),
                        label: Text(
                          _cleanUrlDisplay(task.url!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onPressed: () {
                          onOpenUrl?.call(task.url!);
                        },
                      ),

                    const Spacer(),

                    // Time tracking controls
                    if (task.hasTimeTracking)
                      _buildTimerButton(
                        ref: ref,
                        isTimerForThisTask: isTimerForThisTask,
                        isTimerRunning: isTimerRunning,
                        isTimerPaused: isTimerPaused,
                        isDark: isDark,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz_rounded, size: 20),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      tooltip: 'Task actions',
      onSelected: (val) {
        switch (val) {
          case 'edit':
            onEdit?.call();
            break;
          case 'add_notes':
            onAddNotes?.call();
            break;
          case 'skip':
            onSkip?.call();
            break;
          case 'archive':
            onToggleArchive?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        if (onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 18),
                SizedBox(width: AppSpacing.sm),
                Text('Edit Task'),
              ],
            ),
          ),
        if (onAddNotes != null)
          const PopupMenuItem(
            value: 'add_notes',
            child: Row(
              children: [
                Icon(Icons.notes_rounded, size: 18),
                SizedBox(width: AppSpacing.sm),
                Text('Add Notes'),
              ],
            ),
          ),
        if (task.recurrenceRuleId != null && onSkip != null)
          const PopupMenuItem(
            value: 'skip',
            child: Row(
              children: [
                Icon(Icons.skip_next_rounded, size: 18),
                SizedBox(width: AppSpacing.sm),
                Text('Skip Occurrence'),
              ],
            ),
          ),
        if (onToggleArchive != null)
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
                const SizedBox(width: AppSpacing.sm),
                Text(task.isArchived ? 'Unarchive' : 'Archive'),
              ],
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: AppColors.error,
                ),
                SizedBox(width: AppSpacing.sm),
                Text('Delete Task', style: TextStyle(color: AppColors.error)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTimerButton({
    required WidgetRef ref,
    required bool isTimerForThisTask,
    required bool isTimerRunning,
    required bool isTimerPaused,
    required bool isDark,
  }) {
    if (isTimerRunning) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusPending,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 6,
              ),
              minimumSize: const Size(0, 32),
              textStyle: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: const Icon(Icons.pause_rounded, size: 16),
            label: const Text('Pause'),
            onPressed: () {
              if (onPauseTimer != null) {
                onPauseTimer!();
              } else {
                ref.read(timerControllerProvider.notifier).pause();
              }
            },
          ),
          AppSpacing.hGapXs,
          IconButton.filledTonal(
            style: IconButton.styleFrom(
              backgroundColor: AppColors.errorContainer,
              foregroundColor: AppColors.error,
              minimumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
            ),
            icon: const Icon(Icons.stop_rounded, size: 18),
            tooltip: 'Stop & Save',
            onPressed: () {
              if (onStopTimer != null) {
                onStopTimer!();
              } else {
                ref.read(timerControllerProvider.notifier).stopAndSave();
              }
            },
          ),
        ],
      );
    }

    if (isTimerPaused) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusDone,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 6,
              ),
              minimumSize: const Size(0, 32),
              textStyle: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 16),
            label: const Text('Resume'),
            onPressed: () {
              if (onResumeTimer != null) {
                onResumeTimer!();
              } else {
                ref.read(timerControllerProvider.notifier).resume();
              }
            },
          ),
          AppSpacing.hGapXs,
          IconButton.filledTonal(
            style: IconButton.styleFrom(
              backgroundColor: AppColors.errorContainer,
              foregroundColor: AppColors.error,
              minimumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
            ),
            icon: const Icon(Icons.stop_rounded, size: 18),
            tooltip: 'Stop & Save',
            onPressed: () {
              if (onStopTimer != null) {
                onStopTimer!();
              } else {
                ref.read(timerControllerProvider.notifier).stopAndSave();
              }
            },
          ),
        ],
      );
    }

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        minimumSize: const Size(0, 32),
        textStyle: AppTypography.labelSmall,
      ),
      icon: const Icon(Icons.play_arrow_rounded, size: 16),
      label: const Text('Track Time'),
      onPressed: () {
        if (onStartTimer != null) {
          onStartTimer!();
        } else {
          ref.read(timerControllerProvider.notifier).start(task.id);
        }
      },
    );
  }

  String _cleanUrlDisplay(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.replaceFirst(RegExp(r'^www\.'), '');
      if (host.isNotEmpty) return host;
    } catch (_) {}
    return 'Link';
  }
}

// =============================================================================
// SUB-COMPONENTS & BADGES
// =============================================================================

class _StatusCircleButton extends StatelessWidget {
  final bool isDone;
  final bool isSkipped;
  final bool isCancelled;
  final VoidCallback onTap;

  const _StatusCircleButton({
    super.key,
    required this.isDone,
    required this.isSkipped,
    required this.isCancelled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget iconWidget;
    Color borderColor;
    Color bgColor;

    if (isDone) {
      iconWidget = const Icon(
        Icons.check_rounded,
        size: 16,
        color: Colors.white,
      );
      borderColor = AppColors.statusDone;
      bgColor = AppColors.statusDone;
    } else if (isSkipped) {
      iconWidget = Icon(
        Icons.skip_next_rounded,
        size: 16,
        color: isDark ? AppColors.onStatusSkippedDark : AppColors.onStatusSkippedLight,
      );
      borderColor = AppColors.statusSkipped;
      bgColor = isDark
          ? AppColors.statusSkippedContainerDark
          : AppColors.statusSkippedContainerLight;
    } else if (isCancelled) {
      iconWidget = const Icon(
        Icons.close_rounded,
        size: 16,
        color: Colors.white,
      );
      borderColor = AppColors.statusCancelled;
      bgColor = AppColors.statusCancelled;
    } else {
      iconWidget = const SizedBox.shrink();
      borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
      bgColor = Colors.transparent;
    }

    return Semantics(
      button: true,
      label: isDone ? 'Mark task as pending' : 'Mark task as done',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            border: Border.all(color: borderColor, width: 2.0),
          ),
          alignment: Alignment.center,
          child: iconWidget,
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool isDark;

  const _PriorityBadge({
    required this.priority,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forPriority(priority.name);
    final bg = AppColors.priorityContainerFor(priority.name, isDark: isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(priority.icon, size: 12, color: color),
          AppSpacing.hGapXxs,
          Text(
            priority.displayName,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelBadge extends StatelessWidget {
  final Label label;
  final bool isDark;

  const _LabelBadge({
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = label.colorAsColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 50 : 35),
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: color.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(label.iconData, size: 12, color: color),
          AppSpacing.hGapXxs,
          Text(
            label.name,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecurrenceBadge extends StatelessWidget {
  final bool isDark;

  const _RecurrenceBadge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? AppColors.primaryLight : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primaryContainerDark
            : AppColors.primaryContainerLight,
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.repeat_rounded, size: 12, color: color),
          AppSpacing.hGapXxs,
          Text(
            'Recurring',
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _DueDateBadge extends StatelessWidget {
  final DateTime dueDate;
  final bool isOverdue;
  final bool isDone;
  final bool isDark;

  const _DueDateBadge({
    required this.dueDate,
    required this.isOverdue,
    required this.isDone,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    IconData icon;
    String text;

    if (isOverdue) {
      bg = isDark
          ? AppColors.statusCancelledContainerDark
          : AppColors.statusCancelledContainerLight;
      textColor = AppColors.error;
      icon = Icons.warning_amber_rounded;
      text = 'Overdue (${AppDateUtils.formatRelativeDate(dueDate)})';
    } else {
      bg = isDark
          ? AppColors.surfaceVariantDark
          : AppColors.surfaceVariantLight;
      textColor = isDone
          ? (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight)
          : (isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight);
      icon = Icons.calendar_today_rounded;
      text = AppDateUtils.formatRelativeDate(dueDate);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          AppSpacing.hGapXxs,
          Text(
            text,
            style: AppTypography.labelSmall.copyWith(
              color: textColor,
              fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _EstimatedMinutesBadge extends StatelessWidget {
  final int minutes;
  final bool isDark;

  const _EstimatedMinutesBadge({
    required this.minutes,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 12, color: textColor),
          AppSpacing.hGapXxs,
          Text(
            '${minutes}m',
            style: AppTypography.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
