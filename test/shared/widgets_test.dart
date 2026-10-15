import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/theme/theme.dart';
import 'package:momentum/data/sync/sync_engine.dart';
import 'package:momentum/domain/enums/enums.dart';
import 'package:momentum/domain/models/models.dart';
import 'package:momentum/features/timer/providers/timer_providers.dart';
import 'package:momentum/shared/widgets/widgets.dart';

void main() {
  Widget buildTestableWidget(
    Widget child, {
    List<Override> overrides = const [],
    Size surfaceSize = const Size(800, 600),
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.light,
        home: MediaQuery(
          data: MediaQueryData(size: surfaceSize),
          child: Material(child: child),
        ),
      ),
    );
  }

  group('IconPickerDialog Tests', () {
    testWidgets('renders categories and search field', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const IconPickerDialog(initialIconName: 'task_alt'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Choose Icon'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Productivity'), findsOneWidget);
      expect(find.text('Learning'), findsOneWidget);
    });

    testWidgets('search filters icons', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const IconPickerDialog(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'terminal');
      await tester.pumpAndSettle();

      expect(find.text('Search Results for "terminal"'), findsOneWidget);
      expect(find.widgetWithText(InkWell, 'terminal'), findsOneWidget);
    });
  });

  group('KpiCard Tests', () {
    testWidgets('renders KPI name, target vs current, and badges', (tester) async {
      final kpi = KpiDefinition(
        id: 'kpi-1',
        userId: 'u1',
        name: 'Daily Study Hours',
        description: 'Read documentation & code',
        kpiType: KpiType.time,
        targetValue: 120.0, // 2 hours
        period: KpiPeriod.daily,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          KpiCard(
            kpi: kpi,
            currentValue: 90.0, // 1h 30m
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Daily Study Hours'), findsOneWidget);
      expect(find.text('Read documentation & code'), findsOneWidget);
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
      expect(find.text('1h 30m'), findsOneWidget);
      expect(find.text('/ 2h'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('shows Goal Met when target is achieved', (tester) async {
      final kpi = KpiDefinition(
        id: 'kpi-2',
        userId: 'u1',
        name: 'Workout Count',
        kpiType: KpiType.count,
        targetValue: 5.0,
        period: KpiPeriod.weekly,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          KpiCard(
            kpi: kpi,
            currentValue: 5.0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Goal Met'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });
  });

  group('LabelCard Tests', () {
    testWidgets('renders label details, child count and progress summary',
        (tester) async {
      final now = DateTime.now();
      final label = Label(
        id: 'label-1',
        userId: 'u1',
        name: 'Flutter Development',
        iconName: 'code',
        color: '#6366F1',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          LabelCard(
            label: label,
            childLabelCount: 3,
            completedTaskCount: 6,
            totalTaskCount: 8,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Flutter Development'), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // child label badge
      expect(find.text('6/8 tasks completed • 75%'), findsOneWidget);
    });
  });

  group('TaskCard Tests', () {
    final now = DateTime.now();
    final task = Task(
      id: 'task-1',
      userId: 'u1',
      title: 'Implement Reusable UI Components',
      description: 'Create AppScaffold, TaskCard, and KpiCard',
      priority: TaskPriority.urgent,
      status: TaskStatus.pending,
      hasTimeTracking: true,
      estimatedMinutes: 45,
      url: 'https://flutter.dev',
      dueDate: now.add(const Duration(days: 2)),
      createdAt: now,
      updatedAt: now,
    );

    testWidgets('renders task card with all attributes and triggers toggle',
        (tester) async {
      bool toggled = false;

      await tester.pumpWidget(
        buildTestableWidget(
          TaskCard(
            task: task,
            onToggleComplete: (val) => toggled = val,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Implement Reusable UI Components'), findsOneWidget);
      expect(find.text('Create AppScaffold, TaskCard, and KpiCard'), findsOneWidget);
      expect(find.text('Urgent'), findsOneWidget);
      expect(find.text('45m'), findsOneWidget);
      expect(find.text('flutter.dev'), findsOneWidget);
      expect(find.text('Track Time'), findsOneWidget);

      // Tap on status checkbox
      await tester.tap(find.byKey(const ValueKey('task_status_button')));
      await tester.pumpAndSettle();
      expect(toggled, isTrue);
    });

    testWidgets('renders overdue warning badge when due date is past', (tester) async {
      final overdueTask = task.copyWith(
        dueDate: now.subtract(const Duration(days: 2)),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          TaskCard(task: overdueTask),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Overdue'), findsOneWidget);
    });
  });

  group('ActiveTimerBanner Tests', () {
    testWidgets('renders when session is running', (tester) async {
      final now = DateTime.now();
      final activeSession = TimerSession(
        id: 'session-1',
        userId: 'u1',
        taskId: 'task-1',
        startedAt: now.subtract(const Duration(minutes: 24, seconds: 15)),
        elapsedSeconds: 1455,
        status: TimerSessionStatus.running,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          const ActiveTimerBanner(),
          overrides: [
            activeTimerStreamProvider.overrideWith((ref) => Stream.value(activeSession)),
            timerCurrentDurationProvider.overrideWith(
              (ref) => Stream.value(const Duration(minutes: 24, seconds: 15)),
            ),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('00:24:15'), findsOneWidget);
      expect(find.text('Tracking time'), findsOneWidget);
      expect(find.byIcon(Icons.pause_circle_filled_rounded), findsOneWidget);
      expect(find.byIcon(Icons.stop_circle_rounded), findsOneWidget);
    });

    testWidgets('renders nothing when no active timer', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const ActiveTimerBanner(),
          overrides: [
            activeTimerStreamProvider.overrideWith((ref) => Stream.value(null)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ActiveTimerBanner), findsOneWidget);
      expect(find.text('Tracking time'), findsNothing);
    });
  });

  group('AppScaffold Responsive Tests', () {
    testWidgets('renders Desktop layout with sidebar when width >= 1024',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AppScaffold(
            currentPath: '/',
            body: Center(child: Text('Dashboard Content')),
          ),
          overrides: [
            syncStatusStreamProvider.overrideWith(
              (ref) => Stream.value(SyncEngineStatus.idle),
            ),
          ],
          surfaceSize: const Size(1200, 800),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Momentum'), findsOneWidget);
      expect(find.text('Dashboard Content'), findsOneWidget);
      expect(find.text("Today's Tasks"), findsOneWidget);
      expect(find.text('All Tasks'), findsOneWidget);
      expect(find.text('Labels & Projects'), findsOneWidget);
      expect(find.text('Analytics & KPIs'), findsOneWidget);
      expect(find.text('Calendar & History'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Up to date'), findsOneWidget); // sync status
    });

    testWidgets('renders Mobile layout with bottom navigation when width < 1024',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AppScaffold(
            currentPath: '/',
            body: Center(child: Text('Mobile Body')),
          ),
          overrides: [
            syncStatusStreamProvider.overrideWith(
              (ref) => Stream.value(SyncEngineStatus.idle),
            ),
          ],
          surfaceSize: const Size(400, 800),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mobile Body'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.menu_rounded), findsOneWidget); // Drawer button
    });
  });
}
