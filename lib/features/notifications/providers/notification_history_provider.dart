import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/notification_history_item.dart';

abstract class NotificationType {
  static const String taskReminder = 'task_reminder';
  static const String hourlyNudge = 'hourly_nudge';
  static const String dailyReport = 'daily_report';
  static const String streakMilestone = 'streak_milestone';
  static const String creatorCadence = 'creator_cadence';
  static const String system = 'system';
}

class NotificationHistoryNotifier
    extends StateNotifier<List<NotificationHistoryItem>> {
  static const String _prefKey = 'momentum_notification_history_v1';
  final _uuid = const Uuid();

  NotificationHistoryNotifier() : super(const []) {
    _loadFromPreferences();
  }

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw != null) {
        final decoded = jsonDecode(raw) as List;
        final list = decoded
            .map((item) =>
                NotificationHistoryItem.fromMap(item as Map<String, dynamic>))
            .toList();
        state = list;
        return;
      }
    } catch (_) {}
  }

  Future<NotificationHistoryItem> addNotification({
    required String title,
    required String body,
    String type = NotificationType.system,
    String? payload,
    String? taskId,
  }) async {
    final item = NotificationHistoryItem(
      id: _uuid.v4(),
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
      isRead: false,
      payload: payload,
      taskId: taskId,
    );

    state = [item, ...state];
    await _persist();
    return item;
  }

  Future<void> markAsRead(String id) async {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isRead: true);
      }
      return item;
    }).toList();
    await _persist();
  }

  Future<void> markAllAsRead() async {
    state = state.map((item) => item.copyWith(isRead: true)).toList();
    await _persist();
  }

  Future<void> deleteNotification(String id) async {
    state = state.where((item) => item.id != id).toList();
    await _persist();
  }

  Future<void> clearAll() async {
    state = [];
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(state.map((item) => item.toMap()).toList());
      await prefs.setString(_prefKey, jsonStr);
    } catch (_) {}
  }
}

final notificationHistoryProvider = StateNotifierProvider<
    NotificationHistoryNotifier, List<NotificationHistoryItem>>((ref) {
  return NotificationHistoryNotifier();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationHistoryProvider);
  return list.where((item) => !item.isRead).length;
});
