import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums/enums.dart';
import '../../domain/models/models.dart' as domain;
import '../local/daos/occurrences_dao.dart';
import '../local/daos/tasks_dao.dart';
import '../local/database.dart' as db;
import '../sync/sync_engine.dart';

/// Contract for task data operations and persistence.
abstract class TaskRepository {
  /// Retrieves tasks scheduled or due on [date] for [userId].
  Future<List<domain.Task>> getTasksForDate(String userId, DateTime date);

  /// Retrieves all non-deleted tasks for [userId].
  Future<List<domain.Task>> getAllTasks(String userId);

  /// Retrieves non-deleted and non-archived tasks tagged with [labelId].
  Future<List<domain.Task>> getTasksByLabel(String labelId);

  /// Creates a new [task], optionally saving its [recurrence] rule.
  Future<void> createTask(
    domain.Task task, {
    domain.RecurrenceRule? recurrence,
  });

  /// Updates an existing [task].
  Future<void> updateTask(domain.Task task);

  /// Soft deletes a task by [id].
  Future<void> deleteTask(String id);

  /// Archives or unarchives a task by [id].
  Future<void> archiveTask(String id, bool archive);

  /// Updates the lifecycle status of a task by [id].
  Future<void> setTaskStatus(String id, TaskStatus status);

  /// Watches stream of tasks scheduled or occurring on [date] for [userId].
  Stream<List<domain.Task>> watchTasksForDate(String userId, DateTime date);

  /// Watches all active (non-deleted, non-archived) tasks for [userId].
  Stream<List<domain.Task>> watchAllActiveTasks(String userId);

  /// Marks a specific occurrence on [occurrenceDate] as completed with optional [notes].
  Future<void> completeTaskOccurrence(
    String userId,
    String taskId,
    DateTime occurrenceDate, {
    String? notes,
  });

  /// Uncompletes a specific occurrence on [occurrenceDate], reverting to pending.
  Future<void> uncompleteTaskOccurrence(
    String userId,
    String taskId,
    DateTime occurrenceDate,
  );
}

/// Drift-backed implementation of [TaskRepository].
class TaskRepositoryImpl implements TaskRepository {
  final db.AppDatabase database;
  final TasksDao tasksDao;
  final OccurrencesDao occurrencesDao;
  final SyncEngine? syncEngine;
  static const Uuid _uuid = Uuid();

  TaskRepositoryImpl({
    required this.database,
    required this.tasksDao,
    required this.occurrencesDao,
    this.syncEngine,
  });

  @override
  Future<List<domain.Task>> getAllTasks(String userId) async {
    final rows = await tasksDao.getAllTasks(userId);
    return rows.map(_mapTaskFromDb).toList();
  }

  @override
  Future<List<domain.Task>> getTasksByLabel(String labelId) async {
    final rows = await tasksDao.getTasksByLabel(labelId);
    return rows.map(_mapTaskFromDb).toList();
  }

  @override
  Future<List<domain.Task>> getTasksForDate(String userId, DateTime date) async {
    final scheduledRows = await tasksDao.getTasksForDate(userId, date);
    return _enrichTasksForDate(userId, date, scheduledRows);
  }

  @override
  Stream<List<domain.Task>> watchTasksForDate(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final triggerQuery = database.select(database.tasks).join([
      leftOuterJoin(
        database.taskOccurrences,
        database.taskOccurrences.taskId.equalsExp(database.tasks.id) &
            database.taskOccurrences.occurrenceDate.isBiggerOrEqualValue(startOfDay) &
            database.taskOccurrences.occurrenceDate.isSmallerOrEqualValue(endOfDay) &
            database.taskOccurrences.isDeleted.equals(false),
      ),
    ]);

    return triggerQuery.watch().asyncMap((_) async {
      return getTasksForDate(userId, date);
    });
  }

  @override
  Stream<List<domain.Task>> watchAllActiveTasks(String userId) {
    return tasksDao
        .watchAllActiveTasks(userId)
        .map((rows) => rows.map(_mapTaskFromDb).toList());
  }

