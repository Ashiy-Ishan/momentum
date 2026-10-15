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

    test('Loads initial seeded notifications on first startup', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final history = container.read(notificationHistoryProvider);
      expect(history.isNotEmpty, isTrue);

      final unread = container.read(unreadNotificationCountProvider);
      expect(unread, greaterThan(0));
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
      final list = container.read(notificationHistoryProvider);
      final unreadItem = list.firstWhere((n) => !n.isRead);

      await notifier.markAsRead(unreadItem.id);
      final afterSingle = container.read(notificationHistoryProvider);
      expect(afterSingle.firstWhere((n) => n.id == unreadItem.id).isRead, isTrue);

      await notifier.markAllAsRead();
      expect(container.read(unreadNotificationCountProvider), 0);
    });

    test('deleteNotification and clearAll remove notifications', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(notificationHistoryProvider.notifier);
      final list = container.read(notificationHistoryProvider);
      final target = list.first;

      await notifier.deleteNotification(target.id);
      expect(container.read(notificationHistoryProvider).any((n) => n.id == target.id), isFalse);

      await notifier.clearAll();
      expect(container.read(notificationHistoryProvider), isEmpty);
      expect(container.read(unreadNotificationCountProvider), 0);
    });
  });
}
