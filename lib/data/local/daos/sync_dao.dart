import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/tables.dart';

part 'sync_dao.g.dart';

@DriftAccessor(tables: [SyncQueueItems])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  Future<List<SyncQueueItem>> getPendingItems() {
    return (select(syncQueueItems)
          ..where((tbl) => tbl.status.equals('pending'))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
        .get();
  }

  Future<void> enqueue(SyncQueueItemsCompanion item) async {
    await into(syncQueueItems).insert(item);
  }

  Future<void> markCompleted(String id) async {
    await (update(syncQueueItems)..where((tbl) => tbl.id.equals(id))).write(
      const SyncQueueItemsCompanion(status: Value('completed')),
    );
  }

  Future<void> markFailed(String id, String error) async {
    await (update(syncQueueItems)..where((tbl) => tbl.id.equals(id))).write(
      SyncQueueItemsCompanion(
        status: const Value('failed'),
        errorMessage: Value(error),
        lastAttemptedAt: Value(DateTime.now()),
      ),
    );
  }

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

  Future<void> clearCompleted() async {
    await (delete(
      syncQueueItems,
    )..where((tbl) => tbl.status.equals('completed'))).go();
  }

  Future<int> pendingCount() async {
    final countExpr = syncQueueItems.id.count();
    final query = selectOnly(syncQueueItems)
      ..addColumns([countExpr])
      ..where(syncQueueItems.status.equals('pending'));
    final row = await query.getSingleOrNull();
    return row?.read(countExpr) ?? 0;
  }

  Stream<int> watchPendingCount() {
    final countExpr = syncQueueItems.id.count();
    final query = selectOnly(syncQueueItems)
      ..addColumns([countExpr])
      ..where(syncQueueItems.status.equals('pending'));
    return query.watchSingleOrNull().map((row) => row?.read(countExpr) ?? 0);
  }
}
