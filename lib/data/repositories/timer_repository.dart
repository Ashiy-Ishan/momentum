import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums/enums.dart';
import '../../domain/models/models.dart' as domain;
import '../local/daos/timer_dao.dart';
import '../local/database.dart' as db;
import '../sync/sync_engine.dart';

abstract class TimerRepository {
  Future<domain.TimerSession?> getActiveSession(String userId);

  Future<domain.TimerSession> startSession(
    String userId,
    String taskId, {
    String? occurrenceId,
  });

  Future<void> pauseSession(String sessionId);

  Future<void> resumeSession(String sessionId);

  Future<void> stopSession(String sessionId);

  Future<int> getTotalTimeForTask(String taskId);

  Future<int> getTotalTimeForLabel(
    String labelId,
    DateTime start,
    DateTime end,
  );

  Stream<domain.TimerSession?> watchActiveSession(String userId);
}

class TimerRepositoryImpl implements TimerRepository {
  final db.AppDatabase database;
  final TimerDao timerDao;
  final SyncEngine? syncEngine;
  static const Uuid _uuid = Uuid();

  TimerRepositoryImpl({
    required this.database,
    required this.timerDao,
    this.syncEngine,
  });

  @override
  Future<domain.TimerSession?> getActiveSession(String userId) async {
    final row = await timerDao.getActiveSession(userId);
    return row != null ? _mapSessionFromDb(row) : null;
  }

  @override
  Future<domain.TimerSession> startSession(
    String userId,
    String taskId, {
    String? occurrenceId,
  }) async {
    final active = await timerDao.getActiveSession(userId);
    if (active != null) {
      await stopSession(active.id);
    }

    final now = DateTime.now();
    final session = domain.TimerSession(
      id: _uuid.v4(),
      userId: userId,
      taskId: taskId,
      occurrenceId: occurrenceId,
      startedAt: now,
      pausedAt: null,
      endedAt: null,
      elapsedSeconds: 0,
      status: TimerSessionStatus.running,
      createdAt: now,
      updatedAt: now,
    );

    await timerDao.insertSession(_mapSessionToCompanion(session));

    await syncEngine?.enqueueOperation(
      tableName: 'timer_sessions',
      recordId: session.id,
      operation: SyncOperation.insert,
      payload: session.toMap(),
    );

    return session;
  }

  @override
  Future<void> pauseSession(String sessionId) async {
    final row = await (database.select(database.timerSessions)
          ..where((tbl) => tbl.id.equals(sessionId) & tbl.isDeleted.equals(false)))
        .getSingleOrNull();

    if (row != null && row.status == TimerSessionStatus.running.name) {
      final now = DateTime.now();
      final diff = now.difference(row.startedAt).inSeconds;
      final addedSeconds = diff > 0 ? diff : 0;
      final totalSeconds = row.elapsedSeconds + addedSeconds;
      final newVersion = row.version + 1;

      await (database.update(database.timerSessions)
            ..where((tbl) => tbl.id.equals(sessionId)))
          .write(
        db.TimerSessionsCompanion(
          status: Value(TimerSessionStatus.paused.name),
          pausedAt: Value(now),
          elapsedSeconds: Value(totalSeconds),
          version: Value(newVersion),
          updatedAt: Value(now),
        ),
      );

      await syncEngine?.enqueueOperation(
        tableName: 'timer_sessions',
        recordId: sessionId,
        operation: SyncOperation.update,
        payload: {
          'id': sessionId,
          'status': TimerSessionStatus.paused.name,
          'paused_at': now.toIso8601String(),
          'elapsed_seconds': totalSeconds,
          'version': newVersion,
          'updated_at': now.toIso8601String(),
        },
      );
    }
  }

