import 'package:equatable/equatable.dart';

/// Configuration and preferences for local push notifications and reminders.
class NotificationSettings with Equatable {
  final String id;
  final String userId;
  final bool hourlyRemindersEnabled;
  final String activeHoursStart; // HH:mm
  final String activeHoursEnd; // HH:mm
  final List<int> activeDays; // 1=Mon..7=Sun
  final bool quietHoursEnabled;
  final String quietStart; // HH:mm
  final String quietEnd; // HH:mm
  final bool dailyReportEnabled;
  final String dailyReportTime; // HH:mm
  final bool motivationEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;

  const NotificationSettings({
    required this.id,
    required this.userId,
    this.hourlyRemindersEnabled = false,
    this.activeHoursStart = '09:00',
    this.activeHoursEnd = '18:00',
    this.activeDays = const [1, 2, 3, 4, 5],
    this.quietHoursEnabled = true,
    this.quietStart = '22:00',
    this.quietEnd = '07:00',
    this.dailyReportEnabled = true,
    this.dailyReportTime = '20:00',
    this.motivationEnabled = true,
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
    this.isDeleted = false,
  });

  /// Factory creating default notification settings.
  factory NotificationSettings.defaults({String id = '', String userId = ''}) {
    final now = DateTime.now();
    return NotificationSettings(
      id: id,
      userId: userId,
      hourlyRemindersEnabled: false,
      activeHoursStart: '09:00',
      activeHoursEnd: '18:00',
      activeDays: const [1, 2, 3, 4, 5],
      quietHoursEnabled: true,
      quietStart: '22:00',
      quietEnd: '07:00',
      dailyReportEnabled: true,
      dailyReportTime: '20:00',
      motivationEnabled: true,
      createdAt: now,
      updatedAt: now,
      version: 1,
      isDeleted: false,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    hourlyRemindersEnabled,
    activeHoursStart,
    activeHoursEnd,
    activeDays,
    quietHoursEnabled,
    quietStart,
    quietEnd,
    dailyReportEnabled,
    dailyReportTime,
    motivationEnabled,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  ];

  NotificationSettings copyWith({
    String? id,
    String? userId,
    bool? hourlyRemindersEnabled,
    String? activeHoursStart,
    String? activeHoursEnd,
    List<int>? activeDays,
    bool? quietHoursEnabled,
    String? quietStart,
    String? quietEnd,
    bool? dailyReportEnabled,
    String? dailyReportTime,
    bool? motivationEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) {
    return NotificationSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hourlyRemindersEnabled:
          hourlyRemindersEnabled ?? this.hourlyRemindersEnabled,
      activeHoursStart: activeHoursStart ?? this.activeHoursStart,
      activeHoursEnd: activeHoursEnd ?? this.activeHoursEnd,
      activeDays: activeDays ?? this.activeDays,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietStart: quietStart ?? this.quietStart,
      quietEnd: quietEnd ?? this.quietEnd,
      dailyReportEnabled: dailyReportEnabled ?? this.dailyReportEnabled,
      dailyReportTime: dailyReportTime ?? this.dailyReportTime,
      motivationEnabled: motivationEnabled ?? this.motivationEnabled,
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
      'hourlyRemindersEnabled': hourlyRemindersEnabled,
      'activeHoursStart': activeHoursStart,
      'activeHoursEnd': activeHoursEnd,
      'activeDays': activeDays,
      'quietHoursEnabled': quietHoursEnabled,
      'quietStart': quietStart,
      'quietEnd': quietEnd,
      'dailyReportEnabled': dailyReportEnabled,
      'dailyReportTime': dailyReportTime,
      'motivationEnabled': motivationEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'version': version,
      'isDeleted': isDeleted,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      id: (map['id'] ?? '').toString(),
      userId: (map['userId'] ?? map['user_id'] ?? '').toString(),
      hourlyRemindersEnabled: _parseBool(
        map['hourlyRemindersEnabled'] ?? map['hourly_reminders_enabled'],
        false,
      ),
      activeHoursStart:
          (map['activeHoursStart'] ?? map['active_hours_start'] ?? '09:00')
              .toString(),
      activeHoursEnd:
          (map['activeHoursEnd'] ?? map['active_hours_end'] ?? '18:00')
              .toString(),
      activeDays:
          _parseIntList(map['activeDays'] ?? map['active_days']) ??
          const [1, 2, 3, 4, 5],
      quietHoursEnabled: _parseBool(
        map['quietHoursEnabled'] ?? map['quiet_hours_enabled'],
        true,
      ),
      quietStart: (map['quietStart'] ?? map['quiet_start'] ?? '22:00')
          .toString(),
      quietEnd: (map['quietEnd'] ?? map['quiet_end'] ?? '07:00').toString(),
      dailyReportEnabled: _parseBool(
        map['dailyReportEnabled'] ?? map['daily_report_enabled'],
        true,
      ),
      dailyReportTime:
          (map['dailyReportTime'] ?? map['daily_report_time'] ?? '20:00')
              .toString(),
      motivationEnabled: _parseBool(
        map['motivationEnabled'] ?? map['motivation_enabled'],
        true,
      ),
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

  static List<int>? _parseIntList(dynamic val) {
    if (val == null) return null;
    if (val is List) {
      return val.map((e) => _tryParseInt(e)).whereType<int>().toList();
    }
    if (val is String && val.isNotEmpty) {
      return val
          .split(',')
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>()
          .toList();
    }
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
}
