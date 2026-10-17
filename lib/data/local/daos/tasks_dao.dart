import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/tables.dart';

part 'tasks_dao.g.dart';

@DriftAccessor(tables: [Tasks, Labels, RecurrenceRules])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  Future<List<Task>> getAllTasks(String userId) {
    return (select(tasks)
          ..where(
            (tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  Future<List<Task>> getTasksForDate(String userId, DateTime date) {
    final start = _startOfDay(date);
    final end = _endOfDay(date);
    return (select(tasks)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.isDeleted.equals(false) &
                tbl.isArchived.equals(false) &
                ((tbl.scheduledDate.isBiggerOrEqualValue(start) &
                        tbl.scheduledDate.isSmallerOrEqualValue(end)) |
                    (tbl.dueDate.isBiggerOrEqualValue(start) &
                        tbl.dueDate.isSmallerOrEqualValue(end))),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.scheduledDate)]))
        .get();
  }

  Future<List<Task>> getTasksByLabel(String labelId) {
    return (select(tasks)
          ..where(
            (tbl) =>
                tbl.labelId.equals(labelId) &
                tbl.isDeleted.equals(false) &
                tbl.isArchived.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  Future<List<Task>> getTasksByStatus(String userId, String status) {
    return (select(tasks)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.status.equals(status) &
                tbl.isDeleted.equals(false) &
                tbl.isArchived.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  Future<Task?> getTaskById(String id) {
    return (select(tasks)
          ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<void> insertTask(TasksCompanion task) async {
    await into(tasks).insert(task);
  }

  Future<void> updateTask(TasksCompanion task) async {
    await update(tasks).replace(task);
  }

  Future<void> updateTaskStatus(String id, String status) async {
    final existing = await (select(tasks)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    await (update(tasks)..where((tbl) => tbl.id.equals(id))).write(
      TasksCompanion(
        status: Value(status),
        version: Value((existing?.version ?? 0) + 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> softDeleteTask(String id) async {
    final existing = await (select(tasks)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    await (update(tasks)..where((tbl) => tbl.id.equals(id))).write(
      TasksCompanion(
        isDeleted: const Value(true),
        version: Value((existing?.version ?? 0) + 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> archiveTask(String id, bool archived) async {
    final existing = await (select(tasks)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    await (update(tasks)..where((tbl) => tbl.id.equals(id))).write(
      TasksCompanion(
        isArchived: Value(archived),
        version: Value((existing?.version ?? 0) + 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Stream<List<Task>> watchTasksForDate(String userId, DateTime date) {
    final start = _startOfDay(date);
    final end = _endOfDay(date);
    return (select(tasks)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.isDeleted.equals(false) &
                tbl.isArchived.equals(false) &
                ((tbl.scheduledDate.isBiggerOrEqualValue(start) &
                        tbl.scheduledDate.isSmallerOrEqualValue(end)) |
                    (tbl.dueDate.isBiggerOrEqualValue(start) &
                        tbl.dueDate.isSmallerOrEqualValue(end))),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.scheduledDate)]))
        .watch();
  }

  Stream<List<Task>> watchTasksByLabel(String labelId) {
    return (select(tasks)
          ..where(
            (tbl) =>
                tbl.labelId.equals(labelId) &
                tbl.isDeleted.equals(false) &
                tbl.isArchived.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();
  }

  Stream<List<Task>> watchAllActiveTasks(String userId) {
    return (select(tasks)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.isDeleted.equals(false) &
                tbl.isArchived.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();
  }

  Future<List<Task>> searchTasks(String userId, String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return Future.value([]);
    final pattern = '%$trimmed%';
    return (select(tasks)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.isDeleted.equals(false) &
                (tbl.title.like(pattern) | tbl.description.like(pattern)),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  Future<int> countTasksByStatus(
    String userId,
    String status, {
    DateTime? date,
  }) async {
    final countExpr = tasks.id.count();
    final query = selectOnly(tasks)..addColumns([countExpr]);

    var predicate =
        tasks.userId.equals(userId) &
        tasks.status.equals(status) &
        tasks.isDeleted.equals(false) &
        tasks.isArchived.equals(false);

    if (date != null) {
      final start = _startOfDay(date);
      final end = _endOfDay(date);
      predicate =
          predicate &
          ((tasks.scheduledDate.isBiggerOrEqualValue(start) &
                  tasks.scheduledDate.isSmallerOrEqualValue(end)) |
              (tasks.dueDate.isBiggerOrEqualValue(start) &
                  tasks.dueDate.isSmallerOrEqualValue(end)));
    }

    query.where(predicate);
    final row = await query.getSingleOrNull();
    return row?.read(countExpr) ?? 0;
  }
}
