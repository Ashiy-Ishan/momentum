import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/data/local/database.dart'
    hide Label, Task, RecurrenceRule, KpiDefinition, TimerSession;
import 'package:momentum/domain/enums/enums.dart';
import 'package:momentum/domain/models/models.dart';
import 'package:momentum/features/analytics/providers/analytics_providers.dart';
import 'package:momentum/features/labels/providers/label_providers.dart';
import 'package:momentum/features/settings/providers/settings_providers.dart';
import 'package:momentum/features/tasks/providers/task_providers.dart';
import 'package:momentum/features/timer/providers/timer_providers.dart';
import 'package:momentum/shared/providers/database_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase inMemoryDb;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    inMemoryDb = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(inMemoryDb),
        currentUserIdProvider.overrideWith((ref) => 'test-user'),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await inMemoryDb.close();
  });

  group('Database & Core Providers', () {
    test('DAOs and current user resolve from container', () {
      final db = container.read(appDatabaseProvider);
      expect(db, equals(inMemoryDb));

      final userId = container.read(currentUserIdProvider);
      expect(userId, equals('test-user'));

      final taskRepo = container.read(taskRepositoryProvider);
      expect(taskRepo, isNotNull);

      final labelRepo = container.read(labelRepositoryProvider);
      expect(labelRepo, isNotNull);
    });
  });

  group('Task Providers & TaskController', () {
    test('TaskFilter filters tasks by status and text query', () async {
      final now = DateTime.now();
      final task1 = Task(
        id: 't-1',
        userId: 'test-user',
        title: 'Complete documentation',
        description: 'Write README and docs',
        status: TaskStatus.pending,
        scheduledDate: now,
        createdAt: now,
        updatedAt: now,
      );
      final task2 = Task(
        id: 't-2',
        userId: 'test-user',
        title: 'Review pull request',
        status: TaskStatus.done,
        scheduledDate: now,
        createdAt: now,
        updatedAt: now,
      );

      final controller = container.read(taskControllerProvider.notifier);
      await controller.createTask(task1);
      await controller.createTask(task2);

      // Verify filtered tasks without filters
      final tasksBeforeFilter =
          await container.read(tasksForSelectedDateProvider.future);
      expect(tasksBeforeFilter.length, equals(2));

      // Filter by status done
      container.read(taskFilterProvider.notifier).state = const TaskFilter(
        status: TaskStatus.done,
      );

      final filteredDone = container.read(filteredTasksProvider).valueOrNull;
      expect(filteredDone?.length, equals(1));
      expect(filteredDone?.first.id, equals('t-2'));

      // Filter by search query
      container.read(taskFilterProvider.notifier).state = const TaskFilter(
        searchQuery: 'documentation',
      );

      final filteredQuery = container.read(filteredTasksProvider).valueOrNull;
      expect(filteredQuery?.length, equals(1));
      expect(filteredQuery?.first.id, equals('t-1'));
    });

    test('TaskController complete and uncomplete occurrence', () async {
      final now = DateTime.now();
      final task = Task(
        id: 't-occ-1',
        userId: 'test-user',
        title: 'Workout',
        scheduledDate: now,
        createdAt: now,
        updatedAt: now,
      );

      final controller = container.read(taskControllerProvider.notifier);
      await controller.createTask(task);

      await controller.completeTaskOccurrence('t-occ-1', now);
      final tasks = await container.refresh(tasksForSelectedDateProvider.future);
      expect(tasks.first.status, equals(TaskStatus.done));

      await controller.uncompleteTaskOccurrence('t-occ-1', now);
      final tasksReverted =
          await container.refresh(tasksForSelectedDateProvider.future);
      expect(tasksReverted.first.status, equals(TaskStatus.pending));
    });
  });

  group('Label Providers & LabelController', () {
    test('seedDefaultLabels and watch root labels', () async {
      final controller = container.read(labelControllerProvider.notifier);
      await controller.seedDefaultLabels();

      final rootLabels = await container.read(rootLabelsStreamProvider.future);
      expect(rootLabels, isNotEmpty);
      expect(rootLabels.any((l) => l.name == 'Learning'), isTrue);

      final learningLabel = rootLabels.firstWhere((l) => l.name == 'Learning');
      final childLabels =
          await container.read(childLabelsProvider(learningLabel.id).future);
      expect(childLabels, isNotEmpty);
    });
  });

  group('Analytics Providers', () {
    test('dashboardStatsProvider computes correct stats', () async {
      final now = DateTime.now();
      final controller = container.read(taskControllerProvider.notifier);

      await controller.createTask(
        Task(
          id: 'stats-1',
          userId: 'test-user',
          title: 'Task A',
          scheduledDate: now,
          status: TaskStatus.done,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await controller.createTask(
        Task(
          id: 'stats-2',
          userId: 'test-user',
          title: 'Task B',
          scheduledDate: now,
          status: TaskStatus.pending,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Await today tasks
      await container.read(todayTasksStreamProvider.future);

      final stats = container.read(dashboardStatsProvider).valueOrNull;
      expect(stats, isNotNull);
      expect(stats!.scheduledTasks, equals(2));
      expect(stats.completedTasks, equals(1));
      expect(stats.remainingTasks, equals(1));
      expect(stats.completionRate, closeTo(0.5, 0.01));
    });
  });

  group('Timer Providers & TimerController', () {
    test('TimerController start, pause, resume, stop', () async {
      final controller = container.read(timerControllerProvider.notifier);

      final session = await controller.start('task-timer-1');
      expect(session, isNotNull);
      expect(session!.status, equals(TimerSessionStatus.running));

      await controller.pause();
      final paused = await container.refresh(activeTimerStreamProvider.future);
      expect(paused?.status, equals(TimerSessionStatus.paused));

      await controller.resume();
      final resumed = await container.refresh(activeTimerStreamProvider.future);
      expect(resumed?.status, equals(TimerSessionStatus.running));

      await controller.stopAndSave();
      final stopped = await container.refresh(activeTimerStreamProvider.future);
      expect(stopped, isNull);
    });
  });

  group('Settings Providers', () {
    test('themeModeProvider updates and persists theme', () async {
      final initial = container.read(themeModeProvider);
      expect(initial, equals(ThemeMode.system));

      await container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
      expect(container.read(themeModeProvider), equals(ThemeMode.dark));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('momentum_theme_mode'), equals('dark'));
    });

    test('notificationSettingsProvider toggles settings', () async {
      final notifier = container.read(notificationSettingsProvider.notifier);
      await notifier.toggleHourlyReminders(true);

      expect(container.read(notificationSettingsProvider).hourlyRemindersEnabled, isTrue);

      await notifier.setDailyReportTime('22:30');
      expect(container.read(notificationSettingsProvider).dailyReportTime, equals('22:30'));
    });
  });
}
