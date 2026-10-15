import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/tables.dart';

part 'kpi_dao.g.dart';

@DriftAccessor(tables: [KpiDefinitions])
class KpiDao extends DatabaseAccessor<AppDatabase> with _$KpiDaoMixin {
  KpiDao(super.db);

  /// Retrieves KPI definitions configured for a label.
  Future<List<KpiDefinition>> getKpisForLabel(String labelId) {
    return (select(kpiDefinitions)
          ..where(
            (tbl) => tbl.labelId.equals(labelId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .get();
  }

  /// Retrieves all KPI definitions for a user.
  Future<List<KpiDefinition>> getAllKpis(String userId) {
    return (select(kpiDefinitions)
          ..where(
            (tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .get();
  }

  /// Inserts a new KPI definition.
  Future<void> insertKpi(KpiDefinitionsCompanion kpi) async {
    await into(kpiDefinitions).insert(kpi);
  }

  /// Updates an existing KPI definition.
  Future<void> updateKpi(KpiDefinitionsCompanion kpi) async {
    await update(kpiDefinitions).replace(kpi);
  }

  /// Soft deletes a KPI definition by setting isDeleted = true.
  Future<void> softDeleteKpi(String id) async {
    await (update(kpiDefinitions)..where((tbl) => tbl.id.equals(id))).write(
      KpiDefinitionsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Watches KPI definitions for a given label.
  Stream<List<KpiDefinition>> watchKpisForLabel(String labelId) {
    return (select(kpiDefinitions)
          ..where(
            (tbl) => tbl.labelId.equals(labelId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .watch();
  }

  /// Watches all KPI definitions for a user.
  Stream<List<KpiDefinition>> watchAllKpis(String userId) {
    return (select(kpiDefinitions)
          ..where(
            (tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .watch();
  }
}
