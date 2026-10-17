import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/errors.dart';
import '../../domain/enums/enums.dart';
import '../local/database.dart';
import '../remote/supabase_client.dart';
import 'conflict_resolver.dart';

import '../../shared/providers/database_provider.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return ref.watch(appDatabaseProvider);
});

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.watch(databaseProvider);
  final supabase = ref.watch(supabaseClientProvider);
  final resolver = ref.watch(conflictResolverProvider);

  final engine = SyncEngine(
    db: db,
    supabase: supabase,
    conflictResolver: resolver,
  );

  engine.initialize();
  ref.onDispose(() => engine.dispose());
  return engine;
});

final syncStatusStreamProvider = StreamProvider<SyncEngineStatus>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.syncStatusStream;
});

final syncStatusProvider = Provider<SyncEngineStatus>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.currentStatus;
});

final syncErrorStreamProvider = StreamProvider<String?>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.syncErrorStream;
});

final syncLastErrorProvider = Provider<String?>((ref) {
  final engine = ref.watch(syncEngineProvider);
  final errorAsync = ref.watch(syncErrorStreamProvider);
  return errorAsync.valueOrNull ?? engine.lastError;
});

enum SyncEngineStatus {
  idle,
  syncing,
  offline,
  error;

  String get displayName {
    switch (this) {
      case SyncEngineStatus.idle:
        return 'Up to date';
      case SyncEngineStatus.syncing:
        return 'Syncing...';
      case SyncEngineStatus.offline:
        return 'Offline';
      case SyncEngineStatus.error:
        return 'Sync error';
    }
  }
}

class SyncEngine {
  final AppDatabase db;
  final MomentumSupabaseClient _supabase;
  final ConflictResolver _conflictResolver;
  final Connectivity _connectivity;
  SharedPreferences? prefs;

  SyncEngine({
    required this.db,
    MomentumSupabaseClient? supabase,
    ConflictResolver? conflictResolver,
    Connectivity? connectivity,
    this.prefs,
  })  : _supabase = supabase ?? MomentumSupabaseClient.instance,
        _conflictResolver = conflictResolver ?? const ConflictResolver(),
        _connectivity = connectivity ?? Connectivity();

  static const String _prefLastSyncKey = 'momentum_last_sync_timestamp';
  static const Uuid _uuid = Uuid();

  SyncEngineStatus _status = SyncEngineStatus.idle;
  String? _lastError;
  DateTime? _lastSyncTime;
  bool _isSyncInProgress = false;
  bool _isOnline = true;
  bool _isInitialized = false;

  final StreamController<SyncEngineStatus> _statusController =
      StreamController<SyncEngineStatus>.broadcast();
  final StreamController<String?> _errorController =
      StreamController<String?>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<dynamic>? _authSubscription;
  RealtimeChannel? _realtimeChannel;
  Timer? _periodicSyncTimer;
  Timer? _debounceTimer;

  SyncEngineStatus get currentStatus => _status;

  Stream<SyncEngineStatus> get syncStatusStream => _statusController.stream;

  Stream<String?> get syncErrorStream => _errorController.stream;

  String? get lastError => _lastError;

  DateTime? get lastSyncTime => _lastSyncTime;

  bool get isOnline => _isOnline;

