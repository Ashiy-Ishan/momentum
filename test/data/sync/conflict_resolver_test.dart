import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/data/sync/conflict_resolver.dart';

void main() {
  group('ConflictResolver', () {
    const resolver = ConflictResolver();

    group('Policy 3: Append-Only (Preserve Both)', () {
      test('identifies completion_events as append-only', () {
        expect(resolver.isAppendOnly('completion_events'), isTrue);
        final result = resolver.resolve(
          tableName: 'completion_events',
          localData: {'id': 'evt-1', 'task_id': 'task-1', 'version': 1},
          remoteData: {'id': 'evt-1', 'task_id': 'task-1', 'version': 2},
        );
        expect(result.resolution, ConflictResolution.preserveBoth);
        expect(result.shouldPreserveBoth, isTrue);
      });

      test('identifies timer_sessions as append-only', () {
        expect(resolver.isAppendOnly('timer_sessions'), isTrue);
        final result = resolver.resolve(
          tableName: 'timer_sessions',
          localData: {'id': 'ts-1', 'elapsed_seconds': 100},
          remoteData: {'id': 'ts-1', 'elapsed_seconds': 200},
        );
        expect(result.resolution, ConflictResolution.preserveBoth);
      });

      test('regular tables are not append-only', () {
        expect(resolver.isAppendOnly('tasks'), isFalse);
        expect(resolver.isAppendOnly('labels'), isFalse);
        expect(resolver.isAppendOnly('recurrence_rules'), isFalse);
        expect(resolver.isAppendOnly('notification_settings'), isFalse);
      });
    });

    group('Policy 2: Server-Wins for Deletion Conflicts', () {
      test('remote deletion wins over local active update', () {
        final now = DateTime.now();
        final result = resolver.resolve(
          tableName: 'tasks',
          localData: {
            'id': 'task-1',
            'title': 'Local modified title',
            'is_deleted': false,
            'updated_at': now.toIso8601String(),
            'version': 5,
          },
          remoteData: {
            'id': 'task-1',
            'title': 'Original title',
            'is_deleted': true,
            'updated_at': now.subtract(const Duration(hours: 1)).toIso8601String(),
            'version': 3,
          },
        );
        expect(result.resolution, ConflictResolution.remoteWins);
        expect(result.isRemoteWinner, isTrue);
      });

      test('remote active record wins over local deletion', () {
        final now = DateTime.now();
        final result = resolver.resolve(
          tableName: 'tasks',
          localData: {
            'id': 'task-1',
            'is_deleted': true,
            'updated_at': now.toIso8601String(),
            'version': 2,
          },
          remoteData: {
            'id': 'task-1',
            'title': 'Remote updated title',
            'is_deleted': false,
            'updated_at': now.toIso8601String(),
            'version': 2,
          },
        );
        expect(result.resolution, ConflictResolution.remoteWins);
      });
    });

    group('Policy 1: Last-Write-Wins based on version & updatedAt', () {
      test('higher local version wins over lower remote version', () {
        final now = DateTime.now();
        final result = resolver.resolve(
          tableName: 'tasks',
          localData: {
            'id': 'task-1',
            'title': 'V2 Local',
            'version': 2,
            'updated_at': now.toIso8601String(),
          },
          remoteData: {
            'id': 'task-1',
            'title': 'V1 Remote',
            'version': 1,
            'updated_at': now.toIso8601String(),
          },
        );
        expect(result.resolution, ConflictResolution.localWins);
        expect(result.isLocalWinner, isTrue);
      });

      test('higher remote version wins over lower local version', () {
        final now = DateTime.now();
        final result = resolver.resolve(
          tableName: 'tasks',
          localData: {
            'id': 'task-1',
            'title': 'V1 Local',
            'version': 1,
            'updated_at': now.toIso8601String(),
          },
          remoteData: {
            'id': 'task-1',
            'title': 'V3 Remote',
            'version': 3,
            'updated_at': now.toIso8601String(),
          },
        );
        expect(result.resolution, ConflictResolution.remoteWins);
      });

      test('equal version: newer local timestamp wins', () {
        final now = DateTime.now();
        final result = resolver.resolve(
          tableName: 'labels',
          localData: {
            'id': 'lbl-1',
            'name': 'Local Newer',
            'version': 1,
            'updated_at': now.toIso8601String(),
          },
          remoteData: {
            'id': 'lbl-1',
            'name': 'Remote Older',
            'version': 1,
            'updated_at': now.subtract(const Duration(minutes: 5)).toIso8601String(),
          },
        );
        expect(result.resolution, ConflictResolution.localWins);
      });

      test('equal version: newer remote timestamp wins', () {
        final now = DateTime.now();
        final result = resolver.resolve(
          tableName: 'labels',
          localData: {
            'id': 'lbl-1',
            'name': 'Local Older',
            'version': 1,
            'updated_at': now.subtract(const Duration(minutes: 5)).toIso8601String(),
          },
          remoteData: {
            'id': 'lbl-1',
            'name': 'Remote Newer',
            'version': 1,
            'updated_at': now.toIso8601String(),
          },
        );
        expect(result.resolution, ConflictResolution.remoteWins);
      });

      test('equal version and equal timestamp: fallback to remote tie-breaker', () {
        final now = DateTime.now();
        final result = resolver.resolve(
          tableName: 'kpi_definitions',
          localData: {
            'id': 'kpi-1',
            'version': 1,
            'updated_at': now.toIso8601String(),
          },
          remoteData: {
            'id': 'kpi-1',
            'version': 1,
            'updated_at': now.toIso8601String(),
          },
        );
        expect(result.resolution, ConflictResolution.remoteWins);
      });
    });
  });
}
