import 'package:equatable/equatable.dart';

import '../enums/enums.dart';

class SyncQueueItem with Equatable {
  final String id;
  final String tableName;
  final String recordId;
  final SyncOperation operation;
  final String payloadJson;
  final int retryCount;
  final DateTime createdAt;
  final DateTime? lastAttemptedAt;
  final String? errorMessage;
  final SyncStatus status;

  const SyncQueueItem({
    required this.id,
    required this.tableName,
    required this.recordId,
    required this.operation,
    required this.payloadJson,
    this.retryCount = 0,
    required this.createdAt,
    this.lastAttemptedAt,
    this.errorMessage,
    this.status = SyncStatus.pending,
  });

  @override
  List<Object?> get props => [
    id,
    tableName,
    recordId,
    operation,
    payloadJson,
    retryCount,
    createdAt,
    lastAttemptedAt,
    errorMessage,
    status,
  ];

  SyncQueueItem copyWith({
    String? id,
    String? tableName,
    String? recordId,
    SyncOperation? operation,
    String? payloadJson,
    int? retryCount,
    DateTime? createdAt,
    DateTime? lastAttemptedAt,
    bool clearLastAttemptedAt = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    SyncStatus? status,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      tableName: tableName ?? this.tableName,
      recordId: recordId ?? this.recordId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptedAt: clearLastAttemptedAt
          ? null
          : (lastAttemptedAt ?? this.lastAttemptedAt),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tableName': tableName,
      'recordId': recordId,
      'operation': operation.name,
      'payloadJson': payloadJson,
      'retryCount': retryCount,
      'createdAt': createdAt.toIso8601String(),
      'lastAttemptedAt': lastAttemptedAt?.toIso8601String(),
      'errorMessage': errorMessage,
      'status': status.name,
    };
  }

  factory SyncQueueItem.fromMap(Map<String, dynamic> map) {
    return SyncQueueItem(
      id: (map['id'] ?? '').toString(),
      tableName: (map['tableName'] ?? map['table_name'] ?? '').toString(),
      recordId: (map['recordId'] ?? map['record_id'] ?? '').toString(),
      operation: map['operation'] != null
          ? SyncOperation.fromString(map['operation'].toString())
          : SyncOperation.insert,
      payloadJson: (map['payloadJson'] ?? map['payload_json'] ?? '').toString(),
      retryCount: _parseInt(map['retryCount'] ?? map['retry_count'], 0),
      createdAt: _parseDateTime(map['createdAt'] ?? map['created_at']),
      lastAttemptedAt: _tryParseDateTime(
        map['lastAttemptedAt'] ?? map['last_attempted_at'],
      ),
      errorMessage: (map['errorMessage'] ?? map['error_message'])?.toString(),
      status: map['status'] != null
          ? SyncStatus.fromString(map['status'].toString())
          : SyncStatus.pending,
    );
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
