import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/app.dart';
import 'package:momentum/data/local/database.dart';
import 'package:momentum/data/sync/sync_engine.dart';
import 'package:momentum/features/dashboard/screens/dashboard_screen.dart';
import 'package:momentum/routing/app_router.dart';
import 'package:momentum/shared/providers/database_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase inMemoryDb;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    inMemoryDb = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(inMemoryDb),
        currentUserIdProvider.overrideWith((ref) => 'test-dashboard-user'),
        syncStatusStreamProvider.overrideWith(
          (ref) => Stream.value(SyncEngineStatus.idle),
        ),
        authGateEnabledProvider.overrideWith((ref) => false),
      ],
    );

    // Seed default labels & platform creator KPIs for test user
    const userId = 'test-dashboard-user';
    final labelRepo = container.read(labelRepositoryProvider);
    final kpiRepo = container.read(kpiRepositoryProvider);

    await labelRepo.seedDefaultLabels(userId);
    final labels = await labelRepo.getAllLabels(userId);
    await kpiRepo.seedDefaultPlatformKpis(userId, labels);
  });

  tearDown(() async {
    container.dispose();
    await inMemoryDb.close();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1200));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MomentumApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('Dashboard Total KPI Scorecard Widget Tests', () {
    testWidgets('renders Executive KPI Scorecard and Quick-Log buttons',
        (tester) async {
      await pumpApp(tester);

      expect(find.byType(DashboardScreen), findsOneWidget);

      // Verify Header and Executive Scorecard
      expect(find.text('Creator Cadence & Total KPIs'), findsOneWidget);
      expect(find.text('Executive KPI Scorecard'), findsOneWidget);

      // Verify filter chips
      expect(find.text('All Totals'), findsOneWidget);
      expect(find.text('Video & Content'), findsOneWidget);
      expect(find.text('Audience Reach'), findsOneWidget);

      // Verify Hero Metric Tiles
      expect(find.text('Video Output'), findsOneWidget);
      expect(find.text('Weekly Posts'), findsOneWidget);
      expect(find.text('Blog Publishing & Code Velocity'), findsOneWidget);
      expect(find.text('TOTAL AUDIENCE & COMMUNITY REACH'), findsOneWidget);

      // Verify Quick-Log Action Buttons
      expect(find.text('+1 Video'), findsOneWidget);
      expect(find.text('+1 Short'), findsOneWidget);
      expect(find.text('+1 Post'), findsOneWidget);
      expect(find.text('+1 Article'), findsOneWidget);
      expect(find.text('+1 Commit'), findsOneWidget);
    });

    testWidgets('Quick-Log +1 Video updates KPI and displays snackbar',
        (tester) async {
      await pumpApp(tester);

      final plusVideoFinder = find.text('+1 Video');
      await tester.ensureVisible(plusVideoFinder);
      await tester.pumpAndSettle();

      await tester.tap(plusVideoFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Logged +1 videos for Weekly Video Generation!'),
          findsOneWidget);
    });

    testWidgets('Quick-Log +1 Post updates KPI and displays snackbar',
        (tester) async {
      await pumpApp(tester);

      final plusPostFinder = find.text('+1 Post');
      await tester.ensureVisible(plusPostFinder);
      await tester.pumpAndSettle();

      await tester.tap(plusPostFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Logged +1 posts for'), findsOneWidget);
    });

    testWidgets('Filter chip toggles between All Totals and Audience Reach',
        (tester) async {
      await pumpApp(tester);

      final audienceChip = find.text('Audience Reach');
      await tester.ensureVisible(audienceChip);
      await tester.pumpAndSettle();

      await tester.tap(audienceChip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Audience Reach card should remain visible
      expect(find.text('TOTAL AUDIENCE & COMMUNITY REACH'), findsOneWidget);
      // Video Output tile should be hidden when filtered to audience
      expect(find.text('Video Output'), findsNothing);
    });

    testWidgets('Notification badge button navigates to notifications history',
        (tester) async {
      await pumpApp(tester);

      final notifIconFinder = find.byIcon(Icons.notifications_none_rounded);
      expect(notifIconFinder, findsOneWidget);

      await tester.tap(notifIconFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify route changed to /notifications
      expect(find.text('Notification History'), findsOneWidget);
    });
  });
}
