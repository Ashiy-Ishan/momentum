import 'package:drift/drift.dart';

import '../../core/constants/default_labels.dart';
import '../../domain/enums/enums.dart';
import '../../domain/models/models.dart' as domain;
import '../local/daos/labels_dao.dart';
import '../local/database.dart' as db;
import '../sync/sync_engine.dart';

/// Contract for category/label data operations and hierarchy management.
abstract class LabelRepository {
  /// Retrieves all non-deleted labels for [userId].
  Future<List<domain.Label>> getAllLabels(String userId);

  /// Retrieves active root-level labels (no parent) for [userId].
  Future<List<domain.Label>> getRootLabels(String userId);

  /// Retrieves active child sub-labels for [parentId].
  Future<List<domain.Label>> getChildLabels(String parentId);

  /// Creates a new [label].
  Future<void> createLabel(domain.Label label);

  /// Updates an existing [label].
  Future<void> updateLabel(domain.Label label);

  /// Archives or unarchives a label by [id].
  Future<void> archiveLabel(String id, bool archive);

  /// Soft deletes a label by [id].
  Future<void> deleteLabel(String id);

  /// Seeds the default productivity labels if the user has no existing labels.
  Future<void> seedDefaultLabels(String userId);

  /// Watches active root-level labels for [userId].
  Stream<List<domain.Label>> watchRootLabels(String userId);

  /// Watches active child sub-labels under [parentId].
  Stream<List<domain.Label>> watchChildLabels(String parentId);

  /// Watches all non-deleted labels for [userId].
  Stream<List<domain.Label>> watchAllLabels(String userId);
}

/// Drift-backed implementation of [LabelRepository].
class LabelRepositoryImpl implements LabelRepository {
  final db.AppDatabase database;
  final LabelsDao labelsDao;
  final SyncEngine? syncEngine;

  LabelRepositoryImpl({
    required this.database,
    required this.labelsDao,
    this.syncEngine,
  });

  @override
  Future<List<domain.Label>> getAllLabels(String userId) async {
    final rows = await labelsDao.getAllLabels(userId);
    return rows.map(_mapLabelFromDb).toList();
  }

  @override
  Future<List<domain.Label>> getRootLabels(String userId) async {
    final rows = await labelsDao.getRootLabels(userId);
    return rows.map(_mapLabelFromDb).toList();
  }

  @override
  Future<List<domain.Label>> getChildLabels(String parentId) async {
    final rows = await labelsDao.getChildLabels(parentId);
    return rows.map(_mapLabelFromDb).toList();
  }

  @override
  Future<void> createLabel(domain.Label label) async {
    await labelsDao.insertLabel(_mapLabelToCompanion(label));

    await syncEngine?.enqueueOperation(
      tableName: 'labels',
      recordId: label.id,
      operation: SyncOperation.insert,
      payload: label.toMap(),
    );
  }

  @override
  Future<void> updateLabel(domain.Label label) async {
    await labelsDao.updateLabel(_mapLabelToCompanion(label));

    await syncEngine?.enqueueOperation(
      tableName: 'labels',
      recordId: label.id,
      operation: SyncOperation.update,
      payload: label.toMap(),
    );
  }

  @override
  Future<void> archiveLabel(String id, bool archive) async {
    await labelsDao.archiveLabel(id, archive);

    await syncEngine?.enqueueOperation(
      tableName: 'labels',
      recordId: id,
      operation: SyncOperation.update,
      payload: {
        'id': id,
        'is_archived': archive,
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Future<void> deleteLabel(String id) async {
    await labelsDao.softDeleteLabel(id);

    await syncEngine?.enqueueOperation(
      tableName: 'labels',
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
  Future<void> seedDefaultLabels(String userId) async {
    final existing = await labelsDao.getAllLabels(userId);
    if (existing.isNotEmpty) return;

    final defaults = DefaultLabels.getDefaults(userId);
    for (final label in defaults) {
      await labelsDao.insertLabel(_mapLabelToCompanion(label));
    }
  }

  @override
  Stream<List<domain.Label>> watchRootLabels(String userId) {
    return labelsDao
        .watchRootLabels(userId)
        .map((rows) => rows.map(_mapLabelFromDb).toList());
  }

  @override
  Stream<List<domain.Label>> watchChildLabels(String parentId) {
    return labelsDao
        .watchChildLabels(parentId)
        .map((rows) => rows.map(_mapLabelFromDb).toList());
  }

  @override
  Stream<List<domain.Label>> watchAllLabels(String userId) {
    return labelsDao
        .watchAllLabels(userId)
        .map((rows) => rows.map(_mapLabelFromDb).toList());
  }

  domain.Label _mapLabelFromDb(db.Label row) {
    return domain.Label(
      id: row.id,
      userId: row.userId,
      parentId: row.parentId,
      name: row.name,
      iconName: row.iconName,
      color: row.color,
      sortOrder: row.sortOrder,
      isArchived: row.isArchived,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      version: row.version,
      isDeleted: row.isDeleted,
    );
  }

  db.LabelsCompanion _mapLabelToCompanion(domain.Label label) {
    return db.LabelsCompanion(
      id: Value(label.id),
      userId: Value(label.userId),
      parentId: Value(label.parentId),
      name: Value(label.name),
      iconName: Value(label.iconName),
      color: Value(label.color),
      sortOrder: Value(label.sortOrder),
      isArchived: Value(label.isArchived),
      createdAt: Value(label.createdAt),
      updatedAt: Value(label.updatedAt),
      version: Value(label.version),
      isDeleted: Value(label.isDeleted),
    );
  }
}
