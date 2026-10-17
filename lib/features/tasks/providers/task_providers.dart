import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/repositories.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/models.dart';
import '../../../shared/providers/database_provider.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class TaskFilter {
  final TaskStatus? status;
  final String? labelId;
  final TaskPriority? priority;
  final String searchQuery;

  const TaskFilter({
    this.status,
    this.labelId,
    this.priority,
    this.searchQuery = '',
  });

  bool get isEmpty =>
      status == null &&
      labelId == null &&
      priority == null &&
      searchQuery.trim().isEmpty;

  TaskFilter copyWith({
    TaskStatus? status,
    bool clearStatus = false,
    String? labelId,
    bool clearLabelId = false,
    TaskPriority? priority,
    bool clearPriority = false,
    String? searchQuery,
  }) {
    return TaskFilter(
      status: clearStatus ? null : (status ?? this.status),
      labelId: clearLabelId ? null : (labelId ?? this.labelId),
      priority: clearPriority ? null : (priority ?? this.priority),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  TaskFilter clear() => const TaskFilter();
}

final taskFilterProvider = StateProvider<TaskFilter>((ref) => const TaskFilter());

final todayTasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchTasksForDate(userId, DateTime.now());
});

final tasksForSelectedDateProvider = StreamProvider<List<Task>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final date = ref.watch(selectedDateProvider);
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchTasksForDate(userId, date);
});

final allTasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchAllActiveTasks(userId);
});

final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsync = ref.watch(tasksForSelectedDateProvider);
  final filter = ref.watch(taskFilterProvider);

  return tasksAsync.whenData((tasks) {
    if (filter.isEmpty) return tasks;

    return tasks.where((task) {
      if (filter.status != null && task.status != filter.status) {
        return false;
      }
      if (filter.labelId != null && task.labelId != filter.labelId) {
        return false;
      }
      if (filter.priority != null && task.priority != filter.priority) {
        return false;
      }
      if (filter.searchQuery.trim().isNotEmpty) {
        final query = filter.searchQuery.trim().toLowerCase();
        final matchesTitle = task.title.toLowerCase().contains(query);
        final matchesDesc =
            task.description?.toLowerCase().contains(query) ?? false;
        if (!matchesTitle && !matchesDesc) {
          return false;
        }
      }
      return true;
    }).toList();
  });
});

class TaskController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  TaskController(this._ref) : super(const AsyncValue.data(null));

  String get _userId => _ref.read(currentUserIdProvider);
  TaskRepository get _repo => _ref.read(taskRepositoryProvider);

  Future<void> createTask(Task task, {RecurrenceRule? recurrence}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.createTask(task, recurrence: recurrence);
    });
  }

  Future<void> updateTask(Task task) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.updateTask(task);
    });
  }

  Future<void> deleteTask(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.deleteTask(id);
    });
  }

  Future<void> archiveTask(String id, bool archive) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.archiveTask(id, archive);
    });
  }

  Future<void> setTaskStatus(String id, TaskStatus status) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.setTaskStatus(id, status);
    });
  }

  Future<void> completeTaskOccurrence(
    String taskId,
    DateTime occurrenceDate, {
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.completeTaskOccurrence(
        _userId,
        taskId,
        occurrenceDate,
        notes: notes,
      );
    });
  }

  Future<void> uncompleteTaskOccurrence(
    String taskId,
    DateTime occurrenceDate,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.uncompleteTaskOccurrence(
        _userId,
        taskId,
        occurrenceDate,
      );
    });
  }

  Future<void> toggleTaskCompletion(
    Task task,
    DateTime occurrenceDate, {
    String? notes,
  }) async {
    if (task.status == TaskStatus.done) {
      await uncompleteTaskOccurrence(task.id, occurrenceDate);
    } else {
      await completeTaskOccurrence(task.id, occurrenceDate, notes: notes);
    }
  }
}

final taskControllerProvider =
    StateNotifierProvider<TaskController, AsyncValue<void>>((ref) {
  return TaskController(ref);
});
