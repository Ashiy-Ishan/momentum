import 'package:equatable/equatable.dart';

import '../enums/enums.dart';

/// Defines a Key Performance Indicator (KPI) metric and its targets.
class KpiDefinition with Equatable {
  final String id;
  final String userId;
  final String? labelId;
  final String name;
  final String? description;
  final KpiType kpiType;
  final double targetValue;
  final KpiPeriod period;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;

  const KpiDefinition({
    required this.id,
    required this.userId,
    this.labelId,
    required this.name,
    this.description,
    this.kpiType = KpiType.count,
    this.targetValue = 0.0,
    this.period = KpiPeriod.daily,
    required this.startDate,
    this.endDate,
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
    name,
    description,
    kpiType,
    targetValue,
    period,
    startDate,
    endDate,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  ];

  KpiDefinition copyWith({
    String? id,
    String? userId,
    String? labelId,
    bool clearLabelId = false,
    String? name,
    String? description,
    bool clearDescription = false,
    KpiType? kpiType,
    double? targetValue,
    KpiPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) {
    return KpiDefinition(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      labelId: clearLabelId ? null : (labelId ?? this.labelId),
      name: name ?? this.name,
      description: clearDescription ? null : (description ?? this.description),
      kpiType: kpiType ?? this.kpiType,
      targetValue: targetValue ?? this.targetValue,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
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
      'name': name,
      'description': description,
      'kpiType': kpiType.name,
      'targetValue': targetValue,
      'period': period.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'version': version,
      'isDeleted': isDeleted,
    };
  }

  factory KpiDefinition.fromMap(Map<String, dynamic> map) {
    return KpiDefinition(
      id: (map['id'] ?? '').toString(),
      userId: (map['userId'] ?? map['user_id'] ?? '').toString(),
      labelId: (map['labelId'] ?? map['label_id'])?.toString(),
      name: (map['name'] ?? '').toString(),
      description: (map['description'])?.toString(),
      kpiType: map['kpiType'] != null || map['kpi_type'] != null
          ? KpiType.fromString((map['kpiType'] ?? map['kpi_type']).toString())
          : KpiType.count,
      targetValue: _parseDouble(map['targetValue'] ?? map['target_value'], 0.0),
      period: map['period'] != null
          ? KpiPeriod.fromString(map['period'].toString())
          : KpiPeriod.daily,
      startDate: _parseDateTime(map['startDate'] ?? map['start_date']),
      endDate: _tryParseDateTime(map['endDate'] ?? map['end_date']),
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

  static double _parseDouble(dynamic val, [double fallback = 0.0]) {
    if (val is double) return val;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? fallback;
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
