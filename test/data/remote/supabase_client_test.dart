import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/data/remote/supabase_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MomentumSupabaseClient', () {
    test('starts unconfigured when instantiated without client', () {
      final client = MomentumSupabaseClient();
      expect(client.isConfigured, isFalse);
      expect(client.currentUser, isNull);
      expect(client.currentUserId, isNull);
      expect(client.isAuthenticated, isFalse);
      expect(client.client, isNull);
      expect(client.from('tasks'), isNull);
    });

    test('initialize returns success(false) when credentials are empty without throwing', () async {
      final client = MomentumSupabaseClient();
      final result = await client.initialize(supabaseUrl: '', supabaseAnonKey: '');
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isFalse);
      expect(client.isConfigured, isFalse);
    });

    test('initialize returns failure when invalid URL is passed', () async {
      final client = MomentumSupabaseClient();
      final result = await client.initialize(
        supabaseUrl: 'not_a_valid_url',
        supabaseAnonKey: 'some_key',
      );
      expect(result.isFailure, isTrue);
      expect(client.isConfigured, isFalse);
    });

    test('credential persistence in SharedPreferences works as expected', () async {
      final client = MomentumSupabaseClient();
      
      final initialCreds = await client.getSavedCredentials();
      expect(initialCreds['url'], isNull);
      expect(initialCreds['anonKey'], isNull);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(MomentumSupabaseClient.prefSupabaseUrl, 'https://test.supabase.co');
      await prefs.setString(MomentumSupabaseClient.prefSupabaseAnonKey, 'test-key-123');

      final saved = await client.getSavedCredentials();
      expect(saved['url'], equals('https://test.supabase.co'));
      expect(saved['anonKey'], equals('test-key-123'));
      expect(saved[MomentumSupabaseClient.prefSupabaseUrl], equals('https://test.supabase.co'));

      await client.clearCredentials();
      final afterClear = await client.getSavedCredentials();
      expect(afterClear['url'], isNull);
      expect(afterClear['anonKey'], isNull);
      expect(client.isConfigured, isFalse);
    });

    test('signInWithEmail validates email and password input', () async {
      final client = MomentumSupabaseClient();

      final r1 = await client.signInWithEmail('', 'password123');
      expect(r1.isFailure, isTrue);
      expect(r1.errorOrNull?.message, contains('cannot be empty'));

      final r2 = await client.signInWithEmail('not-an-email', 'password123');
      expect(r2.isFailure, isTrue);
      expect(r2.errorOrNull?.message, contains('valid email'));

      final r3 = await client.signInWithEmail('test@example.com', '');
      expect(r3.isFailure, isTrue);
      expect(r3.errorOrNull?.message, contains('Password cannot be empty'));

      final r4 = await client.signInWithEmail('test@example.com', 'password123');
      expect(r4.isFailure, isTrue);
      expect(r4.errorOrNull?.message, contains('Supabase is not configured'));
    });

    test('signUpWithEmail validates email and password length', () async {
      final client = MomentumSupabaseClient();

      final r1 = await client.signUpWithEmail('   ', 'password123');
      expect(r1.isFailure, isTrue);
      expect(r1.errorOrNull?.message, contains('cannot be empty'));

      final r2 = await client.signUpWithEmail('bad-email@', 'password123');
      expect(r2.isFailure, isTrue);
      expect(r2.errorOrNull?.message, contains('valid email'));

      final r3 = await client.signUpWithEmail('test@example.com', '');
      expect(r3.isFailure, isTrue);
      expect(r3.errorOrNull?.message, contains('Password cannot be empty'));

      final r4 = await client.signUpWithEmail('test@example.com', '12345');
      expect(r4.isFailure, isTrue);
      expect(r4.errorOrNull?.message, contains('at least 6 characters'));

      final r5 = await client.signUpWithEmail('test@example.com', 'password123');
      expect(r5.isFailure, isTrue);
      expect(r5.errorOrNull?.message, contains('Supabase is not configured'));
    });

    test('purgeUserData validates userId and handles unconfigured client', () async {
      final client = MomentumSupabaseClient();

      final emptyResult = await client.purgeUserData('   ');
      expect(emptyResult.isFailure, isTrue);
      expect(emptyResult.errorOrNull?.message, contains('User ID cannot be empty'));

      final validResult = await client.purgeUserData('user-123');
      expect(validResult.isFailure, isTrue);
      expect(validResult.errorOrNull?.message, contains('Supabase is not configured'));
    });

    test('deleteUserAccount validates authenticated user presence and client configuration', () async {
      final client = MomentumSupabaseClient();
      final result = await client.deleteUserAccount();
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.message, contains('Supabase is not configured'));
    });

    test('authStateChanges and userChanges stream properly when unconfigured', () async {
      final client = MomentumSupabaseClient();
      final events = await client.authStateChanges.toList();
      expect(events, isEmpty);

      final user = await client.userChanges.first;
      expect(user, isNull);
    });

    test('testConnection validates URL and anon key parameters', () async {
      final client = MomentumSupabaseClient();

      final r1 =
          await client.testConnection(supabaseUrl: '', supabaseAnonKey: '');
      expect(r1.isFailure, isTrue);
      expect(r1.errorOrNull?.message, contains('cannot be empty'));

      final r2 = await client.testConnection(
        supabaseUrl: 'not_a_url',
        supabaseAnonKey: 'some-key',
      );
      expect(r2.isFailure, isTrue);
      expect(r2.errorOrNull?.message, contains('Invalid Supabase URL format'));
    });
  });
}
