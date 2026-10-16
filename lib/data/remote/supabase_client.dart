import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/errors.dart';

/// Riverpod provider exposing the application's [MomentumSupabaseClient] instance.
final supabaseClientProvider = Provider<MomentumSupabaseClient>((ref) {
  return MomentumSupabaseClient.instance;
});

/// Riverpod stream provider exposing [AuthState] events.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.authStateChanges;
});

/// Riverpod stream provider exposing the current Supabase [User] changes.
final userChangesProvider = StreamProvider<User?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.userChanges;
});

/// Result data returned when a user signs up.
class SignUpResult {
  const SignUpResult({
    required this.response,
    required this.sessionCreated,
    required this.confirmationEmailSent,
  });

  /// The underlying Supabase [AuthResponse].
  final AuthResponse response;

  /// Whether a session was established immediately upon sign up.
  final bool sessionCreated;

  /// Whether a confirmation email was sent requiring user verification.
  final bool confirmationEmailSent;

  /// The created or signed up [User].
  User? get user => response.user;

  /// The active [Session], if one was created.
  Session? get session => response.session;
}

/// Wrapper around [SupabaseClient] providing safe initialization,
/// offline-first tolerance, configuration checking, credential persistence,
/// and authentication helpers.
class MomentumSupabaseClient {
  MomentumSupabaseClient({SupabaseClient? client})
      : _client = client,
        _isConfigured = client != null;

  static const String prefSupabaseUrl = 'momentum_supabase_url';
  static const String prefSupabaseAnonKey = 'momentum_supabase_anon_key';

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

  /// Stream of currently authenticated [User] changes.
  /// Emits the current user immediately if available, and subsequently on auth changes.
  Stream<User?> get userChanges {
    if (!isConfigured || _client == null) {
      return Stream.value(currentUser);
    }
    return _client!.auth.onAuthStateChange.map((state) => state.session?.user);
  }

