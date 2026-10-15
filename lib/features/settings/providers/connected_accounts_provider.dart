import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/models/connected_account.dart';

/// Supported social and developer creator platforms.
abstract class ConnectedPlatform {
  static const String github = 'github';
  static const String linkedin = 'linkedin';
  static const String youtube = 'youtube';
  static const String instagram = 'instagram';
  static const String twitter = 'twitter';
  static const String blog = 'blog';

  static const List<String> all = [
    github,
    linkedin,
    youtube,
    instagram,
    twitter,
    blog,
  ];

  static String displayName(String platform) {
    switch (platform.toLowerCase()) {
      case github:
        return 'GitHub';
      case linkedin:
        return 'LinkedIn';
      case youtube:
        return 'YouTube';
      case instagram:
        return 'Instagram';
      case twitter:
        return 'X / Twitter';
      case blog:
        return 'Blog / Site';
      default:
        return platform;
    }
  }

  static String defaultUnit(String platform) {
    switch (platform.toLowerCase()) {
      case github:
        return 'followers';
      case linkedin:
        return 'connections';
      case youtube:
        return 'subscribers';
      case instagram:
        return 'followers';
      case twitter:
        return 'followers';
      case blog:
        return 'readers';
      default:
        return 'audience';
    }
  }
}

/// Manages and persists connected creator and social accounts.
class ConnectedAccountsNotifier extends StateNotifier<List<ConnectedAccount>> {
  static const String _prefKey = 'momentum_connected_accounts';

  ConnectedAccountsNotifier() : super([]) {
    _loadFromPreferences();
  }

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List;
        final list = decoded
            .map((item) => ConnectedAccount.fromMap(item as Map<String, dynamic>))
            .toList();
        state = list;
        return;
      }
    } catch (_) {}

    // Initial placeholder empty accounts for supported platforms
    state = [
      const ConnectedAccount(
        platform: ConnectedPlatform.github,
        handle: '',
        profileUrl: '',
        isConnected: false,
        metricUnit: 'followers',
      ),
      const ConnectedAccount(
        platform: ConnectedPlatform.linkedin,
        handle: '',
        profileUrl: '',
        isConnected: false,
        metricUnit: 'connections',
      ),
      const ConnectedAccount(
        platform: ConnectedPlatform.youtube,
        handle: '',
        profileUrl: '',
        isConnected: false,
        metricUnit: 'subscribers',
      ),
      const ConnectedAccount(
        platform: ConnectedPlatform.instagram,
        handle: '',
        profileUrl: '',
        isConnected: false,
        metricUnit: 'followers',
      ),
      const ConnectedAccount(
        platform: ConnectedPlatform.twitter,
        handle: '',
        profileUrl: '',
        isConnected: false,
        metricUnit: 'followers',
      ),
      const ConnectedAccount(
        platform: ConnectedPlatform.blog,
        handle: '',
        profileUrl: '',
        isConnected: false,
        metricUnit: 'readers',
      ),
    ];
  }

  Future<void> saveAccount({
    required String platform,
    required String handle,
    required String profileUrl,
    String? displayName,
    double? metricCount,
  }) async {
    final now = DateTime.now();
    final updated = state.map((acc) {
      if (acc.platform.toLowerCase() == platform.toLowerCase()) {
        return acc.copyWith(
          handle: handle.trim(),
          profileUrl: profileUrl.trim(),
          displayName: displayName?.trim(),
          metricCount: metricCount,
          isConnected: handle.trim().isNotEmpty,
          lastUpdatedAt: now,
        );
      }
      return acc;
    }).toList();

    // If platform wasn't already in list, append it
    if (!updated.any((a) => a.platform.toLowerCase() == platform.toLowerCase())) {
      updated.add(
        ConnectedAccount(
          platform: platform,
          handle: handle.trim(),
          profileUrl: profileUrl.trim(),
          displayName: displayName?.trim(),
          metricCount: metricCount,
          isConnected: handle.trim().isNotEmpty,
          metricUnit: ConnectedPlatform.defaultUnit(platform),
          lastUpdatedAt: now,
        ),
      );
    }

    state = updated;
    await _persist();
  }

  Future<void> disconnectAccount(String platform) async {
    final updated = state.map((acc) {
      if (acc.platform.toLowerCase() == platform.toLowerCase()) {
        return acc.copyWith(
          handle: '',
          profileUrl: '',
          displayName: null,
          metricCount: null,
          isConnected: false,
        );
      }
      return acc;
    }).toList();

    state = updated;
    await _persist();
  }

  Future<void> updateMetricCount(String platform, double newCount) async {
    final now = DateTime.now();
    final updated = state.map((acc) {
      if (acc.platform.toLowerCase() == platform.toLowerCase()) {
        return acc.copyWith(
          metricCount: newCount,
          lastUpdatedAt: now,
        );
      }
      return acc;
    }).toList();

    state = updated;
    await _persist();
  }

  ConnectedAccount? getAccount(String platform) {
    try {
      return state.firstWhere(
        (a) => a.platform.toLowerCase() == platform.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(state.map((a) => a.toMap()).toList());
      await prefs.setString(_prefKey, jsonStr);
    } catch (_) {}
  }
}

/// Provider for connected creator and social accounts.
final connectedAccountsProvider =
    StateNotifierProvider<ConnectedAccountsNotifier, List<ConnectedAccount>>(
        (ref) {
  return ConnectedAccountsNotifier();
});
