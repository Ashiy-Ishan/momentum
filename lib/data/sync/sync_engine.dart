import 'dart:async';
import 'dart:convert';
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

/// Riverpod provider for the global database instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  return ref.watch(appDatabaseProvider);
});

/// Riverpod provider exposing the [SyncEngine].
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

/// Stream provider for listening to sync engine status updates.
final syncStatusStreamProvider = StreamProvider<SyncEngineStatus>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.syncStatusStream;
});

/// Current sync engine status.
final syncStatusProvider = Provider<SyncEngineStatus>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.currentStatus;
});

/// Stream provider for listening to sync engine error messages.
final syncErrorStreamProvider = StreamProvider<String?>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.syncErrorStream;
});

/// Current sync engine error message, if any.
final syncLastErrorProvider = Provider<String?>((ref) {
  final engine = ref.watch(syncEngineProvider);
  final errorAsync = ref.watch(syncErrorStreamProvider);
  return errorAsync.valueOrNull ?? engine.lastError;
});

/// Status of the local-first synchronization engine.
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

/// Local-first synchronization engine for Momentum.
///
/// Features:
/// - Enqueues local changes to SQLite `SyncQueueItems`
/// - Monitors network connectivity via `connectivity_plus`
/// - Pushes pending local changes to Supabase with exponential backoff & max retry
/// - Pulls remote updates since `lastSyncTimestamp` and resolves conflicts
/// - Safe error handling: never crashes UI, updates status streams
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

  /// Current status of the sync engine.
  SyncEngineStatus get currentStatus => _status;

  /// Stream of status changes for reactive UI updates.
  Stream<SyncEngineStatus> get syncStatusStream => _statusController.stream;

  /// Stream of sync errors for reactive UI error presentation.
  Stream<String?> get syncErrorStream => _errorController.stream;

  /// Last recorded synchronization error message, if any.
  String? get lastError => _lastError;

  /// Timestamp of the last successful synchronization.
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Indicates whether the device currently has active network connectivity.
  bool get isOnline => _isOnline;

  /// Initializes connectivity listeners, loads stored sync timestamps, and triggers initial sync.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      prefs ??= await SharedPreferences.getInstance();
      final storedSync = prefs?.getString(_prefLastSyncKey);
      if (storedSync != null && storedSync.isNotEmpty) {
        _lastSyncTime = DateTime.tryParse(storedSync);
      }

      // Check initial connectivity
      final initialResults = await _connectivity.checkConnectivity();
      _isOnline = _hasConnection(initialResults);
      _status = _isOnline ? SyncEngineStatus.idle : SyncEngineStatus.offline;
      _emitStatus(_status);

      // Listen to connectivity transitions
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (results) {
          final online = _hasConnection(results);
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

      // Listen to auth state transitions
      _authSubscription = _supabase.authStateChanges.listen((data) {
        if (_supabase.isAuthenticated && _isOnline) {
          unawaited(triggerSync());
          _setupRealtimeSubscription();
        } else {
          _cleanupRealtime();
        }
      });

      // Initial sync and realtime subscription if online and authenticated
      if (_isOnline && _supabase.isConfigured && _supabase.isAuthenticated) {
        unawaited(triggerSync());
        _setupRealtimeSubscription();
      }
    } catch (e, st) {
      debugPrint('SyncEngine initialization warning: $e\n$st');
    }
  }

  /// Sets up Supabase Realtime channel to listen for cross-device database changes
  /// and establishes a reliable periodic sync heartbeat.
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

    // Periodic heartbeat sync every 25 seconds for cross-device parity
    _periodicSyncTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (_isOnline &&
          _supabase.isConfigured &&
          _supabase.isAuthenticated &&
          !_isSyncInProgress) {
        unawaited(triggerSync());
      }
    });
  }

  void _debounceRemoteSync() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
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

  /// Disposes of background listeners and streams.
  void dispose() {
    _cleanupRealtime();
    _connectivitySubscription?.cancel();
    _authSubscription?.cancel();
    _statusController.close();
    _errorController.close();
  }

  /// Enqueues a local data operation into SQLite `SyncQueueItems`.
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

      // Attempt automatic sync if online and authenticated
      if (_isOnline && _supabase.isConfigured && _supabase.isAuthenticated) {
        unawaited(triggerSync());
      }
    } catch (e, st) {
      debugPrint('SyncEngine: Failed to enqueue operation: $e\n$st');
    }
  }

  /// Manually triggers a synchronization cycle (Push local changes -> Pull remote changes).
  Future<Result<bool>> triggerSync() async {
    if (_isSyncInProgress) {
      return Result.success(false);
    }

    if (!_isOnline) {
      _updateStatus(SyncEngineStatus.offline);
      return Result.success(false);
    }

    if (!_supabase.isConfigured || !_supabase.isAuthenticated) {
      _updateStatus(SyncEngineStatus.idle);
      return Result.success(false);
    }

    _isSyncInProgress = true;
    _updateStatus(SyncEngineStatus.syncing);

    try {
      // 1. Push local changes
      await _pushLocalChanges();

      // 2. Pull remote changes
      await _pullRemoteChanges();

      // 3. Clear completed queue items
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

  // ===========================================================================
  // PUSH LOCAL CHANGES
  // ===========================================================================
  Future<void> _pushLocalChanges() async {
    final pendingItems = await db.syncDao.getPendingItems();
    if (pendingItems.isEmpty) return;

    for (final item in pendingItems) {
      // Check maximum retries
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

      // If user is authenticated, ensure payload uses authenticated user's ID
      // rather than offline/local 'local-user' placeholder for Supabase RLS compatibility.
      final currentAuthUserId = _supabase.currentUserId;
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
          // Soft-delete on server
          await client.from(remoteTable).update({
            'is_deleted': true,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', item.recordId);
        } else {
          // Insert or update (upsert)
          await client.from(remoteTable).upsert(remotePayload);
        }

        await db.syncDao.markCompleted(item.id);
      } catch (e) {
        await db.syncDao.incrementRetry(item.id);

        if (item.retryCount + 1 >= AppConstants.maxRetryAttempts) {
          await db.syncDao.markFailed(item.id, e.toString());
        }

        // Exponential backoff
        final backoffMs = min(300 * pow(2, item.retryCount).toInt(), 5000);
        await Future<void>.delayed(Duration(milliseconds: backoffMs));
      }
    }
  }

  // ===========================================================================
  // PULL REMOTE CHANGES
  // ===========================================================================
  Future<void> _pullRemoteChanges() async {
    final userId = _supabase.currentUserId;
    final client = _supabase.client;
    if (userId == null || client == null) return;

    final lastSyncIso = _lastSyncTime?.toIso8601String() ??
        DateTime.fromMillisecondsSinceEpoch(0).toIso8601String();

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

        final response = remoteTable == 'completion_events'
            ? await filtered.gt('created_at', lastSyncIso)
            : await filtered.gt('updated_at', lastSyncIso);

        final List<dynamic> rows = response;

        for (final row in rows) {
          if (row is! Map<String, dynamic>) continue;
          final recordId = row['id']?.toString();
          if (recordId == null || recordId.isEmpty) continue;

          final localTable = _mapToLocalTableName(remoteTable);
          final existingLocal = await _getLocalRecord(localTable, recordId);

          if (existingLocal == null) {
            // New record from server: insert into local database
            await _upsertLocalRecord(localTable, row);
          } else {
            // Existing record: evaluate conflict resolution
            final resolution = _conflictResolver.resolve(
              tableName: remoteTable,
              localData: existingLocal,
              remoteData: row,
            );

            if (resolution.isRemoteWinner) {
              await _upsertLocalRecord(localTable, row);
            } else if (resolution.shouldPreserveBoth) {
              // Append-only table: both records preserved
              await _upsertLocalRecord(localTable, row);
            } else if (resolution.isLocalWinner) {
              // Local record is newer: enqueue it to update server
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

  // ===========================================================================
  // LOCAL SQLITE DIRECT ACCESS
  // ===========================================================================
  Future<Map<String, dynamic>?> _getLocalRecord(
    String tableName,
    String id,
  ) async {
    try {
      final rows = await db.customSelect(
        'SELECT * FROM $tableName WHERE id = ? LIMIT 1',
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
      switch (localTable) {
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

  // ===========================================================================
  // HELPERS
  // ===========================================================================
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
    if (local == 'notification_settings_table') return 'notification_settings';
    if (local == 'user_profiles') return 'users';
    return local;
  }

  String _mapToLocalTableName(String remote) {
    if (remote == 'notification_settings') return 'notification_settings_table';
    if (remote == 'users') return 'user_profiles';
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
      output[key] = entry.value;
    }
    return output;
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
}
