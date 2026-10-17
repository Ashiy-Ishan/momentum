import 'package:drift/drift.dart';

import '../../core/constants/default_kpis.dart';
import '../../domain/enums/enums.dart';
import '../../domain/models/models.dart' as domain;
import '../local/daos/kpi_dao.dart';
import '../local/database.dart' as db;
import '../sync/sync_engine.dart';

abstract class KpiRepository {
  Future<List<domain.KpiDefinition>> getKpisForLabel(String labelId);

  Future<List<domain.KpiDefinition>> getAllKpis(String userId);

  Future<void> createKpi(domain.KpiDefinition kpi);

  Future<void> updateKpi(domain.KpiDefinition kpi);

  Future<void> updateCurrentValue(String id, double newValue);

  Future<void> incrementCurrentValue(String id, double delta);

  Future<void> deleteKpi(String id);

  Future<void> seedDefaultPlatformKpis(
    String userId,
    List<domain.Label> labels,
  );

  Stream<List<domain.KpiDefinition>> watchKpisForLabel(String labelId);

  Stream<List<domain.KpiDefinition>> watchAllKpis(String userId);
}

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
    final updated = kpi.copyWith(
      version: kpi.version + 1,
      updatedAt: DateTime.now(),
    );
    await kpiDao.updateKpi(_mapKpiToCompanion(updated));

    await syncEngine?.enqueueOperation(
      tableName: 'kpi_definitions',
      recordId: updated.id,
      operation: SyncOperation.update,
      payload: updated.toMap(),
    );
  }

  @override
  Future<void> updateCurrentValue(String id, double newValue) async {
    await kpiDao.updateCurrentValue(id, newValue);

    final row = await (database.select(database.kpiDefinitions)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();

    await syncEngine?.enqueueOperation(
      tableName: 'kpi_definitions',
      recordId: id,
      operation: SyncOperation.update,
      payload: {
        'id': id,
        'current_value': newValue,
        if (row != null) 'version': row.version,
        'updated_at': (row?.updatedAt ?? DateTime.now()).toIso8601String(),
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
          'version': row.version,
          'updated_at': row.updatedAt.toIso8601String(),
        },
      );
    }
  }

  @override
  Future<void> deleteKpi(String id) async {
    await kpiDao.softDeleteKpi(id);

    final row = await (database.select(database.kpiDefinitions)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();

    await syncEngine?.enqueueOperation(
      tableName: 'kpi_definitions',
      recordId: id,
      operation: SyncOperation.delete,
      payload: {
        'id': id,
        'is_deleted': true,
        if (row != null) 'version': row.version,
        'updated_at': (row?.updatedAt ?? DateTime.now()).toIso8601String(),
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
        await syncEngine?.enqueueOperation(
          tableName: 'kpi_definitions',
          recordId: kpi.id,
          operation: SyncOperation.insert,
          payload: kpi.toMap(),
        );
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
