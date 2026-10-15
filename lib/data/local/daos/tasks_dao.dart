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

  /// Retrieves all non-deleted tasks for a user.
  Future<List<Task>> getAllTasks(String userId) {
    return (select(tasks)
          ..where(
            (tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  /// Retrieves non-deleted and non-archived tasks scheduled or due on a specific date.
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

  /// Retrieves non-deleted and non-archived tasks associated with a label.
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

  /// Retrieves non-deleted and non-archived tasks by status for a user.
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

  /// Retrieves a single non-deleted task by its ID.
  Future<Task?> getTaskById(String id) {
    return (select(tasks)
          ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Inserts a new task.
  Future<void> insertTask(TasksCompanion task) async {
    await into(tasks).insert(task);
  }

  /// Updates an existing task.
  Future<void> updateTask(TasksCompanion task) async {
    await update(tasks).replace(task);
  }

  /// Updates status for a task and refreshes updatedAt.
  Future<void> updateTaskStatus(String id, String status) async {
    await (update(tasks)..where((tbl) => tbl.id.equals(id))).write(
      TasksCompanion(status: Value(status), updatedAt: Value(DateTime.now())),
    );
  }

  /// Soft deletes a task.
  Future<void> softDeleteTask(String id) async {
    await (update(tasks)..where((tbl) => tbl.id.equals(id))).write(
      TasksCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Archives or unarchives a task.
  Future<void> archiveTask(String id, bool archived) async {
    await (update(tasks)..where((tbl) => tbl.id.equals(id))).write(
      TasksCompanion(
        isArchived: Value(archived),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Watches tasks scheduled or due on a given date.
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

  /// Watches tasks under a specific label.
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

  /// Watches all active (non-deleted, non-archived) tasks for a user.
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

  /// Searches non-deleted tasks matching a text query in title or description.
  Future<List<Task>> searchTasks(String userId, String query) {
    final pattern = '%$query%';
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

  /// Counts tasks by status, optionally filtering by date.
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
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }
}
