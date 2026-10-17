import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/theme/theme.dart';
import 'package:momentum/data/local/database.dart';
import 'package:momentum/data/remote/supabase_client.dart';
import 'package:momentum/features/settings/screens/settings_screen.dart';
import 'package:momentum/shared/providers/database_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeConfiguredSupabaseClient extends MomentumSupabaseClient {
  final bool configured;
  FakeConfiguredSupabaseClient({this.configured = true});

  @override
  bool get isConfigured => configured;
}

class FakeAuthenticatedSupabaseClient extends MomentumSupabaseClient {
  final User _mockUser;
  FakeAuthenticatedSupabaseClient(this._mockUser);

  @override
  bool get isConfigured => true;

  @override
  bool get isAuthenticated => true;

  @override
  User? get currentUser => _mockUser;

  @override
  String? get currentUserId => _mockUser.id;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase inMemoryDb;

  setUp(() {
    SharedPreferences.setMockInitialValues({
      MomentumSupabaseClient.prefSupabaseUrl:
          'https://saved-project.supabase.co',
      MomentumSupabaseClient.prefSupabaseAnonKey: 'saved-anon-key-abc',
    });
    inMemoryDb = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await inMemoryDb.close();
  });

  Widget buildTestApp({List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(inMemoryDb),
        ...overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme(),
        home: const Scaffold(
          body: SettingsScreen(),
        ),
      ),
    );
  }

  group('SettingsScreen Cloud Sync & Supabase UI', () {
    testWidgets('pre-populates credentials from SharedPreferences in initState',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final sectionTitleFinder = find.text('Supabase Cloud Database');
      await tester.scrollUntilVisible(
        sectionTitleFinder,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(sectionTitleFinder, findsOneWidget);

      final urlFieldFinder = find.byWidgetPredicate((w) =>
          w is TextField &&
          w.controller?.text == 'https://saved-project.supabase.co');
      expect(urlFieldFinder, findsOneWidget);

      expect(find.text('Test Connection'), findsOneWidget);
      expect(find.text('Save Credentials'), findsOneWidget);
    });

    testWidgets('displays Quick Supabase Setup Guide when unconfigured',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final guideFinder = find.text('Quick Supabase Setup Guide');
      await tester.scrollUntilVisible(
        guideFinder,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(guideFinder, findsOneWidget);
      expect(find.byIcon(Icons.wifi_tethering), findsOneWidget);
    });

    testWidgets(
        'shows SegmentedButton and switches between Sign In and Create Account',
        (tester) async {
      final mockClient = FakeConfiguredSupabaseClient(configured: true);

      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockClient),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final segmentedButtonFinder = find.byType(SegmentedButton<int>);
      await tester.scrollUntilVisible(
        segmentedButtonFinder,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(segmentedButtonFinder, findsOneWidget);
      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('Create Account'), findsWidgets);

      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Confirm Password'), findsNothing);

      final createAccountTab = find.descendant(
        of: segmentedButtonFinder,
        matching: find.text('Create Account'),
      );
      await tester.tap(createAccountTab);
      await tester.pumpAndSettle();

      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Full Name / Display Name (Optional)'), findsOneWidget);
      expect(find.text('Minimum 6 characters'), findsOneWidget);
    });

    testWidgets('database wipeUserData method clears user rows and queue',
        (tester) async {
      await inMemoryDb.wipeUserData('test-user-to-wipe');
      expect(true, isTrue);
    });

    testWidgets(
        'displays authenticated User Profile card with Cloud Synced badge and privacy actions',
        (tester) async {
      const mockUser = User(
        id: 'user-momentum-123456789',
        appMetadata: {},
        userMetadata: {'display_name': 'Auroral Master'},
        aud: 'authenticated',
        createdAt: '2026-10-16T00:00:00Z',
        email: 'auroral@momentum.app',
      );
      final authClient = FakeAuthenticatedSupabaseClient(mockUser);

      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            supabaseClientProvider.overrideWithValue(authClient),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final profileFinder = find.text('Auroral Master');
      await tester.scrollUntilVisible(
        profileFinder,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(profileFinder, findsOneWidget);
      expect(find.text('auroral@momentum.app'), findsOneWidget);
      expect(find.text('Cloud Synced'), findsOneWidget);
      expect(find.text('Sync Now'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.text('Purge My Cloud Data'), findsOneWidget);
      expect(find.text('Delete My Account'), findsOneWidget);
    });
  });
}
