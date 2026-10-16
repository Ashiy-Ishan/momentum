import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/data/local/database.dart'
    hide Label, Task, RecurrenceRule, KpiDefinition, TimerSession;
import 'package:momentum/data/remote/supabase_client.dart';
import 'package:momentum/data/repositories/repositories.dart';
import 'package:momentum/data/sync/conflict_resolver.dart';
import 'package:momentum/data/sync/sync_engine.dart';
import 'package:momentum/domain/enums/enums.dart';
import 'package:momentum/domain/models/models.dart';

void main() {
  late AppDatabase db;
  late SyncEngine syncEngine;
  late TaskRepository taskRepo;
  late LabelRepository labelRepo;
  late KpiRepository kpiRepo;

  const testUserId = 'sync-test-user-1';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    syncEngine = SyncEngine(
      db: db,
      supabase: MomentumSupabaseClient.instance,
      conflictResolver: ConflictResolver(),
    );
    taskRepo = TaskRepositoryImpl(
      database: db,
      tasksDao: db.tasksDao,
      occurrencesDao: db.occurrencesDao,
      syncEngine: syncEngine,
    );
    labelRepo = LabelRepositoryImpl(
      database: db,
      labelsDao: db.labelsDao,
      syncEngine: syncEngine,
    );
    kpiRepo = KpiRepositoryImpl(
      database: db,
      kpiDao: db.kpiDao,
      syncEngine: syncEngine,
    );
  });

  tearDown(() async {
    syncEngine.dispose();
    await db.close();
  });

  group('TaskRepository Sync Enqueueing', () {
    test('createTask enqueues insert operation for tasks table', () async {
      final now = DateTime.now();
      final task = Task(
        id: 'task-sync-1',
        userId: testUserId,
        title: 'Publish YouTube Video',
        status: TaskStatus.pending,
        priority: TaskPriority.high,
        category: 'video_generation',
        createdAt: now,
        updatedAt: now,
      );

      await taskRepo.createTask(task);

      final queueItems = await db.syncDao.getPendingItems();
      expect(queueItems, isNotEmpty);
      final taskItem =
          queueItems.firstWhere((item) => item.syncTableName == 'tasks');
      expect(taskItem.recordId, equals('task-sync-1'));
      expect(taskItem.operation, equals(SyncOperation.insert.name));
      expect(taskItem.payloadJson.contains('Publish YouTube Video'), isTrue);
    });

    test('updateTask enqueues update operation for tasks table', () async {
      final now = DateTime.now();
      final task = Task(
        id: 'task-sync-2',
        userId: testUserId,
        title: 'Initial Title',
        status: TaskStatus.pending,
        priority: TaskPriority.medium,
        createdAt: now,
        updatedAt: now,
      );

      await taskRepo.createTask(task);
      await db.syncDao.clearCompleted();

      final updatedTask = task.copyWith(title: 'Updated Title');
      await taskRepo.updateTask(updatedTask);

      final queueItems = await db.syncDao.getPendingItems();
      final updateItem =
          queueItems.firstWhere((item) => item.operation == SyncOperation.update.name);
      expect(updateItem.syncTableName, equals('tasks'));
      expect(updateItem.recordId, equals('task-sync-2'));
      expect(updateItem.payloadJson.contains('Updated Title'), isTrue);
    });

    test('deleteTask enqueues delete operation for tasks table', () async {
      final now = DateTime.now();
      final task = Task(
        id: 'task-sync-3',
        userId: testUserId,
        title: 'To Be Deleted',
        status: TaskStatus.pending,
        priority: TaskPriority.low,
        createdAt: now,
        updatedAt: now,
      );

      await taskRepo.createTask(task);
      await db.syncDao.clearCompleted();

      await taskRepo.deleteTask('task-sync-3');

      final queueItems = await db.syncDao.getPendingItems();
      final deleteItem =
          queueItems.firstWhere((item) => item.operation == SyncOperation.delete.name);
      expect(deleteItem.syncTableName, equals('tasks'));
      expect(deleteItem.recordId, equals('task-sync-3'));
    });

    test('completeTaskOccurrence enqueues completion and occurrence sync', () async {
      final today = DateTime.now();
      final task = Task(
        id: 'task-sync-4',
        userId: testUserId,
        title: 'Daily Meditation',
        status: TaskStatus.pending,
        priority: TaskPriority.medium,
        scheduledDate: today,
        createdAt: today,
        updatedAt: today,
      );

      await taskRepo.createTask(task);
      await db.syncDao.clearCompleted();

      await taskRepo.completeTaskOccurrence(
        testUserId,
        'task-sync-4',
        today,
        notes: 'Great session',
      );

      final queueItems = await db.syncDao.getPendingItems();
      expect(queueItems, isNotEmpty);
      final occurrenceItem = queueItems
          .where((item) => item.syncTableName == 'task_occurrences')
          .toList();
      final completionItem = queueItems
          .where((item) => item.syncTableName == 'completion_events')
          .toList();

      expect(occurrenceItem, isNotEmpty);
      expect(completionItem, isNotEmpty);
      expect(completionItem.first.payloadJson.contains('Great session'), isTrue);
    });
  });

  group('LabelRepository Sync Enqueueing', () {
    test('createLabel and updateLabel enqueue operations', () async {
      final now = DateTime.now();
      final label = Label(
        id: 'label-sync-1',
        userId: testUserId,
        name: 'YouTube Project',
        iconName: 'video_library',
        color: '#FF0000',
        createdAt: now,
        updatedAt: now,
      );

      await labelRepo.createLabel(label);

      final items = await db.syncDao.getPendingItems();
      expect(items.any((i) => i.syncTableName == 'labels' && i.recordId == 'label-sync-1'), isTrue);

      final updated = label.copyWith(name: 'YouTube Studio');
      await labelRepo.updateLabel(updated);

      final updatedItems = await db.syncDao.getPendingItems();
      expect(updatedItems.any((i) => i.payloadJson.contains('YouTube Studio')), isTrue);
    });
  });

  group('KpiRepository Sync Enqueueing', () {
    test('createKpi and updateCurrentValue enqueue operations', () async {
      final now = DateTime.now();
      final kpi = KpiDefinition(
        id: 'kpi-sync-1',
        userId: testUserId,
        name: 'Weekly Videos',
        kpiType: KpiType.count,
        targetValue: 3,
        currentValue: 1,
        period: KpiPeriod.weekly,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await kpiRepo.createKpi(kpi);

      var items = await db.syncDao.getPendingItems();
      expect(items.any((i) => i.syncTableName == 'kpi_definitions' && i.recordId == 'kpi-sync-1'), isTrue);

      await kpiRepo.updateCurrentValue('kpi-sync-1', 2);

      items = await db.syncDao.getPendingItems();
      expect(items.any((i) => i.payloadJson.contains('"current_value":2.0') || i.payloadJson.contains('"current_value":2')), isTrue);
    });
  });
}
