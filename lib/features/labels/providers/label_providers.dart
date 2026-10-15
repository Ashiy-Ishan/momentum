import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/repositories.dart';
import '../../../domain/models/models.dart';
import '../../../shared/providers/database_provider.dart';

// =============================================================================
// Label Streams
// =============================================================================

/// Watches root-level categories/labels for the current user.
final rootLabelsStreamProvider = StreamProvider<List<Label>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final repo = ref.watch(labelRepositoryProvider);
  return repo.watchRootLabels(userId);
});

/// Watches all non-deleted categories/labels for the current user.
final allLabelsStreamProvider = StreamProvider<List<Label>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final repo = ref.watch(labelRepositoryProvider);
  return repo.watchAllLabels(userId);
});

/// Watches sub-labels belonging to a specific [parentId].
final childLabelsProvider =
    StreamProvider.family<List<Label>, String>((ref, parentId) {
  final repo = ref.watch(labelRepositoryProvider);
  return repo.watchChildLabels(parentId);
});

/// Selected label identifier for filtering or inspection.
final selectedLabelIdProvider = StateProvider<String?>((ref) => null);

// =============================================================================
// Label Controller
// =============================================================================

/// Controller managing label mutations, reordering, and archiving.
class LabelController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  LabelController(this._ref) : super(const AsyncValue.data(null));

  String get _userId => _ref.read(currentUserIdProvider);
  LabelRepository get _repo => _ref.read(labelRepositoryProvider);

  /// Creates a new label.
  Future<void> createLabel(Label label) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.createLabel(label);
    });
  }

  /// Updates an existing label.
  Future<void> updateLabel(Label label) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.updateLabel(label);
    });
  }

  /// Archives or unarchives a label by ID.
  Future<void> archiveLabel(String id, bool archive) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.archiveLabel(id, archive);
    });
  }

  /// Soft deletes a label by ID.
  Future<void> deleteLabel(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.deleteLabel(id);
    });
  }

  /// Updates sort order for an ordered list of labels.
  Future<void> reorderLabels(List<Label> labels) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      for (var i = 0; i < labels.length; i++) {
        final updated = labels[i].copyWith(
          sortOrder: i,
          updatedAt: DateTime.now(),
        );
        await _repo.updateLabel(updated);
      }
    });
  }

  /// Seeds default productivity labels if none exist.
  Future<void> seedDefaultLabels() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.seedDefaultLabels(_userId);
    });
  }
}

/// Label controller provider.
final labelControllerProvider =
    StateNotifierProvider<LabelController, AsyncValue<void>>((ref) {
  return LabelController(ref);
});
