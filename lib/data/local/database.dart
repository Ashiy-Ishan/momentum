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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        try {
          final result = await customSelect('PRAGMA table_info(kpi_definitions)').get();
          final existingColumns = result.map((row) => row.read<String>('name')).toSet();

          if (!existingColumns.contains('current_value')) {
            await m.addColumn(kpiDefinitions, kpiDefinitions.currentValue);
          }
          if (!existingColumns.contains('long_term_target')) {
            await m.addColumn(kpiDefinitions, kpiDefinitions.longTermTarget);
          }
          if (!existingColumns.contains('unit')) {
            await m.addColumn(kpiDefinitions, kpiDefinitions.unit);
          }
          if (!existingColumns.contains('platform')) {
            await m.addColumn(kpiDefinitions, kpiDefinitions.platform);
          }
          if (!existingColumns.contains('metric_category')) {
            await m.addColumn(kpiDefinitions, kpiDefinitions.metricCategory);
          }
        } catch (_) {}
      }
    },
    beforeOpen: (details) async {
      try {
        final result = await customSelect('PRAGMA table_info(kpi_definitions)').get();
        final existingColumns = result.map((row) => row.read<String>('name')).toSet();

        if (!existingColumns.contains('current_value')) {
          await customStatement(
            'ALTER TABLE kpi_definitions ADD COLUMN current_value REAL NOT NULL DEFAULT 0.0',
          );
        }
        if (!existingColumns.contains('long_term_target')) {
          await customStatement(
            'ALTER TABLE kpi_definitions ADD COLUMN long_term_target REAL',
          );
        }
        if (!existingColumns.contains('unit')) {
          await customStatement(
            'ALTER TABLE kpi_definitions ADD COLUMN unit TEXT NOT NULL DEFAULT "count"',
          );
        }
        if (!existingColumns.contains('platform')) {
          await customStatement(
            'ALTER TABLE kpi_definitions ADD COLUMN platform TEXT NOT NULL DEFAULT "general"',
          );
        }
        if (!existingColumns.contains('metric_category')) {
          await customStatement(
            'ALTER TABLE kpi_definitions ADD COLUMN metric_category TEXT NOT NULL DEFAULT "output"',
          );
        }
      } catch (_) {}
    },
  );

  /// Wipes all local data associated with a specific user ID.
  Future<void> wipeUserData(String userId) async {
    await transaction(() async {
      await (delete(completionEvents)..where((t) => t.userId.equals(userId))).go();
      await (delete(taskOccurrences)..where((t) => t.userId.equals(userId))).go();
      await (delete(attachments)..where((t) => t.userId.equals(userId))).go();
      await (delete(tasks)..where((t) => t.userId.equals(userId))).go();
      await (delete(recurrenceRules)..where((t) => t.userId.equals(userId))).go();
      await (delete(timerSessions)..where((t) => t.userId.equals(userId))).go();
      await (delete(kpiDefinitions)..where((t) => t.userId.equals(userId))).go();
      await (delete(labels)..where((t) => t.userId.equals(userId))).go();
      await (delete(notificationSettingsTable)..where((t) => t.userId.equals(userId))).go();
      await (delete(userProfiles)..where((t) => t.id.equals(userId))).go();
      await delete(syncQueueItems).go();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'momentum.db'));
    return NativeDatabase.createInBackground(file, logStatements: false);
  });
}
