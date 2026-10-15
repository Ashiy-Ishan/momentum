import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/tables.dart';

part 'timer_dao.g.dart';

@DriftAccessor(tables: [TimerSessions, Tasks])
class TimerDao extends DatabaseAccessor<AppDatabase> with _$TimerDaoMixin {
  TimerDao(super.db);

  /// Retrieves the currently active timer session (running or paused) for a user.
  Future<TimerSession?> getActiveSession(String userId) {
    return (select(timerSessions)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.isDeleted.equals(false) &
                (tbl.status.equals('running') | tbl.status.equals('paused')) &
                tbl.endedAt.isNull(),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Retrieves all timer sessions for a specific task.
  Future<List<TimerSession>> getSessionsForTask(String taskId) {
    return (select(timerSessions)
          ..where(
            (tbl) => tbl.taskId.equals(taskId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)]))
        .get();
  }

  /// Inserts a new timer session.
  Future<void> insertSession(TimerSessionsCompanion session) async {
    await into(timerSessions).insert(session);
  }

  /// Updates an existing timer session.
  Future<void> updateSession(TimerSessionsCompanion session) async {
    await update(timerSessions).replace(session);
  }

  /// Computes total elapsed seconds tracked for a specific task.
  Future<int> getTotalTimeForTask(String taskId) async {
    final sumExpr = timerSessions.elapsedSeconds.sum();
    final query = selectOnly(timerSessions)
      ..addColumns([sumExpr])
      ..where(
        timerSessions.taskId.equals(taskId) &
            timerSessions.isDeleted.equals(false),
      );
    final row = await query.getSingle();
    return row.read(sumExpr) ?? 0;
  }

  /// Computes total elapsed seconds tracked for tasks under a label in a date range.
  Future<int> getTotalTimeForLabel(
    String labelId,
    DateTime start,
    DateTime end,
  ) async {
    final sumExpr = timerSessions.elapsedSeconds.sum();
    final query =
        selectOnly(timerSessions)
            .join([innerJoin(tasks, tasks.id.equalsExp(timerSessions.taskId))])
          ..addColumns([sumExpr])
          ..where(
            tasks.labelId.equals(labelId) &
                tasks.isDeleted.equals(false) &
                timerSessions.isDeleted.equals(false) &
                timerSessions.startedAt.isBiggerOrEqualValue(start) &
                timerSessions.startedAt.isSmallerOrEqualValue(end),
          );
    final row = await query.getSingle();
    return row.read(sumExpr) ?? 0;
  }

  /// Watches the active timer session for a user.
  Stream<TimerSession?> watchActiveSession(String userId) {
    return (select(timerSessions)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.isDeleted.equals(false) &
                (tbl.status.equals('running') | tbl.status.equals('paused')) &
                tbl.endedAt.isNull(),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)])
          ..limit(1))
        .watchSingleOrNull();
  }
}
