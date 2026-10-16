import 'package:drift/drift.dart';

import '../../core/constants/default_kpis.dart';
import '../../domain/enums/enums.dart';
import '../../domain/models/models.dart' as domain;
import '../local/daos/kpi_dao.dart';
import '../local/database.dart' as db;
import '../sync/sync_engine.dart';

/// Contract for Key Performance Indicator (KPI) metrics tracking.
abstract class KpiRepository {
  /// Retrieves KPI definitions configured for [labelId].
  Future<List<domain.KpiDefinition>> getKpisForLabel(String labelId);

  /// Retrieves all KPI definitions for [userId].
  Future<List<domain.KpiDefinition>> getAllKpis(String userId);

  /// Creates a new [kpi] metric definition.
  Future<void> createKpi(domain.KpiDefinition kpi);

  /// Updates an existing [kpi] metric definition.
  Future<void> updateKpi(domain.KpiDefinition kpi);

  /// Updates the current recorded value of a KPI definition.
  Future<void> updateCurrentValue(String id, double newValue);

  /// Increments or decrements the current recorded value of a KPI definition by [delta].
  Future<void> incrementCurrentValue(String id, double delta);

  /// Soft deletes a KPI definition by [id].
  Future<void> deleteKpi(String id);

  /// Seeds default platform and output creator KPIs for [userId] (YouTube, Instagram, Blog).
  Future<void> seedDefaultPlatformKpis(
    String userId,
    List<domain.Label> labels,
  );

  /// Watches KPI definitions configured for [labelId].
  Stream<List<domain.KpiDefinition>> watchKpisForLabel(String labelId);

  /// Watches all KPI definitions for [userId].
  Stream<List<domain.KpiDefinition>> watchAllKpis(String userId);
}

/// Drift-backed implementation of [KpiRepository].
class KpiRepositoryImpl implements KpiRepository {
  final db.AppDatabase database;
  final KpiDao kpiDao;
  final SyncEngine? syncEngine;

  KpiRepositoryImpl({
    required this.database,
    required this.kpiDao,
    this.syncEngine,
  });

  @override
  Future<List<domain.KpiDefinition>> getKpisForLabel(String labelId) async {
    final rows = await kpiDao.getKpisForLabel(labelId);
    return rows.map(_mapKpiFromDb).toList();
  }

  @override
  Future<List<domain.KpiDefinition>> getAllKpis(String userId) async {
    final rows = await kpiDao.getAllKpis(userId);
    return rows.map(_mapKpiFromDb).toList();
  }

  @override
  Future<void> createKpi(domain.KpiDefinition kpi) async {
    await kpiDao.insertKpi(_mapKpiToCompanion(kpi));

    await syncEngine?.enqueueOperation(
      tableName: 'kpi_definitions',
      recordId: kpi.id,
      operation: SyncOperation.insert,
      payload: kpi.toMap(),
    );
  }

  @override
  Future<void> updateKpi(domain.KpiDefinition kpi) async {
    await kpiDao.updateKpi(_mapKpiToCompanion(kpi));

    await syncEngine?.enqueueOperation(
      tableName: 'kpi_definitions',
      recordId: kpi.id,
      operation: SyncOperation.update,
      payload: kpi.toMap(),
    );
  }

  @override
  Future<void> updateCurrentValue(String id, double newValue) async {
    await kpiDao.updateCurrentValue(id, newValue);

    await syncEngine?.enqueueOperation(
      tableName: 'kpi_definitions',
      recordId: id,
      operation: SyncOperation.update,
      payload: {
        'id': id,
        'current_value': newValue,
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Future<void> incrementCurrentValue(String id, double delta) async {
    await kpiDao.incrementCurrentValue(id, delta);

    final row = await (database.select(database.kpiDefinitions)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (row != null) {
      await syncEngine?.enqueueOperation(
        tableName: 'kpi_definitions',
        recordId: id,
        operation: SyncOperation.update,
        payload: {
          'id': id,
          'current_value': row.currentValue,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  @override
  Future<void> deleteKpi(String id) async {
    await kpiDao.softDeleteKpi(id);

    await syncEngine?.enqueueOperation(
      tableName: 'kpi_definitions',
      recordId: id,
      operation: SyncOperation.delete,
      payload: {
        'id': id,
        'is_deleted': true,
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Future<void> seedDefaultPlatformKpis(
    String userId,
    List<domain.Label> labels,
  ) async {
    final existing = await kpiDao.getAllKpis(userId);
    final existingIds = existing.map((k) => k.id).toSet();
    final defaults = DefaultKpis.getDefaults(userId, labels: labels);
    for (final kpi in defaults) {
      if (!existingIds.contains(kpi.id)) {
        await kpiDao.insertKpi(_mapKpiToCompanion(kpi));
      }
    }
  }

  @override
  Stream<List<domain.KpiDefinition>> watchKpisForLabel(String labelId) {
    return kpiDao
        .watchKpisForLabel(labelId)
        .map((rows) => rows.map(_mapKpiFromDb).toList());
  }

  @override
  Stream<List<domain.KpiDefinition>> watchAllKpis(String userId) {
    return kpiDao
        .watchAllKpis(userId)
        .map((rows) => rows.map(_mapKpiFromDb).toList());
  }

  domain.KpiDefinition _mapKpiFromDb(db.KpiDefinition row) {
    return domain.KpiDefinition(
      id: row.id,
      userId: row.userId,
      labelId: row.labelId,
      name: row.name,
      description: row.description,
      kpiType: KpiType.fromString(row.kpiType),
      targetValue: row.targetValue,
      currentValue: row.currentValue,
      longTermTarget: row.longTermTarget,
      unit: row.unit,
      platform: row.platform,
      metricCategory: row.metricCategory,
      period: KpiPeriod.fromString(row.period),
      startDate: row.startDate,
      endDate: row.endDate,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      version: row.version,
      isDeleted: row.isDeleted,
    );
  }

  db.KpiDefinitionsCompanion _mapKpiToCompanion(domain.KpiDefinition kpi) {
    return db.KpiDefinitionsCompanion(
      id: Value(kpi.id),
      userId: Value(kpi.userId),
      labelId: Value(kpi.labelId),
      name: Value(kpi.name),
      description: Value(kpi.description),
      kpiType: Value(kpi.kpiType.name),
      targetValue: Value(kpi.targetValue),
      currentValue: Value(kpi.currentValue),
      longTermTarget: Value(kpi.longTermTarget),
      unit: Value(kpi.unit),
      platform: Value(kpi.platform),
      metricCategory: Value(kpi.metricCategory),
      period: Value(kpi.period.name),
      startDate: Value(kpi.startDate),
      endDate: Value(kpi.endDate),
      createdAt: Value(kpi.createdAt),
      updatedAt: Value(kpi.updatedAt),
      version: Value(kpi.version),
      isDeleted: Value(kpi.isDeleted),
    );
  }
}
