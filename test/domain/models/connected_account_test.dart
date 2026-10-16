import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/domain/models/connected_account.dart';

void main() {
  group('ConnectedAccount Domain Model', () {
    test('Default constructor and helper getters work as expected', () {
      const account = ConnectedAccount(
        platform: 'github',
        handle: 'alex-dev',
        profileUrl: 'https://github.com/alex-dev',
        displayName: 'Alex Developer',
        avatarUrl: 'https://avatars.githubusercontent.com/u/12345',
        authToken: 'ghp_secret_token',
        metricCount: 1540,
        metricUnit: 'followers',
        additionalStats: {
          'public_repos': 42,
          'stars': 210,
          'members': 5,
          'following': 80,
        },
      );

      expect(account.platformDisplayName, 'GitHub');
      expect(account.hasAuthToken, isTrue);
      expect(account.publicRepos, 42);
      expect(account.totalStars, 210);
      expect(account.membersCount, 5);
      expect(account.followingCount, 80);
      expect(account.isConnected, isTrue);
      expect(account.isSyncing, isFalse);
    });

    test('Serialization toMap and fromMap works symmetrically', () {
      final now = DateTime.now();
      final account = ConnectedAccount(
        platform: 'github',
        handle: 'torvalds',
        profileUrl: 'https://github.com/torvalds',
        displayName: 'Linus Torvalds',
        avatarUrl: 'https://avatars.githubusercontent.com/u/1024',
        authToken: 'ghp_my_pat',
        metricCount: 220000,
        metricUnit: 'followers',
        additionalStats: const {
          'public_repos': 8,
          'stars': 150000,
          'members': 0,
        },
        isConnected: true,
        lastUpdatedAt: now,
      );

      final map = account.toMap();
      final reconstructed = ConnectedAccount.fromMap(map);

      expect(reconstructed.platform, account.platform);
      expect(reconstructed.handle, account.handle);
      expect(reconstructed.profileUrl, account.profileUrl);
      expect(reconstructed.displayName, account.displayName);
      expect(reconstructed.avatarUrl, account.avatarUrl);
      expect(reconstructed.authToken, account.authToken);
      expect(reconstructed.metricCount, account.metricCount);
      expect(reconstructed.metricUnit, account.metricUnit);
      expect(reconstructed.publicRepos, 8);
      expect(reconstructed.totalStars, 150000);
      expect(reconstructed.isConnected, isTrue);
      expect(reconstructed.lastUpdatedAt?.millisecondsSinceEpoch,
          now.millisecondsSinceEpoch);
    });

    test('copyWith updates fields without mutating original', () {
      const initial = ConnectedAccount(
        platform: 'github',
        handle: 'octocat',
        profileUrl: 'https://github.com/octocat',
      );

      final updated = initial.copyWith(
        metricCount: 500,
        avatarUrl: 'https://github.com/octocat.png',
        syncError: 'Rate limit',
        isSyncing: true,
      );

      expect(updated.handle, 'octocat');
      expect(updated.metricCount, 500);
      expect(updated.avatarUrl, 'https://github.com/octocat.png');
      expect(updated.syncError, 'Rate limit');
      expect(updated.isSyncing, isTrue);
      expect(initial.metricCount, isNull);
    });
  });
}
