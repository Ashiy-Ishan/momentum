import 'package:equatable/equatable.dart';

import '../enums/enums.dart';

/// Represents a task in Momentum.
class Task with Equatable {
  final String id;
  final String userId;
  final String? labelId;
  final String title;
  final String? description;
  final String? iconName;
  final String? imagePath;
  final String? url;
  final String? category;
  final TaskStatus status;
  final TaskPriority priority;
  final bool hasTimeTracking;
  final int? estimatedMinutes;
  final String? recurrenceRuleId;
  final DateTime? scheduledDate;
  final DateTime? dueDate;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;

  const Task({
    required this.id,
    required this.userId,
    this.labelId,
    required this.title,
    this.description,
    this.iconName,
    this.imagePath,
    this.url,
    this.category,
    this.status = TaskStatus.pending,
    this.priority = TaskPriority.medium,
    this.hasTimeTracking = false,
    this.estimatedMinutes,
    this.recurrenceRuleId,
    this.scheduledDate,
    this.dueDate,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    labelId,
    title,
    description,
    iconName,
    imagePath,
    url,
    category,
    status,
    priority,
    hasTimeTracking,
    estimatedMinutes,
    recurrenceRuleId,
    scheduledDate,
    dueDate,
    isArchived,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  ];

  Task copyWith({
    String? id,
    String? userId,
    String? labelId,
    bool clearLabelId = false,
    String? title,
    String? description,
    bool clearDescription = false,
    String? iconName,
    bool clearIconName = false,
    String? imagePath,
    bool clearImagePath = false,
    String? url,
    bool clearUrl = false,
    String? category,
    bool clearCategory = false,
    TaskStatus? status,
    TaskPriority? priority,
    bool? hasTimeTracking,
    int? estimatedMinutes,
    bool clearEstimatedMinutes = false,
    String? recurrenceRuleId,
    bool clearRecurrenceRuleId = false,
    DateTime? scheduledDate,
    bool clearScheduledDate = false,
    DateTime? dueDate,
    bool clearDueDate = false,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      labelId: clearLabelId ? null : (labelId ?? this.labelId),
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      iconName: clearIconName ? null : (iconName ?? this.iconName),
      imagePath: clearImagePath ? null : (imagePath ?? this.imagePath),
      url: clearUrl ? null : (url ?? this.url),
      category: clearCategory ? null : (category ?? this.category),
      status: status ?? this.status,
      priority: priority ?? this.priority,
      hasTimeTracking: hasTimeTracking ?? this.hasTimeTracking,
      estimatedMinutes: clearEstimatedMinutes
          ? null
          : (estimatedMinutes ?? this.estimatedMinutes),
      recurrenceRuleId: clearRecurrenceRuleId
          ? null
          : (recurrenceRuleId ?? this.recurrenceRuleId),
      scheduledDate: clearScheduledDate
          ? null
          : (scheduledDate ?? this.scheduledDate),
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      isArchived: isArchived ?? this.isArchived,
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
      'labelId': labelId,
      'title': title,
      'description': description,
      'iconName': iconName,
      'imagePath': imagePath,
      'url': url,
      'category': category,
      'status': status.name,
      'priority': priority.name,
      'hasTimeTracking': hasTimeTracking,
      'estimatedMinutes': estimatedMinutes,
      'recurrenceRuleId': recurrenceRuleId,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'version': version,
      'isDeleted': isDeleted,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: (map['id'] ?? '').toString(),
      userId: (map['userId'] ?? map['user_id'] ?? '').toString(),
      labelId: (map['labelId'] ?? map['label_id'])?.toString(),
      title: (map['title'] ?? '').toString(),
      description: (map['description'])?.toString(),
      iconName: (map['iconName'] ?? map['icon_name'])?.toString(),
      imagePath: (map['imagePath'] ?? map['image_path'])?.toString(),
      url: (map['url'])?.toString(),
      category: (map['category'])?.toString(),
      status: map['status'] != null
          ? TaskStatus.fromString(map['status'].toString())
          : TaskStatus.pending,
      priority: map['priority'] != null
          ? TaskPriority.fromString(map['priority'].toString())
          : TaskPriority.medium,
      hasTimeTracking: _parseBool(
        map['hasTimeTracking'] ?? map['has_time_tracking'],
        false,
      ),
      estimatedMinutes: _tryParseInt(
        map['estimatedMinutes'] ?? map['estimated_minutes'],
      ),
      recurrenceRuleId: (map['recurrenceRuleId'] ?? map['recurrence_rule_id'])
          ?.toString(),
      scheduledDate: _tryParseDateTime(
        map['scheduledDate'] ?? map['scheduled_date'],
      ),
      dueDate: _tryParseDateTime(map['dueDate'] ?? map['due_date']),
      isArchived: _parseBool(map['isArchived'] ?? map['is_archived'], false),
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

  static int? _tryParseInt(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val);
    return null;
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
