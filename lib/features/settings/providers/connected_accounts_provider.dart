import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/platform_sync_service.dart';
import '../../../domain/models/connected_account.dart';
import '../../../shared/providers/database_provider.dart';

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

final platformSyncServiceProvider = Provider<PlatformSyncService>((ref) {
  return PlatformSyncService();
});

class ConnectedAccountsNotifier extends StateNotifier<List<ConnectedAccount>> {
  static const String _prefKey = 'momentum_connected_accounts';
  final Ref? ref;
  final PlatformSyncService _syncService;

  ConnectedAccountsNotifier({this.ref, PlatformSyncService? syncService})
      : _syncService = syncService ?? PlatformSyncService(),
        super(_defaultInitialAccounts()) {
    _loadFromPreferences();
  }

  static List<ConnectedAccount> _defaultInitialAccounts() => const [
        ConnectedAccount(
          platform: ConnectedPlatform.github,
          handle: '',
          profileUrl: '',
          isConnected: false,
          metricUnit: 'followers',
        ),
        ConnectedAccount(
          platform: ConnectedPlatform.linkedin,
          handle: '',
          profileUrl: '',
          isConnected: false,
          metricUnit: 'connections',
        ),
        ConnectedAccount(
          platform: ConnectedPlatform.youtube,
          handle: '',
          profileUrl: '',
          isConnected: false,
          metricUnit: 'subscribers',
        ),
        ConnectedAccount(
          platform: ConnectedPlatform.instagram,
          handle: '',
          profileUrl: '',
          isConnected: false,
          metricUnit: 'followers',
        ),
        ConnectedAccount(
          platform: ConnectedPlatform.twitter,
          handle: '',
          profileUrl: '',
          isConnected: false,
          metricUnit: 'followers',
        ),
        ConnectedAccount(
          platform: ConnectedPlatform.blog,
          handle: '',
          profileUrl: '',
          isConnected: false,
          metricUnit: 'readers',
        ),
      ];

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List;
        final list = decoded
            .map((item) =>
                ConnectedAccount.fromMap(item as Map<String, dynamic>))
            .toList();
        if (mounted) {
          state = list;
        }
      }
    } catch (_) {}
  }

  Future<PlatformSyncResult?> saveAccount({
    required String platform,
    required String handle,
    required String profileUrl,
    String? displayName,
    String? authToken,
    double? metricCount,
    bool autoSync = true,
  }) async {
    final now = DateTime.now();
    final cleanHandle = handle.trim();
    final cleanUrl = profileUrl.trim().isNotEmpty
        ? profileUrl.trim()
        : (platform.toLowerCase() == 'github' && cleanHandle.isNotEmpty
            ? 'https://github.com/$cleanHandle'
            : '');

    final updated = state.map((acc) {
      if (acc.platform.toLowerCase() == platform.toLowerCase()) {
        return acc.copyWith(
          handle: cleanHandle,
          profileUrl: cleanUrl,
          displayName: displayName?.trim(),
          authToken: authToken?.trim(),
          metricCount: metricCount ?? acc.metricCount,
          isConnected: cleanHandle.isNotEmpty,
          syncError: null,
          lastUpdatedAt: now,
        );
      }
      return acc;
    }).toList();

    if (!updated.any((a) => a.platform.toLowerCase() == platform.toLowerCase())) {
      updated.add(
        ConnectedAccount(
          platform: platform,
          handle: cleanHandle,
          profileUrl: cleanUrl,
          displayName: displayName?.trim(),
          authToken: authToken?.trim(),
          metricCount: metricCount,
          isConnected: cleanHandle.isNotEmpty,
          metricUnit: ConnectedPlatform.defaultUnit(platform),
          lastUpdatedAt: now,
        ),
      );
    }

    state = updated;
    await _persist();

    if (autoSync && cleanHandle.isNotEmpty) {
      return await syncAccount(platform);
    }
    return null;
  }

  Future<PlatformSyncResult> syncAccount(String platform) async {
    final target = getAccount(platform);
    if (target == null || target.handle.trim().isEmpty) {
      return PlatformSyncResult.failure(
        platform: platform,
        handle: target?.handle ?? '',
        metricUnit: 'followers',
        error: 'No handle specified to sync.',
      );
    }

    state = state.map((acc) {
      if (acc.platform.toLowerCase() == platform.toLowerCase()) {
        return acc.copyWith(isSyncing: true, syncError: null);
      }
      return acc;
    }).toList();

    final result = await _syncService.syncAccount(
      platform: platform,
      rawHandle: target.handle,
      authToken: target.authToken,
    );

    final now = DateTime.now();
    state = state.map((acc) {
      if (acc.platform.toLowerCase() == platform.toLowerCase()) {
        if (result.success) {
          return acc.copyWith(
            handle: result.handle,
            displayName: result.displayName ?? acc.displayName,
            avatarUrl: result.avatarUrl ?? acc.avatarUrl,
            metricCount: result.metricCount ?? acc.metricCount,
            metricUnit: result.metricUnit,
            additionalStats: result.additionalStats,
            isSyncing: false,
            syncError: null,
            isConnected: true,
            lastUpdatedAt: now,
          );
        } else {
          return acc.copyWith(
            isSyncing: false,
            syncError: result.errorMessage,
          );
        }
      }
      return acc;
    }).toList();

    await _persist();

    if (result.success && ref != null) {
      await _syncMatchingKpis(platform, result);
    }

    return result;
  }

  Future<void> syncAllAccounts() async {
    for (final acc in state.where((a) => a.isConnected && a.handle.isNotEmpty)) {
      await syncAccount(acc.platform);
    }
  }

  Future<void> _syncMatchingKpis(
      String platform, PlatformSyncResult result) async {
    final activeRef = ref;
    if (activeRef == null) return;
    try {
      final userId = activeRef.read(currentUserIdProvider);
      final kpiRepo = activeRef.read(kpiRepositoryProvider);
      final allKpis = await kpiRepo.getAllKpis(userId);

      for (final k in allKpis) {
        if (k.platform.toLowerCase() == platform.toLowerCase()) {
          if (k.metricCategory == 'follower_growth' ||
              k.metricCategory == 'subscriber_growth') {
            if (result.metricCount != null && result.metricCount! > 0) {
              await kpiRepo.updateCurrentValue(k.id, result.metricCount!);
            }
          }
          else if (platform.toLowerCase() == 'github' &&
              (k.name.toLowerCase().contains('repo') ||
                  k.name.toLowerCase().contains('project') ||
                  (k.description?.toLowerCase().contains('repo') ?? false))) {
            final repos = result.additionalStats['public_repos'];
            if (repos is num && repos > 0) {
              await kpiRepo.updateCurrentValue(k.id, repos.toDouble());
            }
          }
          else if (k.name.toLowerCase().contains('star') ||
              (k.description?.toLowerCase().contains('star') ?? false)) {
            final stars = result.additionalStats['stars'];
            if (stars is num && stars > 0) {
              await kpiRepo.updateCurrentValue(k.id, stars.toDouble());
            }
          }
          else if (k.name.toLowerCase().contains('member') ||
              (k.description?.toLowerCase().contains('member') ?? false)) {
            final members = result.additionalStats['members'];
            if (members is num && members > 0) {
              await kpiRepo.updateCurrentValue(k.id, members.toDouble());
            }
          }
        }
      }
    } catch (_) {}
  }

  Future<void> disconnectAccount(String platform) async {
    final updated = state.map((acc) {
      if (acc.platform.toLowerCase() == platform.toLowerCase()) {
        return acc.copyWith(
          handle: '',
          profileUrl: '',
          displayName: null,
          avatarUrl: null,
          authToken: null,
          metricCount: null,
          additionalStats: null,
          syncError: null,
          isSyncing: false,
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

final connectedAccountsProvider =
    StateNotifierProvider<ConnectedAccountsNotifier, List<ConnectedAccount>>(
        (ref) {
  return ConnectedAccountsNotifier(ref: ref);
});