  @override
  Future<void> resumeSession(String sessionId) async {
    final row = await (database.select(database.timerSessions)
          ..where((tbl) => tbl.id.equals(sessionId) & tbl.isDeleted.equals(false)))
        .getSingleOrNull();

    if (row != null && row.status == TimerSessionStatus.paused.name) {
      final now = DateTime.now();
      final newVersion = row.version + 1;

      await (database.update(database.timerSessions)
            ..where((tbl) => tbl.id.equals(sessionId)))
          .write(
        db.TimerSessionsCompanion(
          status: Value(TimerSessionStatus.running.name),
          startedAt: Value(now),
          pausedAt: const Value(null),
          version: Value(newVersion),
          updatedAt: Value(now),
        ),
      );

      await syncEngine?.enqueueOperation(
        tableName: 'timer_sessions',
        recordId: sessionId,
        operation: SyncOperation.update,
        payload: {
          'id': sessionId,
          'status': TimerSessionStatus.running.name,
          'started_at': now.toIso8601String(),
          'paused_at': null,
          'version': newVersion,
          'updated_at': now.toIso8601String(),
        },
      );
    }
  }

  @override
  Future<void> stopSession(String sessionId) async {
    final row = await (database.select(database.timerSessions)
          ..where((tbl) => tbl.id.equals(sessionId) & tbl.isDeleted.equals(false)))
        .getSingleOrNull();

    if (row != null) {
      final now = DateTime.now();
      int totalSeconds = row.elapsedSeconds;

      if (row.status == TimerSessionStatus.running.name) {
        final diff = now.difference(row.startedAt).inSeconds;
        totalSeconds += diff > 0 ? diff : 0;
      }
      final newVersion = row.version + 1;

      await (database.update(database.timerSessions)
            ..where((tbl) => tbl.id.equals(sessionId)))
          .write(
        db.TimerSessionsCompanion(
          status: Value(TimerSessionStatus.completed.name),
          endedAt: Value(now),
          elapsedSeconds: Value(totalSeconds),
          version: Value(newVersion),
          updatedAt: Value(now),
        ),
      );

      await syncEngine?.enqueueOperation(
        tableName: 'timer_sessions',
        recordId: sessionId,
        operation: SyncOperation.update,
        payload: {
          'id': sessionId,
          'status': TimerSessionStatus.completed.name,
          'ended_at': now.toIso8601String(),
          'elapsed_seconds': totalSeconds,
          'version': newVersion,
          'updated_at': now.toIso8601String(),
        },
      );
    }
  }

  @override
  Future<int> getTotalTimeForTask(String taskId) {
    return timerDao.getTotalTimeForTask(taskId);
  }

  @override
  Future<int> getTotalTimeForLabel(
    String labelId,
    DateTime start,
    DateTime end,
  ) {
    return timerDao.getTotalTimeForLabel(labelId, start, end);
  }

  @override
  Stream<domain.TimerSession?> watchActiveSession(String userId) {
    return timerDao.watchActiveSession(userId).map((row) {
      return row != null ? _mapSessionFromDb(row) : null;
    });
  }

  domain.TimerSession _mapSessionFromDb(db.TimerSession row) {
    return domain.TimerSession(
      id: row.id,
      userId: row.userId,
      taskId: row.taskId,
      occurrenceId: row.occurrenceId,
      startedAt: row.startedAt,
      pausedAt: row.pausedAt,
      endedAt: row.endedAt,
      elapsedSeconds: row.elapsedSeconds,
      status: TimerSessionStatus.fromString(row.status),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      version: row.version,
      isDeleted: row.isDeleted,
    );
  }

  db.TimerSessionsCompanion _mapSessionToCompanion(
    domain.TimerSession session,
  ) {
    return db.TimerSessionsCompanion(
      id: Value(session.id),
      userId: Value(session.userId),
      taskId: Value(session.taskId),
      occurrenceId: Value(session.occurrenceId),
      startedAt: Value(session.startedAt),
      pausedAt: Value(session.pausedAt),
      endedAt: Value(session.endedAt),
      elapsedSeconds: Value(session.elapsedSeconds),
      status: Value(session.status.name),
      createdAt: Value(session.createdAt),
      updatedAt: Value(session.updatedAt),
      version: Value(session.version),
      isDeleted: Value(session.isDeleted),
    );
  }
}
