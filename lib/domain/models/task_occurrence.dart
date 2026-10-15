import 'package:equatable/equatable.dart';

import '../enums/enums.dart';

/// Represents a single occurrence of a recurring or scheduled task.
class TaskOccurrence with Equatable {
  final String id;
  final String userId;
  final String taskId;
  final DateTime occurrenceDate;
  final TaskStatus status;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;

  const TaskOccurrence({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.occurrenceDate,
    this.status = TaskStatus.pending,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    taskId,
    occurrenceDate,
    status,
    completedAt,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  ];

  TaskOccurrence copyWith({
    String? id,
    String? userId,
    String? taskId,
    DateTime? occurrenceDate,
    TaskStatus? status,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) {
    return TaskOccurrence(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      status: status ?? this.status,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'taskId': taskId,
      'occurrenceDate': occurrenceDate.toIso8601String(),
      'status': status.name,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'version': version,
      'isDeleted': isDeleted,
    };
  }

  factory TaskOccurrence.fromMap(Map<String, dynamic> map) {
    return TaskOccurrence(
      id: (map['id'] ?? '').toString(),
      userId: (map['userId'] ?? map['user_id'] ?? '').toString(),
      taskId: (map['taskId'] ?? map['task_id'] ?? '').toString(),
      occurrenceDate: _parseDateTime(
        map['occurrenceDate'] ?? map['occurrence_date'],
      ),
      status: map['status'] != null
          ? TaskStatus.fromString(map['status'].toString())
          : TaskStatus.pending,
      completedAt: _tryParseDateTime(map['completedAt'] ?? map['completed_at']),
      createdAt: _parseDateTime(map['createdAt'] ?? map['created_at']),
      updatedAt: _parseDateTime(map['updatedAt'] ?? map['updated_at']),
      version: _parseInt(map['version'], 1),
      isDeleted: _parseBool(map['isDeleted'] ?? map['is_deleted'], false),
    );
  }

  static bool _parseBool(dynamic val, [bool fallback = false]) {
    if (val is bool) return val;
    if (val is num) return val != 0;
    if (val is String) {
      final lower = val.trim().toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return fallback;
  }

  static int _parseInt(dynamic val, [int fallback = 0]) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? fallback;
    return fallback;
  }

  static DateTime _parseDateTime(dynamic val) {
    if (val is DateTime) return val;
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    if (val is String && val.isNotEmpty) {
      final parsed = DateTime.tryParse(val);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  static DateTime? _tryParseDateTime(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    if (val is String && val.isNotEmpty) return DateTime.tryParse(val);
    return null;
  }
}
