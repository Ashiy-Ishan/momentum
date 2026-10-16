import 'package:equatable/equatable.dart';

/// Represents a user's connected social or developer account (GitHub, LinkedIn, YouTube, etc.).
class ConnectedAccount extends Equatable {
  final String platform; // 'github', 'linkedin', 'youtube', 'instagram', 'twitter', 'blog'
  final String handle; // e.g. '@alexdev', 'alex-coder'
  final String profileUrl; // e.g. 'https://github.com/alexdev'
  final String? displayName;
  final String? avatarUrl;
  final String? authToken; // Optional API token (e.g. GitHub Personal Access Token)
  final double? metricCount; // e.g. followers, subscribers, connections
  final String? metricUnit; // e.g. 'followers', 'subs', 'connections'
  final Map<String, dynamic>? additionalStats; // e.g. {'public_repos': 42, 'stars': 120, 'members': 15}
  final bool isConnected;
  final bool isSyncing;
  final String? syncError;
  final DateTime? lastUpdatedAt;

  const ConnectedAccount({
    required this.platform,
    required this.handle,
    required this.profileUrl,
    this.displayName,
    this.avatarUrl,
    this.authToken,
    this.metricCount,
    this.metricUnit,
    this.additionalStats,
    this.isConnected = true,
    this.isSyncing = false,
    this.syncError,
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

  /// Whether an API token / PAT is configured.
  bool get hasAuthToken => authToken != null && authToken!.trim().isNotEmpty;

  /// Public repositories count (for GitHub or developer accounts).
  int? get publicRepos => additionalStats?['public_repos'] as int?;

  /// Total stars received across repositories.
  int? get totalStars => additionalStats?['stars'] as int?;

  /// Organization members or team contributors count.
  int? get membersCount => additionalStats?['members'] as int?;

  /// Following count.
  int? get followingCount => additionalStats?['following'] as int?;

  ConnectedAccount copyWith({
    String? platform,
    String? handle,
    String? profileUrl,
    String? displayName,
    String? avatarUrl,
    String? authToken,
    double? metricCount,
    String? metricUnit,
    Map<String, dynamic>? additionalStats,
    bool? isConnected,
    bool? isSyncing,
    String? syncError,
    DateTime? lastUpdatedAt,
  }) {
    return ConnectedAccount(
      platform: platform ?? this.platform,
      handle: handle ?? this.handle,
      profileUrl: profileUrl ?? this.profileUrl,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      authToken: authToken ?? this.authToken,
      metricCount: metricCount ?? this.metricCount,
      metricUnit: metricUnit ?? this.metricUnit,
      additionalStats: additionalStats ?? this.additionalStats,
      isConnected: isConnected ?? this.isConnected,
      isSyncing: isSyncing ?? this.isSyncing,
      syncError: syncError,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'platform': platform,
      'handle': handle,
      'profileUrl': profileUrl,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'authToken': authToken,
      'metricCount': metricCount,
      'metricUnit': metricUnit,
      'additionalStats': additionalStats,
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
      avatarUrl: map['avatarUrl'] as String?,
      authToken: map['authToken'] as String?,
      metricCount: (map['metricCount'] as num?)?.toDouble(),
      metricUnit: map['metricUnit'] as String?,
      additionalStats: map['additionalStats'] != null
          ? Map<String, dynamic>.from(map['additionalStats'] as Map)
          : null,
      isConnected: map['isConnected'] as bool? ?? true,
      isSyncing: false,
      syncError: null,
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
        avatarUrl,
        authToken,
        metricCount,
        metricUnit,
        additionalStats,
        isConnected,
        isSyncing,
        syncError,
        lastUpdatedAt,
      ];
}
