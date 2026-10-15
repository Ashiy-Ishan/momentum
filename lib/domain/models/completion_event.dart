import 'package:equatable/equatable.dart';

/// Records the completion of a task or task occurrence.
class CompletionEvent with Equatable {
  final String id;
  final String userId;
  final String taskId;
  final String? occurrenceId;
  final DateTime completedAt;
  final String? notes;
  final DateTime createdAt;
  final bool isDeleted;

  const CompletionEvent({
    required this.id,
    required this.userId,
    required this.taskId,
    this.occurrenceId,
    required this.completedAt,
    this.notes,
    required this.createdAt,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    taskId,
    occurrenceId,
    completedAt,
    notes,
    createdAt,
    isDeleted,
  ];

  CompletionEvent copyWith({
    String? id,
    String? userId,
    String? taskId,
    String? occurrenceId,
    bool clearOccurrenceId = false,
    DateTime? completedAt,
    String? notes,
    bool clearNotes = false,
    DateTime? createdAt,
    bool? isDeleted,
  }) {
    return CompletionEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      occurrenceId: clearOccurrenceId
          ? null
          : (occurrenceId ?? this.occurrenceId),
      completedAt: completedAt ?? this.completedAt,
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'taskId': taskId,
      'occurrenceId': occurrenceId,
      'completedAt': completedAt.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  factory CompletionEvent.fromMap(Map<String, dynamic> map) {
    return CompletionEvent(
      id: (map['id'] ?? '').toString(),
      userId: (map['userId'] ?? map['user_id'] ?? '').toString(),
      taskId: (map['taskId'] ?? map['task_id'] ?? '').toString(),
      occurrenceId: (map['occurrenceId'] ?? map['occurrence_id'])?.toString(),
      completedAt: _parseDateTime(map['completedAt'] ?? map['completed_at']),
      notes: (map['notes'])?.toString(),
      createdAt: _parseDateTime(map['createdAt'] ?? map['created_at']),
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

  static DateTime _parseDateTime(dynamic val) {
    if (val is DateTime) return val;
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    if (val is String && val.isNotEmpty) {
      final parsed = DateTime.tryParse(val);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }
}
