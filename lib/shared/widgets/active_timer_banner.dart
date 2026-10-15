import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/enums/enums.dart';
import '../../domain/models/models.dart';
import '../../features/timer/providers/timer_providers.dart';
import '../providers/database_provider.dart';

/// Provider fetching the task currently associated with the active timer session.
final activeTimerTaskProvider = FutureProvider<Task?>((ref) async {
  final session = ref.watch(activeTimerStreamProvider).valueOrNull;
  if (session == null) return null;
  final tasksDao = ref.watch(tasksDaoProvider);
  final taskRow = await tasksDao.getTaskById(session.taskId);
  if (taskRow == null) return null;
  return Task(
    id: taskRow.id,
    userId: taskRow.userId,
    labelId: taskRow.labelId,
    title: taskRow.title,
    description: taskRow.description,
    iconName: taskRow.iconName,
    imagePath: taskRow.imagePath,
    url: taskRow.url,
    category: taskRow.category,
    status: TaskStatus.fromString(taskRow.status),
    priority: TaskPriority.fromString(taskRow.priority),
    hasTimeTracking: taskRow.hasTimeTracking,
    estimatedMinutes: taskRow.estimatedMinutes,
    recurrenceRuleId: taskRow.recurrenceRuleId,
    scheduledDate: taskRow.scheduledDate,
    dueDate: taskRow.dueDate,
    isArchived: taskRow.isArchived,
    createdAt: taskRow.createdAt,
    updatedAt: taskRow.updatedAt,
    version: taskRow.version,
    isDeleted: taskRow.isDeleted,
  );
});

