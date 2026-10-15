import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/tables.dart';

part 'labels_dao.g.dart';

@DriftAccessor(tables: [Labels])
class LabelsDao extends DatabaseAccessor<AppDatabase> with _$LabelsDaoMixin {
  LabelsDao(super.db);

  /// Retrieves all non-deleted labels for a user ordered by sort order.
  Future<List<Label>> getAllLabels(String userId) {
    return (select(labels)
          ..where(
            (tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .get();
  }

  /// Retrieves active root-level labels (no parent) for a user.
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

  /// Retrieves active child labels belonging to a parent label.
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

  /// Retrieves a single label by its primary key.
  Future<Label?> getLabelById(String id) {
    return (select(labels)
          ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Inserts a new label record.
  Future<void> insertLabel(LabelsCompanion label) async {
    await into(labels).insert(label);
  }

  /// Updates an existing label record.
  Future<void> updateLabel(LabelsCompanion label) async {
    await update(labels).replace(label);
  }

  /// Soft deletes a label by setting isDeleted = true.
  Future<void> softDeleteLabel(String id) async {
    await (update(labels)..where((tbl) => tbl.id.equals(id))).write(
      LabelsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Archives or unarchives a label.
  Future<void> archiveLabel(String id, bool archived) async {
    await (update(labels)..where((tbl) => tbl.id.equals(id))).write(
      LabelsCompanion(
        isArchived: Value(archived),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Watches active root-level labels for a user.
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

  /// Watches all non-deleted labels for a user.
  Stream<List<Label>> watchAllLabels(String userId) {
    return (select(labels)
          ..where(
            (tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .watch();
  }

  /// Watches active child labels for a parent label.
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

  /// Watches a single label by its id.
  Stream<Label?> watchLabel(String id) {
    return (select(labels)
          ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
        .watchSingleOrNull();
  }
}
