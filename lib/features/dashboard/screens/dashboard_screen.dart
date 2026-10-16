import 'package:flutter/material.dart';
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
import '../../settings/providers/connected_accounts_provider.dart';
import '../../tasks/providers/task_providers.dart';
import '../../tasks/widgets/task_card.dart';

/// Central dashboard screen displaying modern user greeting header,
/// side-by-side hero gradient action cards, multi-gradient daily momentum card,
/// live creator cadence & KPI cards, pastel category squircle focus areas,
/// and today's task list.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  TaskStatus? _selectedStatusFilter;
  bool _isInitializingKpis = false;

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

  Color _getCategoryPastelColor(String name, bool isDark) {
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
    return isDark ? const Color(0xFF24223A) : const Color(0xFFF1F0F8);
  }

  Color _getCategoryAccentColor(String name) {
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
    final syncStatus = ref.watch(syncStatusStreamProvider).valueOrNull ??
        ref.watch(syncStatusProvider);

    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d').format(now);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
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
            ),

            const SizedBox(height: 18),

            // 2. Hero Feature Cards: "Create New Task" (Purple gradient) & "Start Focus Session" (Amber gradient)
            _buildHeroActionCards(context),

            const SizedBox(height: 18),

            // 3. Daily Progress Summary Card (Multi-gradient progress bar & streak)
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

            // 4. Motivational Quote Card
            quoteAsync.when(
              data: (quote) => quote != null
                  ? _buildQuoteCard(context, quote, isDark)
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 18),

            // 5. Creator Output & Platform Cadence (Live APIs & KPIs)
            allKpisAsync.when(
              data: (kpis) => _buildPlatformOutputSection(context, kpis, isDark),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),

            // 6. Focus Areas ("Browse Categories")
            _buildFocusAreasSection(
              context,
              isDark: isDark,
              rootLabelsAsync: rootLabelsAsync,
              allLabels: allLabels,
              allKpis: allKpisAsync.valueOrNull ?? [],
            ),

            const SizedBox(height: 24),

            // 7. Today's Tasks Section
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
        _buildCircularIconButton(
          context,
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notifications',
          isDark: isDark,
          onTap: () => context.push('/notifications'),
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
  // 2. HERO ACTION CARDS
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
  // 3. DAILY PROGRESS SUMMARY CARD
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF472B6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      size: 20,
                      color: Color(0xFFF472B6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Daily Momentum',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              // Streak Pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 12)),
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

          const SizedBox(height: 16),

          // Completion status & percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${stats.completedTasks} of ${stats.scheduledTasks} tasks done',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$percentage% Done',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Multi-gradient segmented progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 10,
              width: double.infinity,
              color:
                  isDark ? const Color(0xFF27243B) : const Color(0xFFF0EDF7),
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
  // 4. MOTIVATIONAL QUOTE CARD
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
  // 5. CREATOR OUTPUT & PLATFORM CADENCE
  // ===========================================================================
  Widget _buildPlatformOutputSection(
    BuildContext context,
    List<KpiDefinition> kpis,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    if (kpis.isEmpty) {
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
                    'Creator Cadence & Live APIs',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track YouTube videos, GitHub commits, Instagram reach, and career targets with live sync.',
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

    final connectedAccounts = ref.watch(connectedAccountsProvider);
    final activeAccounts =
        connectedAccounts.where((a) => a.isConnected).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt_rounded,
                    size: 20, color: Color(0xFFF59E0B)),
                const SizedBox(width: 6),
                Text(
                  'Creator Cadence & Live APIs',
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
        if (activeAccounts.isNotEmpty) ...[
          const SizedBox(height: 6),
          SizedBox(
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                          Icon(_platformIcon(acc.platform),
                              size: 14, color: color),
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
          ),
        ],
        const SizedBox(height: 10),
        SizedBox(
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
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
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
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  // ===========================================================================
  // 6. FOCUS AREAS ("Browse Categories")
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
    final pastelBg = _getCategoryPastelColor(label.name, isDark);
    final accentColor = _getCategoryAccentColor(label.name);

    return Container(
      width: 175,
      margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: pastelBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.3 : 0.2),
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
                        color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.8),
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
  // 7. TODAY'S TASKS SECTION
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