  /// Retrieves saved Supabase credentials from [SharedPreferences].
  Future<Map<String, String?>> getSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final url = prefs.getString(prefSupabaseUrl);
      final key = prefs.getString(prefSupabaseAnonKey);
      return {
        'url': url,
        'anonKey': key,
        prefSupabaseUrl: url,
        prefSupabaseAnonKey: key,
      };
    } catch (e) {
      debugPrint('MomentumSupabaseClient: Failed to read saved credentials: $e');
      return {
        'url': null,
        'anonKey': null,
        prefSupabaseUrl: null,
        prefSupabaseAnonKey: null,
      };
    }
  }

  /// Signs out, removes credentials from [SharedPreferences], and resets [_isConfigured].
  Future<void> clearCredentials() async {
    try {
      await signOut();
    } catch (e) {
      debugPrint('MomentumSupabaseClient: Notice signing out during clearCredentials: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(prefSupabaseUrl);
      await prefs.remove(prefSupabaseAnonKey);
    } catch (e) {
      debugPrint('MomentumSupabaseClient: Failed to remove saved credentials: $e');
    }

    _isConfigured = false;
  }

  /// Tests network and credential connectivity to a Supabase project.
  Future<Result<bool>> testConnection({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    final url = supabaseUrl.trim();
    final anonKey = supabaseAnonKey.trim();

    if (url.isEmpty || anonKey.isEmpty) {
      return Result.failure(
        const ValidationError('Supabase URL and Anon Key cannot be empty.'),
      );
    }

    try {
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
        return Result.failure(
          const ValidationError('Invalid Supabase URL format.'),
        );
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      try {
        final request = await client.getUrl(uri.replace(path: '/auth/v1/health'));
        request.headers.set('apikey', anonKey);
        request.headers.set('Authorization', 'Bearer $anonKey');
        final response = await request.close();

        if (response.statusCode >= 200 && response.statusCode < 400) {
          return Result.success(true);
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          return Result.failure(
            AuthError(
              'Authentication failed (HTTP ${response.statusCode}). Please verify your Anon Key.',
            ),
          );
        } else {
          return Result.failure(
            AuthError(
              'Supabase server responded with HTTP status ${response.statusCode}.',
            ),
          );
        }
      } finally {
        client.close();
      }
    } catch (e, st) {
      return Result.failure(
        NetworkError('Connection test failed: $e', stackTrace: st),
      );
    }
  }

  /// Safely initializes Supabase.
  ///
  /// If credentials are not provided via arguments, attempts to read them
  /// from [SharedPreferences], falling back to compile-time environment variables.
  ///
  /// If valid credentials are provided and [persist] is true, they are saved
  /// to [SharedPreferences].
  ///
  /// If credentials are missing, empty, or offline, this method will not throw.
  /// Instead, it marks [isConfigured] as `false` and returns a successful `Result.success(false)`.
  Future<Result<bool>> initialize({
    String? supabaseUrl,
    String? supabaseAnonKey,
    bool persist = true,
  }) async {
    final bool urlExplicitlyProvided = supabaseUrl != null;
    final bool keyExplicitlyProvided = supabaseAnonKey != null;

    String? url = supabaseUrl?.trim();
    String? anonKey = supabaseAnonKey?.trim();

    // If caller explicitly passed empty strings, do not fall back to defaults
    final bool explicitEmpty = (urlExplicitlyProvided && url!.isEmpty) ||
        (keyExplicitlyProvided && anonKey!.isEmpty);

    if (!explicitEmpty) {
      // 1. Read from SharedPreferences if not supplied
      if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
        try {
          final prefs = await SharedPreferences.getInstance();
          if (url == null || url.isEmpty) {
            final savedUrl = prefs.getString(prefSupabaseUrl)?.trim();
            if (savedUrl != null && savedUrl.isNotEmpty) {
              url = savedUrl;
            }
          }
          if (anonKey == null || anonKey.isEmpty) {
            final savedKey = prefs.getString(prefSupabaseAnonKey)?.trim();
            if (savedKey != null && savedKey.isNotEmpty) {
              anonKey = savedKey;
            }
          }
        } catch (e) {
          debugPrint(
            'MomentumSupabaseClient: Notice reading saved credentials from SharedPreferences: $e',
          );
        }
      }

      // 2. Fallback to compile-time environment variables, then AppConstants defaults
      if (url == null || url.isEmpty) {
        const envUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
        if (envUrl.isNotEmpty) {
          url = envUrl.trim();
        } else if (AppConstants.defaultSupabaseUrl.isNotEmpty) {
          url = AppConstants.defaultSupabaseUrl.trim();
        }
      }
      if (anonKey == null || anonKey.isEmpty) {
        const envKey =
            String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
        if (envKey.isNotEmpty) {
          anonKey = envKey.trim();
        } else if (AppConstants.defaultSupabaseAnonKey.isNotEmpty) {
          anonKey = AppConstants.defaultSupabaseAnonKey.trim();
        }
      }
    }

    if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
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

      // 3. Persist valid credentials if requested
      if (persist) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(prefSupabaseUrl, url);
          await prefs.setString(prefSupabaseAnonKey, anonKey);
        } catch (e) {
          debugPrint('MomentumSupabaseClient: Failed to persist credentials: $e');
        }
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

  /// Helper to convert Supabase [AuthException] to user-friendly message.
  String _getFriendlyAuthErrorMessage(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials') ||
        msg.contains('invalid grant')) {
      return 'Invalid email or password. Please verify your credentials and try again.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Your email address has not been confirmed yet. Please check your inbox for the verification link.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already registered') ||
        msg.contains('email address already exists')) {
      return 'An account with this email address already exists. Please sign in instead.';
    }
    if (msg.contains('user not found')) {
      return 'No account was found matching this email address.';
    }
    if (msg.contains('rate limit') ||
        msg.contains('too many requests') ||
        msg.contains('over_email_send_rate_limit')) {
      return 'Too many attempts. Please wait a few moments before trying again.';
    }
    if (msg.contains('password should be at least')) {
      return e.message;
    }
    return e.message.isNotEmpty
        ? e.message
        : 'Authentication failed. Please verify your credentials and try again.';
  }

  /// Signs in an existing user with email and password.
  Future<Result<AuthResponse>> signInWithEmail(
    String email,
    String password,
  ) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      return Result.failure(
        const AuthError('Email address cannot be empty.'),
      );
    }

    final emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegExp.hasMatch(trimmedEmail)) {
      return Result.failure(
        const AuthError('Please enter a valid email address.'),
      );
    }

    if (password.isEmpty) {
      return Result.failure(
        const AuthError('Password cannot be empty.'),
      );
    }

    if (!isConfigured || _client == null) {
      return Result.failure(
        const AuthError('Supabase is not configured. Cloud sync is disabled.'),
      );
    }

    try {
      final response = await _client!.auth.signInWithPassword(
        email: trimmedEmail,
        password: password,
      );
      return Result.success(response);
    } on AuthException catch (e, st) {
      final friendlyMsg = _getFriendlyAuthErrorMessage(e);
      return Result.failure(
        AuthError(friendlyMsg, details: e.statusCode, stackTrace: st),
      );
    } catch (e, st) {
      return Result.failure(
        AuthError('Sign in failed: $e', stackTrace: st),
      );
    }
  }

  /// Registers a new user with email and password.
  Future<Result<SignUpResult>> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      return Result.failure(
        const AuthError('Email address cannot be empty.'),
      );
    }

    final emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegExp.hasMatch(trimmedEmail)) {
      return Result.failure(
        const AuthError('Please enter a valid email address.'),
      );
    }

    if (password.isEmpty) {
      return Result.failure(
        const AuthError('Password cannot be empty.'),
      );
    }

    if (password.length < 6) {
      return Result.failure(
        const AuthError('Password must be at least 6 characters long.'),
      );
    }

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
        email: trimmedEmail,
        password: password,
        data: data,
      );

      final sessionCreated = response.session != null;
      final confirmationEmailSent =
          response.session == null && response.user != null;

      return Result.success(
        SignUpResult(
          response: response,
          sessionCreated: sessionCreated,
          confirmationEmailSent: confirmationEmailSent,
        ),
      );
    } on AuthException catch (e, st) {
      final friendlyMsg = _getFriendlyAuthErrorMessage(e);
      return Result.failure(
        AuthError(friendlyMsg, details: e.statusCode, stackTrace: st),
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
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      return Result.failure(
        const AuthError('Email address cannot be empty.'),
      );
    }

    if (!isConfigured || _client == null) {
      return Result.failure(
        const AuthError('Supabase is not configured.'),
      );
    }

    try {
      await _client!.auth.resetPasswordForEmail(trimmedEmail);
      return Result.success(null);
    } on AuthException catch (e, st) {
      final friendlyMsg = _getFriendlyAuthErrorMessage(e);
      return Result.failure(
        AuthError(friendlyMsg, details: e.statusCode, stackTrace: st),
      );
    } catch (e, st) {
      return Result.failure(
        AuthError('Password reset failed: $e', stackTrace: st),
      );
    }
  }

  /// Deletes all user data records from Supabase tables for the given [userId].
  ///
  /// Clears tables in relational order:
  /// completion_events, task_occurrences, timer_sessions, attachments,
  /// tasks, recurrence_rules, kpi_definitions, labels, notification_settings.
  Future<Result<void>> purgeUserData(String userId) async {
    final trimmedId = userId.trim();
    if (trimmedId.isEmpty) {
      return Result.failure(
        const ValidationError('User ID cannot be empty.'),
      );
    }

    if (!isConfigured || _client == null) {
      return Result.failure(
        const AuthError('Supabase is not configured. Cloud sync is disabled.'),
      );
    }

    const tables = [
      'completion_events',
      'task_occurrences',
      'timer_sessions',
      'attachments',
      'tasks',
      'recurrence_rules',
      'kpi_definitions',
      'labels',
      'notification_settings',
    ];

    final List<String> errors = [];
    for (final table in tables) {
      try {
        await _client!.from(table).delete().eq('user_id', trimmedId);
      } catch (e) {
        debugPrint(
          'MomentumSupabaseClient: Notice deleting from $table for user $trimmedId: $e',
        );
        errors.add('$table: $e');
      }
    }

    if (errors.isNotEmpty) {
      return Result.failure(
        DatabaseError(
          'Failed to purge some user data: ${errors.join('; ')}',
        ),
      );
    }

    return Result.success(null);
  }

  /// Purges all data associated with the current user, deletes their profile, and signs out.
  Future<Result<void>> deleteUserAccount() async {
    if (!isConfigured || _client == null) {
      return Result.failure(
        const AuthError('Supabase is not configured. Cloud sync is disabled.'),
      );
    }

    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      return Result.failure(
        const AuthError('No authenticated user found to delete.'),
      );
    }

    // 1. Purge all records from partitioned tables
    final purgeRes = await purgeUserData(userId);
    if (purgeRes.isFailure) {
      return purgeRes;
    }

    // 2. Delete user profile from public.users
    try {
      await _client!.from('users').delete().eq('id', userId);
    } catch (e) {
      debugPrint(
        'MomentumSupabaseClient: Notice deleting profile from users table: $e',
      );
    }

    // 3. Sign out the user
    await signOut();

    return Result.success(null);
  }

  /// Query builder helper for Supabase tables.
  SupabaseQueryBuilder? from(String table) {
    if (!isConfigured || _client == null) return null;
    return _client!.from(table);
  }
}
