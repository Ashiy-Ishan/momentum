import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/tables.dart';

part 'labels_dao.g.dart';

@DriftAccessor(tables: [Labels])
class LabelsDao extends DatabaseAccessor<AppDatabase> with _$LabelsDaoMixin {
  LabelsDao(super.db);

  Future<List<Label>> getAllLabels(String userId) {
    return (select(labels)
          ..where(
            (tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .get();
  }

  Future<List<Label>> getRootLabels(String userId) {
    return (select(labels)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.parentId.isNull() &
                tbl.isDeleted.equals(false) &
                tbl.isArchived.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .get();
  }

  Future<List<Label>> getChildLabels(String parentId) {
    return (select(labels)
          ..where(
            (tbl) =>
                tbl.parentId.equals(parentId) &
                tbl.isDeleted.equals(false) &
                tbl.isArchived.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .get();
  }

  Future<Label?> getLabelById(String id) {
    return (select(labels)
          ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<void> insertLabel(LabelsCompanion label) async {
    await into(labels).insert(label);
  }

  Future<void> updateLabel(LabelsCompanion label) async {
    await update(labels).replace(label);
  }

  Future<void> softDeleteLabel(String id) async {
    final existing = await (select(labels)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    await (update(labels)..where((tbl) => tbl.id.equals(id))).write(
      LabelsCompanion(
        isDeleted: const Value(true),
        version: Value((existing?.version ?? 0) + 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> archiveLabel(String id, bool archived) async {
    final existing = await (select(labels)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    await (update(labels)..where((tbl) => tbl.id.equals(id))).write(
      LabelsCompanion(
        isArchived: Value(archived),
        version: Value((existing?.version ?? 0) + 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Stream<List<Label>> watchRootLabels(String userId) {
    return (select(labels)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.parentId.isNull() &
                tbl.isDeleted.equals(false) &
                tbl.isArchived.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .watch();
  }

  Stream<List<Label>> watchAllLabels(String userId) {
    return (select(labels)
          ..where(
            (tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .watch();
  }

  Stream<List<Label>> watchChildLabels(String parentId) {
    return (select(labels)
          ..where(
            (tbl) =>
                tbl.parentId.equals(parentId) &
                tbl.isDeleted.equals(false) &
                tbl.isArchived.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .watch();
  }

  Stream<Label?> watchLabel(String id) {
    return (select(labels)
          ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
        .watchSingleOrNull();
  }
}
