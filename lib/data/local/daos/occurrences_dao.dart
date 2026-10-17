import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/tables.dart';

part 'occurrences_dao.g.dart';

@DriftAccessor(tables: [TaskOccurrences, CompletionEvents])
class OccurrencesDao extends DatabaseAccessor<AppDatabase>
    with _$OccurrencesDaoMixin {
  OccurrencesDao(super.db);

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  Future<List<TaskOccurrence>> getOccurrencesForDate(
    String userId,
    DateTime date,
  ) {
    final start = _startOfDay(date);
    final end = _endOfDay(date);
    return (select(taskOccurrences)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.isDeleted.equals(false) &
                tbl.occurrenceDate.isBiggerOrEqualValue(start) &
                tbl.occurrenceDate.isSmallerOrEqualValue(end),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.occurrenceDate)]))
        .get();
  }

  Future<List<TaskOccurrence>> getOccurrencesForDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) {
    return (select(taskOccurrences)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.isDeleted.equals(false) &
                tbl.occurrenceDate.isBiggerOrEqualValue(start) &
                tbl.occurrenceDate.isSmallerOrEqualValue(end),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.occurrenceDate)]))
        .get();
  }

  Future<TaskOccurrence?> getOccurrenceById(String id) {
    return (select(taskOccurrences)
          ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<void> insertOccurrence(TaskOccurrencesCompanion occ) async {
    await into(taskOccurrences).insert(occ);
  }

  Future<void> updateOccurrenceStatus(
    String id,
    String status, {
    DateTime? completedAt,
  }) async {
    final existing = await (select(taskOccurrences)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    await (update(taskOccurrences)..where((tbl) => tbl.id.equals(id))).write(
      TaskOccurrencesCompanion(
        status: Value(status),
        completedAt: Value(completedAt),
        version: Value((existing?.version ?? 0) + 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> insertCompletionEvent(CompletionEventsCompanion event) async {
    await into(completionEvents).insert(event);
  }

  Future<List<CompletionEvent>> getCompletionEventsForTask(String taskId) {
    return (select(completionEvents)
          ..where(
            (tbl) => tbl.taskId.equals(taskId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.completedAt)]))
        .get();
  }

  Future<int> countCompletedOccurrences(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final countExpr = taskOccurrences.id.count();
    final query = selectOnly(taskOccurrences)
      ..addColumns([countExpr])
      ..where(
        taskOccurrences.userId.equals(userId) &
            taskOccurrences.isDeleted.equals(false) &
            (taskOccurrences.status.equals('done') |
                taskOccurrences.status.equals('completed')) &
            taskOccurrences.occurrenceDate.isBiggerOrEqualValue(start) &
            taskOccurrences.occurrenceDate.isSmallerOrEqualValue(end),
      );
    final row = await query.getSingleOrNull();
    return row?.read(countExpr) ?? 0;
  }

  Future<int> countScheduledOccurrences(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final countExpr = taskOccurrences.id.count();
    final query = selectOnly(taskOccurrences)
      ..addColumns([countExpr])
      ..where(
        taskOccurrences.userId.equals(userId) &
            taskOccurrences.isDeleted.equals(false) &
            taskOccurrences.occurrenceDate.isBiggerOrEqualValue(start) &
            taskOccurrences.occurrenceDate.isSmallerOrEqualValue(end),
      );
    final row = await query.getSingleOrNull();
    return row?.read(countExpr) ?? 0;
  }

  Stream<List<TaskOccurrence>> watchOccurrencesForDate(
    String userId,
    DateTime date,
  ) {
    final start = _startOfDay(date);
    final end = _endOfDay(date);
    return (select(taskOccurrences)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.isDeleted.equals(false) &
                tbl.occurrenceDate.isBiggerOrEqualValue(start) &
                tbl.occurrenceDate.isSmallerOrEqualValue(end),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.occurrenceDate)]))
        .watch();
  }
}
