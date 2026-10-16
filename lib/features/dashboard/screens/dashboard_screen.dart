import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../data/sync/sync_engine.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/models.dart';
import '../../../shared/providers/database_provider.dart';
import '../../analytics/providers/analytics_providers.dart';
import '../../labels/providers/label_providers.dart';
import '../../motivation/domain/motivation_quote.dart';
import '../../motivation/providers/motivation_providers.dart';
import '../../notifications/providers/notification_history_provider.dart';
import '../../settings/providers/connected_accounts_provider.dart';
import '../../tasks/providers/task_providers.dart';
import '../../tasks/widgets/task_card.dart';

/// Central dashboard screen displaying modern user greeting header,
/// interactive sync & system error alert banner, side-by-side hero gradient action cards,
/// multi-metric daily momentum card with circular ring + gradient progress,
/// total KPI executive overview & creator cadence, pastel category squircle focus areas,
/// and today's task list.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  TaskStatus? _selectedStatusFilter;
  String _kpiViewMode = 'all'; // 'all', 'output', 'audience'
  bool _isInitializingKpis = false;
  bool _isErrorDismissed = false;
  bool _isErrorExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoSeedKpisIfEmpty();
    });
  }

  Future<void> _autoSeedKpisIfEmpty() async {
    try {
      final userId = ref.read(currentUserIdProvider);
      final kpiRepo = ref.read(kpiRepositoryProvider);
      final existing = await kpiRepo.getAllKpis(userId);
      if (existing.isEmpty && mounted) {
        final labelRepo = ref.read(labelRepositoryProvider);
        await labelRepo.seedDefaultLabels(userId);
        final labels = await labelRepo.getAllLabels(userId);
        await kpiRepo.seedDefaultPlatformKpis(userId, labels);
      }
    } catch (_) {}
  }

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

  Color _getCategoryPastelColor(String name, Color accent, bool isDark) {
    final lower = name.toLowerCase();
    if (lower.contains('youtube')) {
      return isDark ? const Color(0xFF381F2B) : const Color(0xFFFEE2E2);
    } else if (lower.contains('social') || lower.contains('instagram')) {
      return isDark ? const Color(0xFF2D1D45) : const Color(0xFFF3E8FF);
    } else if (lower.contains('learn') ||
        lower.contains('dev') ||
        lower.contains('git')) {
      return isDark ? const Color(0xFF142B45) : const Color(0xFFE0F2FE);
    } else if (lower.contains('career') || lower.contains('work')) {
      return isDark ? const Color(0xFF3B2F18) : const Color(0xFFFEF3C7);
    }

    // Blend from accent color for custom user-created labels
    return isDark
        ? Color.alphaBlend(accent.withValues(alpha: 0.16), const Color(0xFF201D33))
        : Color.alphaBlend(accent.withValues(alpha: 0.10), Colors.white);
  }

  Color _getCategoryAccentColor(String name, String? hexColor) {
    if (hexColor != null && hexColor.isNotEmpty) {
      return _colorFromHex(hexColor, AppColors.primary);
    }
    final lower = name.toLowerCase();
    if (lower.contains('youtube')) {
      return const Color(0xFFEF4444);
    } else if (lower.contains('social') || lower.contains('instagram')) {
      return const Color(0xFFA855F7);
    } else if (lower.contains('learn') ||
        lower.contains('dev') ||
        lower.contains('git')) {
      return const Color(0xFF0284C7);
    } else if (lower.contains('career') || lower.contains('work')) {
      return const Color(0xFFD97706);
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final greeting = ref.watch(currentGreetingProvider);
    final userName = ref.watch(currentUserNameProvider);
    final quoteAsync = ref.watch(currentQuoteProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final todayTasksAsync = ref.watch(todayTasksStreamProvider);
    final rootLabelsAsync = ref.watch(rootLabelsStreamProvider);
    final allLabels = ref.watch(allLabelsStreamProvider).valueOrNull ?? [];
    final allKpisAsync = ref.watch(allKpisStreamProvider);
    final totalKpisAsync = ref.watch(totalKpiMetricsProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final syncStatus = ref.watch(syncStatusStreamProvider).valueOrNull ??
        ref.watch(syncStatusProvider);
    final syncError = ref.watch(syncLastErrorProvider);

    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d').format(now);

    final showSyncError = (syncStatus == SyncEngineStatus.error ||
            (syncError != null && syncError.isNotEmpty)) &&
        !_isErrorDismissed;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _isErrorDismissed = false;
          });
          ref.read(refreshQuoteProvider)();
          await ref.read(syncEngineProvider).triggerSync();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            // 1. Top Welcome Header with Circular Avatar, Greeting, Date, and Quick Actions
            _buildTopWelcomeHeader(
              context,
              isDark: isDark,
              greeting: greeting,
              userName: userName,
              formattedDate: formattedDate,
              syncStatus: syncStatus ?? SyncEngineStatus.offline,
              unreadCount: unreadCount,
            ),

            const SizedBox(height: 14),

            // 2. Interactive Sync & Operational Error Banner (shows errors on screen when they happen)
            if (showSyncError) ...[
              _buildSyncErrorBanner(
                context,
                error: syncError,
                isDark: isDark,
              ),
              const SizedBox(height: 14),
            ],

            // 3. Hero Feature Cards: "Create New Task" (Purple gradient) & "Start Focus Session" (Amber gradient)
            _buildHeroActionCards(context),

            const SizedBox(height: 18),

            // 4. Daily Progress Summary Card (Circular Indicator + Multi-gradient bar + Streak)
            statsAsync.when(
              data: (stats) => _buildProgressSummaryCard(context, stats, isDark),
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

            const SizedBox(height: 14),

            // 5. Motivational Quote Card
            quoteAsync.when(
              data: (quote) => quote != null
                  ? _buildQuoteCard(context, quote, isDark)
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 18),

            // 6. Creator Output & Total KPIs Overview (Live APIs & Metric Scorecard)
            allKpisAsync.when(
              data: (kpis) {
                final totals =
                    totalKpisAsync.valueOrNull ?? const TotalKpiMetrics();
                return _buildTotalKpisAndCadenceSection(
                  context,
                  kpis: kpis,
                  totals: totals,
                  isDark: isDark,
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),

            // 7. Focus Areas ("Browse Categories")
            _buildFocusAreasSection(
              context,
              isDark: isDark,
              rootLabelsAsync: rootLabelsAsync,
              allLabels: allLabels,
              allKpis: allKpisAsync.valueOrNull ?? [],
            ),

            const SizedBox(height: 24),

            // 8. Today's Tasks Section
            _buildTodayTasksSection(
              context,
              isDark: isDark,
              todayTasksAsync: todayTasksAsync,
              now: now,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: () => context.push('/tasks/new'),
        tooltip: 'Create Task',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  // ===========================================================================
  // 1. TOP WELCOME HEADER
  // ===========================================================================
  Widget _buildTopWelcomeHeader(
    BuildContext context, {
    required bool isDark,
    required String greeting,
    required String userName,
    required String formattedDate,
    required SyncEngineStatus syncStatus,
    int unreadCount = 0,
  }) {
    final theme = Theme.of(context);
    final initial =
        userName.trim().isNotEmpty ? userName.trim()[0].toUpperCase() : 'M';

    return Row(
      children: [
        // Circular Avatar with vibrant gradient ring
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Greeting and Date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      'Hi, $userName 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                formattedDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Quick Circular Action Buttons
        _buildCircularIconButton(
          context,
          icon: Icons.search_rounded,
          tooltip: 'Search Tasks',
          isDark: isDark,
          onTap: () => context.push('/tasks'),
        ),
        const SizedBox(width: 8),
        _buildCircularSyncButton(context, syncStatus, isDark),
        const SizedBox(width: 8),
        Badge(
          isLabelVisible: unreadCount > 0,
          label: Text(
            '$unreadCount',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFFEF4444),
          child: _buildCircularIconButton(
            context,
            icon: Icons.notifications_none_rounded,
            tooltip: unreadCount > 0
                ? 'Notifications ($unreadCount new)'
                : 'Notifications',
            isDark: isDark,
            onTap: () => context.push('/notifications'),
          ),
        ),
        const SizedBox(width: 8),
        _buildCircularIconButton(
          context,
          icon: Icons.settings_outlined,
          tooltip: 'Settings',
          isDark: isDark,
          onTap: () => context.push('/settings'),
        ),
      ],
    );
  }

  Widget _buildCircularIconButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required bool isDark,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isDark
            ? AppColors.surfaceVariantDark.withValues(alpha: 0.6)
            : AppColors.surfaceVariantLight.withValues(alpha: 0.8),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20,
              color: iconColor ??
                  (isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularSyncButton(
    BuildContext context,
    SyncEngineStatus status,
    bool isDark,
  ) {
    IconData icon;
    Color color;
    String tooltip;

    switch (status) {
      case SyncEngineStatus.syncing:
        return Container(
          width: 38,
          height: 38,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? AppColors.surfaceVariantDark.withValues(alpha: 0.6)
                : AppColors.surfaceVariantLight.withValues(alpha: 0.8),
          ),
          child: const CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncEngineStatus.idle:
        icon = Icons.cloud_done_rounded;
        color = AppColors.statusDone;
        tooltip = 'Synced with Cloud';
        break;
      case SyncEngineStatus.offline:
        icon = Icons.cloud_off_rounded;
        color = isDark ? Colors.white54 : Colors.black45;
        tooltip = 'Offline Mode';
        break;
      case SyncEngineStatus.error:
        icon = Icons.sync_problem_rounded;
        color = AppColors.error;
        tooltip = 'Sync Error';
        break;
    }

    return _buildCircularIconButton(
      context,
      icon: icon,
      tooltip: tooltip,
      isDark: isDark,
      iconColor: color,
      onTap: () async {
        await ref.read(syncEngineProvider).triggerSync();
      },
    );
  }

  // ===========================================================================
  // 2. ERROR BANNER (shows errors on screen when they happen)
  // ===========================================================================
  Widget _buildSyncErrorBanner(
    BuildContext context, {
    required String? error,
    required bool isDark,
  }) {
    final cleanError = error?.isNotEmpty == true
        ? error!
        : 'An error occurred during cloud synchronization. Check your internet connection or Supabase settings.';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3F1D1D) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.error.withValues(alpha: isDark ? 0.45 : 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Sync / System Notice',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.error,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 16),
                tooltip: 'Copy error message',
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: cleanError));
                  context.showSnackBar('Error message copied to clipboard');
                },
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 16),
                tooltip: 'Dismiss notice',
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  setState(() => _isErrorDismissed = true);
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            cleanError,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: isDark ? Colors.white70 : const Color(0xFF991B1B),
              height: 1.3,
            ),
            maxLines: _isErrorExpanded ? null : 3,
            overflow: _isErrorExpanded ? null : TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (cleanError.length > 80)
                TextButton(
                  style:
                      TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  onPressed: () =>
                      setState(() => _isErrorExpanded = !_isErrorExpanded),
                  child: Text(
                    _isErrorExpanded ? 'Show Less' : 'Show Details',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: AppColors.error.withValues(alpha: 0.18),
                  foregroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: const Text(
                  'Retry Sync',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  context.showSnackBar('Retrying synchronization...');
                  await ref.read(syncEngineProvider).triggerSync();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. HERO ACTION CARDS
  // ===========================================================================
  Widget _buildHeroActionCards(BuildContext context) {
    return Row(
      children: [
        // Left Card: "Create New Task" (Purple gradient)
        Expanded(
          child: _HeroActionCard(
            title: 'Create\nNew Task',
            subtitle: 'Schedule today',
            icon: Icons.add_task_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shadowColor: const Color(0xFF7C3AED).withValues(alpha: 0.35),
            onTap: () => context.push('/tasks/new'),
          ),
        ),
        const SizedBox(width: 14),

        // Right Card: "Start Focus Session" (Sunset Amber/Orange gradient)
        Expanded(
          child: _HeroActionCard(
            title: 'Start Focus\nSession',
            subtitle: 'Pomodoro timer',
            icon: Icons.timer_outlined,
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shadowColor: const Color(0xFFF97316).withValues(alpha: 0.35),
            onTap: () => context.push('/tasks'),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 4. DAILY PROGRESS SUMMARY CARD (Circular Ring + Multi-gradient + Streak)
  // ===========================================================================
  Widget _buildProgressSummaryCard(
    BuildContext context,
    DashboardStats stats,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final percentage = (stats.completionRate * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.borderDark
              : AppColors.borderLight.withValues(alpha: 0.8),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Circular Indicator + Title & Streak
          Row(
            children: [
              // Circular Progress Ring (preserves previous version function)
              SizedBox(
                width: 58,
                height: 58,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: stats.scheduledTasks > 0
                          ? stats.completionRate.clamp(0.0, 1.0)
                          : 0.0,
                      strokeWidth: 5.5,
                      backgroundColor: isDark
                          ? const Color(0xFF27243B)
                          : const Color(0xFFF0EDF7),
                      color: percentage == 100
                          ? AppColors.statusDone
                          : const Color(0xFF7C3AED),
                    ),
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Title and Summary Details
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
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        // Streak Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥',
                                  style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                '${stats.streakDays}d streak',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${stats.completedTasks} completed of ${stats.scheduledTasks} planned',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Multi-gradient segmented progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 8,
              width: double.infinity,
              color: isDark ? const Color(0xFF27243B) : const Color(0xFFF0EDF7),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: stats.scheduledTasks > 0
                    ? stats.completionRate.clamp(0.0, 1.0)
                    : 0.0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFF472B6), // Soft Pink
                        Color(0xFFFB923C), // Sunset Orange
                        Color(0xFF38BDF8), // Bright Sky
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 3 Bottom Stats Badges
          Row(
            children: [
              Expanded(
                child: _buildProgressStatBadge(
                  label: 'Completed',
                  value: '${stats.completedTasks}',
                  color: const Color(0xFF10B981),
                  bgColor: const Color(0xFF10B981).withValues(alpha: 0.12),
                  icon: Icons.check_circle_rounded,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildProgressStatBadge(
                  label: 'Remaining',
                  value: '${stats.remainingTasks}',
                  color: const Color(0xFFF59E0B),
                  bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  icon: Icons.hourglass_top_rounded,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildProgressStatBadge(
                  label: 'Scheduled',
                  value: '${stats.scheduledTasks}',
                  color: const Color(0xFF7C3AED),
                  bgColor: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                  icon: Icons.assignment_outlined,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStatBadge({
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. MOTIVATIONAL QUOTE CARD
  // ===========================================================================
  Widget _buildQuoteCard(
    BuildContext context,
    MotivationQuote quote,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceVariantDark.withValues(alpha: 0.4)
            : const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.format_quote_rounded,
              color: Color(0xFF7C3AED),
              size: 20,
            ),
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
                    color: const Color(0xFF7C3AED),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 18),
            tooltip: 'New quote',
            visualDensity: VisualDensity.compact,
            onPressed: () {
              ref.read(refreshQuoteProvider)();
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. CREATOR OUTPUT & TOTAL KPIS CADENCE
  // ===========================================================================
  Widget _buildTotalKpisAndCadenceSection(
    BuildContext context, {
    required List<KpiDefinition> kpis,
    required TotalKpiMetrics totals,
    required bool isDark,
  }) {
    if (kpis.isEmpty) {
      return _buildEmptyKpiPrompt(context, isDark: isDark);
    }

    final theme = Theme.of(context);
    final connectedAccounts = ref.watch(connectedAccountsProvider);
    final activeAccounts =
        connectedAccounts.where((a) => a.isConnected).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header with Velocity Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.insights_rounded,
                    size: 20, color: Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                Text(
                  'Creator Cadence & Total KPIs',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (activeAccounts.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.sync_rounded, size: 16),
                    tooltip: 'Sync all connected accounts with API',
                    visualDensity: VisualDensity.compact,
                    onPressed: () async {
                      context.showSnackBar(
                          'Syncing creator accounts with live APIs...');
                      await ref
                          .read(connectedAccountsProvider.notifier)
                          .syncAllAccounts();
                      if (context.mounted) {
                        context.showSnackBar('Accounts and KPIs updated!');
                      }
                    },
                  ),
                TextButton.icon(
                  onPressed: () => context.push('/settings'),
                  icon: const Icon(Icons.link, size: 14),
                  label: Text(
                    activeAccounts.isEmpty
                        ? 'Connect'
                        : '${activeAccounts.length} Connected',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 10),

        // 2. Executive Total KPI Overview Card
        _buildTotalKpiScorecardCard(context, totals: totals, isDark: isDark),

        const SizedBox(height: 14),

        // 3. Quick Output Logging Action Bar
        _buildQuickLogOutputBar(context, isDark: isDark),

        if (activeAccounts.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildConnectedAccountsStrip(context, activeAccounts, isDark: isDark),
        ],

        const SizedBox(height: 14),

        // 4. Individual Platform KPI Breakdown Carousel Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Platform Targets Breakdown',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            Text(
              '${kpis.length} tracked',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildIndividualKpiCarousel(context, kpis: kpis, isDark: isDark),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildEmptyKpiPrompt(BuildContext context, {required bool isDark}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Color(0xFF7C3AED),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Creator Cadence & Total KPIs',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track total video output, weekly posts, blog publishing, and subscriber & follower milestones across platforms.',
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
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _isInitializingKpis
                ? null
                : () async {
                    setState(() => _isInitializingKpis = true);
                    try {
                      final userId = ref.read(currentUserIdProvider);
                      final labelRepo = ref.read(labelRepositoryProvider);
                      final kpiRepo = ref.read(kpiRepositoryProvider);

                      await labelRepo.seedDefaultLabels(userId);
                      final currentLabels =
                          await labelRepo.getAllLabels(userId);

                      await kpiRepo.seedDefaultPlatformKpis(
                        userId,
                        currentLabels,
                      );

                      if (context.mounted) {
                        context.showSnackBar(
                          'Platform creator KPIs initialized successfully!',
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        context.showSnackBar(
                          'Failed to initialize KPIs: $e',
                          isError: true,
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isInitializingKpis = false);
                      }
                    }
                  },
            child: _isInitializingKpis
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Initialize'),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // EXECUTIVE TOTAL KPI SCORECARD
  // ===========================================================================
  Widget _buildTotalKpiScorecardCard(
    BuildContext context, {
    required TotalKpiMetrics totals,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final velocityPercent = (totals.overallCompletionRate * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.borderDark
              : AppColors.borderLight.withValues(alpha: 0.9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Velocity & On-Track Summary Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Executive KPI Scorecard',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${totals.achievedCount} of ${totals.totalKpisCount} targets met • $velocityPercent% overall velocity',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt,
                        size: 14, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text(
                      '$velocityPercent% Active',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Total Velocity Progress Indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: totals.overallCompletionRate.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: isDark
                  ? const Color(0xFF1E283D)
                  : const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF10B981), // Auroral Jade
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Category Mode Filter Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildKpiFilterChip(
                  label: 'All Totals',
                  selected: _kpiViewMode == 'all',
                  onTap: () => setState(() => _kpiViewMode = 'all'),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildKpiFilterChip(
                  label: 'Video & Content',
                  selected: _kpiViewMode == 'output',
                  onTap: () => setState(() => _kpiViewMode = 'output'),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildKpiFilterChip(
                  label: 'Audience Reach',
                  selected: _kpiViewMode == 'audience',
                  onTap: () => setState(() => _kpiViewMode = 'audience'),
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 4 Executive Hero Metrics
          if (_kpiViewMode == 'all' || _kpiViewMode == 'output') ...[
            Row(
              children: [
                // 1. Weekly Video Generation Total
                Expanded(
                  child: _buildMetricTile(
                    title: 'Video Output',
                    primaryValue:
                        '${totals.totalVideosCurrent.toInt()} / ${totals.totalVideosTarget.toInt()} videos',
                    subValue:
                        '${totals.totalShortsCurrent.toInt()}/${totals.totalShortsTarget.toInt()} shorts',
                    milestone: totals.totalVideosLongTerm != null
                        ? 'Goal: ${totals.totalVideosLongTerm!.toInt()}'
                        : null,
                    progress: totals.totalVideosTarget > 0
                        ? (totals.totalVideosCurrent /
                                totals.totalVideosTarget)
                            .clamp(0.0, 1.0)
                        : 0.0,
                    accentColor: const Color(0xFFFF0033),
                    icon: Icons.play_circle_filled_rounded,
                    isDark: isDark,
                    onQuickAdd: () => _incrementKpiByCategory(
                      'video_generation',
                      'videos',
                      1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // 2. Weekly Post Publication Total
                Expanded(
                  child: _buildMetricTile(
                    title: 'Weekly Posts',
                    primaryValue:
                        '${totals.totalPostsCurrent.toInt()} / ${totals.totalPostsTarget.toInt()} posts',
                    subValue: 'Instagram & LinkedIn',
                    milestone: totals.totalPostsLongTerm != null
                        ? 'Goal: ${totals.totalPostsLongTerm!.toInt()}'
                        : null,
                    progress: totals.totalPostsTarget > 0
                        ? (totals.totalPostsCurrent /
                                totals.totalPostsTarget)
                            .clamp(0.0, 1.0)
                        : 0.0,
                    accentColor: const Color(0xFFE1306C),
                    icon: Icons.camera_alt_rounded,
                    isDark: isDark,
                    onQuickAdd: () => _incrementKpiByCategory(
                      'post_publication',
                      'posts',
                      1.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          if (_kpiViewMode == 'all' || _kpiViewMode == 'output') ...[
            // 3. Blog & Articles Total
            _buildMetricTile(
              title: 'Blog Publishing & Code Velocity',
              primaryValue:
                  '${totals.totalArticlesCurrent.toInt()} / ${totals.totalArticlesTarget.toInt()} articles published',
              subValue:
                  '${totals.totalCommitsCurrent.toInt()} weekly commits & pull requests shipped',
              milestone: totals.totalArticlesLongTerm != null
                  ? 'Goal: ${totals.totalArticlesLongTerm!.toInt()} articles'
                  : null,
              progress: totals.totalArticlesTarget > 0
                  ? (totals.totalArticlesCurrent / totals.totalArticlesTarget)
                      .clamp(0.0, 1.0)
                  : 0.0,
              accentColor: const Color(0xFFF97316),
              icon: Icons.article_rounded,
              isDark: isDark,
              onQuickAdd: () => _incrementKpiByCategory(
                'blog_publication',
                'articles',
                1.0,
              ),
            ),
            const SizedBox(height: 10),
          ],

          if (_kpiViewMode == 'all' || _kpiViewMode == 'audience') ...[
            // 4. Combined Audience & Community Reach
            _buildAudienceMetricCard(
              totals: totals,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKpiFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF7C3AED)
              : (isDark
                  ? AppColors.surfaceVariantDark.withValues(alpha: 0.6)
                  : AppColors.surfaceVariantLight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFF7C3AED)
                : (isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight.withValues(alpha: 0.8)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: selected
                ? Colors.white
                : (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String primaryValue,
    required String subValue,
    required String? milestone,
    required double progress,
    required Color accentColor,
    required IconData icon,
    required bool isDark,
    required VoidCallback onQuickAdd,
  }) {
    final isMet = progress >= 1.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Color.alphaBlend(
                accentColor.withValues(alpha: 0.08),
                const Color(0xFF101625),
              )
            : Color.alphaBlend(
                accentColor.withValues(alpha: 0.05),
                Colors.white,
              ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isMet
              ? AppColors.statusDone.withValues(alpha: 0.5)
              : accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: isMet ? 1.4 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 14, color: accentColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onQuickAdd,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 11, color: accentColor),
                      Text(
                        '1',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            primaryValue,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  subValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              if (milestone != null) ...[
                const SizedBox(width: 4),
                Text(
                  milestone,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.primaryLight
                        : AppColors.primaryDark,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: isDark
                  ? const Color(0xFF1E283D)
                  : const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(
                isMet ? AppColors.statusDone : accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudienceMetricCard({
    required TotalKpiMetrics totals,
    required bool isDark,
  }) {
    const audienceColor = Color(0xFF06B6D4); // Electric Cyan
    final longTermPercent = (totals.audienceLongTermProgress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Color.alphaBlend(
                audienceColor.withValues(alpha: 0.08),
                const Color(0xFF101625),
              )
            : Color.alphaBlend(
                audienceColor.withValues(alpha: 0.05),
                Colors.white,
              ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: audienceColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: audienceColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      size: 15,
                      color: audienceColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'TOTAL AUDIENCE & COMMUNITY REACH',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: audienceColor,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              Text(
                'Milestone: ${_formatMetric(totals.totalAudienceLongTermTarget)} ($longTermPercent%)',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatMetric(totals.totalAudienceCurrent)} Subscribers & Followers',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Target: ${_formatMetric(totals.totalAudienceShortTermTarget)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: totals.audienceShortTermProgress,
              minHeight: 5,
              backgroundColor: isDark
                  ? const Color(0xFF1E283D)
                  : const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(audienceColor),
            ),
          ),
          const SizedBox(height: 10),
          // Platform Breakdown Pill Wrap
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: totals.audienceMetrics.map((item) {
              final color = AppColors.forPlatform(item.platform);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_platformIcon(item.platform), size: 11, color: color),
                    const SizedBox(width: 4),
                    Text(
                      '${item.platform.toUpperCase()}: ${_formatMetric(item.currentValue)} ${item.unit}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // QUICK-LOG OUTPUT BAR
  // ===========================================================================
  Widget _buildQuickLogOutputBar(BuildContext context, {required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceVariantDark.withValues(alpha: 0.5)
            : AppColors.surfaceVariantLight.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? AppColors.borderDark
              : AppColors.borderLight.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.flash_on_rounded,
              size: 16, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          const Text(
            'Quick Log:',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickLogButton(
                    label: '+1 Video',
                    color: const Color(0xFFFF0033),
                    onTap: () => _incrementKpiByCategory(
                      'video_generation',
                      'videos',
                      1.0,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _buildQuickLogButton(
                    label: '+1 Short',
                    color: const Color(0xFFFF0033),
                    onTap: () => _incrementKpiByCategory(
                      'video_generation',
                      'shorts',
                      1.0,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _buildQuickLogButton(
                    label: '+1 Post',
                    color: const Color(0xFFE1306C),
                    onTap: () => _incrementKpiByCategory(
                      'post_publication',
                      'posts',
                      1.0,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _buildQuickLogButton(
                    label: '+1 Article',
                    color: const Color(0xFFF97316),
                    onTap: () => _incrementKpiByCategory(
                      'blog_publication',
                      'articles',
                      1.0,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _buildQuickLogButton(
                    label: '+1 Commit',
                    color: const Color(0xFF2EA043),
                    onTap: () => _incrementKpiByCategory(
                      'output',
                      'commits',
                      1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLogButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildConnectedAccountsStrip(
    BuildContext context,
    List<ConnectedAccount> activeAccounts, {
    required bool isDark,
  }) {
    return SizedBox(
      height: 34,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: activeAccounts.length,
        itemBuilder: (context, idx) {
          final acc = activeAccounts[idx];
          final color = AppColors.forPlatform(acc.platform);
          return InkWell(
            onTap: () => context.push('/settings'),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (acc.avatarUrl != null && acc.avatarUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        acc.avatarUrl!,
                        width: 16,
                        height: 16,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(_platformIcon(acc.platform),
                                size: 14, color: color),
                      ),
                    )
                  else
                    Icon(_platformIcon(acc.platform), size: 14, color: color),
                  const SizedBox(width: 6),
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
                      '• ${_formatMetric(acc.metricCount!)} ${acc.metricUnit}'
                      '${acc.publicRepos != null ? " • ${acc.publicRepos} repos" : ""}',
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildIndividualKpiCarousel(
    BuildContext context, {
    required List<KpiDefinition> kpis,
    required bool isDark,
  }) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
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
            margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isMet
                    ? AppColors.statusDone.withValues(alpha: 0.5)
                    : (isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight.withValues(alpha: 0.8)),
                width: isMet ? 1.4 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
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
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: platformColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _platformIcon(kpi.platform),
                            size: 14,
                            color: platformColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          kpi.platform.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: platformColor,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => _showEditKpiDialog(context, kpi),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: (isDark
                                      ? AppColors.surfaceVariantDark
                                      : AppColors.surfaceVariantLight)
                                  .withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(6),
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
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: platformColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
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
                    Expanded(
                      child: Text(
                        isMilestone
                            ? '${_formatMetric(kpi.currentValue)} / ${_formatMetric(kpi.targetValue)} ${kpi.unit}'
                            : '${kpi.currentValue.toInt()} / ${kpi.targetValue.toInt()} ${kpi.unit}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    if (kpi.hasLongTermTarget) ...[
                      const SizedBox(width: 4),
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
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
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
    );
  }

  Future<void> _incrementKpiByCategory(
      String category, String unitKeyword, double delta) async {
    final kpis = ref.read(allKpisStreamProvider).valueOrNull ?? [];
    if (kpis.isEmpty) return;

    KpiDefinition? target;
    for (final k in kpis) {
      if (k.metricCategory.toLowerCase() == category.toLowerCase() &&
          k.unit.toLowerCase().contains(unitKeyword.toLowerCase())) {
        target = k;
        break;
      }
    }
    target ??= kpis.cast<KpiDefinition?>().firstWhere(
          (k) => k?.metricCategory.toLowerCase() == category.toLowerCase(),
          orElse: () => null,
        );
    target ??= kpis.cast<KpiDefinition?>().firstWhere(
          (k) =>
              k?.unit.toLowerCase().contains(unitKeyword.toLowerCase()) ??
              false,
          orElse: () => null,
        );
    target ??= kpis.first;

    await ref
        .read(kpiRepositoryProvider)
        .incrementCurrentValue(target.id, delta);
    if (mounted) {
      context.showSnackBar(
        'Logged +${delta.toInt()} ${target.unit} for ${target.name}!',
      );
    }
  }

  // ===========================================================================
  // 7. FOCUS AREAS ("Browse Categories")
  // ===========================================================================
  Widget _buildFocusAreasSection(
    BuildContext context, {
    required bool isDark,
    required AsyncValue<List<Label>> rootLabelsAsync,
    required List<Label> allLabels,
    required List<KpiDefinition> allKpis,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.category_rounded,
                    size: 18, color: Color(0xFF7C3AED)),
                const SizedBox(width: 6),
                Text(
                  'Focus Areas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              icon: const Icon(Icons.tune, size: 14),
              label: const Text('Manage', style: TextStyle(fontSize: 12)),
              onPressed: () => context.push('/labels'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        rootLabelsAsync.when(
          data: (labels) {
            if (labels.isEmpty) {
              return _buildEmptyFocusAreas(context);
            }
            return SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: labels.length,
                itemBuilder: (context, index) {
                  final label = labels[index];
                  final childCount =
                      allLabels.where((l) => l.parentId == label.id).length;
                  final matchingKpis = allKpis.where((k) {
                    if (k.labelId == label.id) return true;
                    final lname = label.name.toLowerCase();
                    if (lname.contains('youtube') &&
                        k.platform.toLowerCase() == 'youtube') {
                      return true;
                    }
                    if ((lname.contains('social') ||
                            lname.contains('instagram')) &&
                        (k.platform.toLowerCase() == 'instagram' ||
                            k.platform.toLowerCase() == 'social')) {
                      return true;
                    }
                    if (lname.contains('learning') &&
                        k.platform.toLowerCase() == 'github') {
                      return true;
                    }
                    if (lname.contains('career') &&
                        k.platform.toLowerCase() == 'linkedin') {
                      return true;
                    }
                    return false;
                  }).toList();

                  return _buildPastelCategoryCard(
                    context,
                    label: label,
                    subLabelCount: childCount,
                    matchingKpis: matchingKpis,
                    isDark: isDark,
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
      ],
    );
  }

  Widget _buildPastelCategoryCard(
    BuildContext context, {
    required Label label,
    required int subLabelCount,
    required List<KpiDefinition> matchingKpis,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final accentColor = _getCategoryAccentColor(label.name, label.color);
    final pastelBg = _getCategoryPastelColor(label.name, accentColor, isDark);

    return Container(
      width: 175,
      margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: pastelBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.35 : 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => context.push('/labels/parent/${label.id}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withValues(alpha: isDark ? 0.15 : 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        AppIcons.fromName(label.iconName),
                        color: accentColor,
                        size: 20,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: accentColor.withValues(alpha: 0.7),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (matchingKpis.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              matchingKpis.first.metricCategory ==
                                      'subscriber_growth'
                                  ? '${_formatMetric(matchingKpis.first.currentValue)} ${matchingKpis.first.unit}'
                                  : '${matchingKpis.first.currentValue.toInt()}/${matchingKpis.first.targetValue.toInt()} ${matchingKpis.first.unit}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            matchingKpis.first.targetValue > 0
                                ? '${((matchingKpis.first.currentValue / matchingKpis.first.targetValue).clamp(0.0, 1.0) * 100).toInt()}%'
                                : '0%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: matchingKpis.first.targetValue > 0
                              ? (matchingKpis.first.currentValue /
                                      matchingKpis.first.targetValue)
                                  .clamp(0.0, 1.0)
                              : 0.0,
                          minHeight: 4,
                          backgroundColor:
                              accentColor.withValues(alpha: 0.18),
                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                        ),
                      ),
                    ] else ...[
                      Text(
                        '$subLabelCount sub-labels',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Seed Default Focus Areas (YouTube, Learning, etc.)'),
        onPressed: () {
          ref.read(labelControllerProvider.notifier).seedDefaultLabels();
        },
      ),
    );
  }

  // ===========================================================================
  // 8. TODAY'S TASKS SECTION
  // ===========================================================================
  Widget _buildTodayTasksSection(
    BuildContext context, {
    required bool isDark,
    required AsyncValue<List<Task>> todayTasksAsync,
    required DateTime now,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.today_rounded,
                    size: 20, color: Color(0xFF7C3AED)),
                const SizedBox(width: 8),
                Text(
                  "Today's Tasks",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 8),
                todayTasksAsync.maybeWhen(
                  data: (tasks) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${tasks.where((t) => t.status == TaskStatus.done).length}/${tasks.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Quick Add', style: TextStyle(fontSize: 12)),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => context.push('/tasks/new'),
            ),
          ],
        ),

        // Status Filter Chips
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedStatusFilter == null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (_) =>
                      setState(() => _selectedStatusFilter = null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Pending'),
                  selected: _selectedStatusFilter == TaskStatus.pending,
                  avatar: const Icon(Icons.hourglass_empty, size: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (_) => setState(
                      () => _selectedStatusFilter = TaskStatus.pending),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Doing'),
                  selected: _selectedStatusFilter == TaskStatus.doing,
                  avatar: const Icon(Icons.play_arrow, size: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (_) =>
                      setState(() => _selectedStatusFilter = TaskStatus.doing),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Done'),
                  selected: _selectedStatusFilter == TaskStatus.done,
                  avatar: const Icon(Icons.check, size: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (_) =>
                      setState(() => _selectedStatusFilter = TaskStatus.done),
                ),
              ],
            ),
          ),
        ),

        // Tasks list
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
    final currentCtrl = TextEditingController(
      text: kpi.currentValue.toInt().toString(),
    );
    final targetCtrl = TextEditingController(
      text: kpi.targetValue.toInt().toString(),
    );
    final longTermCtrl = TextEditingController(
      text: kpi.longTermTarget?.toInt().toString() ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${kpi.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Value (${kpi.unit}):',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: currentCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  suffixText: kpi.unit,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Period Target (${kpi.period.displayName}):',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: targetCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  suffixText: kpi.unit,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Long-Term Milestone Goal:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: longTermCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'e.g. 10000',
                  suffixText: kpi.unit,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
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
              final currentVal = double.tryParse(currentCtrl.text.trim()) ??
                  kpi.currentValue;
              final targetVal = double.tryParse(targetCtrl.text.trim()) ??
                  kpi.targetValue;
              final longTermVal =
                  double.tryParse(longTermCtrl.text.trim()) ?? kpi.longTermTarget;

              final updated = kpi.copyWith(
                currentValue: currentVal,
                targetValue: targetVal,
                longTermTarget: longTermVal,
                updatedAt: DateTime.now(),
              );

              await ref.read(kpiRepositoryProvider).updateKpi(updated);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save Changes'),
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

// =============================================================================
// HERO ACTION CARD WIDGET
// =============================================================================
class _HeroActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final Color shadowColor;
  final VoidCallback onTap;

  const _HeroActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 20),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 18,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        height: 1.15,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
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
}
