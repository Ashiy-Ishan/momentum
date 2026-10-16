import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/enums/enums.dart';
import '../../../domain/models/models.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/widgets/icon_picker_dialog.dart';
import '../../labels/providers/label_providers.dart';
import '../providers/task_providers.dart';

/// Screen / Form dialog to create or edit a [Task].
class TaskFormScreen extends ConsumerStatefulWidget {
  final String? taskId;
  final Task? initialTask;
  final String? defaultParentLabelId;
  final String? defaultLabelId;
  final DateTime? defaultScheduledDate;

  const TaskFormScreen({
    super.key,
    this.taskId,
    this.initialTask,
    this.defaultParentLabelId,
    this.defaultLabelId,
    this.defaultScheduledDate,
  });

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  static const _uuid = Uuid();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _categoryController;
  late TextEditingController _urlController;
  late TextEditingController _durationHoursController;
  late TextEditingController _durationMinutesController;

  TaskPriority _priority = TaskPriority.medium;
  String? _parentLabelId;
  String? _subLabelId;
  DateTime? _scheduledDate;
  DateTime? _dueDate;
  RecurrenceType _recurrenceType = RecurrenceType.once;
  bool _hasTimeTracking = false;
  String? _iconName;

  bool _isLoading = false;
  Task? _loadedTask;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _categoryController = TextEditingController();
    _urlController = TextEditingController();
    _durationHoursController = TextEditingController();
    _durationMinutesController = TextEditingController();

