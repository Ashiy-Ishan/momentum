import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/sync/sync_engine.dart';
import '../../features/desktop_hud/services/conky_service.dart';
import '../../features/desktop_hud/services/desktop_hud_launcher.dart';
import '../../features/notifications/providers/notification_history_provider.dart';
import '../../features/settings/providers/settings_providers.dart';
import 'active_timer_banner.dart';

/// Navigation item descriptor for Momentum app navigation.
class MomentumNavItem {
  final String label;
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final bool isPrimaryMobile;

  const MomentumNavItem({
    required this.label,
    required this.route,
    required this.icon,
    required this.activeIcon,
    this.isPrimaryMobile = false,
  });
}

/// The 7 official navigation routes for Momentum.
const List<MomentumNavItem> kMomentumNavItems = [
  MomentumNavItem(
    label: 'Dashboard',
    route: '/',
    icon: Icons.grid_view_outlined,
    activeIcon: Icons.grid_view_rounded,
    isPrimaryMobile: true,
  ),
  MomentumNavItem(
    label: "Today's Tasks",
    route: '/today',
    icon: Icons.today_outlined,
    activeIcon: Icons.today_rounded,
    isPrimaryMobile: true,
  ),
  MomentumNavItem(
    label: 'All Tasks',
    route: '/tasks',
    icon: Icons.task_alt_outlined,
    activeIcon: Icons.task_alt_rounded,
    isPrimaryMobile: true,
  ),
  MomentumNavItem(
    label: 'Labels & Projects',
    route: '/labels',
    icon: Icons.folder_outlined,
    activeIcon: Icons.folder_rounded,
    isPrimaryMobile: false,
  ),
  MomentumNavItem(
    label: 'Analytics & KPIs',
    route: '/analytics',
    icon: Icons.insights_outlined,
    activeIcon: Icons.insights_rounded,
    isPrimaryMobile: true,
  ),
  MomentumNavItem(
    label: 'Calendar & History',
    route: '/calendar',
    icon: Icons.calendar_month_outlined,
    activeIcon: Icons.calendar_month_rounded,
    isPrimaryMobile: false,
  ),
  MomentumNavItem(
    label: 'Settings',
    route: '/settings',
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
    isPrimaryMobile: true,
  ),
];

/// Primary responsive application layout for Momentum.
///
/// Responsive Breakpoints:
/// - Desktop (screenWidth >= 1024):
///   - Left Navigation Sidebar with Logo & Title
///   - 7 Navigation Items with active indicators
///   - Bottom Section with Active Timer Pill, Theme Mode Toggle, and Sync Status
/// - Mobile / Tablet (screenWidth < 1024):
///   - Top AppBar with Title, Search, and Quick Add Task actions
///   - Bottom Navigation Bar with 5 primary items (Dashboard, Today, Tasks, Analytics, Settings)
///   - Drawer with complete navigation list (including Labels and Calendar) + footer actions
///   - Floating Action Button to quickly add tasks
class AppScaffold extends ConsumerStatefulWidget {
  /// The main screen body content.
  final Widget body;

  /// Optional AppBar title string. Defaults to current screen name or 'Momentum'.
  final String? title;

  /// Optional custom title widget.
  final Widget? titleWidget;

  /// Custom quick action widgets in mobile AppBar or desktop header.
  final List<Widget>? actions;

  /// Explicit current path route (e.g. '/today'). If omitted, automatically
  /// resolved from [GoRouter].
  final String? currentPath;

  /// Custom navigation handler. If omitted, uses [GoRouter.go].
  final ValueChanged<String>? onNavigate;

  /// Callback when user taps the Add Task quick button.
  final VoidCallback? onAddTask;

  /// Callback when user taps the Search quick button.
  final VoidCallback? onSearch;

  /// Whether to display the Floating Action Button on mobile. Defaults to true.
  final bool showFab;

  /// Custom override for Floating Action Button.
  final Widget? floatingActionButton;

  /// Bottom sheet widget.
  final Widget? bottomSheet;

