import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/repositories.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/models.dart';
import '../../../shared/providers/database_provider.dart';

final activeTimerStreamProvider = StreamProvider<TimerSession?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final repo = ref.watch(timerRepositoryProvider);
  return repo.watchActiveSession(userId);
});

final timerCurrentDurationProvider =
    StreamProvider.autoDispose<Duration>((ref) async* {
  final activeSession = ref.watch(activeTimerStreamProvider).valueOrNull;

  if (activeSession == null) {
    yield Duration.zero;
    return;
  }

  yield activeSession.currentElapsed;

  if (activeSession.status == TimerSessionStatus.running) {
    while (true) {
      await Future<void>.delayed(const Duration(seconds: 1));
      yield activeSession.currentElapsed;
    }
  }
});

class TimerController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  TimerController(this._ref) : super(const AsyncValue.data(null));

  String get _userId => _ref.read(currentUserIdProvider);
  TimerRepository get _repo => _ref.read(timerRepositoryProvider);

  Future<TimerSession?> start(String taskId, {String? occurrenceId}) async {
    state = const AsyncValue.loading();
    TimerSession? created;
    state = await AsyncValue.guard(() async {
      created = await _repo.startSession(
        _userId,
        taskId,
        occurrenceId: occurrenceId,
      );
    });
    return created;
  }

  Future<void> pause() async {
    final active = await _repo.getActiveSession(_userId);
    if (active == null || active.status != TimerSessionStatus.running) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.pauseSession(active.id);
    });
  }

  Future<void> resume() async {
    final active = await _repo.getActiveSession(_userId);
    if (active == null || active.status != TimerSessionStatus.paused) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.resumeSession(active.id);
    });
  }

  Future<void> stopAndSave() async {
    final active = await _repo.getActiveSession(_userId);
    if (active == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.stopSession(active.id);
    });
  }
}

final timerControllerProvider =
    StateNotifierProvider<TimerController, AsyncValue<void>>((ref) {
  return TimerController(ref);
});
