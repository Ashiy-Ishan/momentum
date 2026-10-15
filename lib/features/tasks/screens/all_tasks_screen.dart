import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/theme.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/models.dart';
import '../../labels/providers/label_providers.dart';
import '../providers/task_providers.dart';
import '../widgets/task_card.dart';

enum TaskSortOption {
  dueDate,
  scheduledDate,
  priority,
  title,
  createdAt;

  String get displayName {
    switch (this) {
      case TaskSortOption.dueDate:
        return 'Due Date';
      case TaskSortOption.scheduledDate:
        return 'Scheduled Date';
      case TaskSortOption.priority:
        return 'Priority';
      case TaskSortOption.title:
        return 'Title';
      case TaskSortOption.createdAt:
        return 'Created Date';
    }
  }
}

enum TaskGroupingOption {
  none,
  label,
  status,
  priority;

  String get displayName {
    switch (this) {
      case TaskGroupingOption.none:
        return 'No Grouping';
      case TaskGroupingOption.label:
        return 'By Label';
      case TaskGroupingOption.status:
        return 'By Status';
      case TaskGroupingOption.priority:
        return 'By Priority';
    }
  }
}

/// Screen displaying all user tasks with full-text search, multi-faceted filtering,
/// dynamic sorting, multi-attribute grouping, and complete CRUD actions.
class AllTasksScreen extends ConsumerStatefulWidget {
  const AllTasksScreen({super.key});

  @override
  ConsumerState<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends ConsumerState<AllTasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  TaskStatus? _selectedStatus;
  TaskPriority? _selectedPriority;
  String? _selectedLabelId;
  String? _selectedCategory;

  TaskSortOption _sortOption = TaskSortOption.dueDate;
  bool _sortAscending = true;
  TaskGroupingOption _groupingOption = TaskGroupingOption.none;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Task> _applyFiltersAndSort(List<Task> tasks) {
    final result = tasks.where((t) {
      // Search query filter
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.trim().toLowerCase();
        final matchTitle = t.title.toLowerCase().contains(query);
        final matchDesc = t.description?.toLowerCase().contains(query) ?? false;
        final matchCat = t.category?.toLowerCase().contains(query) ?? false;
        if (!matchTitle && !matchDesc && !matchCat) return false;
      }

      // Status filter
      if (_selectedStatus != null && t.status != _selectedStatus) return false;

      // Priority filter
      if (_selectedPriority != null && t.priority != _selectedPriority) {
        return false;
      }

      // Label filter
      if (_selectedLabelId != null && t.labelId != _selectedLabelId) {
        return false;
      }

      // Category filter
      if (_selectedCategory != null &&
          _selectedCategory!.isNotEmpty &&
          t.category != _selectedCategory) {
        return false;
      }

      return true;
    }).toList();

