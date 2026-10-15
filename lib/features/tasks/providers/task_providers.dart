import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/repositories.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/models.dart';
import '../../../shared/providers/database_provider.dart';

// =============================================================================
// Selected Date & Filters
// =============================================================================

/// Currently selected calendar date in task view.
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Filter criteria for querying and displaying tasks.
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

/// Active task filter state provider.
final taskFilterProvider = StateProvider<TaskFilter>((ref) => const TaskFilter());

// =============================================================================
// Task Streams
// =============================================================================

/// Watches active tasks scheduled or occurring today.
final todayTasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchTasksForDate(userId, DateTime.now());
});

/// Watches tasks scheduled or occurring on [selectedDateProvider].
final tasksForSelectedDateProvider = StreamProvider<List<Task>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final date = ref.watch(selectedDateProvider);
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchTasksForDate(userId, date);
});

/// Watches all active non-archived, non-deleted tasks for the current user.
final allTasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchAllActiveTasks(userId);
});

/// Computes filtered tasks list based on [tasksForSelectedDateProvider] and [taskFilterProvider].
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

// =============================================================================
// Task Controller
// =============================================================================

/// Controller managing task mutations and completion state transitions.
class TaskController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  TaskController(this._ref) : super(const AsyncValue.data(null));

  String get _userId => _ref.read(currentUserIdProvider);
  TaskRepository get _repo => _ref.read(taskRepositoryProvider);

  /// Creates a new task and optional recurrence rule.
  Future<void> createTask(Task task, {RecurrenceRule? recurrence}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.createTask(task, recurrence: recurrence);
    });
  }

  /// Updates an existing task.
  Future<void> updateTask(Task task) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.updateTask(task);
    });
  }

  /// Deletes a task by ID.
  Future<void> deleteTask(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.deleteTask(id);
    });
  }

  /// Archives or unarchives a task.
  Future<void> archiveTask(String id, bool archive) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.archiveTask(id, archive);
    });
  }

  /// Updates status for a task directly.
  Future<void> setTaskStatus(String id, TaskStatus status) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.setTaskStatus(id, status);
    });
  }

  /// Marks a specific occurrence on [occurrenceDate] as completed.
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

  /// Reverts completion of a task occurrence on [occurrenceDate].
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

  /// Toggles completion status for [task] on [occurrenceDate].
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

/// Task controller provider.
final taskControllerProvider =
    StateNotifierProvider<TaskController, AsyncValue<void>>((ref) {
  return TaskController(ref);
});
