import 'package:drift/drift.dart';

import '../../domain/enums/enums.dart';
import '../../domain/models/models.dart' as domain;
import '../local/daos/kpi_dao.dart';
import '../local/database.dart' as db;

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

  /// Soft deletes a KPI definition by [id].
  Future<void> deleteKpi(String id);

  /// Watches KPI definitions configured for [labelId].
  Stream<List<domain.KpiDefinition>> watchKpisForLabel(String labelId);

  /// Watches all KPI definitions for [userId].
  Stream<List<domain.KpiDefinition>> watchAllKpis(String userId);
}

/// Drift-backed implementation of [KpiRepository].
class KpiRepositoryImpl implements KpiRepository {
  final db.AppDatabase database;
  final KpiDao kpiDao;

  KpiRepositoryImpl({
    required this.database,
    required this.kpiDao,
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
  }

  @override
  Future<void> updateKpi(domain.KpiDefinition kpi) async {
    await kpiDao.updateKpi(_mapKpiToCompanion(kpi));
  }

  @override
  Future<void> deleteKpi(String id) async {
    await kpiDao.softDeleteKpi(id);
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
