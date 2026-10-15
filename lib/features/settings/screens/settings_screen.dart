import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../data/remote/supabase_client.dart';
import '../../../data/sync/sync_engine.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/models.dart';
import '../../../shared/providers/database_provider.dart';
import '../../analytics/providers/analytics_providers.dart';
import '../../labels/providers/label_providers.dart';
import '../../linux_wallpaper/renderers/wallpaper_svg_renderer.dart';
import '../../linux_wallpaper/services/linux_wallpaper_service.dart';
import '../../motivation/providers/motivation_providers.dart';
import '../../tasks/providers/task_providers.dart';
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
  bool _wallpaperEnabled = false;
  bool _wallpaperAutoUpdate = true;
  bool _wallpaperApplying = false;

  // Supabase Auth & Config State
  final TextEditingController _supabaseUrlController = TextEditingController();
  final TextEditingController _supabaseKeyController = TextEditingController();
  final TextEditingController _authEmailController = TextEditingController();
  final TextEditingController _authPasswordController = TextEditingController();
  bool _isAuthLoading = false;
  bool _isKeyObscured = true;

  @override
  void initState() {
    super.initState();
    _wallpaperService = LinuxWallpaperService();
    _isLinuxSupported = Platform.isLinux;
    _initWallpaperState();
  }

  Future<void> _initWallpaperState() async {
    if (_isLinuxSupported) {
      final enabled = await _wallpaperService.isEnabled();
      final auto = await _wallpaperService.isAutoUpdateEnabled();
      if (mounted) {
        setState(() {
          _wallpaperEnabled = enabled;
          _wallpaperAutoUpdate = auto;
        });
      }
    }
  }

  @override
  void dispose() {
    _wallpaperService.dispose();
    _supabaseUrlController.dispose();
    _supabaseKeyController.dispose();
    _authEmailController.dispose();
    _authPasswordController.dispose();
    super.dispose();
  }

  Future<void> _applyWallpaperNow() async {
    setState(() => _wallpaperApplying = true);
    final stats =
        ref.read(dashboardStatsProvider).valueOrNull ?? const DashboardStats();
    final quote = ref.read(currentQuoteProvider).valueOrNull;
    final allLabels = ref.read(allLabelsStreamProvider).valueOrNull ?? [];
    final allTasks = ref.read(allTasksStreamProvider).valueOrNull ?? [];

    final parentLabels = allLabels.where((l) => l.parentId == null);
    final parentMap = <String, ({int completed, int total})>{};

    for (final p in parentLabels) {
      final childrenIds = allLabels
          .where((l) => l.parentId == p.id)
          .map((l) => l.id)
          .toSet();
      final pTasks = allTasks.where(
        (t) => t.labelId == p.id || (t.labelId != null && childrenIds.contains(t.labelId)),
      );
      final total = pTasks.length;
      final completed =
          pTasks.where((t) => t.status == TaskStatus.done).length;
      parentMap[p.name] = (completed: completed, total: total);
    }

    final data = WallpaperData(
      date: DateTime.now(),
      completedTasks: stats.completedTasks,
      totalTasks: stats.scheduledTasks,
      currentStreak: stats.streakDays,
      motivationalQuote: quote?.text ?? 'Consistency is the DNA of mastery.',
      quoteAuthor: quote?.author ?? 'Robin Sharma',
      parentLabelProgress: parentMap,
      isDark: true,
    );

    final success = await _wallpaperService.updateWallpaper(data);
    if (mounted) {
      setState(() => _wallpaperApplying = false);
      context.showSnackBar(
        success
            ? 'Dynamic wallpaper applied successfully!'
            : 'Could not apply wallpaper on current desktop environment.',
        isError: !success,
      );
    }
  }

  Future<void> _restoreOriginalWallpaper() async {
    final success = await _wallpaperService.restoreOriginalWallpaper();
    if (mounted) {
      setState(() => _wallpaperEnabled = false);
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
          // Section 1: Appearance
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
              ],
            ),
          ),
          AppSpacing.vGapLg,

          // Section 3: Linux Desktop Dynamic Wallpaper
          _buildSectionHeader(
            'Linux Desktop Wallpaper Dashboard',
            Icons.desktop_windows_outlined,
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
                          color: _isLinuxSupported
                              ? AppColors.statusDone.withValues(alpha: 0.15)
                              : Colors.grey.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          _isLinuxSupported
                              ? 'Linux Environment: ${_wallpaperService.environment.name.toUpperCase()}'
                              : 'Linux Desktop Not Detected',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _isLinuxSupported
                                ? AppColors.statusDone
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vGapSm,
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable Wallpaper Dashboard'),
                    subtitle: const Text(
                      'Renders your tasks and streak directly onto your Linux desktop background',
                    ),
                    value: _wallpaperEnabled,
                    onChanged: _isLinuxSupported
                        ? (val) async {
                            setState(() => _wallpaperEnabled = val);
                            await _wallpaperService.setEnabled(val);
                            if (val) {
                              await _applyWallpaperNow();
                            }
                          }
                        : null,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Auto Update on Task Change'),
                    subtitle: const Text(
                      'Automatically re-renders wallpaper when completing or adding tasks',
                    ),
                    value: _wallpaperAutoUpdate,
                    onChanged: _wallpaperEnabled
                        ? (val) async {
                            setState(() => _wallpaperAutoUpdate = val);
                            await _wallpaperService.setAutoUpdateEnabled(val);
                          }
                        : null,
                  ),
                  AppSpacing.vGapMd,
                  Row(
                    children: [
                      FilledButton.icon(
                        icon: _wallpaperApplying
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.wallpaper, size: 18),
                        label: const Text('Apply Wallpaper Now'),
                        onPressed: (_isLinuxSupported && !_wallpaperApplying)
                            ? _applyWallpaperNow
                            : null,
                      ),
                      AppSpacing.hGapSm,
                      OutlinedButton(
                        onPressed:
                            _isLinuxSupported ? _restoreOriginalWallpaper : null,
                        child: const Text('Restore Original'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.vGapLg,

          // Section 4: Cloud Sync (Supabase)
          _buildSectionHeader('Cloud Sync & Storage', Icons.cloud_outlined),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Supabase Connection',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: syncStatus == SyncEngineStatus.idle
                              ? AppColors.statusDone.withValues(alpha: 0.15)
                              : syncStatus == SyncEngineStatus.syncing
                                  ? AppColors.statusDoing.withValues(alpha: 0.15)
                                  : Colors.grey.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              syncStatus == SyncEngineStatus.idle
                                  ? Icons.check_circle
                                  : syncStatus == SyncEngineStatus.syncing
                                      ? Icons.sync
                                      : Icons.cloud_off,
                              size: 13,
                              color: syncStatus == SyncEngineStatus.idle
                                  ? AppColors.statusDone
                                  : theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (syncStatus ?? SyncEngineStatus.offline).displayName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: syncStatus == SyncEngineStatus.idle
                                    ? AppColors.statusDone
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vGapSm,
                  TextField(
                    controller: _supabaseUrlController,
                    decoration: InputDecoration(
                      labelText: 'Supabase URL',
                      hintText: 'https://xxx.supabase.co',
                      prefixIcon: const Icon(Icons.link),
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
                      labelText: 'Supabase Anon Key',
                      prefixIcon: const Icon(Icons.vpn_key_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isKeyObscured
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => _isKeyObscured = !_isKeyObscured),
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
                      FilledButton.tonal(
                        onPressed: () async {
                          final url = _supabaseUrlController.text.trim();
                          final key = _supabaseKeyController.text.trim();
                          if (url.isEmpty || key.isEmpty) return;

                          final res = await supabase.initialize(
                            supabaseUrl: url,
                            supabaseAnonKey: key,
                          );
                          if (!context.mounted) return;
                          context.showSnackBar(
                            res.isSuccess
                                ? 'Supabase configured'
                                : 'Configuration failed',
                            isError: !res.isSuccess,
                          );
                        },
                        child: const Text('Save Credentials'),
                      ),
                      AppSpacing.hGapSm,
                      FilledButton.icon(
                        icon: const Icon(Icons.sync, size: 16),
                        label: const Text('Sync Now'),
                        onPressed: () async {
                          await ref.read(syncEngineProvider).triggerSync();
                          if (!context.mounted) return;
                          context.showSnackBar('Sync complete');
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Account Authentication
                  Text(
                    supabase.isAuthenticated
                        ? 'Authenticated Account'
                        : 'Sign In / Register',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.vGapSm,
                  if (supabase.isAuthenticated) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          supabase.currentUser?.email ?? 'Logged in',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            await supabase.signOut();
                            if (!context.mounted) return;
                            setState(() {});
                            context.showSnackBar('Signed out');
                          },
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  ] else ...[
                    TextField(
                      controller: _authEmailController,
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
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        isDense: true,
                      ),
                    ),
                    AppSpacing.vGapSm,
                    Row(
                      children: [
                        FilledButton(
                          onPressed: _isAuthLoading
                              ? null
                              : () async {
                                  final email =
                                      _authEmailController.text.trim();
                                  final password =
                                      _authPasswordController.text.trim();
                                  if (email.isEmpty || password.isEmpty) return;
                                  setState(() => _isAuthLoading = true);
                                  final res = await supabase.signInWithEmail(
                                      email, password);
                                  setState(() => _isAuthLoading = false);
                                  if (!context.mounted) return;
                                  context.showSnackBar(
                                    res.isSuccess
                                        ? 'Signed in successfully'
                                        : 'Sign in failed: ${res.errorOrNull?.message}',
                                    isError: !res.isSuccess,
                                  );
                                },
                          child: const Text('Sign In'),
                        ),
                        AppSpacing.hGapSm,
                        OutlinedButton(
                          onPressed: _isAuthLoading
                              ? null
                              : () async {
                                  final email =
                                      _authEmailController.text.trim();
                                  final password =
                                      _authPasswordController.text.trim();
                                  if (email.isEmpty || password.isEmpty) return;
                                  setState(() => _isAuthLoading = true);
                                  final res = await supabase.signUpWithEmail(
                                      email, password);
                                  setState(() => _isAuthLoading = false);
                                  if (!context.mounted) return;
                                  context.showSnackBar(
                                    res.isSuccess
                                        ? 'Sign up confirmation email sent'
                                        : 'Sign up failed: ${res.errorOrNull?.message}',
                                    isError: !res.isSuccess,
                                  );
                                },
                          child: const Text('Create Account'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
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
}
