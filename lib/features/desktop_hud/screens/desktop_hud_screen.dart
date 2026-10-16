import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/models.dart';
import '../../../shared/providers/database_provider.dart';
import '../../analytics/providers/analytics_providers.dart';
import '../../motivation/providers/motivation_providers.dart';
import '../../tasks/providers/task_providers.dart';

enum HudPosition {
  topRight,
  bottomRight,
  fullOverlay,
}

/// Interactive Desktop HUD screen inspired by Conky.
///
/// Overlays on top of the user's wallpaper with a translucent glassmorphic
/// backdrop, live digital clock, daily momentum streak, real-time KPI stats,
/// and an interactive task list allowing users to check off, toggle, and add
/// tasks in real time across Linux, macOS, Windows, and Web.
class DesktopHudScreen extends ConsumerStatefulWidget {
  const DesktopHudScreen({super.key});

  @override
  ConsumerState<DesktopHudScreen> createState() => _DesktopHudScreenState();
}

class _DesktopHudScreenState extends ConsumerState<DesktopHudScreen> {
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  HudPosition _position = HudPosition.topRight;
  double _opacity = 0.55;
  bool _isQuickAdding = false;
  final TextEditingController _quickAddController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _quickAddController.dispose();
    super.dispose();
  }

  Future<void> _handleQuickAddTask() async {
    final title = _quickAddController.text.trim();
    if (title.isEmpty) return;

    final userId = ref.read(currentUserIdProvider);
    final now = DateTime.now();

    final newTask = Task(
      id: 'task_${now.millisecondsSinceEpoch}',
      userId: userId,
      title: title,
      status: TaskStatus.pending,
      priority: TaskPriority.medium,
      scheduledDate: DateTime(now.year, now.month, now.day),
      createdAt: now,
      updatedAt: now,
    );

    await ref.read(taskRepositoryProvider).createTask(newTask);

    if (mounted) {
      _quickAddController.clear();
      setState(() => _isQuickAdding = false);
      context.showSnackBar('Task added to Today\'s HUD');
    }
  }

  Future<void> _toggleTaskStatus(Task task) async {
    final nextStatus =
        task.status == TaskStatus.done ? TaskStatus.pending : TaskStatus.done;
    await ref.read(taskRepositoryProvider).setTaskStatus(task.id, nextStatus);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats =
        ref.watch(dashboardStatsProvider).valueOrNull ?? const DashboardStats();
    final todayTasksAsync = ref.watch(todayTasksStreamProvider);
    final quoteAsync = ref.watch(currentQuoteProvider);
    final kpisAsync = ref.watch(allKpisStreamProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Semi-translucent interactive background layer
          GestureDetector(
            onTap: () {
              if (_isQuickAdding) {
                setState(() => _isQuickAdding = false);
              }
            },
            child: Container(
              color: Colors.black.withValues(alpha: 0.15),
            ),
          ),

          // 2. HUD Positioning Box
          Align(
            alignment: _getAlignmentForPosition(_position),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    width: math.min(
                      _position == HudPosition.fullOverlay ? 720.0 : 420.0,
                      MediaQuery.of(context).size.width - 32.0,
                    ),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.92,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: _opacity),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.15),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // HUD Header: Title & Window Controls
                        _buildHudHeader(context),
                        const Divider(height: 1, color: Colors.white24),

                        // Scrollable HUD Body
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Clock & Date Display (Conky Signature)
                                _buildClockDateSection(),
                                AppSpacing.vGapMd,

                                // Daily Progress & Streak Stats
                                _buildMomentumStreakSection(stats),
                                AppSpacing.vGapMd,

                                // Interactive Today's Tasks
                                _buildInteractiveTasksSection(
                                  todayTasksAsync,
                                  theme,
                                ),
                                AppSpacing.vGapMd,

                                // Creator Platform KPIs
                                _buildKpiSection(kpisAsync),
                                AppSpacing.vGapMd,

                                // Motivational Quote Citation
                                _buildQuoteSection(quoteAsync),
                              ],
                            ),
                          ),
                        ),

                        // HUD Bottom Bar: Opacity & Position Controls
                        const Divider(height: 1, color: Colors.white24),
                        _buildHudFooterControls(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Alignment _getAlignmentForPosition(HudPosition pos) {
    switch (pos) {
      case HudPosition.topRight:
        return Alignment.topRight;
      case HudPosition.bottomRight:
        return Alignment.bottomRight;
      case HudPosition.fullOverlay:
        return Alignment.center;
    }
  }

  Widget _buildHudHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'MOMENTUM HUD',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'CONKY MODE',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            tooltip: 'Exit HUD to Dashboard',
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClockDateSection() {
    final timeStr = DateFormat('HH:mm:ss').format(_now);
    final dateStr = DateFormat('EEEE, d MMMM y').format(_now).toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          timeStr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          dateStr,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildMomentumStreakSection(DashboardStats stats) {
    final percent = stats.scheduledTasks > 0
        ? (stats.completedTasks / stats.scheduledTasks).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      color: AppColors.statusCancelled, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${stats.streakDays}d Streak',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${stats.completedTasks}/${stats.scheduledTasks} (${(percent * 100).toInt()}%)',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveTasksSection(
    AsyncValue<List<Task>> todayTasksAsync,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      color: AppColors.secondary, size: 16),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'TODAY\'S TASKS (INTERACTIVE)',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              iconSize: 18,
              icon: Icon(
                _isQuickAdding ? Icons.close : Icons.add_circle_outline_rounded,
                color: AppColors.secondary,
              ),
              tooltip: 'Quick Add Task',
              onPressed: () =>
                  setState(() => _isQuickAdding = !_isQuickAdding),
            ),
          ],
        ),
        if (_isQuickAdding) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quickAddController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  onSubmitted: (_) => _handleQuickAddTask(),
                  decoration: InputDecoration(
                    hintText: 'Enter task title & press Enter...',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    filled: true,
                    fillColor: Colors.black45,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(color: AppColors.secondary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: AppColors.secondary,
                ),
                onPressed: _handleQuickAddTask,
                child: const Text('Add', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 4),
        todayTasksAsync.when(
          data: (tasks) {
            if (tasks.isEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                child: const Text(
                  'No tasks scheduled for today. Click + to add one.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              separatorBuilder: (context, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final task = tasks[index];
                final isDone = task.status == TaskStatus.done;

                return InkWell(
                  onTap: () => _toggleTaskStatus(task),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDone
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: isDone ? Colors.white10 : Colors.white24,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isDone
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          size: 18,
                          color:
                              isDone ? AppColors.secondary : Colors.white70,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              color: isDone ? Colors.white38 : Colors.white,
                              fontSize: 13,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (task.priority == TaskPriority.high ||
                            task.priority == TaskPriority.urgent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.statusCancelled
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'HIGH',
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.statusCancelled,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (e, _) => Text(
            'Error loading tasks: $e',
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiSection(AsyncValue<List<KpiDefinition>> kpisAsync) {
    return kpisAsync.when(
      data: (kpis) {
        if (kpis.isEmpty) return const SizedBox.shrink();

        final displayKpis = kpis.take(4).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PLATFORM TARGETS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: displayKpis.map((kpi) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up_rounded,
                          size: 13, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        '${kpi.name}: ${kpi.targetValue.toInt()} ${kpi.unit}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildQuoteSection(AsyncValue<dynamic> quoteAsync) {
    return quoteAsync.when(
      data: (quote) {
        if (quote == null) return const SizedBox.shrink();
        final text = quote.text?.toString() ?? '';
        final author = quote.author?.toString() ?? '';

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '“$text”',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  height: 1.3,
                ),
              ),
              if (author.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '— $author',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildHudFooterControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 6,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Position: ',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              DropdownButton<HudPosition>(
                value: _position,
                dropdownColor: const Color(0xFF0F172A),
                underline: const SizedBox.shrink(),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 18),
                style: const TextStyle(color: Colors.white, fontSize: 11),
                onChanged: (pos) {
                  if (pos != null) setState(() => _position = pos);
                },
                items: const [
                  DropdownMenuItem(
                    value: HudPosition.topRight,
                    child: Text('Top Right'),
                  ),
                  DropdownMenuItem(
                    value: HudPosition.bottomRight,
                    child: Text('Bottom Right'),
                  ),
                  DropdownMenuItem(
                    value: HudPosition.fullOverlay,
                    child: Text('Center Overlay'),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Glass: ',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              SizedBox(
                width: 70,
                child: SliderTheme(
                  data: const SliderThemeData(
                    thumbShape:
                        RoundSliderThumbShape(enabledThumbRadius: 6),
                    trackHeight: 2,
                    activeTrackColor: AppColors.secondary,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: AppColors.secondary,
                  ),
                  child: Slider(
                    value: _opacity,
                    min: 0.25,
                    max: 0.90,
                    onChanged: (val) => setState(() => _opacity = val),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
