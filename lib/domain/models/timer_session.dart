import 'package:equatable/equatable.dart';

import '../enums/enums.dart';

/// Tracks a time-tracking session for a task or occurrence.
class TimerSession with Equatable {
  final String id;
  final String userId;
  final String taskId;
  final String? occurrenceId;
  final DateTime startedAt;
  final DateTime? pausedAt;
  final DateTime? endedAt;
  final int elapsedSeconds;
  final TimerSessionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;

  const TimerSession({
    required this.id,
    required this.userId,
    required this.taskId,
    this.occurrenceId,
    required this.startedAt,
    this.pausedAt,
    this.endedAt,
    this.elapsedSeconds = 0,
    this.status = TimerSessionStatus.running,
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
    this.isDeleted = false,
  });

  /// The static recorded elapsed duration.
  Duration get elapsed => Duration(seconds: elapsedSeconds);

  /// Dynamically calculated elapsed duration accounting for active running state.
  Duration get currentElapsed {
    if (status == TimerSessionStatus.running) {
      final runningDuration = DateTime.now().difference(startedAt);
      final runningSeconds = runningDuration.inSeconds > 0
          ? runningDuration.inSeconds
          : 0;
      return Duration(seconds: elapsedSeconds + runningSeconds);
    }
    return elapsed;
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    taskId,
    occurrenceId,
    startedAt,
    pausedAt,
    endedAt,
    elapsedSeconds,
    status,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  ];

  TimerSession copyWith({
    String? id,
    String? userId,
    String? taskId,
    String? occurrenceId,
    bool clearOccurrenceId = false,
    DateTime? startedAt,
    DateTime? pausedAt,
    bool clearPausedAt = false,
    DateTime? endedAt,
    bool clearEndedAt = false,
    int? elapsedSeconds,
    TimerSessionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) {
    return TimerSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      occurrenceId: clearOccurrenceId
          ? null
          : (occurrenceId ?? this.occurrenceId),
      startedAt: startedAt ?? this.startedAt,
      pausedAt: clearPausedAt ? null : (pausedAt ?? this.pausedAt),
      endedAt: clearEndedAt ? null : (endedAt ?? this.endedAt),
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      status: status ?? this.status,
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
      'occurrenceId': occurrenceId,
      'startedAt': startedAt.toIso8601String(),
      'pausedAt': pausedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'elapsedSeconds': elapsedSeconds,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'version': version,
      'isDeleted': isDeleted,
    };
  }

  factory TimerSession.fromMap(Map<String, dynamic> map) {
    return TimerSession(
      id: (map['id'] ?? '').toString(),
      userId: (map['userId'] ?? map['user_id'] ?? '').toString(),
      taskId: (map['taskId'] ?? map['task_id'] ?? '').toString(),
      occurrenceId: (map['occurrenceId'] ?? map['occurrence_id'])?.toString(),
      startedAt: _parseDateTime(map['startedAt'] ?? map['started_at']),
      pausedAt: _tryParseDateTime(map['pausedAt'] ?? map['paused_at']),
      endedAt: _tryParseDateTime(map['endedAt'] ?? map['ended_at']),
      elapsedSeconds: _parseInt(
        map['elapsedSeconds'] ?? map['elapsed_seconds'],
        0,
      ),
      status: map['status'] != null
          ? TimerSessionStatus.fromString(map['status'].toString())
          : TimerSessionStatus.running,
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
