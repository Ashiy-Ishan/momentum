import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../domain/models/models.dart';
import '../../../shared/providers/database_provider.dart';

// =============================================================================
// Theme Mode Provider & Persistence
// =============================================================================

/// Manages and persists application theme mode (light, dark, system).
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _prefKey = 'momentum_theme_mode';

  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadFromPreferences();
  }

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null) {
        if (saved == ThemeMode.light.name) {
          super.state = ThemeMode.light;
        } else if (saved == ThemeMode.dark.name) {
          super.state = ThemeMode.dark;
        } else {
          super.state = ThemeMode.system;
        }
      }
    } catch (_) {
      // Fallback to system default on preference read error
    }
  }

  @override
  set state(ThemeMode value) {
    super.state = value;
    _persist(value);
  }

  /// Sets and persists a new theme mode.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
  }

  Future<void> _persist(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, mode.name);
    } catch (_) {
      // Ignored
    }
  }
}

/// Active theme mode provider.
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// =============================================================================
// Notification Settings Provider & Persistence
// =============================================================================

/// Manages and persists reminder schedule and quiet hour preferences.
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final Ref _ref;
  static const Uuid _uuid = Uuid();

  Future<void>? _loadFuture;

  NotificationSettingsNotifier(this._ref)
      : super(NotificationSettings.defaults(userId: 'local-user')) {
    _loadFuture = _loadSettings();
  }

  String get _userId => _ref.read(currentUserIdProvider);

  Future<void> _loadSettings() async {
    final db = _ref.read(appDatabaseProvider);
    final row = await (db.select(db.notificationSettingsTable)
          ..where(
            (tbl) => tbl.userId.equals(_userId) & tbl.isDeleted.equals(false),
          )
          ..limit(1))
        .getSingleOrNull();

    if (row != null) {
      final activeDays = row.activeDays
          .split(',')
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>()
          .toList();

      state = NotificationSettings(
        id: row.id,
        userId: row.userId,
        hourlyRemindersEnabled: row.hourlyRemindersEnabled,
        activeHoursStart: row.activeHoursStart,
        activeHoursEnd: row.activeHoursEnd,
        activeDays: activeDays.isNotEmpty ? activeDays : const [1, 2, 3, 4, 5],
        quietHoursEnabled: row.quietHoursEnabled,
        quietStart: row.quietStart,
        quietEnd: row.quietEnd,
        dailyReportEnabled: row.dailyReportEnabled,
        dailyReportTime: row.dailyReportTime,
        motivationEnabled: row.motivationEnabled,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        version: row.version,
        isDeleted: row.isDeleted,
      );
    } else {
      state = NotificationSettings.defaults(
        id: _uuid.v4(),
        userId: _userId,
      );
      await _saveToDatabase(state);
    }
  }

  /// Updates and persists the entire settings configuration.
  Future<void> updateSettings(NotificationSettings newSettings) async {
    if (_loadFuture != null) {
      await _loadFuture;
    }
    state = newSettings.copyWith(updatedAt: DateTime.now());
    await _saveToDatabase(state);
  }

  /// Toggles hourly reminder notifications.
  Future<void> toggleHourlyReminders(bool enabled) async {
    await updateSettings(state.copyWith(hourlyRemindersEnabled: enabled));
  }

  /// Toggles quiet hours filter.
  Future<void> toggleQuietHours(bool enabled) async {
    await updateSettings(state.copyWith(quietHoursEnabled: enabled));
  }

  /// Toggles daily productivity end-of-day report.
  Future<void> toggleDailyReport(bool enabled) async {
    await updateSettings(state.copyWith(dailyReportEnabled: enabled));
  }

  /// Toggles periodic motivational quotes.
  Future<void> toggleMotivation(bool enabled) async {
    await updateSettings(state.copyWith(motivationEnabled: enabled));
  }

  /// Updates daily report trigger time (format HH:mm).
  Future<void> setDailyReportTime(String time) async {
    await updateSettings(state.copyWith(dailyReportTime: time));
  }

  /// Updates active hours start and end (format HH:mm).
  Future<void> setActiveHours(String start, String end) async {
    await updateSettings(
      state.copyWith(
        activeHoursStart: start,
        activeHoursEnd: end,
      ),
    );
  }

  Future<void> _saveToDatabase(NotificationSettings s) async {
    final db = _ref.read(appDatabaseProvider);
    final daysStr = s.activeDays.join(',');

    await db.into(db.notificationSettingsTable).insertOnConflictUpdate(
          NotificationSettingsTableCompanion(
            id: drift.Value(s.id),
            userId: drift.Value(s.userId),
            hourlyRemindersEnabled: drift.Value(s.hourlyRemindersEnabled),
            activeHoursStart: drift.Value(s.activeHoursStart),
            activeHoursEnd: drift.Value(s.activeHoursEnd),
            activeDays: drift.Value(daysStr),
            quietHoursEnabled: drift.Value(s.quietHoursEnabled),
            quietStart: drift.Value(s.quietStart),
            quietEnd: drift.Value(s.quietEnd),
            dailyReportEnabled: drift.Value(s.dailyReportEnabled),
            dailyReportTime: drift.Value(s.dailyReportTime),
            motivationEnabled: drift.Value(s.motivationEnabled),
            createdAt: drift.Value(s.createdAt),
            updatedAt: drift.Value(s.updatedAt),
            version: drift.Value(s.version),
            isDeleted: drift.Value(s.isDeleted),
          ),
        );
  }
}

/// Notification settings provider.
final notificationSettingsProvider = StateNotifierProvider<
    NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier(ref);
});
