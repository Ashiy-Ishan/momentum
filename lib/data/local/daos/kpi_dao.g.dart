// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kpi_dao.dart';

// ignore_for_file: type=lint
mixin _$KpiDaoMixin on DatabaseAccessor<AppDatabase> {
  $KpiDefinitionsTable get kpiDefinitions => attachedDatabase.kpiDefinitions;
  KpiDaoManager get managers => KpiDaoManager(this);
}

class KpiDaoManager {
  final _$KpiDaoMixin _db;
  KpiDaoManager(this._db);
  $$KpiDefinitionsTableTableManager get kpiDefinitions =>
      $$KpiDefinitionsTableTableManager(
        _db.attachedDatabase,
        _db.kpiDefinitions,
      );
}
