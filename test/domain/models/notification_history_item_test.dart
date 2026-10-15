import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/domain/models/notification_history_item.dart';

void main() {
  group('NotificationHistoryItem Domain Model', () {
    test('Default values and fields instantiate accurately', () {
      final now = DateTime.now();
      final item = NotificationHistoryItem(
        id: 'notif_1',
        title: 'Task Reminder',
        body: 'Do not forget to complete coding task.',
        createdAt: now,
      );

      expect(item.id, 'notif_1');
      expect(item.title, 'Task Reminder');
      expect(item.body, 'Do not forget to complete coding task.');
      expect(item.type, 'system');
      expect(item.isRead, isFalse);
      expect(item.payload, isNull);
      expect(item.taskId, isNull);
    });

    test('Serialization toMap and fromMap works symmetrically', () {
      final now = DateTime.now();
      final item = NotificationHistoryItem(
        id: 'notif_2',
        title: 'Streak Milestone',
        body: 'You reached a 7-day consistency streak!',
        type: 'streak_milestone',
        createdAt: now,
        isRead: true,
        payload: '/analytics',
        taskId: 'task_abc',
      );

      final map = item.toMap();
      final reconstructed = NotificationHistoryItem.fromMap(map);

      expect(reconstructed, item);
      expect(reconstructed.type, 'streak_milestone');
      expect(reconstructed.payload, '/analytics');
      expect(reconstructed.taskId, 'task_abc');
      expect(reconstructed.isRead, isTrue);
    });

    test('copyWith modifies state immutably', () {
      final now = DateTime.now();
      final item = NotificationHistoryItem(
        id: 'notif_3',
        title: 'Daily Report',
        body: 'Summary ready',
        createdAt: now,
        isRead: false,
      );

      final readItem = item.copyWith(isRead: true, payload: '/today');
      expect(readItem.isRead, isTrue);
      expect(readItem.payload, '/today');
      expect(item.isRead, isFalse);
    });
  });
}
