import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/daos/daos.dart';
import '../../data/local/database.dart';
import '../../data/remote/supabase_client.dart';
import '../../data/repositories/repositories.dart';

/// Central Drift database instance provider.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => database.close());
  return database;
});

// =============================================================================
// DAOs
// =============================================================================

/// Tasks DAO provider.
final tasksDaoProvider = Provider<TasksDao>((ref) {
  return ref.watch(appDatabaseProvider).tasksDao;
});

/// Labels DAO provider.
final labelsDaoProvider = Provider<LabelsDao>((ref) {
  return ref.watch(appDatabaseProvider).labelsDao;
});

/// KPI DAO provider.
final kpiDaoProvider = Provider<KpiDao>((ref) {
  return ref.watch(appDatabaseProvider).kpiDao;
});

/// Timer sessions DAO provider.
final timerDaoProvider = Provider<TimerDao>((ref) {
  return ref.watch(appDatabaseProvider).timerDao;
});

/// Occurrences & Completion Events DAO provider.
final occurrencesDaoProvider = Provider<OccurrencesDao>((ref) {
  return ref.watch(appDatabaseProvider).occurrencesDao;
});

/// Offline sync queue DAO provider.
final syncDaoProvider = Provider<SyncDao>((ref) {
  return ref.watch(appDatabaseProvider).syncDao;
});

// =============================================================================
// Repositories
// =============================================================================

/// Task repository provider.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    tasksDao: ref.watch(tasksDaoProvider),
    occurrencesDao: ref.watch(occurrencesDaoProvider),
  );
});

/// Label repository provider.
final labelRepositoryProvider = Provider<LabelRepository>((ref) {
  return LabelRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    labelsDao: ref.watch(labelsDaoProvider),
  );
});

/// KPI repository provider.
final kpiRepositoryProvider = Provider<KpiRepository>((ref) {
  return KpiRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    kpiDao: ref.watch(kpiDaoProvider),
  );
});

/// Timer session repository provider.
final timerRepositoryProvider = Provider<TimerRepository>((ref) {
  return TimerRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    timerDao: ref.watch(timerDaoProvider),
  );
});

// =============================================================================
// Current User State
// =============================================================================

/// Holds the currently active user identifier ('local-user' by default).
/// Reactively follows the Supabase authenticated user when available.
final currentUserIdProvider = StateProvider<String>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final initialUser = supabase.currentUser?.id ?? 'local-user';

  // Reactively sync whenever Supabase auth changes
  final subscription = supabase.authStateChanges.listen((authState) {
    final nextUserId = authState.session?.user.id ?? 'local-user';
    if (ref.controller.state != nextUserId) {
      ref.controller.state = nextUserId;
    }
  });

  ref.onDispose(() => subscription.cancel());
  return initialUser;
});

/// Holds the currently active user display name for greetings and UI.
final currentUserNameProvider = Provider<String>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.currentUser;
  if (user != null) {
    final meta = user.userMetadata;
    final metaName =
        meta?['full_name'] ?? meta?['display_name'] ?? meta?['name'];
    if (metaName != null && metaName.toString().trim().isNotEmpty) {
      return metaName.toString().trim();
    }
    if (user.email != null && user.email!.contains('@')) {
      final handle = user.email!.split('@').first.trim();
      if (handle.isNotEmpty) {
        return handle[0].toUpperCase() + handle.substring(1);
      }
    }
  }
  return 'Creator';
});
