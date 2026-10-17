import 'package:equatable/equatable.dart';

import '../enums/enums.dart';

class RecurrenceRule with Equatable {
  final String id;
  final String userId;
  final RecurrenceType type;
  final List<int>? daysOfWeek;
  final int? intervalDays;
  final int? intervalMonths;
  final DateTime startDate;
  final DateTime? endDate;
  final int? maxOccurrences;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;

  const RecurrenceRule({
    required this.id,
    required this.userId,
    required this.type,
    this.daysOfWeek,
    this.intervalDays,
    this.intervalMonths,
    required this.startDate,
    this.endDate,
    this.maxOccurrences,
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    daysOfWeek,
    intervalDays,
    intervalMonths,
    startDate,
    endDate,
    maxOccurrences,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  ];

  RecurrenceRule copyWith({
    String? id,
    String? userId,
    RecurrenceType? type,
    List<int>? daysOfWeek,
    bool clearDaysOfWeek = false,
    int? intervalDays,
    bool clearIntervalDays = false,
    int? intervalMonths,
    bool clearIntervalMonths = false,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
    int? maxOccurrences,
    bool clearMaxOccurrences = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) {
    return RecurrenceRule(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      daysOfWeek: clearDaysOfWeek ? null : (daysOfWeek ?? this.daysOfWeek),
      intervalDays: clearIntervalDays
          ? null
          : (intervalDays ?? this.intervalDays),
      intervalMonths: clearIntervalMonths
          ? null
          : (intervalMonths ?? this.intervalMonths),
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      maxOccurrences: clearMaxOccurrences
          ? null
          : (maxOccurrences ?? this.maxOccurrences),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  bool isScheduledFor(DateTime date) {
    if (isDeleted) return false;

    final target = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);

    if (target.isBefore(start)) return false;

    if (endDate != null) {
      final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
      if (target.isAfter(end)) return false;
    }

    if (!_matchesPattern(target, start)) {
      return false;
    }

    if (maxOccurrences != null && maxOccurrences! > 0) {
      final count = _countOccurrencesUpTo(target, start);
      if (count > maxOccurrences!) {
        return false;
      }
    }

    return true;
  }

  DateTime? nextOccurrenceAfter(DateTime date) {
    if (isDeleted) return null;

    final start = DateTime(startDate.year, startDate.month, startDate.day);
    DateTime check = DateTime(
      date.year,
      date.month,
      date.day,
    ).add(const Duration(days: 1));
    if (check.isBefore(start)) {
      check = start;
    }

    final end = endDate != null
        ? DateTime(endDate!.year, endDate!.month, endDate!.day)
        : null;

    final maxLookahead = check.add(const Duration(days: 1095));

    while (!check.isAfter(maxLookahead)) {
      if (end != null && check.isAfter(end)) {
        return null;
      }

      if (isScheduledFor(check)) {
        return DateTime(
          check.year,
          check.month,
          check.day,
          startDate.hour,
          startDate.minute,
          startDate.second,
        );
      }
      check = check.add(const Duration(days: 1));
    }

    return null;
  }

  bool _matchesPattern(DateTime target, DateTime start) {
    final diffDays = target.difference(start).inDays;

    switch (type) {
      case RecurrenceType.once:
        return target.isAtSameMomentAs(start);

      case RecurrenceType.daily:
        final step = (intervalDays != null && intervalDays! > 0)
            ? intervalDays!
            : 1;
        return diffDays % step == 0;

      case RecurrenceType.weekdays:
        return target.weekday >= DateTime.monday &&
            target.weekday <= DateTime.friday;

      case RecurrenceType.everyOtherDay:
        return diffDays % 2 == 0;

      case RecurrenceType.everyNDays:
        final step = (intervalDays != null && intervalDays! > 0)
            ? intervalDays!
            : 1;
        return diffDays % step == 0;

      case RecurrenceType.weekly:
        final validDays = (daysOfWeek != null && daysOfWeek!.isNotEmpty)
            ? daysOfWeek!
            : [start.weekday];
        if (!validDays.contains(target.weekday)) return false;

        final step = (intervalDays != null && intervalDays! > 0)
            ? (intervalDays! ~/ 7)
            : 1;
        final intervalWeeks = step > 0 ? step : 1;
        final startWeek = start.difference(DateTime(1970, 1, 5)).inDays ~/ 7;
        final targetWeek = target.difference(DateTime(1970, 1, 5)).inDays ~/ 7;
        return (targetWeek - startWeek) % intervalWeeks == 0;

      case RecurrenceType.monthly:
        final step = (intervalMonths != null && intervalMonths! > 0)
            ? intervalMonths!
            : 1;
        final monthsDiff =
            (target.year - start.year) * 12 + target.month - start.month;
        if (monthsDiff < 0 || monthsDiff % step != 0) return false;
        return target.day == start.day;

      case RecurrenceType.everyNMonths:
        final step = (intervalMonths != null && intervalMonths! > 0)
            ? intervalMonths!
            : 1;
        final monthsDiff =
            (target.year - start.year) * 12 + target.month - start.month;
        if (monthsDiff < 0 || monthsDiff % step != 0) return false;
        return target.day == start.day;

      case RecurrenceType.custom:
        if (daysOfWeek != null && daysOfWeek!.isNotEmpty) {
          if (!daysOfWeek!.contains(target.weekday)) return false;
        }
        if (intervalDays != null && intervalDays! > 0) {
          if (diffDays % intervalDays! != 0) return false;
        }
        if (intervalMonths != null && intervalMonths! > 0) {
          final monthsDiff =
              (target.year - start.year) * 12 + target.month - start.month;
          if (monthsDiff < 0 || monthsDiff % intervalMonths! != 0) {
            return false;
          }
          if (target.day != start.day) return false;
        }
        return true;
    }
  }

  int _countOccurrencesUpTo(DateTime target, DateTime start) {
    int count = 0;
    DateTime cur = start;
    while (!cur.isAfter(target)) {
      if (_matchesPattern(cur, start)) {
        count++;
      }
      cur = cur.add(const Duration(days: 1));
    }
    return count;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'daysOfWeek': daysOfWeek,
      'intervalDays': intervalDays,
      'intervalMonths': intervalMonths,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'maxOccurrences': maxOccurrences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'version': version,
      'isDeleted': isDeleted,
    };
  }

  factory RecurrenceRule.fromMap(Map<String, dynamic> map) {
    return RecurrenceRule(
      id: (map['id'] ?? '').toString(),
      userId: (map['userId'] ?? map['user_id'] ?? '').toString(),
      type: map['type'] != null
          ? RecurrenceType.fromString(map['type'].toString())
          : RecurrenceType.once,
      daysOfWeek: _parseIntList(map['daysOfWeek'] ?? map['days_of_week']),
      intervalDays: _tryParseInt(map['intervalDays'] ?? map['interval_days']),
      intervalMonths: _tryParseInt(
        map['intervalMonths'] ?? map['interval_months'],
      ),
      startDate: _parseDateTime(map['startDate'] ?? map['start_date']),
      endDate: _tryParseDateTime(map['endDate'] ?? map['end_date']),
      maxOccurrences: _tryParseInt(
        map['maxOccurrences'] ?? map['max_occurrences'],
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

  static DateTime? _tryParseDateTime(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    if (val is String && val.isNotEmpty) return DateTime.tryParse(val);
    return null;
  }
}
