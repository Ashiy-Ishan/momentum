import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/errors.dart';

final supabaseClientProvider = Provider<MomentumSupabaseClient>((ref) {
  return MomentumSupabaseClient.instance;
});

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.authStateChanges;
});

final userChangesProvider = StreamProvider<User?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.userChanges;
});

class SignUpResult {
  const SignUpResult({
    required this.response,
    required this.sessionCreated,
    required this.confirmationEmailSent,
  });

  final AuthResponse response;

  final bool sessionCreated;

  final bool confirmationEmailSent;

  User? get user => response.user;

  Session? get session => response.session;
}

class MomentumSupabaseClient {
  MomentumSupabaseClient({SupabaseClient? client})
      : _client = client,
        _isConfigured = client != null;

  static const String prefSupabaseUrl = 'momentum_supabase_url';
  static const String prefSupabaseAnonKey = 'momentum_supabase_anon_key';

  static MomentumSupabaseClient? _instance;

  static MomentumSupabaseClient get instance =>
      _instance ??= MomentumSupabaseClient();

  SupabaseClient? _client;
  String? _currentUrl;
  bool _isConfigured = false;

  bool get isConfigured => _isConfigured && _client != null;

  String? get currentUrl => _currentUrl;

  SupabaseClient? get client => _client;

  User? get currentUser => isConfigured ? _client?.auth.currentUser : null;

  String? get currentUserId => currentUser?.id;

  bool get isAuthenticated => currentUser != null;

  Stream<AuthState> get authStateChanges {
    if (!isConfigured || _client == null) {
      return const Stream.empty();
    }
    return _client!.auth.onAuthStateChange;
  }

  Stream<User?> get userChanges {
    if (!isConfigured || _client == null) {
      return Stream.value(currentUser);
    }
    return _client!.auth.onAuthStateChange.map((state) => state.session?.user);
  }

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

    try {
      if (Supabase.instance.isInitialized) {
        await Supabase.instance.dispose();
      }
    } catch (_) {}

    _client = null;
    _isConfigured = false;
    _currentUrl = null;
  }

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
        final request = await client
            .getUrl(uri.replace(path: '/auth/v1/health'))
            .timeout(const Duration(seconds: 8));
        request.headers.set('apikey', anonKey);
        request.headers.set('Authorization', 'Bearer $anonKey');
        final response = await request.close().timeout(const Duration(seconds: 8));
        await response.drain<void>();

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
        client.close(force: true);
      }
    } catch (e, st) {
      return Result.failure(
        NetworkError('Connection test failed: $e', stackTrace: st),
      );
    }
  }

  Future<Result<bool>> initialize({
    String? supabaseUrl,
    String? supabaseAnonKey,
    bool persist = true,
  }) async {
    final bool urlExplicitlyProvided = supabaseUrl != null;
    final bool keyExplicitlyProvided = supabaseAnonKey != null;

    String? url = supabaseUrl?.trim();
    String? anonKey = supabaseAnonKey?.trim();

    final bool explicitEmpty = (urlExplicitlyProvided && url!.isEmpty) ||
        (keyExplicitlyProvided && anonKey!.isEmpty);

    if (!explicitEmpty) {
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

      if (persist) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(prefSupabaseUrl, url);
          await prefs.setString(prefSupabaseAnonKey, anonKey);
        } catch (e) {
          debugPrint('MomentumSupabaseClient: Failed to persist credentials: $e');
        }
      }

      try {
        if (Supabase.instance.isInitialized) {
          if (_currentUrl != url) {
            await Supabase.instance.dispose();
          } else {
            _client = Supabase.instance.client;
            _isConfigured = true;
            _currentUrl = url;
            return Result.success(true);
          }
        }
      } catch (_) {
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
      _currentUrl = url;
      debugPrint('MomentumSupabaseClient: Successfully initialized Supabase.');
      return Result.success(true);
    } catch (e, st) {
      _isConfigured = false;
      _currentUrl = null;
      debugPrint('MomentumSupabaseClient: Failed to initialize Supabase: $e');
      return Result.failure(
        AuthError(
          'Failed to initialize Supabase: $e',
          stackTrace: st,
        ),
      );
    }
  }

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
      ).timeout(const Duration(seconds: 15));
      return Result.success(response);
    } on TimeoutException {
      return Result.failure(
        const NetworkError('Sign in request timed out. Please check your network connection.'),
      );
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
      ).timeout(const Duration(seconds: 15));

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
    } on TimeoutException {
      return Result.failure(
        const NetworkError('Sign up request timed out. Please check your network connection.'),
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

  Future<Result<void>> signOut() async {
    if (!isConfigured || _client == null) {
      return Result.success(null);
    }

    try {
      await _client!.auth.signOut().timeout(const Duration(seconds: 10));
      return Result.success(null);
    } on TimeoutException {
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
      await _client!.auth.resetPasswordForEmail(trimmedEmail).timeout(const Duration(seconds: 10));
      return Result.success(null);
    } on TimeoutException {
      return Result.failure(
        const NetworkError('Password reset request timed out. Please check your network connection.'),
      );
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
        await _client!.from(table).delete().eq('user_id', trimmedId).timeout(const Duration(seconds: 10));
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

    final purgeRes = await purgeUserData(userId);
    if (purgeRes.isFailure) {
      return purgeRes;
    }

    try {
      await _client!.from('users').delete().eq('id', userId).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint(
        'MomentumSupabaseClient: Notice deleting profile from users table: $e',
      );
    }

    await signOut();

    return Result.success(null);
  }

  SupabaseQueryBuilder? from(String table) {
    if (!isConfigured || _client == null) return null;
    return _client!.from(table);
  }
}
