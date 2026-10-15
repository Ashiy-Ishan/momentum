import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/tables.dart';

part 'sync_dao.g.dart';

@DriftAccessor(tables: [SyncQueueItems])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  /// Retrieves pending synchronization queue items ordered by creation time.
  Future<List<SyncQueueItem>> getPendingItems() {
    return (select(syncQueueItems)
          ..where((tbl) => tbl.status.equals('pending'))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
        .get();
  }

  /// Enqueues a new item into the sync queue.
  Future<void> enqueue(SyncQueueItemsCompanion item) async {
    await into(syncQueueItems).insert(item);
  }

  /// Marks a sync queue item as completed.
  Future<void> markCompleted(String id) async {
    await (update(syncQueueItems)..where((tbl) => tbl.id.equals(id))).write(
      const SyncQueueItemsCompanion(status: Value('completed')),
    );
  }

  /// Marks a sync queue item as failed with an error message.
  Future<void> markFailed(String id, String error) async {
    await (update(syncQueueItems)..where((tbl) => tbl.id.equals(id))).write(
      SyncQueueItemsCompanion(
        status: const Value('failed'),
        errorMessage: Value(error),
        lastAttemptedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Increments the retry counter and updates the last attempted timestamp.
  Future<void> incrementRetry(String id) async {
    final item = await (select(
      syncQueueItems,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (item != null) {
      await (update(syncQueueItems)..where((tbl) => tbl.id.equals(id))).write(
        SyncQueueItemsCompanion(
          retryCount: Value(item.retryCount + 1),
          lastAttemptedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  /// Clears all successfully completed items from the queue.
  Future<void> clearCompleted() async {
    await (delete(
      syncQueueItems,
    )..where((tbl) => tbl.status.equals('completed'))).go();
  }

  /// Gets the count of currently pending items.
  Future<int> pendingCount() async {
    final countExpr = syncQueueItems.id.count();
    final query = selectOnly(syncQueueItems)
      ..addColumns([countExpr])
      ..where(syncQueueItems.status.equals('pending'));
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// Watches the stream of pending item count.
  Stream<int> watchPendingCount() {
    final countExpr = syncQueueItems.id.count();
    final query = selectOnly(syncQueueItems)
      ..addColumns([countExpr])
      ..where(syncQueueItems.status.equals('pending'));
    return query.watchSingle().map((row) => row.read(countExpr) ?? 0);
  }
}
