import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/tables.dart';

part 'kpi_dao.g.dart';

@DriftAccessor(tables: [KpiDefinitions])
class KpiDao extends DatabaseAccessor<AppDatabase> with _$KpiDaoMixin {
  KpiDao(super.db);

  Future<List<KpiDefinition>> getKpisForLabel(String labelId) {
    return (select(kpiDefinitions)
          ..where(
            (tbl) => tbl.labelId.equals(labelId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .get();
  }

  Future<List<KpiDefinition>> getAllKpis(String userId) {
    return (select(kpiDefinitions)
          ..where(
            (tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .get();
  }

  Future<void> insertKpi(KpiDefinitionsCompanion kpi) async {
    await into(kpiDefinitions).insert(kpi);
  }

  Future<void> updateKpi(KpiDefinitionsCompanion kpi) async {
    await update(kpiDefinitions).replace(kpi);
  }

  Future<void> updateCurrentValue(String id, double newValue) async {
    final existing = await (select(kpiDefinitions)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    await (update(kpiDefinitions)..where((tbl) => tbl.id.equals(id))).write(
      KpiDefinitionsCompanion(
        currentValue: Value(newValue),
        version: Value((existing?.version ?? 0) + 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> incrementCurrentValue(String id, double delta) async {
    await transaction(() async {
      final existing = await (select(kpiDefinitions)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();
      if (existing != null) {
        await (update(kpiDefinitions)..where((tbl) => tbl.id.equals(id))).write(
          KpiDefinitionsCompanion(
            currentValue: Value(existing.currentValue + delta),
            version: Value(existing.version + 1),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    });
  }

  Future<void> softDeleteKpi(String id) async {
    final existing = await (select(kpiDefinitions)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    await (update(kpiDefinitions)..where((tbl) => tbl.id.equals(id))).write(
      KpiDefinitionsCompanion(
        isDeleted: const Value(true),
        version: Value((existing?.version ?? 0) + 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Stream<List<KpiDefinition>> watchKpisForLabel(String labelId) {
    return (select(kpiDefinitions)
          ..where(
            (tbl) => tbl.labelId.equals(labelId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .watch();
  }

  Stream<List<KpiDefinition>> watchAllKpis(String userId) {
    return (select(kpiDefinitions)
          ..where(
            (tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .watch();
  }
}
