import 'package:equatable/equatable.dart';

/// Represents an archived notification alert in the notification history.
class NotificationHistoryItem extends Equatable {
  final String id;
  final String title;
  final String body;
  final String type; // 'task_reminder', 'hourly_nudge', 'daily_report', 'streak_milestone', 'creator_cadence', 'system'
  final DateTime createdAt;
  final bool isRead;
  final String? payload; // e.g. '/tasks', '/today', '/analytics'
  final String? taskId;

  const NotificationHistoryItem({
    required this.id,
    required this.title,
    required this.body,
    this.type = 'system',
    required this.createdAt,
    this.isRead = false,
    this.payload,
    this.taskId,
  });

  NotificationHistoryItem copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    DateTime? createdAt,
    bool? isRead,
    String? payload,
    String? taskId,
  }) {
    return NotificationHistoryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      payload: payload ?? this.payload,
      taskId: taskId ?? this.taskId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'payload': payload,
      'taskId': taskId,
    };
  }

  factory NotificationHistoryItem.fromMap(Map<String, dynamic> map) {
    return NotificationHistoryItem(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      type: map['type'] as String? ?? 'system',
      createdAt: DateTime.parse(map['createdAt'] as String),
      isRead: map['isRead'] as bool? ?? false,
      payload: map['payload'] as String?,
      taskId: map['taskId'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        type,
        createdAt,
        isRead,
        payload,
        taskId,
      ];
}
