import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/services/platform_sync_service.dart';

void main() {
  group('PlatformSyncService Tests', () {
    test('extractCleanHandle handles usernames, leading @ and full URLs', () {
      expect(PlatformSyncService.extractCleanHandle('torvalds', 'github'), 'torvalds');
      expect(PlatformSyncService.extractCleanHandle('@torvalds', 'github'), 'torvalds');
      expect(PlatformSyncService.extractCleanHandle('https://github.com/torvalds', 'github'), 'torvalds');
      expect(PlatformSyncService.extractCleanHandle('https://github.com/torvalds/', 'github'), 'torvalds');
      expect(PlatformSyncService.extractCleanHandle('https://linkedin.com/in/satya', 'linkedin'), 'satya');
      expect(PlatformSyncService.extractCleanHandle('   alex_coder   ', 'twitter'), 'alex_coder');
    });

    test('PlatformSyncResult failure factory assigns correct properties', () {
      final res = PlatformSyncResult.failure(
        platform: 'github',
        handle: 'nonexistent_user_9999',
        metricUnit: 'followers',
        error: 'User not found',
      );

      expect(res.success, isFalse);
      expect(res.platform, 'github');
      expect(res.handle, 'nonexistent_user_9999');
      expect(res.errorMessage, 'User not found');
      expect(res.metricCount, isNull);
    });
  });
}
