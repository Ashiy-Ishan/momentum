import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/kpi_dao.dart';
import 'daos/labels_dao.dart';
import 'daos/occurrences_dao.dart';
import 'daos/sync_dao.dart';
import 'daos/tasks_dao.dart';
import 'daos/timer_dao.dart';
import 'tables/tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Labels,
    Tasks,
    RecurrenceRules,
    TaskOccurrences,
    CompletionEvents,
    TimerSessions,
    KpiDefinitions,
    Attachments,
    SyncQueueItems,
    NotificationSettingsTable,
    UserProfiles,
  ],
  daos: [LabelsDao, TasksDao, OccurrencesDao, TimerDao, KpiDao, SyncDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // For testing
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Future migrations
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'momentum.db'));
    return NativeDatabase.createInBackground(file, logStatements: false);
  });
}