    if (widget.initialTask != null) {
      _populateFromTask(widget.initialTask!);
    } else if (widget.taskId != null) {
      // Will load in didChangeDependencies or post-frame callback
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadTask());
    } else {
      _scheduledDate = widget.defaultScheduledDate ?? DateTime.now();
      _parentLabelId = widget.defaultParentLabelId;
      _subLabelId = widget.defaultLabelId;
    }
  }

  void _populateFromTask(Task t) {
    _loadedTask = t;
    _titleController.text = t.title;
    _descController.text = t.description ?? '';
    _categoryController.text = t.category ?? '';
    _urlController.text = t.url ?? '';
    _priority = t.priority;
    _scheduledDate = t.scheduledDate;
    _dueDate = t.dueDate;
    _hasTimeTracking = t.hasTimeTracking;
    _iconName = t.iconName;

    if (t.estimatedMinutes != null && t.estimatedMinutes! > 0) {
      final hours = t.estimatedMinutes! ~/ 60;
      final mins = t.estimatedMinutes! % 60;
      _durationHoursController.text = hours > 0 ? hours.toString() : '';
      _durationMinutesController.text = mins > 0 ? mins.toString() : '';
    }

    _subLabelId = t.labelId;
  }

  Future<void> _loadTask() async {
    if (widget.taskId == null) return;
    final allTasks = ref.read(allTasksStreamProvider).valueOrNull ?? [];
    final t = allTasks.cast<Task?>().firstWhere(
          (item) => item?.id == widget.taskId,
          orElse: () => null,
        );
    if (t != null) {
      if (mounted) setState(() => _populateFromTask(t));
      return;
    }

    try {
      final userId = ref.read(currentUserIdProvider);
      final tasks = await ref.read(taskRepositoryProvider).getAllTasks(userId);
      final fetched = tasks.cast<Task?>().firstWhere(
            (item) => item?.id == widget.taskId,
            orElse: () => null,
          );
      if (fetched != null && mounted) {
        setState(() => _populateFromTask(fetched));
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    _urlController.dispose();
    _durationHoursController.dispose();
    _durationMinutesController.dispose();
    super.dispose();
  }

  Future<void> _pickScheduledDate() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 5);
    final last = DateTime(now.year + 20);
    final initial = _scheduledDate ?? now;
    final safeInitial = initial.isBefore(first)
        ? first
        : (initial.isAfter(last) ? last : initial);

    final picked = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) {
      setState(() {
        _scheduledDate = picked;
        if (_dueDate != null && _dueDate!.isBefore(picked)) {
          _dueDate = picked;
        }
      });
    }
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final first = _scheduledDate ?? DateTime(now.year - 5);
    final last = DateTime(now.year + 20);
    final initial = _dueDate ?? (_scheduledDate ?? now);
    final safeInitial = initial.isBefore(first)
        ? first
        : (initial.isAfter(last) ? last : initial);

    final picked = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickIcon() async {
    final icon = await IconPickerDialog.show(
      context,
      initialIconName: _iconName,
    );
    if (icon != null) {
      setState(() => _iconName = icon);
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    if (_scheduledDate != null &&
        _dueDate != null &&
        _dueDate!.isBefore(_scheduledDate!)) {
      context.showSnackBar(
        'Due date cannot be before scheduled date',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    final userId = ref.read(currentUserIdProvider);
    final now = DateTime.now();

    final hours = int.tryParse(_durationHoursController.text.trim()) ?? 0;
    final mins = int.tryParse(_durationMinutesController.text.trim()) ?? 0;
    final totalEstimatedMinutes = (hours * 60) + mins;

    // Use chosen subLabelId, or fallback to parentLabelId
    final finalLabelId = _subLabelId ?? _parentLabelId;

    final isEditing = _loadedTask != null || widget.taskId != null;
    final taskId = _loadedTask?.id ?? widget.taskId ?? _uuid.v4();

    RecurrenceRule? rule;
    String? ruleId;
    if (_recurrenceType != RecurrenceType.once) {
      ruleId = _uuid.v4();
      rule = RecurrenceRule(
        id: ruleId,
        userId: userId,
        type: _recurrenceType,
        startDate: _scheduledDate ?? now,
        createdAt: now,
        updatedAt: now,
      );
    }

    final taskToSave = Task(
      id: taskId,
      userId: userId,
      labelId: finalLabelId,
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      category: _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim(),
      url: _urlController.text.trim().isEmpty ? null : _urlController.text.trim(),
      iconName: _iconName,
      status: _loadedTask?.status ?? TaskStatus.pending,
      priority: _priority,
      hasTimeTracking: _hasTimeTracking,
      estimatedMinutes:
          totalEstimatedMinutes > 0 ? totalEstimatedMinutes : null,
      recurrenceRuleId: ruleId ?? _loadedTask?.recurrenceRuleId,
      scheduledDate: _scheduledDate,
      dueDate: _dueDate,
      createdAt: _loadedTask?.createdAt ?? now,
      updatedAt: now,
      version: (_loadedTask?.version ?? 0) + 1,
    );

    try {
      if (isEditing) {
        await ref.read(taskControllerProvider.notifier).updateTask(taskToSave);
      } else {
        await ref
            .read(taskControllerProvider.notifier)
            .createTask(taskToSave, recurrence: rule);
      }

      if (mounted) {
        context.showSnackBar(
          isEditing ? 'Task updated successfully' : 'Task created successfully',
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/tasks');
        }
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Failed to save task: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allLabels = ref.watch(allLabelsStreamProvider).valueOrNull ?? [];
    final rootLabels = allLabels.where((l) => l.parentId == null).toList();

    // If subLabelId is set but parentLabelId is not, infer parent
    if (_subLabelId != null && _parentLabelId == null) {
      final sub = allLabels.cast<Label?>().firstWhere(
            (l) => l?.id == _subLabelId,
            orElse: () => null,
          );
      if (sub?.parentId != null) {
        _parentLabelId = sub!.parentId;
      }
    }

    final availableSubLabels = _parentLabelId != null
        ? allLabels.where((l) => l.parentId == _parentLabelId).toList()
        : <Label>[];

    final isEditing = _loadedTask != null || widget.taskId != null;
    final isStillLoading = widget.taskId != null && _loadedTask == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/tasks');
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check, size: 18),
              label: Text(isEditing ? 'Update' : 'Save'),
              onPressed: (_isLoading || isStillLoading) ? null : _saveTask,
            ),
          ),
        ],
      ),
      body: isStillLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
            // Task Title
            TextFormField(
              controller: _titleController,
              autofocus: !isEditing,
              decoration: InputDecoration(
                labelText: 'Task Title *',
                hintText: 'e.g. Record Flutter tutorial video',
                prefixIcon: _iconName != null
                    ? Icon(AppIcons.fromName(_iconName!),
                        color: theme.colorScheme.primary)
                    : const Icon(Icons.title),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.insert_emoticon_outlined),
                  tooltip: 'Pick Icon',
                  onPressed: _pickIcon,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              validator: Validators.validateTitle,
            ),
            AppSpacing.vGapMd,

            // Description / Notes
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description / Notes',
                hintText: 'Add details, bullet points, context...',
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.notes_outlined),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
            AppSpacing.vGapMd,

            // Priority Selector
            Text(
              'Priority',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vGapXs,
            SegmentedButton<TaskPriority>(
              segments: [
                ButtonSegment(
                  value: TaskPriority.low,
                  label: const Text('Low'),
                  icon: Icon(TaskPriority.low.icon, size: 16),
                ),
                ButtonSegment(
                  value: TaskPriority.medium,
                  label: const Text('Medium'),
                  icon: Icon(TaskPriority.medium.icon, size: 16),
                ),
                ButtonSegment(
                  value: TaskPriority.high,
                  label: const Text('High'),
                  icon: Icon(TaskPriority.high.icon, size: 16),
                ),
                ButtonSegment(
                  value: TaskPriority.urgent,
                  label: const Text('Urgent'),
                  icon: Icon(TaskPriority.urgent.icon, size: 16),
                ),
              ],
              selected: {_priority},
              onSelectionChanged: (val) {
                setState(() => _priority = val.first);
              },
            ),
            AppSpacing.vGapLg,

            // Parent & Sub Label Section
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
              ),
              child: Padding(
                padding: AppSpacing.allMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Focus Area & Sub-Label',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.vGapSm,
                    // Parent Label Dropdown
                    DropdownButtonFormField<String?>(
                      initialValue: _parentLabelId,
                      decoration: InputDecoration(
                        labelText: 'Focus Area (Parent Label)',
                        prefixIcon: const Icon(Icons.folder_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('None (General)'),
                        ),
                        if (_parentLabelId != null &&
                            !rootLabels.any((l) => l.id == _parentLabelId))
                          DropdownMenuItem(
                            value: _parentLabelId,
                            child: Text('Focus Area ($_parentLabelId)'),
                          ),
                        ...rootLabels.map((l) {
                          return DropdownMenuItem(
                            value: l.id,
                            child: Row(
                              children: [
                                Icon(AppIcons.fromName(l.iconName), size: 18),
                                const SizedBox(width: 8),
                                Text(l.name),
                              ],
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _parentLabelId = val;
                          _subLabelId = null; // Reset sub-label when parent changes
                        });
                      },
                    ),

                    if (availableSubLabels.isNotEmpty || _subLabelId != null) ...[
                      AppSpacing.vGapSm,
                      DropdownButtonFormField<String?>(
                        initialValue: _subLabelId,
                        decoration: InputDecoration(
                          labelText: 'Sub-Label (Channel / Project)',
                          prefixIcon: const Icon(Icons.subdirectory_arrow_right),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All / Direct Parent'),
                          ),
                          if (_subLabelId != null &&
                              !availableSubLabels
                                  .any((l) => l.id == _subLabelId))
                            DropdownMenuItem(
                              value: _subLabelId,
                              child: Text('Sub-Label ($_subLabelId)'),
                            ),
                          ...availableSubLabels.map((l) {
                            return DropdownMenuItem(
                              value: l.id,
                              child: Row(
                                children: [
                                  Icon(AppIcons.fromName(l.iconName), size: 18),
                                  const SizedBox(width: 8),
                                  Text(l.name),
                                ],
                              ),
                            );
                          }),
                        ],
                        onChanged: (val) => setState(() => _subLabelId = val),
                      ),
                    ],

                    AppSpacing.vGapSm,
                    TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: 'Category / Tag (Optional)',
                        hintText: 'e.g. Editing, Research, Work',
                        prefixIcon: const Icon(Icons.label_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.vGapMd,

            // Schedule & Due Dates Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
              ),
              child: Padding(
                padding: AppSpacing.allMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dates & Recurrence',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.vGapSm,

                    // Scheduled Date
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: const Text('Scheduled Date'),
                      subtitle: Text(
                        _scheduledDate != null
                            ? _scheduledDate!.formatted
                            : 'No scheduled date',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_scheduledDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () =>
                                  setState(() => _scheduledDate = null),
                            ),
                          FilledButton.tonal(
                            onPressed: _pickScheduledDate,
                            child: const Text('Pick'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),

                    // Due Date
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.flag_outlined),
                      title: const Text('Due Date (Deadline)'),
                      subtitle: Text(
                        _dueDate != null
                            ? _dueDate!.formatted
                            : 'No deadline set',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_dueDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => setState(() => _dueDate = null),
                            ),
                          FilledButton.tonal(
                            onPressed: _pickDueDate,
                            child: const Text('Pick'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),

                    // Recurrence
                    DropdownButtonFormField<RecurrenceType>(
                      initialValue: _recurrenceType,
                      decoration: InputDecoration(
                        labelText: 'Recurrence Pattern',
                        prefixIcon: const Icon(Icons.repeat),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: RecurrenceType.once,
                          child: Text('Does not repeat (Once)'),
                        ),
                        DropdownMenuItem(
                          value: RecurrenceType.daily,
                          child: Text('Daily'),
                        ),
                        DropdownMenuItem(
                          value: RecurrenceType.weekdays,
                          child: Text('Weekdays (Mon-Fri)'),
                        ),
                        DropdownMenuItem(
                          value: RecurrenceType.everyOtherDay,
                          child: Text('Every Other Day'),
                        ),
                        DropdownMenuItem(
                          value: RecurrenceType.weekly,
                          child: Text('Weekly'),
                        ),
                        DropdownMenuItem(
                          value: RecurrenceType.monthly,
                          child: Text('Monthly'),
                        ),
                        DropdownMenuItem(
                          value: RecurrenceType.custom,
                          child: Text('Custom'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _recurrenceType = val);
                      },
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.vGapMd,

            // Time Tracking & Duration Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
              ),
              child: Padding(
                padding: AppSpacing.allMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Enable Time Tracking',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Allows starting and stopping live timer sessions on this task',
                      ),
                      value: _hasTimeTracking,
                      onChanged: (val) => setState(() => _hasTimeTracking = val),
                    ),
                    if (_hasTimeTracking) ...[
                      AppSpacing.vGapSm,
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _durationHoursController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Est. Hours',
                                prefixIcon: const Icon(Icons.hourglass_empty),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                ),
                              ),
                            ),
                          ),
                          AppSpacing.hGapSm,
                          Expanded(
                            child: TextFormField(
                              controller: _durationMinutesController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              validator: (val) {
                                if (val != null && val.trim().isNotEmpty) {
                                  final m = int.tryParse(val.trim());
                                  if (m == null || m > 59) {
                                    return '0-59';
                                  }
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Est. Minutes',
                                prefixIcon: const Icon(Icons.timer_outlined),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            AppSpacing.vGapMd,

            // Website URL
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Website / Resource URL (Optional)',
                hintText: 'https://...',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              validator: (val) {
                if (val != null && val.trim().isNotEmpty) {
                  return Validators.validateUrl(val);
                }
                return null;
              },
            ),
            AppSpacing.vGapXl,

            // Save Button
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                isEditing ? 'Update Task' : 'Create Task',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: _isLoading ? null : _saveTask,
            ),
            AppSpacing.vGapLg,
          ],
        ),
      ),
    );
  }
}
