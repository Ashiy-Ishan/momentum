import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/data/remote/supabase_client.dart';

void main() {
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

    test('auth helpers fail gracefully when unconfigured', () async {
      final client = MomentumSupabaseClient();
      final signInResult = await client.signInWithEmail('test@example.com', 'password123');
      expect(signInResult.isFailure, isTrue);
      expect(signInResult.errorOrNull?.message, contains('Supabase is not configured'));

      final signUpResult = await client.signUpWithEmail('test@example.com', 'password123');
      expect(signUpResult.isFailure, isTrue);
      expect(signUpResult.errorOrNull?.message, contains('Supabase is not configured'));

      final resetResult = await client.resetPassword('test@example.com');
      expect(resetResult.isFailure, isTrue);

      final signOutResult = await client.signOut();
      expect(signOutResult.isSuccess, isTrue);
    });

    test('authStateChanges emits empty stream when unconfigured', () async {
      final client = MomentumSupabaseClient();
      final events = await client.authStateChanges.toList();
      expect(events, isEmpty);
    });
  });
}