  Future<bool> _verifyInternetAccess() async {
    try {
      String? host;
      final url = _supabase.currentUrl;
      if (url != null && url.isNotEmpty) {
        host = Uri.tryParse(url)?.host;
      }
      host ??= 'google.com';

      final lookup = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 4));
      return lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
    } catch (_) {
      try {
        final fallbackLookup = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 3));
        return fallbackLookup.isNotEmpty &&
            fallbackLookup[0].rawAddress.isNotEmpty;
      } catch (_) {
        return false;
      }
    }
  }

  Future<bool> _checkAndSetOnlineStatus() async {
    bool hasNet = false;
    try {
      final results = await _connectivity.checkConnectivity();
      hasNet = _hasConnection(results);
    } catch (e) {
      debugPrint('SyncEngine: connectivity_plus check notice ($e), checking socket...');
      hasNet = false;
    }

    if (!hasNet) {
      hasNet = await _verifyInternetAccess();
    }

    _isOnline = hasNet;
    _status = _isOnline ? SyncEngineStatus.idle : SyncEngineStatus.offline;
    _emitStatus(_status);
    return _isOnline;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      prefs ??= await SharedPreferences.getInstance();
      final storedSync = prefs?.getString(_prefLastSyncKey);
      if (storedSync != null && storedSync.isNotEmpty) {
        _lastSyncTime = DateTime.tryParse(storedSync);
      }
    } catch (e) {
      debugPrint('SyncEngine: prefs load notice: $e');
    }

    await _checkAndSetOnlineStatus();

    try {
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (results) async {
          var online = _hasConnection(results);
          if (!online) {
            online = await _verifyInternetAccess();
          }
          if (_isOnline != online) {
            _isOnline = online;
            if (!_isOnline) {
              _updateStatus(SyncEngineStatus.offline);
            } else {
              _updateStatus(SyncEngineStatus.idle);
              if (_supabase.isConfigured && _supabase.isAuthenticated) {
                unawaited(triggerSync());
                _setupRealtimeSubscription();
              }
            }
          }
        },
      );
    } catch (e) {
      debugPrint('SyncEngine: connectivity listener notice: $e');
    }

    try {
      _authSubscription = _supabase.authStateChanges.listen((data) async {
        debugPrint('SyncEngine: Auth state change: ${data.event}');
        if (_supabase.isAuthenticated) {
          if (!_isOnline) {
            await _checkAndSetOnlineStatus();
          }
          if (_isOnline) {
            unawaited(triggerSync());
            _setupRealtimeSubscription();
          }
        } else {
          _cleanupRealtime();
        }
      });
    } catch (e) {
      debugPrint('SyncEngine: auth listener notice: $e');
    }

    if (_supabase.isConfigured && _supabase.isAuthenticated) {
      if (!_isOnline) {
        await _checkAndSetOnlineStatus();
      }
      if (_isOnline) {
        unawaited(triggerSync());
        _setupRealtimeSubscription();
      }
    }
  }

  void _setupRealtimeSubscription() {
    _cleanupRealtime();
    if (!_supabase.isConfigured || !_supabase.isAuthenticated) return;

    try {
      final client = _supabase.client;
      if (client != null) {
        _realtimeChannel = client.channel('public:momentum_realtime')
          ..onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            callback: (payload) {
              debugPrint('SyncEngine: Realtime DB change received for ${payload.table}');
              _debounceRemoteSync();
            },
          )
          ..subscribe();
      }
    } catch (e) {
      debugPrint('SyncEngine: Realtime subscription notice: $e');
    }

    _periodicSyncTimer = Timer.periodic(const Duration(seconds: 25), (_) async {
      if (!_supabase.isConfigured || !_supabase.isAuthenticated || _isSyncInProgress) {
        return;
      }
      if (!_isOnline) {
        await _checkAndSetOnlineStatus();
      }
      if (_isOnline) {
        unawaited(triggerSync());
      }
    });
  }

  void _debounceRemoteSync() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
      if (!_isOnline) {
        await _checkAndSetOnlineStatus();
      }
      if (_isOnline && _supabase.isConfigured && _supabase.isAuthenticated) {
        unawaited(triggerSync());
      }
    });
  }

  void _cleanupRealtime() {
    try {
      _realtimeChannel?.unsubscribe();
      _realtimeChannel = null;
    } catch (_) {}
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  void dispose() {
    _cleanupRealtime();
    _connectivitySubscription?.cancel();
    _authSubscription?.cancel();
    _statusController.close();
    _errorController.close();
  }

  Future<void> enqueueOperation({
    required String tableName,
    required String recordId,
    required SyncOperation operation,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final item = SyncQueueItemsCompanion(
        id: Value(_uuid.v4()),
        syncTableName: Value(tableName),
        recordId: Value(recordId),
        operation: Value(operation.name),
        payloadJson: Value(jsonEncode(payload)),
        retryCount: const Value(0),
        createdAt: Value(DateTime.now()),
        status: const Value('pending'),
      );

      await db.syncDao.enqueue(item);

      if (_supabase.isConfigured && _supabase.isAuthenticated) {
        if (!_isOnline) {
          await _checkAndSetOnlineStatus();
        }
        if (_isOnline) {
          unawaited(triggerSync());
        }
      }
    } catch (e, st) {
      debugPrint('SyncEngine: Failed to enqueue operation: $e\n$st');
    }
  }

  Future<Result<bool>> triggerSync({bool forceFullSync = false}) async {
    if (_isSyncInProgress) {
      return Result.success(false);
    }

    if (!_isOnline) {
      final hasNet = await _checkAndSetOnlineStatus();
      if (!hasNet) {
        _updateStatus(SyncEngineStatus.offline);
        return Result.success(false);
      }
    }

    if (!_supabase.isConfigured || !_supabase.isAuthenticated) {
      _updateStatus(SyncEngineStatus.idle);
      return Result.success(false);
    }

    _isSyncInProgress = true;
    _updateStatus(SyncEngineStatus.syncing);

    try {
      await _pushLocalChanges();

      await _pullRemoteChanges(forceFullSync: forceFullSync);

      await db.syncDao.clearCompleted();

      _lastSyncTime = DateTime.now().toUtc();
      await _saveLastSyncTime(_lastSyncTime!);
      _lastError = null;
      _updateStatus(SyncEngineStatus.idle);

      return Result.success(true);
    } catch (e, st) {
      _lastError = e.toString();
      debugPrint('SyncEngine: Sync failed: $e\n$st');
      _updateStatus(SyncEngineStatus.error, error: e.toString());
      return Result.failure(
        SyncError('Sync cycle failed: $e', stackTrace: st),
      );
    } finally {
      _isSyncInProgress = false;
    }
  }

  Future<void> _pushLocalChanges() async {
    final currentAuthUserId = _supabase.currentUserId;
    if (currentAuthUserId != null && currentAuthUserId.isNotEmpty) {
      await _reconcileUnsyncedLocalRecords(currentAuthUserId);
    }

    final pendingItems = await db.syncDao.getPendingItems();
    if (pendingItems.isEmpty) return;

    for (final item in pendingItems) {
      if (item.retryCount >= AppConstants.maxRetryAttempts) {
        await db.syncDao.markFailed(
          item.id,
          'Exceeded max retry attempts (${AppConstants.maxRetryAttempts})',
        );
        continue;
      }

      Map<String, dynamic> rawPayload = {};
      try {
        if (item.payloadJson.isNotEmpty) {
          rawPayload = jsonDecode(item.payloadJson) as Map<String, dynamic>;
        }
      } catch (_) {}

      final remoteTable = _mapToRemoteTableName(item.syncTableName);
      final remotePayload = _toRemoteSnakeCase(rawPayload);

      if (currentAuthUserId != null && currentAuthUserId.isNotEmpty) {
        if (remotePayload.containsKey('user_id') &&
            (remotePayload['user_id'] == 'local-user' || remotePayload['user_id'] == null)) {
          remotePayload['user_id'] = currentAuthUserId;
        }
        if (remoteTable == 'users' && remotePayload['id'] == 'local-user') {
          remotePayload['id'] = currentAuthUserId;
        }
      }

      try {
        final client = _supabase.client;
        if (client == null) throw const SyncError('Supabase client unavailable');

        final op = SyncOperation.fromString(item.operation);
        if (op == SyncOperation.delete) {
          await client.from(remoteTable).update({
            'is_deleted': true,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', item.recordId).timeout(const Duration(seconds: 15));
        } else {
          await client.from(remoteTable).upsert(remotePayload).timeout(const Duration(seconds: 15));
        }

        await db.syncDao.markCompleted(item.id);
      } catch (e) {
        await db.syncDao.incrementRetry(item.id);

        if (item.retryCount + 1 >= AppConstants.maxRetryAttempts) {
          await db.syncDao.markFailed(item.id, e.toString());
        }

        final backoffMs = min(300 * pow(2, item.retryCount).toInt(), 5000);
        await Future<void>.delayed(Duration(milliseconds: backoffMs));
      }
    }
  }

  Future<void> _reconcileUnsyncedLocalRecords(String currentUserId) async {
    final client = _supabase.client;
    if (client == null) return;

    const tables = [
      'tasks',
      'labels',
      'kpi_definitions',
      'recurrence_rules',
      'task_occurrences',
      'completion_events',
      'timer_sessions',
      'attachments',
      'notification_settings_table',
    ];
    for (final table in tables) {
      try {
        await db.customUpdate(
          'UPDATE $table SET user_id = ? WHERE user_id = ? OR user_id IS NULL OR user_id = ""',
          variables: [
            Variable.withString(currentUserId),
            Variable.withString('local-user'),
          ],
          updates: {},
        );
      } catch (e) {
        debugPrint('SyncEngine: Notice updating user_id on $table: $e');
      }
    }

    try {
      await db.customUpdate(
        'UPDATE user_profiles SET id = ? WHERE id = ? OR id IS NULL OR id = ""',
        variables: [
          Variable.withString(currentUserId),
          Variable.withString('local-user'),
        ],
        updates: {},
      );
    } catch (e) {
      debugPrint('SyncEngine: Notice updating id on user_profiles: $e');
    }

    try {
      final remoteLabelRows = await client
          .from('labels')
          .select('id')
          .eq('user_id', currentUserId)
          .timeout(const Duration(seconds: 10));
      final Set<String> remoteLabelIds = {
        for (final r in (remoteLabelRows as List<dynamic>)) (r['id'] as String),
      };

      final localLabels = await (db.select(db.labels)
            ..where((tbl) => tbl.userId.equals(currentUserId)))
          .get();

      final rootLabels = localLabels
          .where((l) => l.parentId == null || l.parentId!.isEmpty)
          .toList();
      final childLabels = localLabels
          .where((l) => l.parentId != null && l.parentId!.isNotEmpty)
          .toList();

      for (final l in rootLabels) {
        if (!remoteLabelIds.contains(l.id)) {
          try {
            final payload = _mapLabelToRemoteMap(l, currentUserId);
            await client.from('labels').upsert(payload).timeout(const Duration(seconds: 10));
            remoteLabelIds.add(l.id);
          } catch (e) {
            debugPrint('SyncEngine: Error upserting root label ${l.id}: $e');
          }
        }
      }

      for (final l in childLabels) {
        if (!remoteLabelIds.contains(l.id)) {
          try {
            final payload = _mapLabelToRemoteMap(l, currentUserId);
            await client.from('labels').upsert(payload).timeout(const Duration(seconds: 10));
            remoteLabelIds.add(l.id);
          } catch (e) {
            debugPrint('SyncEngine: Error upserting child label ${l.id}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('SyncEngine: Labels reconciliation notice: $e');
    }

    try {
      final remoteRecurrenceRows = await client
          .from('recurrence_rules')
          .select('id')
          .eq('user_id', currentUserId)
          .timeout(const Duration(seconds: 10));
      final Set<String> remoteRecurrenceIds = {
        for (final r in (remoteRecurrenceRows as List<dynamic>))
          (r['id'] as String),
      };

      final localRules = await (db.select(db.recurrenceRules)
            ..where((tbl) => tbl.userId.equals(currentUserId)))
          .get();

      for (final r in localRules) {
        if (!remoteRecurrenceIds.contains(r.id)) {
          try {
            await client.from('recurrence_rules').upsert({
              'id': r.id,
              'user_id': currentUserId,
              'type': r.type,
              'days_of_week': r.daysOfWeek,
              'interval_days': r.intervalDays,
              'interval_months': r.intervalMonths,
              'start_date': r.startDate.toIso8601String(),
              'end_date': r.endDate?.toIso8601String(),
              'max_occurrences': r.maxOccurrences,
              'created_at': r.createdAt.toIso8601String(),
              'updated_at': r.updatedAt.toIso8601String(),
              'version': r.version,
              'is_deleted': r.isDeleted,
            }).timeout(const Duration(seconds: 10));
            remoteRecurrenceIds.add(r.id);
          } catch (e) {
            debugPrint('SyncEngine: Error upserting recurrence rule ${r.id}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('SyncEngine: Recurrence rules reconciliation notice: $e');
    }

    try {
      final remoteTaskRows = await client
          .from('tasks')
          .select('id')
          .eq('user_id', currentUserId)
          .timeout(const Duration(seconds: 10));
      final Set<String> remoteTaskIds = {
        for (final r in (remoteTaskRows as List<dynamic>)) (r['id'] as String),
      };

      final localTasks = await (db.select(db.tasks)
            ..where((tbl) => tbl.userId.equals(currentUserId)))
          .get();

      for (final t in localTasks) {
        if (!remoteTaskIds.contains(t.id)) {
          try {
            final payload = _mapTaskToRemoteMap(t, currentUserId);
            await client.from('tasks').upsert(payload).timeout(const Duration(seconds: 10));
            remoteTaskIds.add(t.id);
          } catch (e) {
            debugPrint(
              'SyncEngine: Error upserting task ${t.id} (${t.title}): $e',
            );
            try {
              final fallbackPayload = _mapTaskToRemoteMap(t, currentUserId);
              fallbackPayload['label_id'] = null;
              fallbackPayload['recurrence_rule_id'] = null;
              await client.from('tasks').upsert(fallbackPayload).timeout(const Duration(seconds: 10));
              remoteTaskIds.add(t.id);
            } catch (_) {}
          }
        }
      }
    } catch (e) {
      debugPrint('SyncEngine: Tasks reconciliation notice: $e');
    }

    try {
      final remoteKpiRows = await client
          .from('kpi_definitions')
          .select('id')
          .eq('user_id', currentUserId)
          .timeout(const Duration(seconds: 10));
      final Set<String> remoteKpiIds = {
        for (final r in (remoteKpiRows as List<dynamic>)) (r['id'] as String),
      };

      final localKpis = await (db.select(db.kpiDefinitions)
            ..where((tbl) => tbl.userId.equals(currentUserId)))
          .get();

      for (final k in localKpis) {
        if (!remoteKpiIds.contains(k.id)) {
          try {
            final payload = _mapKpiToRemoteMap(k, currentUserId);
            await client.from('kpi_definitions').upsert(payload).timeout(const Duration(seconds: 10));
            remoteKpiIds.add(k.id);
          } catch (e) {
            debugPrint(
              'SyncEngine: Error upserting KPI ${k.id} (${k.name}): $e',
            );
            try {
              final fallbackPayload = _mapKpiToRemoteMap(k, currentUserId);
              fallbackPayload['label_id'] = null;
              await client.from('kpi_definitions').upsert(fallbackPayload).timeout(const Duration(seconds: 10));
              remoteKpiIds.add(k.id);
            } catch (_) {}
          }
        }
      }
    } catch (e) {
      debugPrint('SyncEngine: KPI reconciliation notice: $e');
    }

    try {
      final remoteOccRows = await client
          .from('task_occurrences')
          .select('id')
          .eq('user_id', currentUserId)
          .timeout(const Duration(seconds: 10));
      final Set<String> remoteOccIds = {
        for (final r in (remoteOccRows as List<dynamic>)) (r['id'] as String),
      };

      final localOccs = await (db.select(db.taskOccurrences)
            ..where((tbl) => tbl.userId.equals(currentUserId)))
          .get();

      for (final occ in localOccs) {
        if (!remoteOccIds.contains(occ.id)) {
          try {
            await client.from('task_occurrences').upsert({
              'id': occ.id,
              'user_id': currentUserId,
              'task_id': occ.taskId,
              'occurrence_date': occ.occurrenceDate.toIso8601String(),
              'status': occ.status,
              'completed_at': occ.completedAt?.toIso8601String(),
              'created_at': occ.createdAt.toIso8601String(),
              'updated_at': occ.updatedAt.toIso8601String(),
              'version': occ.version,
              'is_deleted': occ.isDeleted,
            }).timeout(const Duration(seconds: 10));
            remoteOccIds.add(occ.id);
          } catch (e) {
            debugPrint('SyncEngine: Error upserting task occurrence ${occ.id}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('SyncEngine: Task occurrences reconciliation notice: $e');
    }

    try {
      final remoteCompRows = await client
          .from('completion_events')
          .select('id')
          .eq('user_id', currentUserId)
          .timeout(const Duration(seconds: 10));
      final Set<String> remoteCompIds = {
        for (final r in (remoteCompRows as List<dynamic>)) (r['id'] as String),
      };

      final localComps = await (db.select(db.completionEvents)
            ..where((tbl) => tbl.userId.equals(currentUserId)))
          .get();

      for (final comp in localComps) {
        if (!remoteCompIds.contains(comp.id)) {
          try {
            await client.from('completion_events').upsert({
              'id': comp.id,
              'user_id': currentUserId,
              'task_id': comp.taskId,
              'occurrence_id': comp.occurrenceId,
              'completed_at': comp.completedAt.toIso8601String(),
              'notes': comp.notes,
              'created_at': comp.createdAt.toIso8601String(),
              'is_deleted': comp.isDeleted,
            }).timeout(const Duration(seconds: 10));
            remoteCompIds.add(comp.id);
          } catch (e) {
            debugPrint('SyncEngine: Error upserting completion event ${comp.id}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('SyncEngine: Completion events reconciliation notice: $e');
    }

    try {
      final remoteTimerRows = await client
          .from('timer_sessions')
          .select('id')
          .eq('user_id', currentUserId)
          .timeout(const Duration(seconds: 10));
      final Set<String> remoteTimerIds = {
        for (final r in (remoteTimerRows as List<dynamic>)) (r['id'] as String),
      };

      final localTimers = await (db.select(db.timerSessions)
            ..where((tbl) => tbl.userId.equals(currentUserId)))
          .get();

      for (final timer in localTimers) {
        if (!remoteTimerIds.contains(timer.id)) {
          try {
            await client.from('timer_sessions').upsert({
              'id': timer.id,
              'user_id': currentUserId,
              'task_id': timer.taskId,
              'occurrence_id': timer.occurrenceId,
              'started_at': timer.startedAt.toIso8601String(),
              'paused_at': timer.pausedAt?.toIso8601String(),
              'ended_at': timer.endedAt?.toIso8601String(),
              'elapsed_seconds': timer.elapsedSeconds,
              'status': timer.status,
              'created_at': timer.createdAt.toIso8601String(),
              'updated_at': timer.updatedAt.toIso8601String(),
              'version': timer.version,
              'is_deleted': timer.isDeleted,
            }).timeout(const Duration(seconds: 10));
            remoteTimerIds.add(timer.id);
          } catch (e) {
            debugPrint('SyncEngine: Error upserting timer session ${timer.id}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('SyncEngine: Timer sessions reconciliation notice: $e');
    }

    try {
      final remoteNotifRows = await client
          .from('notification_settings')
          .select('id')
          .eq('user_id', currentUserId)
          .timeout(const Duration(seconds: 10));
      final Set<String> remoteNotifIds = {
        for (final r in (remoteNotifRows as List<dynamic>)) (r['id'] as String),
      };

      final localNotifs = await (db.select(db.notificationSettingsTable)
            ..where((tbl) => tbl.userId.equals(currentUserId)))
          .get();

      for (final n in localNotifs) {
        if (!remoteNotifIds.contains(n.id)) {
          try {
            await client.from('notification_settings').upsert({
              'id': n.id,
              'user_id': currentUserId,
              'hourly_reminders_enabled': n.hourlyRemindersEnabled,
              'active_hours_start': n.activeHoursStart,
              'active_hours_end': n.activeHoursEnd,
              'active_days': n.activeDays,
              'quiet_hours_enabled': n.quietHoursEnabled,
              'quiet_start': n.quietStart,
              'quiet_end': n.quietEnd,
              'daily_report_enabled': n.dailyReportEnabled,
              'daily_report_time': n.dailyReportTime,
              'motivation_enabled': n.motivationEnabled,
              'created_at': n.createdAt.toIso8601String(),
              'updated_at': n.updatedAt.toIso8601String(),
              'version': n.version,
              'is_deleted': n.isDeleted,
            }).timeout(const Duration(seconds: 10));
            remoteNotifIds.add(n.id);
          } catch (e) {
            debugPrint('SyncEngine: Error upserting notification settings ${n.id}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('SyncEngine: Notification settings reconciliation notice: $e');
    }
  }

  Future<void> _pullRemoteChanges({bool forceFullSync = false}) async {
    final userId = _supabase.currentUserId;
    final client = _supabase.client;
    if (userId == null || client == null) return;

    final lastSyncIso = _lastSyncTime != null && !forceFullSync
        ? _lastSyncTime!
            .subtract(const Duration(minutes: 2))
            .toIso8601String()
        : null;

    const remoteTables = [
      'labels',
      'recurrence_rules',
      'tasks',
      'task_occurrences',
      'completion_events',
      'timer_sessions',
      'kpi_definitions',
      'attachments',
      'notification_settings',
      'users',
    ];

    for (final remoteTable in remoteTables) {
      try {
        final query = client.from(remoteTable).select();

        final filtered = remoteTable == 'users'
            ? query.eq('id', userId)
            : query.eq('user_id', userId);

        final dynamic response;
        if (lastSyncIso == null) {
          response = await filtered.timeout(const Duration(seconds: 15));
        } else {
          response = remoteTable == 'completion_events'
              ? await filtered.gt('created_at', lastSyncIso).timeout(const Duration(seconds: 15))
              : await filtered.gt('updated_at', lastSyncIso).timeout(const Duration(seconds: 15));
        }

        final List<dynamic> rows = response is List<dynamic> ? response : [];

        for (final row in rows) {
          if (row is! Map<String, dynamic>) continue;
          final recordId = row['id']?.toString();
          if (recordId == null || recordId.isEmpty) continue;

          final localTable = _mapToLocalTableName(remoteTable);
          final existingLocal = await _getLocalRecord(localTable, recordId);

          if (existingLocal == null) {
            await _upsertLocalRecord(localTable, row);
          } else {
            final resolution = _conflictResolver.resolve(
              tableName: remoteTable,
              localData: existingLocal,
              remoteData: row,
            );

            if (resolution.isRemoteWinner || resolution.shouldPreserveBoth) {
              await _upsertLocalRecord(localTable, row);
            } else if (resolution.isLocalWinner) {
              await enqueueOperation(
                tableName: localTable,
                recordId: recordId,
                operation: SyncOperation.update,
                payload: existingLocal,
              );
            }
          }
        }
      } catch (e, st) {
        debugPrint('SyncEngine: Error pulling table "$remoteTable": $e\n$st');
      }
    }
  }

  Future<Map<String, dynamic>?> _getLocalRecord(
    String tableName,
    String id,
  ) async {
    try {
      final actualTable = _mapToLocalTableName(tableName);
      final rows = await db.customSelect(
        'SELECT * FROM $actualTable WHERE id = ? LIMIT 1',
        variables: [Variable.withString(id)],
        readsFrom: {},
      ).getSingleOrNull();

      return rows?.data;
    } catch (_) {
      return null;
    }
  }

  Future<void> _upsertLocalRecord(
    String localTable,
    Map<String, dynamic> map,
  ) async {
    try {
      final normalized = _mapToLocalTableName(localTable);
      switch (normalized) {
        case 'labels':
          await db.into(db.labels).insert(
            LabelsCompanion(
              id: Value(map['id'].toString()),
              userId: Value((map['user_id'] ?? map['userId']).toString()),
              parentId: Value((map['parent_id'] ?? map['parentId'])?.toString()),
              name: Value((map['name'] ?? '').toString()),
              iconName: Value(
                (map['icon_name'] ?? map['iconName'] ?? 'label').toString(),
              ),
              color: Value(
                (map['color'] ?? '#6366F1').toString(),
              ),
              sortOrder: Value(_parseInt(map['sort_order'] ?? map['sortOrder'], 0)),
              isArchived: Value(
                _parseBool(map['is_archived'] ?? map['isArchived'], false),
              ),
              createdAt: Value(
                _parseDateTime(map['created_at'] ?? map['createdAt']),
              ),
              updatedAt: Value(
                _parseDateTime(map['updated_at'] ?? map['updatedAt']),
              ),
              version: Value(_parseInt(map['version'], 1)),
              isDeleted: Value(
                _parseBool(map['is_deleted'] ?? map['isDeleted'], false),
              ),
            ),
            mode: InsertMode.insertOrReplace,
          );
          break;

        case 'tasks':
          await db.into(db.tasks).insert(
            TasksCompanion(
              id: Value(map['id'].toString()),
              userId: Value((map['user_id'] ?? map['userId']).toString()),
              labelId: Value((map['label_id'] ?? map['labelId'])?.toString()),
              title: Value((map['title'] ?? '').toString()),
              description: Value(map['description']?.toString()),
              iconName: Value((map['icon_name'] ?? map['iconName'])?.toString()),
              imagePath: Value((map['image_path'] ?? map['imagePath'])?.toString()),
              url: Value(map['url']?.toString()),
              category: Value(map['category']?.toString()),
              status: Value(
                (map['status'] ?? 'pending').toString(),
              ),
              priority: Value(
                (map['priority'] ?? 'medium').toString(),
              ),
              hasTimeTracking: Value(
                _parseBool(
                  map['has_time_tracking'] ?? map['hasTimeTracking'],
                  false,
                ),
              ),
              estimatedMinutes: Value(
                _tryParseInt(
                  map['estimated_minutes'] ?? map['estimatedMinutes'],
                ),
              ),
              recurrenceRuleId: Value(
                (map['recurrence_rule_id'] ?? map['recurrenceRuleId'])?.toString(),
              ),
              scheduledDate: Value(
                _tryParseDateTime(
                  map['scheduled_date'] ?? map['scheduledDate'],
                ),
              ),
              dueDate: Value(
                _tryParseDateTime(map['due_date'] ?? map['dueDate']),
              ),
              isArchived: Value(
                _parseBool(map['is_archived'] ?? map['isArchived'], false),
              ),
              createdAt: Value(
                _parseDateTime(map['created_at'] ?? map['createdAt']),
              ),
              updatedAt: Value(
                _parseDateTime(map['updated_at'] ?? map['updatedAt']),
              ),
              version: Value(_parseInt(map['version'], 1)),
              isDeleted: Value(
                _parseBool(map['is_deleted'] ?? map['isDeleted'], false),
              ),
            ),
            mode: InsertMode.insertOrReplace,
          );
          break;

        case 'recurrence_rules':
          await db.into(db.recurrenceRules).insert(
            RecurrenceRulesCompanion(
              id: Value(map['id'].toString()),
              userId: Value((map['user_id'] ?? map['userId']).toString()),
              type: Value((map['type'] ?? 'daily').toString()),
              daysOfWeek: Value(
                (map['days_of_week'] ?? map['daysOfWeek'])?.toString(),
              ),
              intervalDays: Value(
                _tryParseInt(map['interval_days'] ?? map['intervalDays']),
              ),
              intervalMonths: Value(
                _tryParseInt(map['interval_months'] ?? map['intervalMonths']),
              ),
              startDate: Value(
                _parseDateTime(map['start_date'] ?? map['startDate']),
              ),
              endDate: Value(
                _tryParseDateTime(map['end_date'] ?? map['endDate']),
              ),
              maxOccurrences: Value(
                _tryParseInt(map['max_occurrences'] ?? map['maxOccurrences']),
              ),
              createdAt: Value(
                _parseDateTime(map['created_at'] ?? map['createdAt']),
              ),
              updatedAt: Value(
                _parseDateTime(map['updated_at'] ?? map['updatedAt']),
              ),
              version: Value(_parseInt(map['version'], 1)),
              isDeleted: Value(
                _parseBool(map['is_deleted'] ?? map['isDeleted'], false),
              ),
            ),
            mode: InsertMode.insertOrReplace,
          );
          break;

        case 'task_occurrences':
          await db.into(db.taskOccurrences).insert(
            TaskOccurrencesCompanion(
              id: Value(map['id'].toString()),
              userId: Value((map['user_id'] ?? map['userId']).toString()),
              taskId: Value((map['task_id'] ?? map['taskId']).toString()),
              occurrenceDate: Value(
                _parseDateTime(
                  map['occurrence_date'] ?? map['occurrenceDate'],
                ),
              ),
              status: Value((map['status'] ?? 'pending').toString()),
              completedAt: Value(
                _tryParseDateTime(map['completed_at'] ?? map['completedAt']),
              ),
              createdAt: Value(
                _parseDateTime(map['created_at'] ?? map['createdAt']),
              ),
              updatedAt: Value(
                _parseDateTime(map['updated_at'] ?? map['updatedAt']),
              ),
              version: Value(_parseInt(map['version'], 1)),
              isDeleted: Value(
                _parseBool(map['is_deleted'] ?? map['isDeleted'], false),
              ),
            ),
            mode: InsertMode.insertOrReplace,
          );
          break;

        case 'completion_events':
          await db.into(db.completionEvents).insert(
            CompletionEventsCompanion(
              id: Value(map['id'].toString()),
              userId: Value((map['user_id'] ?? map['userId']).toString()),
              taskId: Value((map['task_id'] ?? map['taskId']).toString()),
              occurrenceId: Value(
                (map['occurrence_id'] ?? map['occurrenceId'])?.toString(),
              ),
              completedAt: Value(
                _parseDateTime(map['completed_at'] ?? map['completedAt']),
              ),
              notes: Value(map['notes']?.toString()),
              createdAt: Value(
                _parseDateTime(map['created_at'] ?? map['createdAt']),
              ),
              isDeleted: Value(
                _parseBool(map['is_deleted'] ?? map['isDeleted'], false),
              ),
            ),
            mode: InsertMode.insertOrReplace,
          );
          break;

        case 'timer_sessions':
          await db.into(db.timerSessions).insert(
            TimerSessionsCompanion(
              id: Value(map['id'].toString()),
              userId: Value((map['user_id'] ?? map['userId']).toString()),
              taskId: Value((map['task_id'] ?? map['taskId']).toString()),
              occurrenceId: Value(
                (map['occurrence_id'] ?? map['occurrenceId'])?.toString(),
              ),
              startedAt: Value(
                _parseDateTime(map['started_at'] ?? map['startedAt']),
              ),
              pausedAt: Value(
                _tryParseDateTime(map['paused_at'] ?? map['pausedAt']),
              ),
              endedAt: Value(
                _tryParseDateTime(map['ended_at'] ?? map['endedAt']),
              ),
              elapsedSeconds: Value(
                _parseInt(
                  map['elapsed_seconds'] ?? map['elapsedSeconds'],
                  0,
                ),
              ),
              status: Value((map['status'] ?? 'running').toString()),
              createdAt: Value(
                _parseDateTime(map['created_at'] ?? map['createdAt']),
              ),
              updatedAt: Value(
                _parseDateTime(map['updated_at'] ?? map['updatedAt']),
              ),
              version: Value(_parseInt(map['version'], 1)),
              isDeleted: Value(
                _parseBool(map['is_deleted'] ?? map['isDeleted'], false),
              ),
            ),
            mode: InsertMode.insertOrReplace,
          );
          break;

        case 'kpi_definitions':
          await db.into(db.kpiDefinitions).insert(
            KpiDefinitionsCompanion(
              id: Value(map['id'].toString()),
              userId: Value((map['user_id'] ?? map['userId']).toString()),
              labelId: Value((map['label_id'] ?? map['labelId'])?.toString()),
              name: Value((map['name'] ?? '').toString()),
              description: Value(map['description']?.toString()),
              kpiType: Value((map['kpi_type'] ?? map['kpiType'] ?? 'count').toString()),
              targetValue: Value(
                _parseDouble(map['target_value'] ?? map['targetValue'], 1.0),
              ),
              currentValue: Value(
                _parseDouble(map['current_value'] ?? map['currentValue'], 0.0),
              ),
              longTermTarget: Value(
                _tryParseDouble(
                  map['long_term_target'] ?? map['longTermTarget'],
                ),
              ),
              unit: Value((map['unit'] ?? 'count').toString()),
              platform: Value((map['platform'] ?? 'general').toString()),
              metricCategory: Value(
                (map['metric_category'] ??
                        map['metricCategory'] ??
                        'output')
                    .toString(),
              ),
              period: Value((map['period'] ?? 'daily').toString()),
              startDate: Value(
                _parseDateTime(map['start_date'] ?? map['startDate']),
              ),
              endDate: Value(
                _tryParseDateTime(map['end_date'] ?? map['endDate']),
              ),
              createdAt: Value(
                _parseDateTime(map['created_at'] ?? map['createdAt']),
              ),
              updatedAt: Value(
                _parseDateTime(map['updated_at'] ?? map['updatedAt']),
              ),
              version: Value(_parseInt(map['version'], 1)),
              isDeleted: Value(
                _parseBool(map['is_deleted'] ?? map['isDeleted'], false),
              ),
            ),
            mode: InsertMode.insertOrReplace,
          );
          break;

        case 'attachments':
          await db.into(db.attachments).insert(
            AttachmentsCompanion(
              id: Value(map['id'].toString()),
              userId: Value((map['user_id'] ?? map['userId']).toString()),
              taskId: Value((map['task_id'] ?? map['taskId']).toString()),
              fileName: Value((map['file_name'] ?? map['fileName'] ?? '').toString()),
              filePath: Value((map['file_path'] ?? map['filePath'] ?? '').toString()),
              remoteUrl: Value((map['remote_url'] ?? map['remoteUrl'])?.toString()),
              mimeType: Value((map['mime_type'] ?? map['mimeType'] ?? '').toString()),
              fileSize: Value(_parseInt(map['file_size'] ?? map['fileSize'], 0)),
              syncStatus: Value(
                (map['sync_status'] ?? map['syncStatus'] ?? 'uploaded').toString(),
              ),
              createdAt: Value(
                _parseDateTime(map['created_at'] ?? map['createdAt']),
              ),
              updatedAt: Value(
                _parseDateTime(map['updated_at'] ?? map['updatedAt']),
              ),
              isDeleted: Value(
                _parseBool(map['is_deleted'] ?? map['isDeleted'], false),
              ),
            ),
            mode: InsertMode.insertOrReplace,
          );
          break;

        case 'notification_settings_table':
          await db.into(db.notificationSettingsTable).insert(
            NotificationSettingsTableCompanion(
              id: Value(map['id'].toString()),
              userId: Value((map['user_id'] ?? map['userId']).toString()),
              hourlyRemindersEnabled: Value(
                _parseBool(
                  map['hourly_reminders_enabled'] ??
                      map['hourlyRemindersEnabled'],
                  false,
                ),
              ),
              activeHoursStart: Value(
                (map['active_hours_start'] ??
                        map['activeHoursStart'] ??
                        '08:00')
                    .toString(),
              ),
              activeHoursEnd: Value(
                (map['active_hours_end'] ?? map['activeHoursEnd'] ?? '22:00')
                    .toString(),
              ),
              activeDays: Value(
                (map['active_days'] ?? map['activeDays'] ?? '1,2,3,4,5,6,7')
                    .toString(),
              ),
              quietHoursEnabled: Value(
                _parseBool(
                  map['quiet_hours_enabled'] ?? map['quietHoursEnabled'],
                  false,
                ),
              ),
              quietStart: Value(
                (map['quiet_start'] ?? map['quietStart'] ?? '22:00').toString(),
              ),
              quietEnd: Value(
                (map['quiet_end'] ?? map['quietEnd'] ?? '07:00').toString(),
              ),
              dailyReportEnabled: Value(
                _parseBool(
                  map['daily_report_enabled'] ?? map['dailyReportEnabled'],
                  false,
                ),
              ),
              dailyReportTime: Value(
                (map['daily_report_time'] ?? map['dailyReportTime'] ?? '21:00')
                    .toString(),
              ),
              motivationEnabled: Value(
                _parseBool(
                  map['motivation_enabled'] ?? map['motivationEnabled'],
                  true,
                ),
              ),
              createdAt: Value(
                _parseDateTime(map['created_at'] ?? map['createdAt']),
              ),
              updatedAt: Value(
                _parseDateTime(map['updated_at'] ?? map['updatedAt']),
              ),
              version: Value(_parseInt(map['version'], 1)),
              isDeleted: Value(
                _parseBool(map['is_deleted'] ?? map['isDeleted'], false),
              ),
            ),
            mode: InsertMode.insertOrReplace,
          );
          break;

        case 'user_profiles':
          await db.into(db.userProfiles).insert(
            UserProfilesCompanion(
              id: Value(map['id'].toString()),
              email: Value(map['email']?.toString()),
              displayName: Value(
                (map['display_name'] ?? map['displayName'])?.toString(),
              ),
              avatarUrl: Value(
                (map['avatar_url'] ?? map['avatarUrl'])?.toString(),
              ),
              timezone: Value(
                (map['timezone'] ?? 'UTC').toString(),
              ),
              settingsJson: Value(
                (map['settings_json'] ?? map['settingsJson']) != null
                    ? jsonEncode(map['settings_json'] ?? map['settingsJson'])
                    : null,
              ),
              createdAt: Value(
                _parseDateTime(map['created_at'] ?? map['createdAt']),
              ),
              updatedAt: Value(
                _parseDateTime(map['updated_at'] ?? map['updatedAt']),
              ),
              version: Value(_parseInt(map['version'], 1)),
              isDeleted: Value(
                _parseBool(map['is_deleted'] ?? map['isDeleted'], false),
              ),
            ),
            mode: InsertMode.insertOrReplace,
          );
          break;
      }
    } catch (e, st) {
      debugPrint('SyncEngine: Error upserting to SQLite "$localTable": $e\n$st');
    }
  }

  void _updateStatus(SyncEngineStatus newStatus, {String? error}) {
    _status = newStatus;
    if (error != null) {
      _lastError = error;
      if (!_errorController.isClosed) {
        _errorController.add(_lastError);
      }
    } else if (newStatus == SyncEngineStatus.idle) {
      _lastError = null;
      if (!_errorController.isClosed) {
        _errorController.add(null);
      }
    }
    _emitStatus(newStatus);
  }

  void _emitStatus(SyncEngineStatus status) {
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }

  String _mapToRemoteTableName(String local) {
    if (local == 'notification_settings_table' || local == 'notification_settings') {
      return 'notification_settings';
    }
    if (local == 'user_profiles' || local == 'users') return 'users';
    return local;
  }

  String _mapToLocalTableName(String remote) {
    if (remote == 'notification_settings' || remote == 'notification_settings_table') {
      return 'notification_settings_table';
    }
    if (remote == 'users' || remote == 'user_profiles') return 'user_profiles';
    return remote;
  }

  Future<void> _saveLastSyncTime(DateTime time) async {
    try {
      prefs ??= await SharedPreferences.getInstance();
      await prefs?.setString(_prefLastSyncKey, time.toIso8601String());
    } catch (_) {}
  }

  Map<String, dynamic> _toRemoteSnakeCase(Map<String, dynamic> input) {
    final Map<String, dynamic> output = {};
    for (final entry in input.entries) {
      final key = _camelToSnake(entry.key);
      var val = entry.value;

      if (val is int) {
        if (key.endsWith('_at') || key.endsWith('_date')) {
          final isSeconds = val < 10000000000;
          val = DateTime.fromMillisecondsSinceEpoch(
            isSeconds ? val * 1000 : val,
            isUtc: true,
          ).toIso8601String();
        } else if (_isBooleanColumn(key)) {
          val = val != 0;
        }
      } else if (val is String && _isBooleanColumn(key)) {
        final s = val.trim().toLowerCase();
        if (s == 'true' || s == '1') {
          val = true;
        } else if (s == 'false' || s == '0') {
          val = false;
        }
      }

      output[key] = val;
    }
    return output;
  }

  bool _isBooleanColumn(String key) {
    return key == 'is_deleted' ||
        key == 'is_archived' ||
        key == 'has_time_tracking' ||
        key == 'hourly_reminders_enabled' ||
        key == 'quiet_hours_enabled' ||
        key == 'daily_report_enabled' ||
        key == 'motivation_enabled';
  }

  String _camelToSnake(String input) {
    return input.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }

  bool _parseBool(dynamic val, [bool fallback = false]) {
    if (val is bool) return val;
    if (val is num) return val != 0;
    if (val is String) {
      final s = val.trim().toLowerCase();
      if (s == 'true' || s == '1') return true;
      if (s == 'false' || s == '0') return false;
    }
    return fallback;
  }

  int _parseInt(dynamic val, [int fallback = 0]) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val.trim()) ?? fallback;
    return fallback;
  }

  int? _tryParseInt(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val.trim());
    return null;
  }

  double _parseDouble(dynamic val, [double fallback = 0.0]) {
    if (val is double) return val;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val.trim()) ?? fallback;
    return fallback;
  }

  double? _tryParseDouble(dynamic val) {
    if (val == null) return null;
    if (val is double) return val;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val.trim());
    return null;
  }

  DateTime _parseDateTime(dynamic val) {
    if (val is DateTime) return val;
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    if (val is String && val.trim().isNotEmpty) {
      final dt = DateTime.tryParse(val.trim());
      if (dt != null) return dt;
    }
    return DateTime.now();
  }

  DateTime? _tryParseDateTime(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    if (val is String && val.trim().isNotEmpty) {
      return DateTime.tryParse(val.trim());
    }
    return null;
  }

  Map<String, dynamic> _mapTaskToRemoteMap(Task t, String authUserId) {
    return {
      'id': t.id,
      'user_id': authUserId,
      'label_id': t.labelId,
      'title': t.title,
      'description': t.description,
      'icon_name': t.iconName,
      'image_path': t.imagePath,
      'url': t.url,
      'category': t.category,
      'status': t.status,
      'priority': t.priority,
      'has_time_tracking': t.hasTimeTracking,
      'estimated_minutes': t.estimatedMinutes,
      'recurrence_rule_id': t.recurrenceRuleId,
      'scheduled_date': t.scheduledDate?.toIso8601String(),
      'due_date': t.dueDate?.toIso8601String(),
      'is_archived': t.isArchived,
      'created_at': t.createdAt.toIso8601String(),
      'updated_at': t.updatedAt.toIso8601String(),
      'version': t.version,
      'is_deleted': t.isDeleted,
    };
  }

  Map<String, dynamic> _mapLabelToRemoteMap(Label l, String authUserId) {
    return {
      'id': l.id,
      'user_id': authUserId,
      'parent_id': l.parentId,
      'name': l.name,
      'icon_name': l.iconName,
      'color': l.color,
      'sort_order': l.sortOrder,
      'is_archived': l.isArchived,
      'created_at': l.createdAt.toIso8601String(),
      'updated_at': l.updatedAt.toIso8601String(),
      'version': l.version,
      'is_deleted': l.isDeleted,
    };
  }

  Map<String, dynamic> _mapKpiToRemoteMap(KpiDefinition k, String authUserId) {
    return {
      'id': k.id,
      'user_id': authUserId,
      'label_id': k.labelId,
      'name': k.name,
      'description': k.description,
      'kpi_type': k.kpiType,
      'target_value': k.targetValue,
      'current_value': k.currentValue,
      'long_term_target': k.longTermTarget,
      'unit': k.unit,
      'platform': k.platform,
      'metric_category': k.metricCategory,
      'period': k.period,
      'start_date': k.startDate.toIso8601String(),
      'end_date': k.endDate?.toIso8601String(),
      'created_at': k.createdAt.toIso8601String(),
      'updated_at': k.updatedAt.toIso8601String(),
      'version': k.version,
      'is_deleted': k.isDeleted,
    };
  }
}