  @override
  Future<void> createTask(
    domain.Task task, {
    domain.RecurrenceRule? recurrence,
  }) async {
    domain.Task finalTask = task;

    if (recurrence != null) {
      final daysOfWeekStr = recurrence.daysOfWeek?.join(',');
      await database.into(database.recurrenceRules).insert(
            db.RecurrenceRulesCompanion(
              id: Value(recurrence.id),
              userId: Value(recurrence.userId),
              type: Value(recurrence.type.name),
              daysOfWeek: Value(daysOfWeekStr),
              intervalDays: Value(recurrence.intervalDays),
              intervalMonths: Value(recurrence.intervalMonths),
              startDate: Value(recurrence.startDate),
              endDate: Value(recurrence.endDate),
              maxOccurrences: Value(recurrence.maxOccurrences),
              createdAt: Value(recurrence.createdAt),
              updatedAt: Value(recurrence.updatedAt),
              version: Value(recurrence.version),
              isDeleted: Value(recurrence.isDeleted),
            ),
          );
      finalTask = task.copyWith(recurrenceRuleId: recurrence.id);

      await syncEngine?.enqueueOperation(
        tableName: 'recurrence_rules',
        recordId: recurrence.id,
        operation: SyncOperation.insert,
        payload: recurrence.toMap(),
      );
    }

    await tasksDao.insertTask(_mapTaskToCompanion(finalTask));

    await syncEngine?.enqueueOperation(
      tableName: 'tasks',
      recordId: finalTask.id,
      operation: SyncOperation.insert,
      payload: finalTask.toMap(),
    );
  }

  @override
  Future<void> updateTask(domain.Task task) async {
    await tasksDao.updateTask(_mapTaskToCompanion(task));

    await syncEngine?.enqueueOperation(
      tableName: 'tasks',
      recordId: task.id,
      operation: SyncOperation.update,
      payload: task.toMap(),
    );
  }

