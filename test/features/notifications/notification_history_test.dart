import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/features/notifications/providers/notification_history_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationHistoryNotifier Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Starts with empty notification history without artificial mock seeds', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final history = container.read(notificationHistoryProvider);
      expect(history.isEmpty, isTrue);

      final unread = container.read(unreadNotificationCountProvider);
      expect(unread, 0);
    });

    test('addNotification prepends new notification item and updates unread count', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(notificationHistoryProvider.notifier);
      final initialUnread = container.read(unreadNotificationCountProvider);

      final added = await notifier.addNotification(
        title: 'New Reminder',
        body: 'Submit daily status report',
        type: NotificationType.dailyReport,
        payload: '/today',
      );

      final updated = container.read(notificationHistoryProvider);
      expect(updated.first.id, added.id);
      expect(updated.first.title, 'New Reminder');
      expect(container.read(unreadNotificationCountProvider), initialUnread + 1);
    });

    test('markAsRead and markAllAsRead update unread count', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(notificationHistoryProvider.notifier);
      final item1 = await notifier.addNotification(
        title: 'Notification 1',
        body: 'Body 1',
        type: NotificationType.system,
      );
      await notifier.addNotification(
        title: 'Notification 2',
        body: 'Body 2',
        type: NotificationType.streakMilestone,
      );

      expect(container.read(unreadNotificationCountProvider), 2);

      await notifier.markAsRead(item1.id);
      final afterSingle = container.read(notificationHistoryProvider);
      expect(afterSingle.firstWhere((n) => n.id == item1.id).isRead, isTrue);
      expect(container.read(unreadNotificationCountProvider), 1);

      await notifier.markAllAsRead();
      expect(container.read(unreadNotificationCountProvider), 0);
    });

    test('deleteNotification and clearAll remove notifications', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(notificationHistoryProvider.notifier);
      final item1 = await notifier.addNotification(
        title: 'Target Item',
        body: 'Body',
        type: NotificationType.system,
      );
      await notifier.addNotification(
        title: 'Another Item',
        body: 'Body',
        type: NotificationType.system,
      );

      await notifier.deleteNotification(item1.id);
      expect(container.read(notificationHistoryProvider).any((n) => n.id == item1.id), isFalse);

      await notifier.clearAll();
      expect(container.read(notificationHistoryProvider), isEmpty);
      expect(container.read(unreadNotificationCountProvider), 0);
    });
  });
}
