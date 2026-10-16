import 'dart:convert';
import 'dart:io';

/// Result from syncing an external platform account.
class PlatformSyncResult {
  final bool success;
  final String platform;
  final String handle;
  final double? metricCount;
  final String metricUnit;
  final String? displayName;
  final String? avatarUrl;
  final Map<String, dynamic> additionalStats;
  final String? errorMessage;

  const PlatformSyncResult({
    required this.success,
    required this.platform,
    required this.handle,
    this.metricCount,
    required this.metricUnit,
    this.displayName,
    this.avatarUrl,
    this.additionalStats = const {},
    this.errorMessage,
  });

  factory PlatformSyncResult.failure({
    required String platform,
    required String handle,
    required String metricUnit,
    required String error,
  }) {
    return PlatformSyncResult(
      success: false,
      platform: platform,
      handle: handle,
      metricUnit: metricUnit,
      errorMessage: error,
    );
  }
}

/// Service that communicates with public and authenticated platform APIs (GitHub, etc.).
class PlatformSyncService {
  final HttpClient _client;

  PlatformSyncService({HttpClient? client}) : _client = client ?? HttpClient() {
    _client.connectionTimeout = const Duration(seconds: 10);
  }

  /// Cleans up raw handle input (strips `@` and extracts username from profile URLs).
  static String extractCleanHandle(String input, String platform) {
    var cleaned = input.trim();
    if (cleaned.isEmpty) return '';

    // Strip trailing slashes
    while (cleaned.endsWith('/')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }

    // If a full URL was provided, extract the last path segment
    if (cleaned.startsWith('http://') || cleaned.startsWith('https://')) {
      final uri = Uri.tryParse(cleaned);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        // e.g. https://github.com/username or https://linkedin.com/in/username
        cleaned = uri.pathSegments.last;
      }
    }

    // Strip leading @
    if (cleaned.startsWith('@')) {
      cleaned = cleaned.substring(1);
    }