/// Formats a [Duration] into standard digital timer format (e.g. "00:24:15").
String formatDurationTimer(Duration duration) {
  final d = duration.isNegative ? Duration.zero : duration;
  final hours = d.inHours.toString().padLeft(2, '0');
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

/// Floating or fixed banner showing the user's currently active timer session.
///
/// Displays:
/// - Task title (or fallback indicator)
/// - Live ticking elapsed time ("00:24:15")
/// - Quick action buttons: Pause, Resume, Stop & Save
/// - Animated pulsing indicator when running
class ActiveTimerBanner extends ConsumerWidget {
  /// Whether the banner should float over the layout with an elevated drop-shadow.
  final bool isFloating;

  /// Optional custom callback when user taps on the banner.
  final VoidCallback? onTap;

  /// Optional callback after timer is stopped.
  final VoidCallback? onStopped;

  /// Optional padding around the banner.
  final EdgeInsetsGeometry? margin;

  const ActiveTimerBanner({
    super.key,
    this.isFloating = false,
    this.onTap,
    this.onStopped,
    this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSessionAsync = ref.watch(activeTimerStreamProvider);
    final activeSession = activeSessionAsync.valueOrNull;

    if (activeSession == null) {
      return const SizedBox.shrink();
    }

    final durationAsync = ref.watch(timerCurrentDurationProvider);
    final duration = durationAsync.valueOrNull ?? activeSession.currentElapsed;
    final taskAsync = ref.watch(activeTimerTaskProvider);
    final task = taskAsync.valueOrNull;

    final isRunning = activeSession.status == TimerSessionStatus.running;
    final isPaused = activeSession.status == TimerSessionStatus.paused;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bannerContent = Container(
      margin: margin ??
          (isFloating
              ? const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                )
              : EdgeInsets.zero),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? (isRunning
                ? AppColors.primaryContainerDark
                : AppColors.surfaceElevatedDark)
            : (isRunning
                ? AppColors.primaryContainerLight
                : AppColors.surfaceElevatedLight),
        borderRadius: isFloating ? AppRadius.borderLg : AppRadius.borderNone,
        border: Border.all(
          color: isRunning
              ? (isDark
                  ? AppColors.primaryLight.withAlpha(120)
                  : AppColors.primary.withAlpha(100))
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: 1.0,
        ),
        boxShadow: isFloating
            ? [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withAlpha(140)
                      : AppColors.primary.withAlpha(30),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: isFloating ? AppRadius.borderLg : AppRadius.borderNone,
          child: Row(
            children: [
              // ---------------------------------------------------------------
              // Status Indicator Dot / Icon
              // ---------------------------------------------------------------
              _TimerStatusIndicator(isRunning: isRunning, isPaused: isPaused),

              AppSpacing.hGapSm,

              // ---------------------------------------------------------------
              // Task Title & State Description
              // ---------------------------------------------------------------
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task?.title ?? 'Active Session',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      isRunning ? 'Tracking time' : 'Paused',
                      style: AppTypography.labelSmall.copyWith(
                        color: isRunning
                            ? (isDark
                                ? AppColors.primaryLight
                                : AppColors.primary)
                            : (isDark
                                ? AppColors.statusPending
                                : AppColors.onStatusPendingLight),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.hGapSm,

              // ---------------------------------------------------------------
              // Live Timer Monospace Digits
              // ---------------------------------------------------------------
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withAlpha(60)
                      : Colors.white.withAlpha(180),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Text(
                  formatDurationTimer(duration),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),

              AppSpacing.hGapSm,

              // ---------------------------------------------------------------
              // Controls: Pause / Resume / Stop
              // ---------------------------------------------------------------
              if (isRunning)
                IconButton(
                  icon: const Icon(Icons.pause_circle_filled_rounded),
                  iconSize: 28,
                  color: AppColors.statusPending,
                  tooltip: 'Pause Timer',
                  onPressed: () async {
                    await ref.read(timerControllerProvider.notifier).pause();
                  },
                )
              else if (isPaused)
                IconButton(
                  icon: const Icon(Icons.play_circle_fill_rounded),
                  iconSize: 28,
                  color: AppColors.statusDone,
                  tooltip: 'Resume Timer',
                  onPressed: () async {
                    await ref.read(timerControllerProvider.notifier).resume();
                  },
                ),

              IconButton(
                icon: const Icon(Icons.stop_circle_rounded),
                iconSize: 28,
                color: AppColors.error,
                tooltip: 'Stop & Save',
                onPressed: () async {
                  await ref.read(timerControllerProvider.notifier).stopAndSave();
                  onStopped?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );

    return isFloating ? SafeArea(child: bannerContent) : bannerContent;
  }
}

/// Compact pill widget representation of the active timer for sidebars, rails, or headers.
class ActiveTimerPill extends ConsumerWidget {
  final VoidCallback? onTap;

  const ActiveTimerPill({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSessionAsync = ref.watch(activeTimerStreamProvider);
    final activeSession = activeSessionAsync.valueOrNull;

    if (activeSession == null) {
      return const SizedBox.shrink();
    }

    final durationAsync = ref.watch(timerCurrentDurationProvider);
    final duration = durationAsync.valueOrNull ?? activeSession.currentElapsed;
    final taskAsync = ref.watch(activeTimerTaskProvider);
    final task = taskAsync.valueOrNull;

    final isRunning = activeSession.status == TimerSessionStatus.running;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? (isRunning
                ? AppColors.primaryContainerDark
                : AppColors.surfaceElevatedDark)
            : (isRunning
                ? AppColors.primaryContainerLight
                : AppColors.surfaceVariantLight),
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: isRunning
              ? (isDark ? AppColors.primaryLight : AppColors.primary)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs + 2,
            ),
            child: Row(
              children: [
                _TimerStatusIndicator(
                  isRunning: isRunning,
                  isPaused: !isRunning,
                  size: 8,
                ),
                AppSpacing.hGapXs,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        task?.title ?? 'Active Timer',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        formatDurationTimer(duration),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isRunning)
                  IconButton(
                    icon: const Icon(Icons.pause_rounded, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    tooltip: 'Pause',
                    onPressed: () {
                      ref.read(timerControllerProvider.notifier).pause();
                    },
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    tooltip: 'Resume',
                    onPressed: () {
                      ref.read(timerControllerProvider.notifier).resume();
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.stop_rounded, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  color: AppColors.error,
                  tooltip: 'Stop & Save',
                  onPressed: () {
                    ref.read(timerControllerProvider.notifier).stopAndSave();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerStatusIndicator extends StatefulWidget {
  final bool isRunning;
  final bool isPaused;
  final double size;

  const _TimerStatusIndicator({
    required this.isRunning,
    required this.isPaused,
    this.size = 10,
  });

  @override
  State<_TimerStatusIndicator> createState() => _TimerStatusIndicatorState();
}

class _TimerStatusIndicatorState extends State<_TimerStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.25).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    if (widget.isRunning) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _TimerStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !_animController.isAnimating) {
      _animController.repeat(reverse: true);
    } else if (!widget.isRunning && _animController.isAnimating) {
      _animController.stop();
      _animController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isRunning
        ? AppColors.statusDone
        : (widget.isPaused ? AppColors.statusPending : AppColors.statusSkipped);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = widget.isRunning ? _pulseAnimation.value : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: widget.isRunning
                  ? [
                      BoxShadow(
                        color: color.withAlpha(120),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      },
    );
  }
}
