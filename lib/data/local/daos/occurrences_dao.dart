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

  /// Retrieves occurrences for a user on a specific calendar day.
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

  /// Retrieves occurrences within a specified date range.
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

  /// Retrieves a single occurrence by ID.
  Future<TaskOccurrence?> getOccurrenceById(String id) {
    return (select(taskOccurrences)
          ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Inserts a task occurrence.
  Future<void> insertOccurrence(TaskOccurrencesCompanion occ) async {
    await into(taskOccurrences).insert(occ);
  }

  /// Updates occurrence status and optional completion timestamp.
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

  /// Inserts a completion event.
  Future<void> insertCompletionEvent(CompletionEventsCompanion event) async {
    await into(completionEvents).insert(event);
  }

  /// Retrieves all completion events for a specific task.
  Future<List<CompletionEvent>> getCompletionEventsForTask(String taskId) {
    return (select(completionEvents)
          ..where(
            (tbl) => tbl.taskId.equals(taskId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.completedAt)]))
        .get();
  }

  /// Counts completed occurrences in a date range.
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

  /// Counts all scheduled occurrences in a date range.
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

  /// Watches occurrences on a specific calendar day.
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
