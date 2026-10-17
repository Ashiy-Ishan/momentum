import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/data/local/database.dart'
    hide Label, Task, RecurrenceRule, KpiDefinition, TimerSession;
import 'package:momentum/data/repositories/repositories.dart';
import 'package:momentum/domain/enums/enums.dart';
import 'package:momentum/domain/models/models.dart';

void main() {
  late AppDatabase db;
  late TaskRepository taskRepo;
  late LabelRepository labelRepo;
  late KpiRepository kpiRepo;
  late TimerRepository timerRepo;

  const testUserId = 'test-user-1';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    taskRepo = TaskRepositoryImpl(
      database: db,
      tasksDao: db.tasksDao,
      occurrencesDao: db.occurrencesDao,
    );
    labelRepo = LabelRepositoryImpl(
      database: db,
      labelsDao: db.labelsDao,
    );
    kpiRepo = KpiRepositoryImpl(
      database: db,
      kpiDao: db.kpiDao,
    );
    timerRepo = TimerRepositoryImpl(
      database: db,
      timerDao: db.timerDao,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('LabelRepository', () {
    test('seedDefaultLabels creates default labels when empty', () async {
      final initial = await labelRepo.getAllLabels(testUserId);
      expect(initial, isEmpty);

      await labelRepo.seedDefaultLabels(testUserId);

      final afterSeed = await labelRepo.getAllLabels(testUserId);
      expect(afterSeed, isNotEmpty);

      final roots = await labelRepo.getRootLabels(testUserId);
      expect(roots, isNotEmpty);

      final firstRoot = roots.first;
      final children = await labelRepo.getChildLabels(firstRoot.id);
      expect(children, isNotEmpty);
    });

    test('createLabel and updateLabel work correctly', () async {
      final now = DateTime.now();
      final label = Label(
        id: 'label-123',
        userId: testUserId,
        name: 'Work',
        iconName: 'work',
        color: '#123456',
        createdAt: now,
        updatedAt: now,
      );

      await labelRepo.createLabel(label);
      final all = await labelRepo.getAllLabels(testUserId);
      expect(all.length, equals(1));
      expect(all.first.name, equals('Work'));

      final updated = label.copyWith(name: 'Work Updated');
      await labelRepo.updateLabel(updated);

      final allAfter = await labelRepo.getAllLabels(testUserId);
      expect(allAfter.first.name, equals('Work Updated'));
    });

    test('archiveLabel and deleteLabel update state properly', () async {
      final now = DateTime.now();
      final label = Label(
        id: 'label-arch',
        userId: testUserId,
        name: 'Archive Me',
        iconName: 'archive',
        color: '#000000',
        createdAt: now,
        updatedAt: now,
      );

      await labelRepo.createLabel(label);
      await labelRepo.archiveLabel('label-arch', true);

      final roots = await labelRepo.getRootLabels(testUserId);
      expect(roots.any((l) => l.id == 'label-arch'), isFalse);

      await labelRepo.deleteLabel('label-arch');
      final all = await labelRepo.getAllLabels(testUserId);
      expect(all.any((l) => l.id == 'label-arch'), isFalse);
    });
  });

  group('TaskRepository', () {
    test('createTask, getTasksForDate, completeTaskOccurrence flow', () async {
      final today = DateTime.now();
      final task = Task(
        id: 'task-1',
        userId: testUserId,
        title: 'Review PR',
        scheduledDate: today,
        createdAt: today,
        updatedAt: today,
      );

      await taskRepo.createTask(task);
      final tasks = await taskRepo.getTasksForDate(testUserId, today);
      expect(tasks.length, equals(1));
      expect(tasks.first.title, equals('Review PR'));
      expect(tasks.first.status, equals(TaskStatus.pending));

      await taskRepo.completeTaskOccurrence(testUserId, 'task-1', today, notes: 'Done well');
      final updatedTasks = await taskRepo.getTasksForDate(testUserId, today);
      expect(updatedTasks.first.status, equals(TaskStatus.done));

      await taskRepo.uncompleteTaskOccurrence(testUserId, 'task-1', today);
      final revertedTasks = await taskRepo.getTasksForDate(testUserId, today);
      expect(revertedTasks.first.status, equals(TaskStatus.pending));
    });

    test('createTask with recurrence rule matches recurring dates', () async {
      final today = DateTime.now();
      final rule = RecurrenceRule(
        id: 'rule-daily-1',
        userId: testUserId,
        type: RecurrenceType.daily,
        startDate: today.subtract(const Duration(days: 2)),
        createdAt: today,
        updatedAt: today,
      );

      final task = Task(
        id: 'recurring-task-1',
        userId: testUserId,
        title: 'Morning Yoga',
        recurrenceRuleId: rule.id,
        createdAt: today,
        updatedAt: today,
      );

      await taskRepo.createTask(task, recurrence: rule);

      final tasks = await taskRepo.getTasksForDate(testUserId, today);
      expect(tasks.any((t) => t.id == 'recurring-task-1'), isTrue);
    });
  });

  group('KpiRepository', () {
    test('create, get, and delete KPI', () async {
      final now = DateTime.now();
      final kpi = KpiDefinition(
        id: 'kpi-1',
        userId: testUserId,
        labelId: 'label-1',
        name: 'Daily Coding',
        kpiType: KpiType.time,
        targetValue: 120,
        period: KpiPeriod.daily,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await kpiRepo.createKpi(kpi);
      final kpis = await kpiRepo.getKpisForLabel('label-1');
      expect(kpis.length, equals(1));
      expect(kpis.first.name, equals('Daily Coding'));

      await kpiRepo.deleteKpi('kpi-1');
      final kpisAfter = await kpiRepo.getKpisForLabel('label-1');
      expect(kpisAfter, isEmpty);
    });
  });

  group('TimerRepository', () {
    test('start, pause, resume, stop timer session', () async {
      final session = await timerRepo.startSession(testUserId, 'task-1');
      expect(session.status, equals(TimerSessionStatus.running));

      final active = await timerRepo.getActiveSession(testUserId);
      expect(active, isNotNull);
      expect(active!.id, equals(session.id));

      await timerRepo.pauseSession(session.id);
      final paused = await timerRepo.getActiveSession(testUserId);
      expect(paused!.status, equals(TimerSessionStatus.paused));

      await timerRepo.resumeSession(session.id);
      final resumed = await timerRepo.getActiveSession(testUserId);
      expect(resumed!.status, equals(TimerSessionStatus.running));

      await timerRepo.stopSession(session.id);
      final stoppedActive = await timerRepo.getActiveSession(testUserId);
      expect(stoppedActive, isNull);
    });
  });
}
