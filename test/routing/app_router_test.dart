import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/app.dart';
import 'package:momentum/data/local/database.dart';
import 'package:momentum/data/sync/sync_engine.dart';
import 'package:momentum/features/analytics/screens/analytics_screen.dart';
import 'package:momentum/features/auth/screens/auth_gate_screen.dart';
import 'package:momentum/features/calendar/screens/calendar_screen.dart';
import 'package:momentum/features/dashboard/screens/dashboard_screen.dart';
import 'package:momentum/features/labels/screens/labels_screen.dart';
import 'package:momentum/features/labels/screens/parent_label_dashboard_screen.dart';
import 'package:momentum/features/labels/screens/sub_label_dashboard_screen.dart';
import 'package:momentum/features/notifications/screens/notification_history_screen.dart';
import 'package:momentum/features/settings/screens/settings_screen.dart';
import 'package:momentum/features/tasks/screens/all_tasks_screen.dart';
import 'package:momentum/features/tasks/screens/task_form_screen.dart';
import 'package:momentum/features/tasks/screens/today_tasks_screen.dart';
import 'package:momentum/routing/app_router.dart';
import 'package:momentum/shared/providers/database_provider.dart';
import 'package:momentum/shared/widgets/app_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase testDb;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    testDb = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(testDb),
        syncStatusStreamProvider.overrideWith(
          (ref) => Stream.value(SyncEngineStatus.idle),
        ),
        authGateEnabledProvider.overrideWith((ref) => false),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await testDb.close();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MomentumApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('AppRouter Navigation Tests', () {
    testWidgets('1. Route / loads DashboardScreen', (tester) async {
      await pumpApp(tester);

      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(AppScaffold), findsOneWidget);
    });

    testWidgets('2. Route /today loads TodayTasksScreen', (tester) async {
      await pumpApp(tester);

      container.read(appRouterProvider).go('/today');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TodayTasksScreen), findsOneWidget);
    });

    testWidgets('3. Route /tasks loads AllTasksScreen', (tester) async {
      await pumpApp(tester);

      container.read(appRouterProvider).go('/tasks');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AllTasksScreen), findsOneWidget);
    });

    testWidgets('4. Route /tasks/new loads TaskFormScreen in creation mode',
        (tester) async {
      await pumpApp(tester);

      container.read(appRouterProvider).go('/tasks/new');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TaskFormScreen), findsOneWidget);
      expect(find.text('New Task'), findsOneWidget);

      final taskForm = tester.widget<TaskFormScreen>(find.byType(TaskFormScreen));
      expect(taskForm.taskId, isNull);
    });

    testWidgets(
        '5. Route /tasks/new with extra parameters (parentLabelId, subLabelId, defaultScheduledDate) unpacks properly',
        (tester) async {
      await pumpApp(tester);

      final scheduledDate = DateTime(2026, 11, 20);
      container.read(appRouterProvider).go(
        '/tasks/new',
        extra: {
          'parentLabelId': 'parent-focus-1',
          'subLabelId': 'sub-channel-2',
          'defaultScheduledDate': scheduledDate,
        },
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TaskFormScreen), findsOneWidget);
      final taskForm = tester.widget<TaskFormScreen>(find.byType(TaskFormScreen));
      expect(taskForm.defaultParentLabelId, 'parent-focus-1');
      expect(taskForm.defaultLabelId, 'sub-channel-2');
      expect(taskForm.defaultScheduledDate, scheduledDate);
    });

    testWidgets('6. Route /tasks/edit/test-task-123 loads TaskFormScreen in edit mode',
        (tester) async {
      await pumpApp(tester);

      container.read(appRouterProvider).go('/tasks/edit/test-task-123');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TaskFormScreen), findsOneWidget);
      expect(find.text('Edit Task'), findsOneWidget);

      final taskForm = tester.widget<TaskFormScreen>(find.byType(TaskFormScreen));
      expect(taskForm.taskId, 'test-task-123');
    });

    testWidgets('7. Route /tasks/test-task-123/edit loads TaskFormScreen in edit mode',
        (tester) async {
      await pumpApp(tester);

      container.read(appRouterProvider).go('/tasks/test-task-123/edit');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TaskFormScreen), findsOneWidget);
      expect(find.text('Edit Task'), findsOneWidget);

      final taskForm = tester.widget<TaskFormScreen>(find.byType(TaskFormScreen));
      expect(taskForm.taskId, 'test-task-123');
    });

    testWidgets('8. Route /labels loads LabelsScreen', (tester) async {
      await pumpApp(tester);

      container.read(appRouterProvider).go('/labels');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(LabelsScreen), findsOneWidget);
    });

    testWidgets('9. Route /labels/parent/parent-123 loads ParentLabelDashboardScreen',
        (tester) async {
      await pumpApp(tester);

      container.read(appRouterProvider).go('/labels/parent/parent-123');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ParentLabelDashboardScreen), findsOneWidget);
      final screen = tester.widget<ParentLabelDashboardScreen>(
          find.byType(ParentLabelDashboardScreen));
      expect(screen.labelId, 'parent-123');
    });

    testWidgets('10. Route /labels/sub/sub-123 loads SubLabelDashboardScreen',
        (tester) async {
      await pumpApp(tester);

      container.read(appRouterProvider).go('/labels/sub/sub-123');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SubLabelDashboardScreen), findsOneWidget);
      final screen = tester.widget<SubLabelDashboardScreen>(
          find.byType(SubLabelDashboardScreen));
      expect(screen.labelId, 'sub-123');
    });

    testWidgets(
        '11. Route /labels/parent-123/sub/sub-456 loads SubLabelDashboardScreen',
        (tester) async {
      await pumpApp(tester);

      container.read(appRouterProvider).go('/labels/parent-123/sub/sub-456');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SubLabelDashboardScreen), findsOneWidget);
      final screen = tester.widget<SubLabelDashboardScreen>(
          find.byType(SubLabelDashboardScreen));
      expect(screen.labelId, 'sub-456');
    });

    testWidgets('12. Route /labels/parent-123 loads ParentLabelDashboardScreen',
        (tester) async {
      await pumpApp(tester);

      container.read(appRouterProvider).go('/labels/parent-123');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ParentLabelDashboardScreen), findsOneWidget);
      final screen = tester.widget<ParentLabelDashboardScreen>(
          find.byType(ParentLabelDashboardScreen));
      expect(screen.labelId, 'parent-123');
    });

    testWidgets('13. Route /analytics loads AnalyticsScreen', (tester) async {
      await pumpApp(tester);

      container.read(appRouterProvider).go('/analytics');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AnalyticsScreen), findsOneWidget);
    });

    testWidgets('14. Route /calendar loads CalendarScreen', (tester) async {
      await pumpApp(tester);

      container.read(appRouterProvider).go('/calendar');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CalendarScreen), findsOneWidget);
    });

    testWidgets('15. Route /settings loads SettingsScreen', (tester) async {
      await pumpApp(tester);

      container.read(appRouterProvider).go('/settings');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('16. Route /notifications loads NotificationHistoryScreen',
        (tester) async {
      await pumpApp(tester);

      container.read(appRouterProvider).go('/notifications');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(NotificationHistoryScreen), findsOneWidget);
    });

    testWidgets(
        '17. Route /invalid/nonexistent/path renders the graceful Page Not Found error screen with Return to Dashboard button and redirects to /',
        (tester) async {
      container.read(appRouterProvider).go('/invalid/nonexistent/path');
      await pumpApp(tester);

      expect(find.byType(NotFoundScreen), findsOneWidget);
      expect(find.text('Page Not Found'), findsOneWidget);
      expect(find.text('Return to Dashboard'), findsOneWidget);

      // Tap Return to Dashboard
      await tester.tap(find.text('Return to Dashboard'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets(
        'Sidebar navigation clicks in AppScaffold (switching between Dashboard, Today, Tasks, Labels, Analytics, Calendar, Settings)',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpApp(tester);
      expect(find.byType(DashboardScreen), findsOneWidget);

      // Navigate to Today's Tasks
      await tester.tap(find.widgetWithText(ListTile, "Today's Tasks"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(TodayTasksScreen), findsOneWidget);

      // Navigate to All Tasks
      await tester.tap(find.widgetWithText(ListTile, 'All Tasks'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AllTasksScreen), findsOneWidget);

      // Navigate to Labels & Projects
      await tester.tap(find.widgetWithText(ListTile, 'Labels & Projects'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(LabelsScreen), findsOneWidget);

      // Navigate to Analytics & KPIs
      await tester.tap(find.widgetWithText(ListTile, 'Analytics & KPIs'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AnalyticsScreen), findsOneWidget);

      // Navigate to Calendar & History
      await tester.tap(find.widgetWithText(ListTile, 'Calendar & History'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(CalendarScreen), findsOneWidget);

      // Navigate to Settings
      await tester.tap(find.widgetWithText(ListTile, 'Settings'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Navigate back to Dashboard
      await tester.tap(find.widgetWithText(ListTile, 'Dashboard'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('18. Route /auth loads AuthGateScreen', (tester) async {
      await pumpApp(tester);

      container.read(appRouterProvider).go('/auth');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AuthGateScreen), findsOneWidget);
      expect(find.text('SIGN IN'), findsNothing); // Text is 'Sign In'
      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('Create Account'), findsOneWidget);
    });
  });

  group('Auth Gate Redirection & UI Tests', () {
    testWidgets('Redirects to /auth on launch when authGate is active and user is unauthenticated',
        (tester) async {
      final authDb = AppDatabase.forTesting(NativeDatabase.memory());
      final authContainer = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(authDb),
          syncStatusStreamProvider.overrideWith(
            (ref) => Stream.value(SyncEngineStatus.idle),
          ),
          authGateEnabledProvider.overrideWith((ref) => true),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: authContainer,
          child: const MomentumApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AuthGateScreen), findsOneWidget);
      expect(find.text('Accelerate Your Creative & Developer Flow'), findsOneWidget);
      expect(find.text('SQL Injection-Free • Parameterized • Cloud Synced'), findsOneWidget);

      authContainer.dispose();
      await authDb.close();
    });

    testWidgets('AuthGateScreen toggles between Sign In and Create Account tabs',
        (tester) async {
      final authDb = AppDatabase.forTesting(NativeDatabase.memory());
      final authContainer = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(authDb),
          syncStatusStreamProvider.overrideWith(
            (ref) => Stream.value(SyncEngineStatus.idle),
          ),
          authGateEnabledProvider.overrideWith((ref) => true),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: authContainer,
          child: const MomentumApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Display Name (Optional)'), findsNothing);
      expect(find.widgetWithText(FilledButton, 'Sign In'), findsOneWidget);

      // Switch to Create Account
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Display Name (Optional)'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Create Account'), findsOneWidget);

      authContainer.dispose();
      await authDb.close();
    });
  });
}

