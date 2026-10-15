import 'package:equatable/equatable.dart';

/// Represents a label/category for grouping tasks or KPIs.
class Label with Equatable {
  final String id;
  final String userId;
  final String? parentId;
  final String name;
  final String iconName; // Material icon name
  final String color; // Hex color string (e.g. #FF5722)
  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;

  const Label({
    required this.id,
    required this.userId,
    this.parentId,
    required this.name,
    required this.iconName,
    required this.color,
    this.sortOrder = 0,
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
    parentId,
    name,
    iconName,
    color,
    sortOrder,
    isArchived,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  ];

  Label copyWith({
    String? id,
    String? userId,
    String? parentId,
    bool clearParentId = false,
    String? name,
    String? iconName,
    String? color,
    int? sortOrder,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) {
    return Label(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      parentId: clearParentId ? null : (parentId ?? this.parentId),
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
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
      'parentId': parentId,
      'name': name,
      'iconName': iconName,
      'color': color,
      'sortOrder': sortOrder,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'version': version,
      'isDeleted': isDeleted,
    };
  }

  factory Label.fromMap(Map<String, dynamic> map) {
    return Label(
      id: (map['id'] ?? '').toString(),
      userId: (map['userId'] ?? map['user_id'] ?? '').toString(),
      parentId: (map['parentId'] ?? map['parent_id'])?.toString(),
      name: (map['name'] ?? '').toString(),
      iconName: (map['iconName'] ?? map['icon_name'] ?? '').toString(),
      color: (map['color'] ?? '').toString(),
      sortOrder: _parseInt(map['sortOrder'] ?? map['sort_order'], 0),
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
