import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/services/platform_sync_service.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/remote/supabase_client.dart';
import '../../../data/sync/sync_engine.dart';
import '../../../domain/models/models.dart';
import '../../../shared/providers/database_provider.dart';
import '../../analytics/providers/analytics_providers.dart';
import '../../desktop_hud/services/conky_service.dart';
import '../../desktop_hud/services/desktop_hud_launcher.dart';
import '../../labels/providers/label_providers.dart';
import '../../linux_wallpaper/services/linux_wallpaper_service.dart';
import '../../tasks/providers/task_providers.dart';
import '../providers/connected_accounts_provider.dart';
import '../providers/settings_providers.dart';

/// Application settings screen covering Appearance theming, Notifications & Active hours,
/// Linux Desktop dynamic wallpaper dashboard, Supabase cloud sync & auth, and JSON Data backup.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Linux Wallpaper State
  late final LinuxWallpaperService _wallpaperService;
  bool _isLinuxSupported = false;

  // Supabase Auth & Config State
  final TextEditingController _supabaseUrlController = TextEditingController();
  final TextEditingController _supabaseKeyController = TextEditingController();
  final TextEditingController _authEmailController = TextEditingController();
  final TextEditingController _authPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();

  bool _isAuthLoading = false;
  bool _isUrlObscured = true;
  bool _isKeyObscured = true;
  bool _showPlainUrlInSummary = false;
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _isTestingConnection = false;
  bool _isSavingCredentials = false;
  bool _isPurgingData = false;
  bool _isDeletingAccount = false;
  bool _isManualSyncing = false;
  int _authTabIndex = 0; // 0: Sign In, 1: Create Account
  bool _showCredentialsConfig = false;

  // Desktop HUD & Conky State
  bool _isConkyInstalled = false;
  bool _isConkyRunning = false;
  bool _isLaunchingHud = false;

  @override
  void initState() {
    super.initState();
    _wallpaperService = LinuxWallpaperService();
    _isLinuxSupported = Platform.isLinux;
    unawaited(_checkConkyStatus());
    _loadSavedSupabaseCredentials();
  }

  Future<void> _checkConkyStatus() async {
    if (Platform.isLinux) {
      final installed = await ConkyService.isConkyInstalled();
      final running = await ConkyService.isConkyRunning();
      if (mounted) {
        setState(() {
          _isConkyInstalled = installed;
          _isConkyRunning = running;
        });
      }
    }
  }

  Future<void> _handleLaunchStandaloneHud() async {
    setState(() => _isLaunchingHud = true);
    final success = await DesktopHudLauncher.launchStandaloneHud();
    if (!mounted) return;
    setState(() => _isLaunchingHud = false);
    if (success) {
      context.showSnackBar(
        'Interactive Desktop HUD launched! Stays on your desktop wallpaper when app is minimized.',
      );
    } else {
      context.showSnackBar('Opening in-app HUD overlay...');
      unawaited(context.push('/hud'));
    }
  }

  Future<void> _handleToggleConky() async {
    if (_isConkyRunning) {
      final stopped = await ConkyService.stopConky();
      if (mounted) {
        setState(() => _isConkyRunning = !stopped);
        context.showSnackBar('Native Conky daemon stopped.');
      }
    } else {
      final tasks = ref.read(todayTasksStreamProvider).valueOrNull ?? [];
      final kpis =
          await ref.read(kpiRepositoryProvider).getAllKpis('local-user');
      final stats = ref.read(dashboardStatsProvider).valueOrNull ??
          const DashboardStats();
      await ConkyService.updateConkyData(
        streakDays: stats.streakDays,
        completionRate: stats.completionRate,
        tasks: tasks,
        kpis: kpis,
      );
      final started = await ConkyService.startConky();
      if (mounted) {
        setState(() => _isConkyRunning = started);
        context.showSnackBar(
          started
              ? 'Native Conky daemon active on desktop background!'
              : 'Could not start Conky daemon.',
          isError: !started,
        );
      }
    }
  }

  Future<void> _handleExportConkyConfig() async {
    final file = await ConkyService.ensureConfigFileExists(overwrite: true);
    if (mounted) {
      context.showSnackBar('Conky configuration written to ${file.path}');
    }
  }

  Future<void> _loadSavedSupabaseCredentials() async {
    final creds = await MomentumSupabaseClient.instance.getSavedCredentials();
    final url = creds['url'] ??
        (AppConstants.defaultSupabaseUrl.isNotEmpty
            ? AppConstants.defaultSupabaseUrl
            : null);
    final key = creds['anonKey'] ??
        (AppConstants.defaultSupabaseAnonKey.isNotEmpty
            ? AppConstants.defaultSupabaseAnonKey
            : null);
    if (mounted) {
      setState(() {
        if (url != null && url.isNotEmpty) {
          _supabaseUrlController.text = url;
        }
        if (key != null && key.isNotEmpty) {
          _supabaseKeyController.text = key;
        }
      });
    }
  }

  @override
  void dispose() {
    _wallpaperService.dispose();
    _supabaseUrlController.dispose();
    _supabaseKeyController.dispose();
    _authEmailController.dispose();
    _authPasswordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _restoreOriginalWallpaper() async {
    final success = await _wallpaperService.restoreOriginalWallpaper();
    if (mounted) {
      context.showSnackBar(
        success
            ? 'Original wallpaper restored.'
            : 'No previous wallpaper recorded.',
      );
    }
  }

  // --- Backup & Export ---
  Future<void> _exportBackup() async {
    final allTasks = ref.read(allTasksStreamProvider).valueOrNull ?? [];
    final allLabels = ref.read(allLabelsStreamProvider).valueOrNull ?? [];
    final allKpis =
        await ref.read(kpiRepositoryProvider).getAllKpis('local-user');

    final backup = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'tasks': allTasks.map((t) => t.toMap()).toList(),
      'labels': allLabels.map((l) => l.toMap()).toList(),
      'kpis': allKpis.map((k) => k.toMap()).toList(),
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(backup);

    if (mounted) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Export JSON Backup'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Backup generated successfully with all tasks, focus areas, and KPI definitions.',
                    style: TextStyle(fontSize: 13),
                  ),
                  AppSpacing.vGapSm,
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: SelectableText(
                      jsonStr,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy to Clipboard'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonStr));
                Navigator.of(ctx).pop();
                context.showSnackBar('Backup copied to clipboard');
              },
            ),
          ],
        ),
      );
    }
  }

  Future<void> _importBackupDialog() async {
    final textCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import JSON Backup'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Paste your JSON backup data below to restore your tasks, labels, and KPI metrics.',
                style: TextStyle(fontSize: 13),
              ),
              AppSpacing.vGapSm,
              TextField(
                controller: textCtrl,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: '{\n  "version": 1,\n  "tasks": [...]\n}',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
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
              final raw = textCtrl.text.trim();
              if (raw.isEmpty) return;

              try {
                final map = jsonDecode(raw) as Map<String, dynamic>;
                final tasksList = (map['tasks'] as List<dynamic>?) ?? [];
                final labelsList = (map['labels'] as List<dynamic>?) ?? [];

                final taskController =
                    ref.read(taskControllerProvider.notifier);
                final labelController =
                    ref.read(labelControllerProvider.notifier);

                for (final l in labelsList) {
                  final label = Label.fromMap(l as Map<String, dynamic>);
                  await labelController.createLabel(label);
                }

                for (final t in tasksList) {
                  final task = Task.fromMap(t as Map<String, dynamic>);
                  await taskController.createTask(task);
                }

                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                }
                if (!mounted) return;
                context.showSnackBar(
                  'Backup restored: ${tasksList.length} tasks, ${labelsList.length} labels.',
                );
              } catch (e) {
                if (!mounted) return;
                context.showSnackBar('Failed to parse backup JSON: $e',
                    isError: true);
              }
            },
            child: const Text('Restore Backup'),
          ),
        ],
      ),
    );
  }

  void _clearCacheSafely() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cache Safely?'),
        content: const Text(
          'This will purge completed offline synchronization items and temporary assets. Your tasks, labels, and settings will remain safe.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final db = ref.read(appDatabaseProvider);
              await db.syncDao.clearCompleted();
              if (mounted) {
                context.showSnackBar('Cache cleaned successfully');
              }
            },
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final notifSettings = ref.watch(notificationSettingsProvider);
    final notifNotifier = ref.read(notificationSettingsProvider.notifier);
    final syncStatus = ref.watch(syncStatusStreamProvider).valueOrNull ??
        ref.watch(syncStatusProvider);
    final supabase = ref.watch(supabaseClientProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Section 1: User Account & Authentication (Placed at the top)
          _buildAccountSection(context, theme, supabase, syncStatus),
          AppSpacing.vGapLg,

          // Section 2: Appearance
          _buildSectionHeader('Appearance', Icons.palette_outlined),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme Mode',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.vGapSm,
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('Light'),
                          icon: Icon(Icons.light_mode_outlined),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('Dark'),
                          icon: Icon(Icons.dark_mode_outlined),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('System'),
                          icon: Icon(Icons.brightness_auto_outlined),
                        ),
                      ],
                      selected: {themeMode},
                      onSelectionChanged: (set) {
                        ref
                            .read(themeModeProvider.notifier)
                            .setThemeMode(set.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.vGapLg,

          // Section 2: Notifications & Reminders
          _buildSectionHeader(
              'Notifications & Reminders', Icons.notifications_outlined),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Hourly Reminders'),
                  subtitle: const Text('Subtle nudge during active work hours'),
                  value: notifSettings.hourlyRemindersEnabled,
                  onChanged: (val) => notifNotifier.toggleHourlyReminders(val),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Active Work Hours'),
                  subtitle: Text(
                    '${notifSettings.activeHoursStart} — ${notifSettings.activeHoursEnd}',
                  ),
                  trailing: TextButton(
                    child: const Text('Change'),
                    onPressed: () async {
                      final start = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 9, minute: 0),
                      );
                      if (start != null && context.mounted) {
                        final end = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 18, minute: 0),
                        );
                        if (end != null) {
                          final startStr =
                              '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
                          final endStr =
                              '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
                          await notifNotifier.setActiveHours(startStr, endStr);
                        }
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Quiet Hours (Do Not Disturb)'),
                  subtitle: Text(
                    'Mute all alerts between ${notifSettings.quietStart} and ${notifSettings.quietEnd}',
                  ),
                  value: notifSettings.quietHoursEnabled,
                  onChanged: (val) => notifNotifier.toggleQuietHours(val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Daily Summary Report'),
                  subtitle: Text(
                    'Recap of day progress at ${notifSettings.dailyReportTime}',
                  ),
                  value: notifSettings.dailyReportEnabled,
                  onChanged: (val) => notifNotifier.toggleDailyReport(val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Motivational Messages'),
                  subtitle: const Text(
                    'Inspiring quotes and encouraging completion messages',
                  ),
                  value: notifSettings.motivationEnabled,
                  onChanged: (val) => notifNotifier.toggleMotivation(val),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history_toggle_off_rounded),
                  title: const Text('Notification History'),
                  subtitle:
                      const Text('View and manage past alerts, reminders, and daily summaries'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/notifications'),
                ),
              ],
            ),
          ),
          AppSpacing.vGapLg,

          // Section 3: Connected Creator & Social Accounts
          _buildConnectedAccountsSection(context),

          // Section 4: Interactive Desktop HUD (Conky Mode)
          _buildSectionHeader(
            'Interactive Desktop HUD (Conky Mode)',
            Icons.dashboard_customize_outlined,
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt_rounded,
                                size: 14, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(
                              _isConkyInstalled
                                  ? 'Native Conky & Desktop Overlay Ready'
                                  : 'Cross-Platform Conky HUD Ready',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isConkyRunning) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.statusDone.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: AppColors.statusDone.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Text(
                            'Conky Active',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.statusDone,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  AppSpacing.vGapSm,
                  Text(
                    'Experience an autonomous Conky-style HUD widget directly over your desktop wallpaper. '
                    'Unlike normal in-app screens, it runs independently and stays visible on your desktop even when Momentum is minimized. '
                    'Includes live digital clock, daily streak counter, real-time KPI targets, and interactive task checkboxes.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  AppSpacing.vGapMd,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        icon: _isLaunchingHud
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.open_in_new_rounded, size: 18),
                        label: Text(
                          _isLaunchingHud
                              ? 'Launching...'
                              : 'Launch Interactive Desktop HUD',
                        ),
                        onPressed: _isLaunchingHud
                            ? null
                            : _handleLaunchStandaloneHud,
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.preview_rounded, size: 18),
                        label: const Text('Preview Inside App'),
                        onPressed: () => context.push('/hud'),
                      ),
                      if (_isLinuxSupported && _isConkyInstalled) ...[
                        FilledButton.tonalIcon(
                          icon: Icon(
                            _isConkyRunning
                                ? Icons.stop_rounded
                                : Icons.play_arrow_rounded,
                            size: 18,
                          ),
                          label: Text(
                            _isConkyRunning
                                ? 'Stop Native Conky'
                                : 'Start Native Conky Daemon',
                          ),
                          onPressed: _handleToggleConky,
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.tune_rounded, size: 16),
                          label: const Text('Export Conky Config'),
                          onPressed: _handleExportConkyConfig,
                        ),
                      ],
                      if (_isLinuxSupported) ...[
                        OutlinedButton(
                          onPressed: _restoreOriginalWallpaper,
                          child: const Text('Restore Original Wallpaper'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.vGapLg,

          // Section 4: Cloud Sync (Supabase)
          _buildSectionHeader('Cloud Sync & Storage', Icons.cloud_outlined),
          _buildSupabaseSection(theme, syncStatus, supabase),
          AppSpacing.vGapLg,

          // Section 5: Data & Backup
          _buildSectionHeader('Data & Local Storage', Icons.storage_outlined),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: const Text('Export JSON Backup'),
                  subtitle: const Text('Export all tasks, categories, and metrics'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _exportBackup,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_upload_outlined),
                  title: const Text('Import Backup'),
                  subtitle: const Text('Restore from existing JSON backup data'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _importBackupDialog,
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      const Icon(Icons.cleaning_services_outlined, color: AppColors.error),
                  title: const Text('Clear Cache Safely',
                      style: TextStyle(color: AppColors.error)),
                  subtitle:
                      const Text('Clears completed sync queue items and cache'),
                  onTap: _clearCacheSafely,
                ),
              ],
            ),
          ),
          AppSpacing.vGapXxl,
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedAccountsSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accounts = ref.watch(connectedAccountsProvider);
    final anyConnected = accounts.any((a) => a.isConnected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader(
              'Connected Creator & Social Accounts',
              Icons.hub_outlined,
            ),
            if (anyConnected)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton.icon(
                  onPressed: () async {
                    context.showSnackBar('Syncing all connected accounts...');
                    await ref
                        .read(connectedAccountsProvider.notifier)
                        .syncAllAccounts();
                    if (context.mounted) {
                      context.showSnackBar('All accounts synced successfully.');
                    }
                  },
                  icon: const Icon(Icons.sync_rounded, size: 14),
                  label: const Text('Sync All', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
          ],
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Link your developer and creator handles to automatically fetch real followers, repos, stars, and organization members across your Momentum dashboard and KPIs.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                AppSpacing.vGapMd,
                ...accounts.map((acc) {
                  final brandColor = AppColors.forPlatform(acc.platform);
                  final isConnected = acc.isConnected;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceVariantDark.withValues(alpha: 0.3)
                          : AppColors.surfaceVariantLight.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: isConnected
                            ? brandColor.withValues(alpha: 0.4)
                            : (isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (acc.avatarUrl != null && acc.avatarUrl!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  acc.avatarUrl!,
                                  width: 28,
                                  height: 28,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: brandColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      _platformIcon(acc.platform),
                                      size: 16,
                                      color: brandColor,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: brandColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  _platformIcon(acc.platform),
                                  size: 16,
                                  color: brandColor,
                                ),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        acc.platformDisplayName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      if (isConnected) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppColors.statusDone
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Connected',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.statusDone,
                                            ),
                                          ),
                                        ),
                                      ],
                                      if (acc.hasAuthToken) ...[
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Token Authorized',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isConnected
                                        ? '${acc.handle}${acc.displayName != null && acc.displayName != acc.handle ? " (${acc.displayName})" : ""}'
                                        : 'Not connected yet',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isConnected
                                          ? (isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondaryLight)
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isConnected) ...[
                              if (acc.isSyncing)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              else
                                IconButton(
                                  icon: const Icon(Icons.sync_rounded, size: 16),
                                  tooltip: 'Sync now with API',
                                  onPressed: () async {
                                    context.showSnackBar(
                                        'Syncing ${acc.platformDisplayName}...');
                                    final res = await ref
                                        .read(connectedAccountsProvider.notifier)
                                        .syncAccount(acc.platform);
                                    if (context.mounted) {
                                      if (res.success) {
                                        context.showSnackBar(
                                            'Synced: ${res.metricCount?.toInt()} ${res.metricUnit}');
                                      } else {
                                        context.showSnackBar(
                                            res.errorMessage ?? 'Sync failed',
                                            isError: true);
                                      }
                                    }
                                  },
                                ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                tooltip: 'Edit details & authorization',
                                onPressed: () =>
                                    _showConnectAccountDialog(context, acc),
                              ),
                              IconButton(
                                icon: const Icon(Icons.link_off_rounded,
                                    size: 16, color: AppColors.statusCancelled),
                                tooltip: 'Disconnect',
                                onPressed: () async {
                                  await ref
                                      .read(connectedAccountsProvider.notifier)
                                      .disconnectAccount(acc.platform);
                                  if (context.mounted) {
                                    context.showSnackBar(
                                        'Disconnected ${acc.platformDisplayName}');
                                  }
                                },
                              ),
                            ] else ...[
                              FilledButton.tonal(
                                onPressed: () =>
                                    _showConnectAccountDialog(context, acc),
                                style: FilledButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                ),
                                child: const Text('Connect',
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ],
                        ),
                        if (isConnected && acc.metricCount != null) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _buildMetricChip(
                                icon: Icons.people_outline,
                                label:
                                    '${acc.metricCount!.toInt()} ${acc.metricUnit ?? "followers"}',
                                color: brandColor,
                              ),
                              if (acc.publicRepos != null)
                                _buildMetricChip(
                                  icon: Icons.source_outlined,
                                  label: '${acc.publicRepos} public repos',
                                  color: AppColors.primary,
                                ),
                              if (acc.totalStars != null && acc.totalStars! > 0)
                                _buildMetricChip(
                                  icon: Icons.star_border_rounded,
                                  label: '${acc.totalStars} stars',
                                  color: Colors.amber,
                                ),
                              if (acc.membersCount != null &&
                                  acc.membersCount! > 0)
                                _buildMetricChip(
                                  icon: Icons.groups_outlined,
                                  label: '${acc.membersCount} members',
                                  color: AppColors.secondary,
                                ),
                              if (acc.lastUpdatedAt != null)
                                Text(
                                  'Synced ${AppDateUtils.formatRelativeDate(acc.lastUpdatedAt!)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                            ],
                          ),
                        ],
                        if (acc.syncError != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.statusCancelled
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 13,
                                    color: AppColors.statusCancelled),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    acc.syncError!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.statusCancelled,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        AppSpacing.vGapLg,
      ],
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showConnectAccountDialog(
      BuildContext context, ConnectedAccount acc) async {
    final handleCtrl = TextEditingController(text: acc.handle);
    final urlCtrl = TextEditingController(text: acc.profileUrl);
    final tokenCtrl = TextEditingController(text: acc.authToken ?? '');
    final countCtrl = TextEditingController(
      text: acc.metricCount != null ? acc.metricCount!.toInt().toString() : '',
    );

    bool isTesting = false;
    PlatformSyncResult? testResult;
    String? testError;
    final showTokenField = acc.platform.toLowerCase() == 'github';
    bool hideToken = true;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final brandColor = AppColors.forPlatform(acc.platform);

          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  _platformIcon(acc.platform),
                  color: brandColor,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text('Connect ${acc.platformDisplayName}'),
              ],
            ),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: brandColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                            color: brandColor.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 15, color: brandColor),
                              const SizedBox(width: 6),
                              Text(
                                'Automatic Metric Synchronization',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: brandColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            acc.platform.toLowerCase() == 'github'
                                ? '• Public Sync: No login needed! Enter your GitHub username or organization to automatically fetch followers, public repos, and members.\n• Optional Token: Add a GitHub Personal Access Token to access private repos, private teams, and avoid rate limits.'
                                : 'Enter your handle to link your profile and track consistency across your Momentum dashboard.',
                            style: const TextStyle(fontSize: 11, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: handleCtrl,
                      onChanged: (val) {
                        if (urlCtrl.text.isEmpty ||
                            urlCtrl.text.startsWith('https://github.com/')) {
                          final clean = PlatformSyncService.extractCleanHandle(
                              val, acc.platform);
                          if (acc.platform.toLowerCase() == 'github') {
                            urlCtrl.text = clean.isNotEmpty
                                ? 'https://github.com/$clean'
                                : '';
                          }
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Username or Handle',
                        hintText: acc.platform == 'github'
                            ? 'e.g. torvalds or my-organization'
                            : (acc.platform == 'linkedin'
                                ? 'e.g. in/satyanadella'
                                : '@channel_handle'),
                        prefixIcon:
                            const Icon(Icons.alternate_email, size: 18),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: urlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Profile or Website URL',
                        hintText: 'https://...',
                        prefixIcon: Icon(Icons.link, size: 18),
                      ),
                    ),
                    if (showTokenField) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: tokenCtrl,
                        obscureText: hideToken,
                        decoration: InputDecoration(
                          labelText: 'GitHub Token / PAT (Optional)',
                          hintText: 'ghp_...',
                          prefixIcon: const Icon(Icons.key_outlined, size: 18),
                          suffixIcon: IconButton(
                            icon: Icon(hideToken
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () => setDialogState(
                                () => hideToken = !hideToken),
                          ),
                          helperText:
                              'Optional: Increases rate limit from 60 to 5,000/hr & reads private org members.',
                          helperMaxLines: 2,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: countCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText:
                                  'Audience / ${acc.metricUnit ?? "Count"}',
                              hintText: 'Auto-fetched via API',
                              prefixIcon:
                                  const Icon(Icons.people_outline, size: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonalIcon(
                          onPressed: isTesting
                              ? null
                              : () async {
                                  final handle = handleCtrl.text.trim();
                                  if (handle.isEmpty) {
                                    setDialogState(() {
                                      testError = 'Please enter a username.';
                                      testResult = null;
                                    });
                                    return;
                                  }

                                  setDialogState(() {
                                    isTesting = true;
                                    testError = null;
                                    testResult = null;
                                  });

                                  final syncService =
                                      ref.read(platformSyncServiceProvider);
                                  final res = await syncService.syncAccount(
                                    platform: acc.platform,
                                    rawHandle: handle,
                                    authToken: tokenCtrl.text.trim(),
                                  );

                                  setDialogState(() {
                                    isTesting = false;
                                    if (res.success) {
                                      testResult = res;
                                      testError = null;
                                      if (res.metricCount != null) {
                                        countCtrl.text = res.metricCount!
                                            .toInt()
                                            .toString();
                                      }
                                      if (acc.platform.toLowerCase() ==
                                              'github' &&
                                          urlCtrl.text.isEmpty) {
                                        urlCtrl.text =
                                            'https://github.com/${res.handle}';
                                      }
                                    } else {
                                      testError = res.errorMessage;
                                      testResult = null;
                                    }
                                  });
                                },
                          icon: isTesting
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Icon(Icons.cloud_sync_outlined, size: 16),
                          label: const Text('Fetch Live',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    if (testResult != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.statusDone.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color:
                                AppColors.statusDone.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            if (testResult!.avatarUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  testResult!.avatarUrl!,
                                  width: 32,
                                  height: 32,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.check_circle,
                                      color: AppColors.statusDone,
                                      size: 24),
                                ),
                              )
                            else
                              const Icon(Icons.check_circle,
                                  color: AppColors.statusDone, size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${testResult!.displayName ?? testResult!.handle} verified!',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.statusDone,
                                    ),
                                  ),
                                  Text(
                                    '• ${testResult!.metricCount?.toInt()} ${testResult!.metricUnit}'
                                    '${testResult!.additionalStats["public_repos"] != null ? " • ${testResult!.additionalStats['public_repos']} repos" : ""}'
                                    '${testResult!.additionalStats["stars"] != null && (testResult!.additionalStats["stars"] as num) > 0 ? " • ${testResult!.additionalStats['stars']} stars" : ""}'
                                    '${testResult!.additionalStats["members"] != null && (testResult!.additionalStats["members"] as num) > 0 ? " • ${testResult!.additionalStats['members']} members" : ""}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (testError != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.statusCancelled
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: AppColors.statusCancelled
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AppColors.statusCancelled, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                testError!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.statusCancelled,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final handle = handleCtrl.text.trim();
                  if (handle.isEmpty) {
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                    }
                    return;
                  }
                  final url = urlCtrl.text.trim();
                  final count = double.tryParse(countCtrl.text.trim());
                  final token = tokenCtrl.text.trim();

                  await ref.read(connectedAccountsProvider.notifier).saveAccount(
                        platform: acc.platform,
                        handle: handle,
                        profileUrl: url,
                        authToken: token.isNotEmpty ? token : null,
                        metricCount: count,
                        autoSync: true,
                      );

                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                    context.showSnackBar(
                        'Saved & Synced ${acc.platformDisplayName} account');
                  }
                },
                child: const Text('Save & Sync'),
              ),
            ],
          );
        },
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
        return Icons.link_rounded;
    }
  }

  // ===========================================================================
  // USER ACCOUNT & SUPABASE HELPERS
  // ===========================================================================

  Widget _buildAccountSection(
    BuildContext context,
    ThemeData theme,
    MomentumSupabaseClient supabase,
    SyncEngineStatus? syncStatus,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('User Account', Icons.account_circle_outlined),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: supabase.isAuthenticated
                ? _buildAuthenticatedUserProfile(
                    context,
                    supabase,
                    syncStatus,
                    theme,
                  )
                : _buildAuthSection(theme, supabase),
          ),
        ),
      ],
    );
  }

  String _maskUrl(String url) {
    if (url.isEmpty) return 'Configured Cloud Database';
    final uri = Uri.tryParse(url);
    if (uri != null && uri.host.isNotEmpty) {
      final hostParts = uri.host.split('.');
      if (hostParts.length >= 2) {
        final subdomain = hostParts.first;
        final maskedPrefix =
            subdomain.length > 4 ? subdomain.substring(0, 3) : '';
        final maskedSub = '$maskedPrefix••••••••';
        final remaining = hostParts.sublist(1).join('.');
        final port = uri.hasPort ? ':${uri.port}' : '';
        return '${uri.scheme}://$maskedSub.$remaining$port';
      }
    }
    return url.length > 8 ? '${url.substring(0, 8)}••••••••' : '••••••••';
  }

  Widget _buildSupabaseSection(
    ThemeData theme,
    SyncEngineStatus? syncStatus,
    MomentumSupabaseClient supabase,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Title & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Supabase Cloud Database',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: supabase.isConfigured
                        ? (syncStatus == SyncEngineStatus.syncing
                            ? AppColors.statusDoing.withValues(alpha: 0.15)
                            : AppColors.statusDone.withValues(alpha: 0.15))
                        : Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        !supabase.isConfigured
                            ? Icons.cloud_off
                            : syncStatus == SyncEngineStatus.syncing
                                ? Icons.sync
                                : Icons.cloud_done,
                        size: 13,
                        color: !supabase.isConfigured
                            ? theme.hintColor
                            : syncStatus == SyncEngineStatus.syncing
                                ? theme.colorScheme.primary
                                : AppColors.statusDone,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        !supabase.isConfigured
                            ? 'Not Configured'
                            : (syncStatus ?? SyncEngineStatus.idle).displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: !supabase.isConfigured
                            ? theme.hintColor
                            : syncStatus == SyncEngineStatus.syncing
                                ? theme.colorScheme.primary
                                : AppColors.statusDone,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.vGapMd,

            // If Supabase is not configured, show Quick Setup Tips & Credential Inputs
            if (!supabase.isConfigured) ...[
              _buildSupabaseSetupTips(theme),
              AppSpacing.vGapMd,
              _buildSupabaseCredentialsInputs(theme),
            ] else ...[
              // Already configured: summary & toggle to edit credentials
              _buildConfiguredSummary(theme),
              if (_showCredentialsConfig) ...[
                AppSpacing.vGapMd,
                _buildSupabaseCredentialsInputs(theme),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSupabaseSetupTips(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline,
                  size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Quick Supabase Setup Guide',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '1. Create a free project at supabase.com.\n'
            '2. Open your project and navigate to Project Settings > API.\n'
            '3. Copy the Project URL (e.g. https://xyz.supabase.co).\n'
            '4. Copy the anon (public) key and paste both below.\n'
            '5. Click "Test Connection" to verify, then "Save Credentials".',
            style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildConfiguredSummary(ThemeData theme) {
    final url = _supabaseUrlController.text.trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: AppColors.secondary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Connected to Project',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _showPlainUrlInSummary
                            ? (url.isNotEmpty
                                ? url
                                : 'Configured Supabase Backend')
                            : _maskUrl(url),
                        style: TextStyle(fontSize: 11, color: theme.hintColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        setState(() {
                          _showPlainUrlInSummary = !_showPlainUrlInSummary;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          _showPlainUrlInSummary
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 13,
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            onPressed: () {
              setState(() => _showCredentialsConfig = !_showCredentialsConfig);
            },
            child: Text(
              _showCredentialsConfig ? 'Hide Config' : 'Edit Credentials',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupabaseCredentialsInputs(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _supabaseUrlController,
          obscureText: _isUrlObscured,
          decoration: InputDecoration(
            labelText: 'Supabase Project URL',
            hintText: 'https://xxx.supabase.co',
            prefixIcon: const Icon(Icons.link),
            suffixIcon: IconButton(
              icon: Icon(
                _isUrlObscured ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () => setState(() => _isUrlObscured = !_isUrlObscured),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            isDense: true,
          ),
        ),
        AppSpacing.vGapSm,
        TextField(
          controller: _supabaseKeyController,
          obscureText: _isKeyObscured,
          decoration: InputDecoration(
            labelText: 'Supabase Anon (Public) Key',
            prefixIcon: const Icon(Icons.vpn_key_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _isKeyObscured ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () => setState(() => _isKeyObscured = !_isKeyObscured),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            isDense: true,
          ),
        ),
        AppSpacing.vGapSm,
        Row(
          children: [
            OutlinedButton.icon(
              icon: _isTestingConnection
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi_tethering, size: 16),
              label:
                  Text(_isTestingConnection ? 'Testing...' : 'Test Connection'),
              onPressed: _isTestingConnection || _isSavingCredentials
                  ? null
                  : _testSupabaseConnection,
            ),
            AppSpacing.hGapSm,
            FilledButton.icon(
              icon: _isSavingCredentials
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save, size: 16),
              label:
                  Text(_isSavingCredentials ? 'Saving...' : 'Save Credentials'),
              onPressed: _isTestingConnection || _isSavingCredentials
                  ? null
                  : _saveSupabaseCredentials,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAuthSection(ThemeData theme, MomentumSupabaseClient supabase) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account & Authentication',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (!supabase.isConfigured) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: theme.hintColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Configure and save your Supabase Project URL & Anon Key above to sign in or create an account.',
                    style: TextStyle(fontSize: 12, color: theme.hintColor),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Clean SegmentedButton: ["Sign In", "Create Account"]
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(
                  value: 0,
                  label: Text('Sign In'),
                  icon: Icon(Icons.login, size: 16),
                ),
                ButtonSegment<int>(
                  value: 1,
                  label: Text('Create Account'),
                  icon: Icon(Icons.person_add_alt_1, size: 16),
                ),
              ],
              selected: {_authTabIndex},
              onSelectionChanged: (newSelection) {
                setState(() => _authTabIndex = newSelection.first);
              },
            ),
          ),
          AppSpacing.vGapMd,

          if (_authTabIndex == 0) ...[
            // SIGN IN TAB
            TextField(
              controller: _authEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                isDense: true,
              ),
            ),
            AppSpacing.vGapSm,
            TextField(
              controller: _authPasswordController,
              obscureText: _isPasswordObscured,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordObscured
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () => setState(
                    () => _isPasswordObscured = !_isPasswordObscured,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                isDense: true,
              ),
            ),
            AppSpacing.vGapSm,
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _isAuthLoading ? null : _handleSignIn,
                  icon: _isAuthLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.login, size: 16),
                  label: Text(_isAuthLoading ? 'Signing In...' : 'Sign In'),
                ),
                AppSpacing.hGapSm,
                TextButton(
                  onPressed: _isAuthLoading ? null : _handleForgotPassword,
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
          ] else ...[
            // CREATE ACCOUNT TAB
            TextField(
              controller: _authEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'you@example.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                isDense: true,
              ),
            ),
            AppSpacing.vGapSm,
            TextField(
              controller: _displayNameController,
              decoration: InputDecoration(
                labelText: 'Full Name / Display Name (Optional)',
                hintText: 'e.g. Alex Mercer',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                isDense: true,
              ),
            ),
            AppSpacing.vGapSm,
            TextField(
              controller: _authPasswordController,
              obscureText: _isPasswordObscured,
              decoration: InputDecoration(
                labelText: 'Password',
                helperText: 'Minimum 6 characters',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordObscured
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () => setState(
                    () => _isPasswordObscured = !_isPasswordObscured,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                isDense: true,
              ),
            ),
            AppSpacing.vGapSm,
            TextField(
              controller: _confirmPasswordController,
              obscureText: _isConfirmPasswordObscured,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
                prefixIcon: const Icon(Icons.lock_reset_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordObscured
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () => setState(
                    () => _isConfirmPasswordObscured =
                        !_isConfirmPasswordObscured,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                isDense: true,
              ),
            ),
            AppSpacing.vGapSm,
            FilledButton.icon(
              onPressed: _isAuthLoading ? null : _handleCreateAccount,
              icon: _isAuthLoading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.person_add_alt_1, size: 16),
              label: Text(
                _isAuthLoading ? 'Creating Account...' : 'Create Account',
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildAuthenticatedUserProfile(
    BuildContext context,
    MomentumSupabaseClient supabase,
    SyncEngineStatus? syncStatus,
    ThemeData theme,
  ) {
    final user = supabase.currentUser;
    final email = user?.email ?? 'Unknown Email';
    final metadata = user?.userMetadata;
    final displayName = (metadata?['display_name'] as String?) ??
        (metadata?['full_name'] as String?) ??
        'Momentum User';
    final userId = user?.id ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Profile Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // User Avatar with Auroral Jade gradient
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D9488), AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.35),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                displayName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // "Cloud Synced" badge with Auroral Jade indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary
                                    .withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: AppColors.secondary
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.secondary,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.secondary
                                              .withValues(alpha: 0.8),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'Cloud Synced',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.email_outlined,
                                size: 14, color: theme.hintColor),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                email,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (userId.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.fingerprint,
                                  size: 14, color: theme.hintColor),
                              const SizedBox(width: 5),
                              Text(
                                'ID: ${userId.length > 16 ? "${userId.substring(0, 16)}..." : userId}',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: theme.hintColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                borderRadius: BorderRadius.circular(4),
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: userId));
                                  context.showSnackBar(
                                    'User ID copied to clipboard',
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Icon(Icons.copy,
                                      size: 12, color: theme.hintColor),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Action Buttons: Sync Now & Sign Out
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: _isManualSyncing
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.sync, size: 16),
                      label: Text(
                        _isManualSyncing ? 'Syncing...' : 'Sync Now',
                      ),
                      onPressed: _isManualSyncing ? null : _handleSyncNow,
                    ),
                  ),
                  AppSpacing.hGapSm,
                  OutlinedButton.icon(
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Sign Out'),
                    onPressed: _handleSignOut,
                  ),
                ],
              ),
            ],
          ),
        ),

        AppSpacing.vGapMd,

        // User Data & Privacy Section
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined,
                      size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'User Data & Privacy',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your remote cloud database footprint or permanently remove your account.',
                style:
                    theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange.shade700,
                      side: BorderSide(
                        color: Colors.orange.shade400.withValues(alpha: 0.6),
                      ),
                    ),
                    icon: _isPurgingData
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.orange.shade700,
                            ),
                          )
                        : const Icon(Icons.cleaning_services_outlined, size: 16),
                    label: Text(
                      _isPurgingData ? 'Purging...' : 'Purge My Cloud Data',
                    ),
                    onPressed: _isPurgingData || _isDeletingAccount
                        ? null
                        : () => _handlePurgeUserData(userId),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: BorderSide(
                        color: Colors.redAccent.withValues(alpha: 0.6),
                      ),
                    ),
                    icon: _isDeletingAccount
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.redAccent,
                            ),
                          )
                        : const Icon(Icons.delete_forever, size: 16),
                    label: Text(
                      _isDeletingAccount ? 'Deleting...' : 'Delete My Account',
                    ),
                    onPressed: _isPurgingData || _isDeletingAccount
                        ? null
                        : () => _handleDeleteAccount(userId),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Supabase Actions ---

  Future<void> _testSupabaseConnection() async {
    final url = _supabaseUrlController.text.trim();
    final key = _supabaseKeyController.text.trim();
    if (url.isEmpty || key.isEmpty) {
      context.showSnackBar(
        'Please enter both Supabase URL and Anon Key.',
        isError: true,
      );
      return;
    }
    setState(() => _isTestingConnection = true);
    final supabase = ref.read(supabaseClientProvider);
    final res = await supabase.testConnection(
      supabaseUrl: url,
      supabaseAnonKey: key,
    );
    if (!mounted) return;
    setState(() => _isTestingConnection = false);

    if (res.isSuccess) {
      context.showSnackBar('Connection successful! Reachable & valid Supabase project.');
    } else {
      context.showSnackBar(
        'Connection test failed: ${res.errorOrNull?.message}',
        isError: true,
      );
    }
  }

  Future<void> _saveSupabaseCredentials() async {
    final url = _supabaseUrlController.text.trim();
    final key = _supabaseKeyController.text.trim();
    if (url.isEmpty || key.isEmpty) {
      context.showSnackBar(
        'Please enter both Supabase URL and Anon Key.',
        isError: true,
      );
      return;
    }
    setState(() => _isSavingCredentials = true);
    final supabase = ref.read(supabaseClientProvider);
    final res = await supabase.initialize(
      supabaseUrl: url,
      supabaseAnonKey: key,
      persist: true,
    );
    if (!mounted) return;
    setState(() => _isSavingCredentials = false);

    if (res.isSuccess) {
      context.showSnackBar('Supabase credentials saved & connected!');
      if (supabase.isAuthenticated) {
        ref.read(currentUserIdProvider.notifier).state =
            supabase.currentUserId ?? 'local-user';
        await ref.read(syncEngineProvider).triggerSync();
      }
    } else {
      context.showSnackBar(
        'Failed to connect: ${res.errorOrNull?.message}',
        isError: true,
      );
    }
  }

  Future<void> _handleSignIn() async {
    final email = _authEmailController.text.trim();
    final password = _authPasswordController.text;

    if (email.isEmpty) {
      context.showSnackBar('Please enter your email address.', isError: true);
      return;
    }
    if (password.isEmpty) {
      context.showSnackBar('Please enter your password.', isError: true);
      return;
    }

    setState(() => _isAuthLoading = true);
    final supabase = ref.read(supabaseClientProvider);
    final res = await supabase.signInWithEmail(email, password);
    if (!mounted) return;
    setState(() => _isAuthLoading = false);

    if (res.isSuccess) {
      final uid = supabase.currentUserId ?? 'local-user';
      ref.read(currentUserIdProvider.notifier).state = uid;
      context.showSnackBar('Signed in successfully as $email');
      await ref.read(syncEngineProvider).triggerSync();
    } else {
      context.showSnackBar(
        res.errorOrNull?.message ?? 'Sign in failed.',
        isError: true,
      );
    }
  }

  Future<void> _handleCreateAccount() async {
    final email = _authEmailController.text.trim();
    final password = _authPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final displayName = _displayNameController.text.trim();

    if (email.isEmpty) {
      context.showSnackBar('Please enter your email address.', isError: true);
      return;
    }
    final emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegExp.hasMatch(email)) {
      context.showSnackBar('Please enter a valid email address.', isError: true);
      return;
    }
    if (password.isEmpty) {
      context.showSnackBar('Please enter a password.', isError: true);
      return;
    }
    if (password.length < 6) {
      context.showSnackBar(
        'Password must be at least 6 characters long.',
        isError: true,
      );
      return;
    }
    if (password != confirmPassword) {
      context.showSnackBar(
        'Passwords do not match. Please verify and re-enter.',
        isError: true,
      );
      return;
    }

    setState(() => _isAuthLoading = true);
    final supabase = ref.read(supabaseClientProvider);
    final res = await supabase.signUpWithEmail(
      email,
      password,
      displayName: displayName.isNotEmpty ? displayName : null,
    );
    if (!mounted) return;
    setState(() => _isAuthLoading = false);

    if (res.isSuccess) {
      final signUpResult = res.valueOrNull;
      if (signUpResult != null && signUpResult.sessionCreated) {
        final uid = supabase.currentUserId ?? 'local-user';
        ref.read(currentUserIdProvider.notifier).state = uid;
        context.showSnackBar('Account created & logged in as $email!');
        await ref.read(syncEngineProvider).triggerSync();
      } else {
        context.showSnackBar(
          'Account created! Please check your email to confirm your account, then sign in.',
        );
      }
    } else {
      context.showSnackBar(
        res.errorOrNull?.message ?? 'Sign up failed.',
        isError: true,
      );
    }
  }

  Future<void> _handleSignOut() async {
    final supabase = ref.read(supabaseClientProvider);
    await supabase.signOut();
    ref.read(currentUserIdProvider.notifier).state = 'local-user';
    if (!mounted) return;
    setState(() {});
    context.showSnackBar('Signed out successfully.');
  }

  Future<void> _handleSyncNow() async {
    setState(() => _isManualSyncing = true);
    await ref.read(syncEngineProvider).triggerSync();
    if (!mounted) return;
    setState(() => _isManualSyncing = false);
    context.showSnackBar('Sync complete');
  }

  Future<void> _handleForgotPassword() async {
    final email = _authEmailController.text.trim();
    if (email.isEmpty) {
      context.showSnackBar(
        'Please enter your email address first.',
        isError: true,
      );
      return;
    }
    final supabase = ref.read(supabaseClientProvider);
    final res = await supabase.resetPassword(email);
    if (!mounted) return;
    if (res.isSuccess) {
      context.showSnackBar('Password reset email sent to $email');
    } else {
      context.showSnackBar(
        res.errorOrNull?.message ?? 'Failed to send password reset email.',
        isError: true,
      );
    }
  }

  Future<void> _handlePurgeUserData(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Purge Cloud Data?'),
          ],
        ),
        content: const Text(
          'Are you sure you want to wipe all your data from Supabase cloud storage?\n\n'
          'All tasks, labels, focus areas, timer logs, and KPIs stored remotely will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Purge Cloud Data'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isPurgingData = true);
    final supabase = ref.read(supabaseClientProvider);
    final res = await supabase.purgeUserData(userId);
    if (!mounted) return;
    setState(() => _isPurgingData = false);

    if (res.isSuccess) {
      context.showSnackBar('Cloud data purged successfully from Supabase.');
    } else {
      context.showSnackBar(
        'Failed to purge cloud data: ${res.errorOrNull?.message}',
        isError: true,
      );
    }
  }

  Future<void> _handleDeleteAccount(String userId) async {
    final deleteCtrl = TextEditingController();
    bool canDelete = false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.dangerous_outlined, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text('Delete Account Permanently'),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This action cannot be undone. All your remote data will be purged, your account will be removed, and local data on this device will be wiped.',
                      style: TextStyle(height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'To confirm deletion, type "DELETE" below:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: deleteCtrl,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'DELETE',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        isDense: true,
                      ),
                      onChanged: (text) {
                        setModalState(() {
                          canDelete = text.trim() == 'DELETE';
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: canDelete ? () => Navigator.of(ctx).pop(true) : null,
                  child: const Text('Delete My Account'),
                ),
              ],
            );
          },
        );
      },
    );

    deleteCtrl.dispose();
    if (confirmed != true || !mounted) return;

    setState(() => _isDeletingAccount = true);
    final supabase = ref.read(supabaseClientProvider);
    final res = await supabase.deleteUserAccount();
    if (!mounted) return;

    if (res.isSuccess) {
      // Wipe local data for this user
      await ref.read(appDatabaseProvider).wipeUserData(userId);
      if (!mounted) return;
      ref.read(currentUserIdProvider.notifier).state = 'local-user';
      setState(() => _isDeletingAccount = false);
      context.showSnackBar('Account deleted and local data cleared.');
    } else {
      setState(() => _isDeletingAccount = false);
      context.showSnackBar(
        'Account deletion failed: ${res.errorOrNull?.message}',
        isError: true,
      );
    }
  }
}