  @override
  Future<void> deleteTask(String id) async {
    await tasksDao.softDeleteTask(id);

    await syncEngine?.enqueueOperation(
      tableName: 'tasks',
      recordId: id,
      operation: SyncOperation.delete,
      payload: {
        'id': id,
        'is_deleted': true,
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Future<void> archiveTask(String id, bool archive) async {
    await tasksDao.archiveTask(id, archive);

    await syncEngine?.enqueueOperation(
      tableName: 'tasks',
      recordId: id,
      operation: SyncOperation.update,
      payload: {
        'id': id,
        'is_archived': archive,
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Future<void> setTaskStatus(String id, TaskStatus status) async {
    final now = DateTime.now();
    await tasksDao.updateTaskStatus(id, status.name);

    await syncEngine?.enqueueOperation(
      tableName: 'tasks',
      recordId: id,
      operation: SyncOperation.update,
      payload: {
        'id': id,
        'status': status.name,
        'updated_at': now.toIso8601String(),
      },
    );
  }

  @override
  Future<void> completeTaskOccurrence(
    String userId,
    String taskId,
    DateTime occurrenceDate, {
    String? notes,
  }) async {
    final startOfDay =
        DateTime(occurrenceDate.year, occurrenceDate.month, occurrenceDate.day);
    final endOfDay = DateTime(
      occurrenceDate.year,
      occurrenceDate.month,
      occurrenceDate.day,
      23,
      59,
      59,
      999,
    );

    final existingOccurrences = await (database.select(database.taskOccurrences)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.taskId.equals(taskId) &
                tbl.occurrenceDate.isBiggerOrEqualValue(startOfDay) &
                tbl.occurrenceDate.isSmallerOrEqualValue(endOfDay) &
                tbl.isDeleted.equals(false),
          ))
        .get();

    final now = DateTime.now();
    String occurrenceId;

    if (existingOccurrences.isNotEmpty) {
      occurrenceId = existingOccurrences.first.id;
      await occurrencesDao.updateOccurrenceStatus(
        occurrenceId,
        TaskStatus.done.name,
        completedAt: now,
      );
    } else {
      occurrenceId = _uuid.v4();
      await occurrencesDao.insertOccurrence(
        db.TaskOccurrencesCompanion(
          id: Value(occurrenceId),
          userId: Value(userId),
          taskId: Value(taskId),
          occurrenceDate: Value(occurrenceDate),
          status: Value(TaskStatus.done.name),
          completedAt: Value(now),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }

    final eventId = _uuid.v4();
    // Insert completion event log
    await occurrencesDao.insertCompletionEvent(
      db.CompletionEventsCompanion(
        id: Value(eventId),
        userId: Value(userId),
        taskId: Value(taskId),
        occurrenceId: Value(occurrenceId),
        completedAt: Value(now),
        notes: Value(notes),
        createdAt: Value(now),
      ),
    );

    // If the task does not repeat, update the main task status
    final taskRow = await tasksDao.getTaskById(taskId);
    if (taskRow != null && taskRow.recurrenceRuleId == null) {
      await tasksDao.updateTaskStatus(taskId, TaskStatus.done.name);
    }

    // Sync occurrence and completion event to cloud
    await syncEngine?.enqueueOperation(
      tableName: 'task_occurrences',
      recordId: occurrenceId,
      operation: SyncOperation.insert,
      payload: {
        'id': occurrenceId,
        'user_id': userId,
        'task_id': taskId,
        'occurrence_date': occurrenceDate.toIso8601String(),
        'status': TaskStatus.done.name,
        'completed_at': now.toIso8601String(),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'version': 1,
        'is_deleted': false,
      },
    );

    await syncEngine?.enqueueOperation(
      tableName: 'completion_events',
      recordId: eventId,
      operation: SyncOperation.insert,
      payload: {
        'id': eventId,
        'user_id': userId,
        'task_id': taskId,
        'occurrence_id': occurrenceId,
        'completed_at': now.toIso8601String(),
        'notes': notes,
        'created_at': now.toIso8601String(),
        'is_deleted': false,
      },
    );

    if (taskRow != null && taskRow.recurrenceRuleId == null) {
      await syncEngine?.enqueueOperation(
        tableName: 'tasks',
        recordId: taskId,
        operation: SyncOperation.update,
        payload: {
          'id': taskId,
          'status': TaskStatus.done.name,
          'updated_at': now.toIso8601String(),
        },
      );
    }
  }

  @override
  Future<void> uncompleteTaskOccurrence(
    String userId,
    String taskId,
    DateTime occurrenceDate,
  ) async {
    final startOfDay =
        DateTime(occurrenceDate.year, occurrenceDate.month, occurrenceDate.day);
    final endOfDay = DateTime(
      occurrenceDate.year,
      occurrenceDate.month,
      occurrenceDate.day,
      23,
      59,
      59,
      999,
    );

    final existingOccurrences = await (database.select(database.taskOccurrences)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.taskId.equals(taskId) &
                tbl.occurrenceDate.isBiggerOrEqualValue(startOfDay) &
                tbl.occurrenceDate.isSmallerOrEqualValue(endOfDay) &
                tbl.isDeleted.equals(false),
          ))
        .get();

    for (final occ in existingOccurrences) {
      await occurrencesDao.updateOccurrenceStatus(
        occ.id,
        TaskStatus.pending.name,
        completedAt: null,
      );

      // Soft delete completion events for this occurrence
      await (database.update(database.completionEvents)
            ..where((tbl) => tbl.occurrenceId.equals(occ.id)))
          .write(
        const db.CompletionEventsCompanion(
          isDeleted: Value(true),
        ),
      );

      await syncEngine?.enqueueOperation(
        tableName: 'task_occurrences',
        recordId: occ.id,
        operation: SyncOperation.update,
        payload: {
          'id': occ.id,
          'status': TaskStatus.pending.name,
          'completed_at': null,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
    }

    // If the task is non-recurring, revert task status to pending
    final taskRow = await tasksDao.getTaskById(taskId);
    if (taskRow != null && taskRow.recurrenceRuleId == null) {
      await tasksDao.updateTaskStatus(taskId, TaskStatus.pending.name);

      await syncEngine?.enqueueOperation(
        tableName: 'tasks',
        recordId: taskId,
        operation: SyncOperation.update,
        payload: {
          'id': taskId,
          'status': TaskStatus.pending.name,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  /// Helper to merge scheduled tasks, recurring pattern matches, and occurrence completions.
  Future<List<domain.Task>> _enrichTasksForDate(
    String userId,
    DateTime date,
    List<db.Task> dateRows,
  ) async {
    final taskMap = <String, domain.Task>{};

    for (final row in dateRows) {
      taskMap[row.id] = _mapTaskFromDb(row);
    }

    // Check active recurring tasks for date inclusion
    final recurringTasks = await (database.select(database.tasks)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.recurrenceRuleId.isNotNull() &
                tbl.isDeleted.equals(false) &
                tbl.isArchived.equals(false),
          ))
        .get();

    for (final taskRow in recurringTasks) {
      if (taskMap.containsKey(taskRow.id)) continue;
      final ruleId = taskRow.recurrenceRuleId;
      if (ruleId == null) continue;

      final ruleRow = await (database.select(database.recurrenceRules)
            ..where((tbl) => tbl.id.equals(ruleId) & tbl.isDeleted.equals(false)))
          .getSingleOrNull();

      if (ruleRow != null) {
        final domainRule = _mapRecurrenceRuleFromDb(ruleRow);
        if (domainRule.isScheduledFor(date)) {
          taskMap[taskRow.id] = _mapTaskFromDb(taskRow);
        }
      }
    }

    // Query occurrence statuses on this date to reflect completed state per day
    final occurrences = await occurrencesDao.getOccurrencesForDate(userId, date);
    final occurrencesByTaskId = <String, db.TaskOccurrence>{};
    for (final occ in occurrences) {
      occurrencesByTaskId[occ.taskId] = occ;
    }

    final enrichedList = taskMap.values.map((task) {
      final occ = occurrencesByTaskId[task.id];
      if (occ != null) {
        return task.copyWith(
          status: TaskStatus.fromString(occ.status),
        );
      }
      return task;
    }).toList();

    enrichedList.sort((a, b) {
      // Sort by priority desc, then title
      final prioComp = b.priority.level.compareTo(a.priority.level);
      if (prioComp != 0) return prioComp;
      return a.title.compareTo(b.title);
    });

    return enrichedList;
  }

  domain.Task _mapTaskFromDb(db.Task row) {
    return domain.Task(
      id: row.id,
      userId: row.userId,
      labelId: row.labelId,
      title: row.title,
      description: row.description,
      iconName: row.iconName,
      imagePath: row.imagePath,
      url: row.url,
      category: row.category,
      status: TaskStatus.fromString(row.status),
      priority: TaskPriority.fromString(row.priority),
      hasTimeTracking: row.hasTimeTracking,
      estimatedMinutes: row.estimatedMinutes,
      recurrenceRuleId: row.recurrenceRuleId,
      scheduledDate: row.scheduledDate,
      dueDate: row.dueDate,
      isArchived: row.isArchived,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      version: row.version,
      isDeleted: row.isDeleted,
    );
  }

  db.TasksCompanion _mapTaskToCompanion(domain.Task task) {
    return db.TasksCompanion(
      id: Value(task.id),
      userId: Value(task.userId),
      labelId: Value(task.labelId),
      title: Value(task.title),
      description: Value(task.description),
      iconName: Value(task.iconName),
      imagePath: Value(task.imagePath),
      url: Value(task.url),
      category: Value(task.category),
      status: Value(task.status.name),
      priority: Value(task.priority.name),
      hasTimeTracking: Value(task.hasTimeTracking),
      estimatedMinutes: Value(task.estimatedMinutes),
      recurrenceRuleId: Value(task.recurrenceRuleId),
      scheduledDate: Value(task.scheduledDate),
      dueDate: Value(task.dueDate),
      isArchived: Value(task.isArchived),
      createdAt: Value(task.createdAt),
      updatedAt: Value(task.updatedAt),
      version: Value(task.version),
      isDeleted: Value(task.isDeleted),
    );
  }

  domain.RecurrenceRule _mapRecurrenceRuleFromDb(db.RecurrenceRule row) {
    List<int>? daysOfWeek;
    if (row.daysOfWeek != null && row.daysOfWeek!.isNotEmpty) {
      daysOfWeek = row.daysOfWeek!
          .split(',')
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>()
          .toList();
    }

    return domain.RecurrenceRule(
      id: row.id,
      userId: row.userId,
      type: RecurrenceType.fromString(row.type),
      daysOfWeek: daysOfWeek,
      intervalDays: row.intervalDays,
      intervalMonths: row.intervalMonths,
      startDate: row.startDate,
      endDate: row.endDate,
      maxOccurrences: row.maxOccurrences,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      version: row.version,
      isDeleted: row.isDeleted,
    );
  }
}
