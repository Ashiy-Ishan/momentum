import 'package:equatable/equatable.dart';

/// Represents a user's connected social or developer account (GitHub, LinkedIn, YouTube, etc.).
class ConnectedAccount extends Equatable {
  final String platform; // 'github', 'linkedin', 'youtube', 'instagram', 'twitter', 'blog'
  final String handle; // e.g. '@alexdev', 'alex-coder'
  final String profileUrl; // e.g. 'https://github.com/alexdev'
  final String? displayName;
  final double? metricCount; // e.g. followers, subscribers, connections
  final String? metricUnit; // e.g. 'followers', 'subs', 'connections'
  final bool isConnected;
  final DateTime? lastUpdatedAt;

  const ConnectedAccount({
    required this.platform,
    required this.handle,
    required this.profileUrl,
    this.displayName,
    this.metricCount,
    this.metricUnit,
    this.isConnected = true,
    this.lastUpdatedAt,
  });

  /// Human-readable brand name of the platform.
  String get platformDisplayName {
    switch (platform.toLowerCase()) {
      case 'github':
        return 'GitHub';
      case 'linkedin':
        return 'LinkedIn';
      case 'youtube':
        return 'YouTube';
      case 'instagram':
        return 'Instagram';
      case 'twitter':
      case 'x':
        return 'X / Twitter';
      case 'blog':
        return 'Blog / Site';
      default:
        return platform;
    }
  }

  ConnectedAccount copyWith({
    String? platform,
    String? handle,
    String? profileUrl,
    String? displayName,
    double? metricCount,
    String? metricUnit,
    bool? isConnected,
    DateTime? lastUpdatedAt,
  }) {
    return ConnectedAccount(
      platform: platform ?? this.platform,
      handle: handle ?? this.handle,
      profileUrl: profileUrl ?? this.profileUrl,
      displayName: displayName ?? this.displayName,
      metricCount: metricCount ?? this.metricCount,
      metricUnit: metricUnit ?? this.metricUnit,
      isConnected: isConnected ?? this.isConnected,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'platform': platform,
      'handle': handle,
      'profileUrl': profileUrl,
      'displayName': displayName,
      'metricCount': metricCount,
      'metricUnit': metricUnit,
      'isConnected': isConnected,
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
    };
  }

  factory ConnectedAccount.fromMap(Map<String, dynamic> map) {
    return ConnectedAccount(
      platform: map['platform'] as String? ?? 'general',
      handle: map['handle'] as String? ?? '',
      profileUrl: map['profileUrl'] as String? ?? '',
      displayName: map['displayName'] as String?,
      metricCount: (map['metricCount'] as num?)?.toDouble(),
      metricUnit: map['metricUnit'] as String?,
      isConnected: map['isConnected'] as bool? ?? true,
      lastUpdatedAt: map['lastUpdatedAt'] != null
          ? DateTime.tryParse(map['lastUpdatedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        platform,
        handle,
        profileUrl,
        displayName,
        metricCount,
        metricUnit,
        isConnected,
        lastUpdatedAt,
      ];
}
