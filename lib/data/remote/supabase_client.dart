import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/errors.dart';

/// Riverpod provider exposing the application's [MomentumSupabaseClient] instance.
final supabaseClientProvider = Provider<MomentumSupabaseClient>((ref) {
  return MomentumSupabaseClient.instance;
});

/// Wrapper around [SupabaseClient] providing safe initialization,
/// offline-first tolerance, configuration checking, and authentication helpers.
class MomentumSupabaseClient {
  MomentumSupabaseClient({SupabaseClient? client})
      : _client = client,
        _isConfigured = client != null;

  static MomentumSupabaseClient? _instance;

  /// Singleton instance of the client wrapper.
  static MomentumSupabaseClient get instance =>
      _instance ??= MomentumSupabaseClient();

  SupabaseClient? _client;
  bool _isConfigured = false;

  /// Returns `true` if Supabase has been properly initialized with valid credentials.
  bool get isConfigured => _isConfigured && _client != null;

  /// Access to the underlying [SupabaseClient], or `null` if not configured.
  SupabaseClient? get client => _client;

  /// Returns the currently authenticated Supabase [User], or `null` if unauthenticated
  /// or if Supabase is not configured.
  User? get currentUser => isConfigured ? _client?.auth.currentUser : null;

  /// Returns the ID of the currently authenticated user, or `null`.
  String? get currentUserId => currentUser?.id;

  /// Indicates whether a user is currently signed in.
  bool get isAuthenticated => currentUser != null;

  /// Stream of [AuthState] changes. Emits an empty stream when not configured.
  Stream<AuthState> get authStateChanges {
    if (!isConfigured || _client == null) {
      return const Stream.empty();
    }
    return _client!.auth.onAuthStateChange;
  }

  /// Safely initializes Supabase.
  ///
  /// If credentials are missing, empty, or offline, this method will not throw.
  /// Instead, it marks [isConfigured] as `false` and returns a successful `Result.success(false)`.
  Future<Result<bool>> initialize({
    String? supabaseUrl,
    String? supabaseAnonKey,
  }) async {
    final url = (supabaseUrl?.trim().isNotEmpty ?? false)
        ? supabaseUrl!.trim()
        : const String.fromEnvironment('SUPABASE_URL', defaultValue: '');

    final anonKey = (supabaseAnonKey?.trim().isNotEmpty ?? false)
        ? supabaseAnonKey!.trim()
        : const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

    if (url.isEmpty || anonKey.isEmpty) {
      debugPrint(
        'MomentumSupabaseClient: Supabase credentials not provided. Operating in local-only mode.',
      );
      _isConfigured = false;
      return Result.success(false);
    }

    try {
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
        debugPrint(
          'MomentumSupabaseClient: Invalid Supabase URL format: $url',
        );
        _isConfigured = false;
        return Result.failure(
          const AuthError('Invalid Supabase URL format provided'),
        );
      }

      // Check if Supabase was already initialized globally
      try {
        _client = Supabase.instance.client;
        _isConfigured = true;
        return Result.success(true);
      } catch (_) {
        // Not initialized yet, proceed to initialize
      }

      final supabase = await Supabase.initialize(
        url: url,
        publishableKey: anonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );

      _client = supabase.client;
      _isConfigured = true;
      debugPrint('MomentumSupabaseClient: Successfully initialized Supabase.');
      return Result.success(true);
    } catch (e, st) {
      _isConfigured = false;
      debugPrint('MomentumSupabaseClient: Failed to initialize Supabase: $e');
      return Result.failure(
        AuthError(
          'Failed to initialize Supabase: $e',
          stackTrace: st,
        ),
      );
    }
  }

  /// Signs in an existing user with email and password.
  Future<Result<AuthResponse>> signInWithEmail(
    String email,
    String password,
  ) async {
    if (!isConfigured || _client == null) {
      return Result.failure(
        const AuthError('Supabase is not configured. Cloud sync is disabled.'),
      );
    }

    try {
      final response = await _client!.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return Result.success(response);
    } on AuthException catch (e, st) {
      return Result.failure(
        AuthError(e.message, details: e.statusCode, stackTrace: st),
      );
    } catch (e, st) {
      return Result.failure(
        AuthError('Sign in failed: $e', stackTrace: st),
      );
    }
  }

  /// Registers a new user with email and password.
  Future<Result<AuthResponse>> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    if (!isConfigured || _client == null) {
      return Result.failure(
        const AuthError('Supabase is not configured. Cloud sync is disabled.'),
      );
    }

    try {
      final Map<String, dynamic>? data =
          displayName != null && displayName.isNotEmpty
              ? {'full_name': displayName, 'display_name': displayName}
              : null;

      final response = await _client!.auth.signUp(
        email: email.trim(),
        password: password,
        data: data,
      );
      return Result.success(response);
    } on AuthException catch (e, st) {
      return Result.failure(
        AuthError(e.message, details: e.statusCode, stackTrace: st),
      );
    } catch (e, st) {
      return Result.failure(
        AuthError('Sign up failed: $e', stackTrace: st),
      );
    }
  }

  /// Signs out the currently active user.
  Future<Result<void>> signOut() async {
    if (!isConfigured || _client == null) {
      return Result.success(null);
    }

    try {
      await _client!.auth.signOut();
      return Result.success(null);
    } on AuthException catch (e, st) {
      return Result.failure(
        AuthError(e.message, details: e.statusCode, stackTrace: st),
      );
    } catch (e, st) {
      return Result.failure(
        AuthError('Sign out failed: $e', stackTrace: st),
      );
    }
  }

  /// Sends a password reset email.
  Future<Result<void>> resetPassword(String email) async {
    if (!isConfigured || _client == null) {
      return Result.failure(
        const AuthError('Supabase is not configured.'),
      );
    }

    try {
      await _client!.auth.resetPasswordForEmail(email.trim());
      return Result.success(null);
    } on AuthException catch (e, st) {
      return Result.failure(
        AuthError(e.message, details: e.statusCode, stackTrace: st),
      );
    } catch (e, st) {
      return Result.failure(
        AuthError('Password reset failed: $e', stackTrace: st),
      );
    }
  }

  /// Query builder helper for Supabase tables.
  SupabaseQueryBuilder? from(String table) {
    if (!isConfigured || _client == null) return null;
    return _client!.from(table);
  }
}
