import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/services/platform_sync_service.dart';
import 'package:momentum/features/settings/providers/connected_accounts_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakePlatformSyncService extends PlatformSyncService {
  @override
  Future<PlatformSyncResult> syncAccount({
    required String platform,
    required String rawHandle,
    String? authToken,
  }) async {
    final clean = PlatformSyncService.extractCleanHandle(rawHandle, platform);
    return PlatformSyncResult(
      success: true,
      platform: platform,
      handle: clean,
      displayName: 'Simulated $clean',
      metricCount: 1250,
      metricUnit: 'followers',
      avatarUrl: 'https://avatars.githubusercontent.com/u/999',
      additionalStats: const {
        'public_repos': 34,
        'stars': 150,
        'members': 4,
      },
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConnectedAccountsNotifier Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initializes with default supported platforms', () {
      final container = ProviderContainer(
        overrides: [
          platformSyncServiceProvider
              .overrideWithValue(FakePlatformSyncService()),
        ],
      );
      addTearDown(container.dispose);

      final accounts = container.read(connectedAccountsProvider);
      expect(accounts.any((a) => a.platform == 'github'), isTrue);
      expect(accounts.any((a) => a.platform == 'linkedin'), isTrue);
      expect(accounts.any((a) => a.platform == 'youtube'), isTrue);
    });

    test('saveAccount and syncAccount fetch live stats and update state',
        () async {
      final fakeService = FakePlatformSyncService();
      final notifier = ConnectedAccountsNotifier(syncService: fakeService);

      await notifier.saveAccount(
        platform: 'github',
        handle: 'flutter-dev',
        profileUrl: 'https://github.com/flutter-dev',
        authToken: 'ghp_sample_token',
        autoSync: true,
      );

      final account = notifier.getAccount('github');
      expect(account, isNotNull);
      expect(account!.isConnected, isTrue);
      expect(account.handle, 'flutter-dev');
      expect(account.metricCount, 1250);
      expect(account.publicRepos, 34);
      expect(account.totalStars, 150);
      expect(account.membersCount, 4);
      expect(account.hasAuthToken, isTrue);
      expect(account.avatarUrl, isNotNull);
    });

    test('disconnectAccount clears account data and marks disconnected',
        () async {
      final fakeService = FakePlatformSyncService();
      final notifier = ConnectedAccountsNotifier(syncService: fakeService);

      await notifier.saveAccount(
        platform: 'github',
        handle: 'test-user',
        profileUrl: 'https://github.com/test-user',
        autoSync: false,
      );

      expect(notifier.getAccount('github')!.isConnected, isTrue);

      await notifier.disconnectAccount('github');
      final cleared = notifier.getAccount('github');
      expect(cleared!.isConnected, isFalse);
      expect(cleared.handle, isEmpty);
      expect(cleared.metricCount, isNull);
    });
  });
}
