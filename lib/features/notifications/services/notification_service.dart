import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Open Momentum',
      );
      const darwinSettings = DarwinInitializationSettings();

      const initSettings = InitializationSettings(
        android: androidSettings,
        linux: linuxSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      if (Platform.isAndroid) {
        final androidImpl = _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await androidImpl?.requestNotificationsPermission();
      }

      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService initialization failed: $e');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'momentum_general',
      'General Notifications',
      channelDescription: 'General updates and reminders from Momentum',
      importance: Importance.high,
      priority: Priority.high,
    );

    const linuxDetails = LinuxNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      linux: linuxDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) return;

    try {
      final scheduledTz = tz.TZDateTime.from(scheduledDate, tz.local);

      const androidDetails = AndroidNotificationDetails(
        'momentum_tasks',
        'Task Reminders',
        channelDescription: 'Reminders for scheduled and due tasks',
        importance: Importance.high,
        priority: Priority.high,
      );

      const details = NotificationDetails(
        android: androidDetails,
        linux: LinuxNotificationDetails(),
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        'Upcoming Task',
        title,
        scheduledTz,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Failed to schedule reminder: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> scheduleDailyReport({
    required int hour,
    required int minute,
    required String summaryText,
  }) async {
    if (!_initialized) await initialize();

    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'momentum_reports',
        'Daily Reports',
        channelDescription: 'End-of-day summary reports',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

      const details = NotificationDetails(
        android: androidDetails,
        linux: LinuxNotificationDetails(),
      );

      await _notificationsPlugin.zonedSchedule(
        999999,
        'Daily Productivity Summary',
        summaryText,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Failed to schedule daily report: $e');
    }
  }
}
