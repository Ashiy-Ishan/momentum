import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/repositories.dart';
import '../../../domain/models/models.dart';
import '../../../shared/providers/database_provider.dart';

final rootLabelsStreamProvider = StreamProvider<List<Label>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final repo = ref.watch(labelRepositoryProvider);
  return repo.watchRootLabels(userId);
});

final allLabelsStreamProvider = StreamProvider<List<Label>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final repo = ref.watch(labelRepositoryProvider);
  return repo.watchAllLabels(userId);
});

final childLabelsProvider =
    StreamProvider.family<List<Label>, String>((ref, parentId) {
  final repo = ref.watch(labelRepositoryProvider);
  return repo.watchChildLabels(parentId);
});

final selectedLabelIdProvider = StateProvider<String?>((ref) => null);

class LabelController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  LabelController(this._ref) : super(const AsyncValue.data(null));

  String get _userId => _ref.read(currentUserIdProvider);
  LabelRepository get _repo => _ref.read(labelRepositoryProvider);

  Future<void> createLabel(Label label) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.createLabel(label);
    });
  }

  Future<void> updateLabel(Label label) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.updateLabel(label);
    });
  }

  Future<void> archiveLabel(String id, bool archive) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.archiveLabel(id, archive);
    });
  }

  Future<void> deleteLabel(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.deleteLabel(id);
    });
  }

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

  Future<void> seedDefaultLabels() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.seedDefaultLabels(_userId);
    });
  }
}

final labelControllerProvider =
    StateNotifierProvider<LabelController, AsyncValue<void>>((ref) {
  return LabelController(ref);
});