    return cleaned.trim();
  }

  /// Syncs an account based on its platform and parameters.
  Future<PlatformSyncResult> syncAccount({
    required String platform,
    required String rawHandle,
    String? authToken,
  }) async {
    final cleanHandle = extractCleanHandle(rawHandle, platform);
    if (cleanHandle.isEmpty) {
      return PlatformSyncResult.failure(
        platform: platform,
        handle: rawHandle,
        metricUnit: 'followers',
        error: 'Please enter a valid username or URL.',
      );
    }

    switch (platform.toLowerCase()) {
      case 'github':
        return _syncGitHub(cleanHandle, authToken);
      default:
        // Generic fallback for platforms without public REST endpoints
        return PlatformSyncResult(
          success: true,
          platform: platform,
          handle: cleanHandle,
          metricUnit: 'followers',
          displayName: cleanHandle,
          additionalStats: const {},
        );
    }
  }

  /// Syncs GitHub account metrics (followers, public repos, following, stars, and members).
  Future<PlatformSyncResult> _syncGitHub(String username, String? authToken) async {
    try {
      // 1. Fetch user or organization profile
      final userUri = Uri.parse('https://api.github.com/users/$username');
      final req = await _client.getUrl(userUri);
      req.headers.set(HttpHeaders.userAgentHeader, 'Momentum-Productivity-App');
      req.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github.v3+json');

      if (authToken != null && authToken.trim().isNotEmpty) {
        req.headers.set(HttpHeaders.authorizationHeader, 'Bearer ${authToken.trim()}');
      }

      final res = await req.close();
      final bodyStr = await res.transform(utf8.decoder).join();

      if (res.statusCode == 404) {
        return PlatformSyncResult.failure(
          platform: 'github',
          handle: username,
          metricUnit: 'followers',
          error: 'GitHub user or organization "$username" not found.',
        );
      }

      if (res.statusCode == 403) {
        final rateLimitRemaining = res.headers.value('x-ratelimit-remaining');
        if (rateLimitRemaining == '0') {
          return PlatformSyncResult.failure(
            platform: 'github',
            handle: username,
            metricUnit: 'followers',
            error:
                'GitHub public API rate limit reached (60/hr). Add a GitHub Personal Access Token in settings to get 5,000 requests/hr.',
          );
        }
        return PlatformSyncResult.failure(
          platform: 'github',
          handle: username,
          metricUnit: 'followers',
          error: 'GitHub API authorization failed. Please check your token.',
        );
      }

      if (res.statusCode != 200) {
        return PlatformSyncResult.failure(
          platform: 'github',
          handle: username,
          metricUnit: 'followers',
          error: 'GitHub API error (HTTP ${res.statusCode}).',
        );
      }

      final userData = jsonDecode(bodyStr) as Map<String, dynamic>;
      final followers = (userData['followers'] as num?)?.toDouble() ?? 0.0;
      final following = (userData['following'] as num?)?.toInt() ?? 0;
      final publicRepos = (userData['public_repos'] as num?)?.toInt() ?? 0;
      final displayName = userData['name'] as String? ?? userData['login'] as String? ?? username;
      final avatarUrl = userData['avatar_url'] as String?;
      final isOrg = userData['type'] == 'Organization';

      // 2. Try fetching total stars from public repos (up to first 100)
      int totalStars = 0;
      int membersCount = 0;

      try {
        final reposUri =
            Uri.parse('https://api.github.com/users/$username/repos?per_page=100&sort=updated');
        final reposReq = await _client.getUrl(reposUri);
        reposReq.headers.set(HttpHeaders.userAgentHeader, 'Momentum-Productivity-App');
        reposReq.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github.v3+json');
        if (authToken != null && authToken.trim().isNotEmpty) {
          reposReq.headers.set(HttpHeaders.authorizationHeader, 'Bearer ${authToken.trim()}');
        }
        final reposRes = await reposReq.close();
        if (reposRes.statusCode == 200) {
          final reposStr = await reposRes.transform(utf8.decoder).join();
          final reposList = jsonDecode(reposStr) as List;
          for (final r in reposList) {
            if (r is Map<String, dynamic>) {
              totalStars += (r['stargazers_count'] as num?)?.toInt() ?? 0;
            }
          }
        }
      } catch (_) {}

      // 3. If organization, fetch members count
      if (isOrg) {
        try {
          final membersUri =
              Uri.parse('https://api.github.com/orgs/$username/members?per_page=100');
          final mReq = await _client.getUrl(membersUri);
          mReq.headers.set(HttpHeaders.userAgentHeader, 'Momentum-Productivity-App');
          mReq.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github.v3+json');
          if (authToken != null && authToken.trim().isNotEmpty) {
            mReq.headers.set(HttpHeaders.authorizationHeader, 'Bearer ${authToken.trim()}');
          }
          final mRes = await mReq.close();
          if (mRes.statusCode == 200) {
            final mStr = await mRes.transform(utf8.decoder).join();
            final mList = jsonDecode(mStr) as List;
            membersCount = mList.length;
          }
        } catch (_) {}
      }

      final stats = <String, dynamic>{
        'followers': followers.toInt(),
        'following': following,
        'public_repos': publicRepos,
        'stars': totalStars,
        if (isOrg || membersCount > 0) 'members': membersCount,
        'type': userData['type'],
        'bio': userData['bio'],
      };

      return PlatformSyncResult(
        success: true,
        platform: 'github',
        handle: username,
        displayName: displayName,
        avatarUrl: avatarUrl,
        metricCount: followers,
        metricUnit: 'followers',
        additionalStats: stats,
      );
    } on SocketException {
      return PlatformSyncResult.failure(
        platform: 'github',
        handle: username,
        metricUnit: 'followers',
        error: 'Unable to connect to GitHub. Check your network connection.',
      );
    } catch (e) {
      return PlatformSyncResult.failure(
        platform: 'github',
        handle: username,
        metricUnit: 'followers',
        error: 'Failed to sync with GitHub: $e',
      );
    }
  }
}
