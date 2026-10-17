import 'package:equatable/equatable.dart';

class UserProfile with Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final String timezone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;

  const UserProfile({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.timezone = 'UTC',
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    avatarUrl,
    timezone,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  ];

  UserProfile copyWith({
    String? id,
    String? email,
    bool clearEmail = false,
    String? displayName,
    bool clearDisplayName = false,
    String? avatarUrl,
    bool clearAvatarUrl = false,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: clearEmail ? null : (email ?? this.email),
      displayName: clearDisplayName ? null : (displayName ?? this.displayName),
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'timezone': timezone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'version': version,
      'isDeleted': isDeleted,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: (map['id'] ?? '').toString(),
      email: (map['email'])?.toString(),
      displayName: (map['displayName'] ?? map['display_name'])?.toString(),
      avatarUrl: (map['avatarUrl'] ?? map['avatar_url'])?.toString(),
      timezone: (map['timezone'] ?? 'UTC').toString(),
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
