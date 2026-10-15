// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_dao.dart';

// ignore_for_file: type=lint
mixin _$TimerDaoMixin on DatabaseAccessor<AppDatabase> {
  $TimerSessionsTable get timerSessions => attachedDatabase.timerSessions;
  $TasksTable get tasks => attachedDatabase.tasks;
  TimerDaoManager get managers => TimerDaoManager(this);
}

class TimerDaoManager {
  final _$TimerDaoMixin _db;
  TimerDaoManager(this._db);
  $$TimerSessionsTableTableManager get timerSessions =>
      $$TimerSessionsTableTableManager(_db.attachedDatabase, _db.timerSessions);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db.attachedDatabase, _db.tasks);
}