  /// Whether to embed the active timer banner at the bottom of the body.
  final bool showActiveTimerBanner;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.titleWidget,
    this.actions,
    this.currentPath,
    this.onNavigate,
    this.onAddTask,
    this.onSearch,
    this.showFab = true,
    this.floatingActionButton,
    this.bottomSheet,
    this.showActiveTimerBanner = true,
  });

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _resolveCurrentPath(BuildContext context) {
    if (widget.currentPath != null && widget.currentPath!.isNotEmpty) {
      return widget.currentPath!;
    }
    try {
      final location = GoRouterState.of(context).uri.path;
      if (location.isNotEmpty) return location;
    } catch (_) {}
    return '/';
  }

  void _handleNavigate(BuildContext context, String path) {
    // If mobile drawer is open, close it
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }

    if (widget.onNavigate != null) {
      widget.onNavigate!(path);
    } else {
      try {
        context.go(path);
      } catch (_) {
        GoRouter.maybeOf(context)?.go(path);
      }
    }
  }

  void _handleAddTask(BuildContext context) {
    if (widget.onAddTask != null) {
      widget.onAddTask!();
    } else {
      _handleNavigate(context, '/tasks/new');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.screenWidth;
    final isDesktop = screenWidth >= AppConstants.desktopBreakpoint;
    final currentPath = _resolveCurrentPath(context);

    if (isDesktop) {
      return _buildDesktopLayout(context, currentPath);
    }

    return _buildMobileLayout(context, currentPath);
  }

  // ===========================================================================
  // DESKTOP LAYOUT (screenWidth >= 1024)
  // ===========================================================================
  Widget _buildDesktopLayout(BuildContext context, String currentPath) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // -------------------------------------------------------------------
          // Left Navigation Sidebar
          // -------------------------------------------------------------------
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                right: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1.0,
                ),
              ),
            ),
            child: Column(
              children: [
                // 1. App Header: Logo & Title
                _buildSidebarHeader(isDark),

                const Divider(height: 1),

                // 2. Navigation Items List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.md,
                    ),
                    children: kMomentumNavItems.map((item) {
                      final isSelected = _isRouteSelected(item.route, currentPath);
                      return _SidebarNavItemTile(
                        item: item,
                        isSelected: isSelected,
                        onTap: () => _handleNavigate(context, item.route),
                      );
                    }).toList(),
                  ),
                ),

                const Divider(height: 1),

                // 3. Bottom Section: Active Timer Pill, Theme Toggle, Sync Status
                _buildSidebarFooter(context, isDark),
              ],
            ),
          ),

          // -------------------------------------------------------------------
          // Main Body Area
          // -------------------------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Desktop Header Bar (Search, Actions, Title)
                _buildDesktopTopBar(context, currentPath, isDark),

                const Divider(height: 1),

                // Body Content with optional inline active timer banner
                Expanded(
                  child: Stack(
                    children: [
                      widget.body,

                      // Floating active timer banner if enabled
                      if (widget.showActiveTimerBanner)
                        const Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: ActiveTimerBanner(
                            isFloating: true,
                            margin: EdgeInsets.all(AppSpacing.md),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: widget.bottomSheet,
    );
  }

  Future<void> _handleHudOption(String value) async {
    if (value == 'standalone') {
      final success = await DesktopHudLauncher.launchStandaloneHud();
      if (!mounted) return;
      if (!success) {
        unawaited(context.push('/hud'));
      } else {
        context.showSnackBar(
          'Desktop HUD launched! Remains on desktop when app minimizes.',
        );
      }
    } else if (value == 'conky') {
      final started = await ConkyService.startConky();
      if (!mounted) return;
      context.showSnackBar(
        started
            ? 'Native Conky daemon active on desktop background!'
            : 'Could not start Conky. Ensure /usr/bin/conky is installed.',
        isError: !started,
      );
    } else {
      if (mounted) {
        unawaited(context.push('/hud'));
      }
    }
  }

  Widget _buildSidebarHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
              borderRadius: AppRadius.borderMd,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1.0,
              ),
            ),
            child: Icon(
              Icons.bolt_rounded,
              color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
              size: 24,
            ),
          ),
          AppSpacing.hGapSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppConstants.appName,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Productivity & KPIs',
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.dashboard_customize_outlined, size: 20),
            tooltip: 'Desktop HUD (Conky Mode)',
            onSelected: (value) => unawaited(_handleHudOption(value)),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'standalone',
                child: Row(
                  children: [
                    Icon(Icons.open_in_new_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Launch Desktop HUD Window'),
                  ],
                ),
              ),
              if (Platform.isLinux)
                const PopupMenuItem(
                  value: 'conky',
                  child: Row(
                    children: [
                      Icon(Icons.desktop_windows_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Start Native Conky Daemon'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'preview',
                child: Row(
                  children: [
                    Icon(Icons.preview_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Preview Inside App'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarFooter(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active Timer Pill (shows when any timer session is active)
          ActiveTimerPill(
            onTap: () => _handleNavigate(context, '/tasks'),
          ),

          AppSpacing.vGapSm,

          // Theme Toggle & Sync Status Row
          const Row(
            children: [
              // Sync Status Indicator Button
              Expanded(child: _SyncStatusIndicator()),

              // Theme Mode Toggle Button
              _ThemeModeToggleButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTopBar(
    BuildContext context,
    String currentPath,
    bool isDark,
  ) {
    final titleText = widget.title ?? _resolveDefaultTitle(currentPath);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Row(
        children: [
          // Page Title
          if (widget.titleWidget != null)
            widget.titleWidget!
          else
            Text(
              titleText,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

          const Spacer(),

          // Search button
          if (widget.onSearch != null) ...[
            IconButton.outlined(
              icon: const Icon(Icons.search_rounded, size: 20),
              tooltip: 'Search (Ctrl+K)',
              onPressed: widget.onSearch,
            ),
            AppSpacing.hGapSm,
          ],

          // Notification Bell Button
          const _NotificationBellButton(),
          AppSpacing.hGapSm,

          // Quick Add Task Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 10,
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Task'),
            onPressed: () => _handleAddTask(context),
          ),

          if (widget.actions != null && widget.actions!.isNotEmpty) ...[
            AppSpacing.hGapSm,
            ...widget.actions!,
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // MOBILE / TABLET LAYOUT (screenWidth < 1024)
  // ===========================================================================
  Widget _buildMobileLayout(BuildContext context, String currentPath) {
    final titleText = widget.title ?? _resolveDefaultTitle(currentPath);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryMobileItems =
        kMomentumNavItems.where((item) => item.isPrimaryMobile).toList();

    final selectedBottomIndex = _resolveBottomNavIndex(
      currentPath,
      primaryMobileItems,
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: widget.titleWidget ??
            Text(
              titleText,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          tooltip: 'Open Menu',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          if (widget.onSearch != null)
            IconButton(
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Search',
              onPressed: widget.onSearch,
            ),
          const _NotificationBellButton(),
          IconButton(
            icon: const Icon(Icons.add_task_rounded),
            tooltip: 'Add Task',
            onPressed: () => _handleAddTask(context),
          ),
          if (widget.actions != null) ...widget.actions!,
        ],
      ),

      // Drawer for full navigation items & settings
      drawer: _buildMobileDrawer(context, currentPath, isDark),

      body: Column(
        children: [
          // Inline active timer banner when active
          if (widget.showActiveTimerBanner)
            ActiveTimerBanner(
              onTap: () => _handleNavigate(context, '/tasks'),
            ),

          Expanded(child: widget.body),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF16132A),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Theme(
              data: theme.copyWith(
                canvasColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: BottomNavigationBar(
                currentIndex: selectedBottomIndex,
                elevation: 0,
                backgroundColor: Colors.transparent,
                type: BottomNavigationBarType.fixed,
                selectedItemColor:
                    isDark ? AppColors.primaryLight : AppColors.primaryDark,
                unselectedItemColor: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
                selectedFontSize: 11,
                unselectedFontSize: 11,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
                onTap: (index) {
                  final target = primaryMobileItems[index];
                  _handleNavigate(context, target.route);
                },
                items: primaryMobileItems.map((item) {
                  final isSelected = _isRouteSelected(item.route, currentPath);
                  return BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Icon(isSelected ? item.activeIcon : item.icon, size: 22),
                    ),
                    label: item.label,
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButton: widget.floatingActionButton ??
          (widget.showFab
              ? FloatingActionButton(
                  heroTag: 'app_scaffold_fab',
                  onPressed: () => _handleAddTask(context),
                  tooltip: 'Add Task',
                  child: const Icon(Icons.add_rounded, size: 28),
                )
              : null),

      bottomSheet: widget.bottomSheet,
    );
  }

  Widget _buildMobileDrawer(
    BuildContext context,
    String currentPath,
    bool isDark,
  ) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildSidebarHeader(isDark),

            const Divider(height: 1),

            // All 7 Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                children: [
                  ...kMomentumNavItems.map((item) {
                    final isSelected = _isRouteSelected(item.route, currentPath);
                    return _SidebarNavItemTile(
                      item: item,
                      isSelected: isSelected,
                      onTap: () => _handleNavigate(context, item.route),
                    );
                  }),
                  const Divider(height: 16),
                  _DrawerNotificationTile(
                    isSelected: _isRouteSelected('/notifications', currentPath),
                    onTap: () => _handleNavigate(context, '/notifications'),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Footer
            _buildSidebarFooter(context, isDark),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // ROUTE HELPERS
  // ===========================================================================
  bool _isRouteSelected(String itemRoute, String currentPath) {
    if (itemRoute == '/') {
      return currentPath == '/' || currentPath.isEmpty;
    }
    return currentPath == itemRoute || currentPath.startsWith('$itemRoute/');
  }

  int _resolveBottomNavIndex(
    String currentPath,
    List<MomentumNavItem> items,
  ) {
    for (int i = 0; i < items.length; i++) {
      if (_isRouteSelected(items[i].route, currentPath)) {
        return i;
      }
    }
    return 0;
  }

  String _resolveDefaultTitle(String path) {
    for (final item in kMomentumNavItems) {
      if (_isRouteSelected(item.route, path)) {
        return item.label;
      }
    }
    return AppConstants.appName;
  }
}

// =============================================================================
// SIDEBAR NAV ITEM TILE
// =============================================================================

class _SidebarNavItemTile extends StatelessWidget {
  final MomentumNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarNavItemTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final selectedBg = isDark
        ? AppColors.primaryContainerDark
        : AppColors.primaryContainerLight;
    final selectedColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final unselectedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      child: Material(
        color: isSelected ? selectedBg : Colors.transparent,
        borderRadius: AppRadius.borderMd,
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          dense: true,
          shape: AppRadius.shapeMd,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 2.0,
          ),
          leading: Icon(
            isSelected ? item.activeIcon : item.icon,
            color: isSelected ? selectedColor : unselectedColor,
            size: 22,
          ),
          title: Text(
            item.label,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? selectedColor : colorScheme.onSurface,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

// =============================================================================
// SYNC STATUS INDICATOR
// =============================================================================

class _SyncStatusIndicator extends ConsumerWidget {
  const _SyncStatusIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatusAsync = ref.watch(syncStatusStreamProvider);
    final SyncEngineStatus status = syncStatusAsync.valueOrNull ??
        ref.watch(syncStatusProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData icon;
    Color color;
    String label;

    switch (status) {
      case SyncEngineStatus.idle:
        icon = Icons.cloud_done_rounded;
        color = AppColors.success;
        label = 'Up to date';
        break;
      case SyncEngineStatus.syncing:
        icon = Icons.sync_rounded;
        color = isDark ? AppColors.primaryLight : AppColors.primary;
        label = 'Syncing...';
        break;
      case SyncEngineStatus.offline:
        icon = Icons.cloud_off_rounded;
        color = isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
        label = 'Offline';
        break;
      case SyncEngineStatus.error:
        icon = Icons.sync_problem_rounded;
        color = AppColors.error;
        label = 'Sync error';
        break;
    }

    return Tooltip(
      message: 'Cloud Sync: $label (Tap to sync)',
      child: InkWell(
        onTap: () {
          ref.read(syncEngineProvider).triggerSync();
        },
        borderRadius: AppRadius.borderSm,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 6.0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (status == SyncEngineStatus.syncing)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              else
                Icon(icon, size: 16, color: color),
              AppSpacing.hGapXs,
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// THEME MODE TOGGLE BUTTON
// =============================================================================

class _ThemeModeToggleButton extends ConsumerWidget {
  const _ThemeModeToggleButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeModeProvider);

    IconData icon;
    String tooltip;

    switch (currentMode) {
      case ThemeMode.light:
        icon = Icons.light_mode_rounded;
        tooltip = 'Theme: Light (Tap to change)';
        break;
      case ThemeMode.dark:
        icon = Icons.dark_mode_rounded;
        tooltip = 'Theme: Dark (Tap to change)';
        break;
      case ThemeMode.system:
        icon = Icons.brightness_auto_rounded;
        tooltip = 'Theme: System (Tap to change)';
        break;
    }

    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: () {
          final next = switch (currentMode) {
            ThemeMode.system => ThemeMode.light,
            ThemeMode.light => ThemeMode.dark,
            ThemeMode.dark => ThemeMode.system,
          };
          ref.read(themeModeProvider.notifier).setThemeMode(next);
        },
      ),
    );
  }
}

class _NotificationBellButton extends ConsumerWidget {
  const _NotificationBellButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Tooltip(
      message: unreadCount > 0
          ? '$unreadCount unread notification${unreadCount > 1 ? "s" : ""}'
          : 'Notification History',
      child: IconButton(
        icon: Badge(
          isLabelVisible: unreadCount > 0,
          label: Text(
            unreadCount > 99 ? '99+' : unreadCount.toString(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.primary,
          textColor: Colors.black,
          child: const Icon(Icons.notifications_outlined, size: 22),
        ),
        onPressed: () {
          context.push('/notifications');
        },
      ),
    );
  }
}

class _DrawerNotificationTile extends ConsumerWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerNotificationTile({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        selected: isSelected,
        selectedTileColor: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        leading: Badge(
          isLabelVisible: unreadCount > 0,
          backgroundColor: AppColors.primary,
          textColor: Colors.black,
          label: Text(
            unreadCount.toString(),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          child: Icon(
            isSelected
                ? Icons.notifications_rounded
                : Icons.notifications_outlined,
            size: 20,
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight),
          ),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? theme.colorScheme.primary : null,
          ),
        ),
        trailing: unreadCount > 0
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unreadCount new',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

