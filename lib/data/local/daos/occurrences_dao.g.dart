// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'occurrences_dao.dart';

// ignore_for_file: type=lint
mixin _$OccurrencesDaoMixin on DatabaseAccessor<AppDatabase> {
  $TaskOccurrencesTable get taskOccurrences => attachedDatabase.taskOccurrences;
  $CompletionEventsTable get completionEvents =>
      attachedDatabase.completionEvents;
  OccurrencesDaoManager get managers => OccurrencesDaoManager(this);
}

class OccurrencesDaoManager {
  final _$OccurrencesDaoMixin _db;
  OccurrencesDaoManager(this._db);
  $$TaskOccurrencesTableTableManager get taskOccurrences =>
      $$TaskOccurrencesTableTableManager(
        _db.attachedDatabase,
        _db.taskOccurrences,
      );
  $$CompletionEventsTableTableManager get completionEvents =>
      $$CompletionEventsTableTableManager(
        _db.attachedDatabase,
        _db.completionEvents,
      );
}