    // Sort
    result.sort((a, b) {
      int cmp = 0;
      switch (_sortOption) {
        case TaskSortOption.dueDate:
          if (a.dueDate == null && b.dueDate == null) {
            cmp = 0;
          } else if (a.dueDate == null) {
            cmp = 1;
          } else if (b.dueDate == null) {
            cmp = -1;
          } else {
            cmp = a.dueDate!.compareTo(b.dueDate!);
          }
          break;
        case TaskSortOption.scheduledDate:
          if (a.scheduledDate == null && b.scheduledDate == null) {
            cmp = 0;
          } else if (a.scheduledDate == null) {
            cmp = 1;
          } else if (b.scheduledDate == null) {
            cmp = -1;
          } else {
            cmp = a.scheduledDate!.compareTo(b.scheduledDate!);
          }
          break;
        case TaskSortOption.priority:
          cmp = b.priority.level.compareTo(a.priority.level);
          break;
        case TaskSortOption.title:
          cmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case TaskSortOption.createdAt:
          cmp = b.createdAt.compareTo(a.createdAt);
          break;
      }
      return _sortAscending ? cmp : -cmp;
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final allTasksAsync = ref.watch(allTasksStreamProvider);
    final allLabels = ref.watch(allLabelsStreamProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Task',
            onPressed: () => context.push('/tasks/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks by title, description or category...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Filter, Sort & Grouping Toolbar
          _buildToolbar(context, allLabels, allTasksAsync.valueOrNull ?? []),

          const Divider(height: 1),

          // Tasks List
          Expanded(
            child: allTasksAsync.when(
              data: (tasks) {
                final filtered = _applyFiltersAndSort(tasks);

                if (tasks.isEmpty) {
                  return _buildEmptyState(
                    title: 'No tasks yet',
                    message:
                        'Create your first task to start organizing your life and goals!',
                    icon: Icons.task_alt,
                  );
                }

                if (filtered.isEmpty) {
                  return _buildEmptyState(
                    title: 'No tasks match criteria',
                    message:
                        'Try clearing search or adjusting active filters to see your tasks.',
                    icon: Icons.filter_alt_off_outlined,
                  );
                }

                // Render based on Grouping Option
                if (_groupingOption == TaskGroupingOption.none) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final task = filtered[index];
                      return TaskCard(
                        task: task,
                        onEdit: () => context.push('/tasks/edit/${task.id}'),
                      );
                    },
                  );
                }

                return _buildGroupedList(context, filtered, allLabels);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
        onPressed: () => context.push('/tasks/new'),
      ),
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    List<Label> allLabels,
    List<Task> allTasks,
  ) {
    // Unique categories from tasks
    final categories = allTasks
        .map((t) => t.category)
        .whereType<String>()
        .where((c) => c.trim().isNotEmpty)
        .toSet()
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Sort Dropdown
          PopupMenuButton<TaskSortOption>(
            tooltip: 'Sort Options',
            child: Chip(
              avatar: Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
              ),
              label: Text('Sort: ${_sortOption.displayName}'),
            ),
            onSelected: (opt) {
              if (_sortOption == opt) {
                setState(() => _sortAscending = !_sortAscending);
              } else {
                setState(() {
                  _sortOption = opt;
                  _sortAscending = true;
                });
              }
            },
            itemBuilder: (ctx) => TaskSortOption.values.map((opt) {
              return PopupMenuItem(
                value: opt,
                child: Row(
                  children: [
                    if (_sortOption == opt)
                      const Icon(Icons.check, size: 16)
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    Text(opt.displayName),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 8),

          // Grouping Dropdown
          PopupMenuButton<TaskGroupingOption>(
            tooltip: 'Group By',
            child: Chip(
              avatar: const Icon(Icons.grid_view_rounded, size: 16),
              label: Text(_groupingOption.displayName),
            ),
            onSelected: (opt) => setState(() => _groupingOption = opt),
            itemBuilder: (ctx) => TaskGroupingOption.values.map((opt) {
              return PopupMenuItem(
                value: opt,
                child: Row(
                  children: [
                    if (_groupingOption == opt)
                      const Icon(Icons.check, size: 16)
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    Text(opt.displayName),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 8),

          // Status Filter Chip
          PopupMenuButton<TaskStatus?>(
            tooltip: 'Filter by Status',
            child: FilterChip(
              label: Text(
                _selectedStatus != null
                    ? _selectedStatus!.displayName
                    : 'Status',
              ),
              selected: _selectedStatus != null,
              onSelected: (_) {},
            ),
            onSelected: (val) => setState(() => _selectedStatus = val),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: null, child: Text('All Statuses')),
              ...TaskStatus.values.map((s) {
                return PopupMenuItem(
                  value: s,
                  child: Row(
                    children: [
                      Icon(s.icon, size: 16, color: s.color),
                      const SizedBox(width: 8),
                      Text(s.displayName),
                    ],
                  ),
                );
              }),
            ],
          ),
          const SizedBox(width: 8),

          // Priority Filter Chip
          PopupMenuButton<TaskPriority?>(
            tooltip: 'Filter by Priority',
            child: FilterChip(
              label: Text(
                _selectedPriority != null
                    ? _selectedPriority!.displayName
                    : 'Priority',
              ),
              selected: _selectedPriority != null,
              onSelected: (_) {},
            ),
            onSelected: (val) => setState(() => _selectedPriority = val),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: null, child: Text('All Priorities')),
              ...TaskPriority.values.map((p) {
                return PopupMenuItem(
                  value: p,
                  child: Row(
                    children: [
                      Icon(p.icon, size: 16, color: p.color),
                      const SizedBox(width: 8),
                      Text(p.displayName),
                    ],
                  ),
                );
              }),
            ],
          ),
          const SizedBox(width: 8),

          // Label Filter Chip
          PopupMenuButton<String?>(
            tooltip: 'Filter by Label',
            child: FilterChip(
              label: Text(
                _selectedLabelId != null
                    ? (allLabels
                            .firstWhereOrNull((l) => l.id == _selectedLabelId)
                            ?.name ??
                        'Label')
                    : 'Label',
              ),
              selected: _selectedLabelId != null,
              onSelected: (_) {},
            ),
            onSelected: (val) => setState(() => _selectedLabelId = val),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: null, child: Text('All Labels')),
              ...allLabels.map((l) {
                return PopupMenuItem(
                  value: l.id,
                  child: Row(
                    children: [
                      Icon(AppIcons.fromName(l.iconName), size: 16),
                      const SizedBox(width: 8),
                      Text(l.name),
                    ],
                  ),
                );
              }),
            ],
          ),

          // Category Filter Chip (if categories exist)
          if (categories.isNotEmpty) ...[
            const SizedBox(width: 8),
            PopupMenuButton<String?>(
              tooltip: 'Filter by Category',
              child: FilterChip(
                label: Text(_selectedCategory ?? 'Category'),
                selected: _selectedCategory != null,
                onSelected: (_) {},
              ),
              onSelected: (val) => setState(() => _selectedCategory = val),
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: null, child: Text('All Categories')),
                ...categories.map((c) {
                  return PopupMenuItem(value: c, child: Text(c));
                }),
              ],
            ),
          ],

          // Clear All Filters
          if (_selectedStatus != null ||
              _selectedPriority != null ||
              _selectedLabelId != null ||
              _selectedCategory != null) ...[
            const SizedBox(width: 8),
            ActionChip(
              avatar: const Icon(Icons.close, size: 16),
              label: const Text('Reset'),
              onPressed: () {
                setState(() {
                  _selectedStatus = null;
                  _selectedPriority = null;
                  _selectedLabelId = null;
                  _selectedCategory = null;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupedList(
    BuildContext context,
    List<Task> tasks,
    List<Label> allLabels,
  ) {
    final theme = Theme.of(context);
    final Map<String, List<Task>> groups = {};

    switch (_groupingOption) {
      case TaskGroupingOption.label:
        for (final t in tasks) {
          final labelName = t.labelId != null
              ? (allLabels.firstWhereOrNull((l) => l.id == t.labelId)?.name ??
                  'Unlabeled')
              : 'Unlabeled';
          groups.putIfAbsent(labelName, () => []).add(t);
        }
        break;
      case TaskGroupingOption.status:
        for (final t in tasks) {
          groups.putIfAbsent(t.status.displayName, () => []).add(t);
        }
        break;
      case TaskGroupingOption.priority:
        for (final t in tasks) {
          groups.putIfAbsent(t.priority.displayName, () => []).add(t);
        }
        break;
      case TaskGroupingOption.none:
        break;
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: groups.entries.map((entry) {
        final groupTitle = entry.key;
        final groupTasks = entry.value;

        return ExpansionTile(
          initiallyExpanded: true,
          title: Row(
            children: [
              Text(
                groupTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${groupTasks.length}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          children: groupTasks.map((task) {
            return TaskCard(
              task: task,
              onEdit: () => context.push('/tasks/edit/${task.id}'),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String message,
    required IconData icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: Colors.grey.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
