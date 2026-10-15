import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../domain/models/models.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/widgets/color_picker_dialog.dart';
import '../../../shared/widgets/icon_picker_dialog.dart';
import '../../tasks/providers/task_providers.dart';
import '../providers/label_providers.dart';

/// Screen allowing hierarchical management of Parent Focus Areas and Sub-Labels,
/// including creation, editing, task counts, tree viewing, reordering, and deletion.
class LabelsScreen extends ConsumerStatefulWidget {
  const LabelsScreen({super.key});

  @override
  ConsumerState<LabelsScreen> createState() => _LabelsScreenState();
}

class _LabelsScreenState extends ConsumerState<LabelsScreen> {
  static const _uuid = Uuid();

  Color _colorFromHex(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    } else if (clean.length == 8) {
      return Color(int.parse(clean, radix: 16));
    }
    return fallback;
  }

  Future<void> _showLabelFormDialog({
    Label? existingLabel,
    String? defaultParentId,
  }) async {
    final theme = Theme.of(context);
    final allLabels = ref.read(allLabelsStreamProvider).valueOrNull ?? [];
    final rootLabels = allLabels.where((l) => l.parentId == null).toList();

    final nameController =
        TextEditingController(text: existingLabel?.name ?? '');
    String selectedIcon = existingLabel?.iconName ?? 'folder';
    String selectedColor = existingLabel?.color ?? '#4F46E5';
    String? selectedParentId =
        existingLabel?.parentId ?? defaultParentId;

    final isEditing = existingLabel != null;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(
              isEditing
                  ? 'Edit Label'
                  : (selectedParentId != null
                      ? 'Add Sub-Label'
                      : 'Add Focus Area'),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Label Name
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Label Name *',
                      hintText: 'e.g. YouTube, Programming, Fitness',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                  AppSpacing.vGapMd,

                  // Parent Label Selector
                  DropdownButtonFormField<String?>(
                    initialValue: selectedParentId,
                    decoration: InputDecoration(
                      labelText: 'Parent Label (Hierarchy)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('None (Root Focus Area)'),
                      ),
                      ...rootLabels
                          .where((r) => r.id != existingLabel?.id)
                          .map((r) => DropdownMenuItem(
                                value: r.id,
                                child: Text(r.name),
                              )),
                    ],
                    onChanged: (val) {
                      setDialogState(() => selectedParentId = val);
                    },
                  ),
                  AppSpacing.vGapMd,

                  // Icon & Color Pickers Row
                  Row(
                    children: [
                      // Icon picker
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(AppIcons.fromName(selectedIcon), size: 20),
                          label: Text(selectedIcon),
                          onPressed: () async {
                            final icon = await IconPickerDialog.show(
                              context,
                              initialIconName: selectedIcon,
                            );
                            if (icon != null) {
                              setDialogState(() => selectedIcon = icon);
                            }
                          },
                        ),
                      ),
                      AppSpacing.hGapSm,
                      // Color picker
                      InkWell(
                        onTap: () async {
                          final color = await ColorPickerDialog.show(
                            context,
                            selectedColorHex: selectedColor,
                          );
                          if (color != null) {
                            setDialogState(() => selectedColor = color);
                          }
                        },
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _colorFromHex(
                                selectedColor, theme.colorScheme.primary),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.color_lens_outlined,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;

                  final userId = ref.read(currentUserIdProvider);
                  final now = DateTime.now();

                  if (isEditing) {
                    final updated = existingLabel.copyWith(
                      name: name,
                      parentId: selectedParentId,
                      clearParentId: selectedParentId == null,
                      iconName: selectedIcon,
                      color: selectedColor,
                      updatedAt: now,
                    );
                    await ref
                        .read(labelControllerProvider.notifier)
                        .updateLabel(updated);
                  } else {
                    final newLabel = Label(
                      id: _uuid.v4(),
                      userId: userId,
                      parentId: selectedParentId,
                      name: name,
                      iconName: selectedIcon,
                      color: selectedColor,
                      createdAt: now,
                      updatedAt: now,
                    );
                    await ref
                        .read(labelControllerProvider.notifier)
                        .createLabel(newLabel);
                  }

                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                  if (mounted) {
                    context.showSnackBar(
                      isEditing ? 'Label updated' : 'Label created',
                    );
                  }
                },
                child: Text(isEditing ? 'Update' : 'Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteLabel(BuildContext context, Label label) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${label.name}"?'),
        content: const Text(
          'Are you sure you want to delete this label? Tasks attached will remain intact but will be unassigned.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref
                  .read(labelControllerProvider.notifier)
                  .deleteLabel(label.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allLabelsAsync = ref.watch(allLabelsStreamProvider);
    final allTasks = ref.watch(allTasksStreamProvider).valueOrNull ?? [];

    // Calculate task counts per label
    final taskCountMap = <String, int>{};
    for (final t in allTasks) {
      if (t.labelId != null) {
        taskCountMap[t.labelId!] = (taskCountMap[t.labelId!] ?? 0) + 1;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Labels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Focus Area',
            onPressed: () => _showLabelFormDialog(),
          ),
          PopupMenuButton<String>(
            tooltip: 'Options',
            onSelected: (val) {
              if (val == 'seed') {
                ref.read(labelControllerProvider.notifier).seedDefaultLabels();
                context.showSnackBar('Default labels generated');
              }
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(
                value: 'seed',
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 18),
                    SizedBox(width: 8),
                    Text('Seed Default Labels'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: allLabelsAsync.when(
        data: (allLabels) {
          final parentLabels =
              allLabels.where((l) => l.parentId == null).toList()
                ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

          if (parentLabels.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.label_off_outlined,
                        size: 56, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No Focus Areas Found',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create custom labels or seed default areas (YouTube, Social Media, Learning, Career, Personal).',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Seed Default Focus Areas'),
                      onPressed: () {
                        ref
                            .read(labelControllerProvider.notifier)
                            .seedDefaultLabels();
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          return ReorderableListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onReorderItem: (oldIndex, newIndex) {
              final items = List<Label>.from(parentLabels);
              final moved = items.removeAt(oldIndex);
              items.insert(newIndex, moved);
              ref.read(labelControllerProvider.notifier).reorderLabels(items);
            },
            children: parentLabels.map((parent) {
              final childLabels = allLabels
                  .where((l) => l.parentId == parent.id)
                  .toList()
                ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

              final parentColor =
                  _colorFromHex(parent.color, theme.colorScheme.primary);
              final directCount = taskCountMap[parent.id] ?? 0;
              final totalChildrenCount = childLabels.fold<int>(
                0,
                (acc, c) => acc + (taskCountMap[c.id] ?? 0),
              );
              final aggregateCount = directCount + totalChildrenCount;

              return Card(
                key: ValueKey(parent.id),
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  side: BorderSide(
                    color: parentColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Theme(
                  data: theme.copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: parentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        AppIcons.fromName(parent.iconName),
                        color: parentColor,
                        size: 20,
                      ),
                    ),
                    title: InkWell(
                      onTap: () =>
                          context.push('/labels/parent/${parent.id}'),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              parent.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              '$aggregateCount tasks',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text(
                      '${childLabels.length} sub-labels · Tap name for dashboard',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          tooltip: 'Add Sub-Label',
                          onPressed: () => _showLabelFormDialog(
                            defaultParentId: parent.id,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (val) {
                            if (val == 'edit') {
                              _showLabelFormDialog(existingLabel: parent);
                            } else if (val == 'dashboard') {
                              context.push('/labels/parent/${parent.id}');
                            } else if (val == 'delete') {
                              _confirmDeleteLabel(context, parent);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'dashboard',
                              child: Row(
                                children: [
                                  Icon(Icons.dashboard_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text('View Dashboard'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit Area'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline,
                                      size: 18, color: AppColors.error),
                                  SizedBox(width: 8),
                                  Text('Delete',
                                      style: TextStyle(color: AppColors.error)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    children: [
                      const Divider(height: 1),
                      // List Child Labels
                      if (childLabels.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Text(
                                'No sub-labels yet',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                icon: const Icon(Icons.add, size: 14),
                                label: const Text('Add Sub-label',
                                    style: TextStyle(fontSize: 12)),
                                onPressed: () => _showLabelFormDialog(
                                  defaultParentId: parent.id,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: childLabels.length,
                          separatorBuilder: (_, _) =>
                              const Divider(height: 1, indent: 48),
                          itemBuilder: (context, cIdx) {
                            final child = childLabels[cIdx];
                            final childColor = _colorFromHex(
                                child.color, theme.colorScheme.secondary);
                            final cTasks = taskCountMap[child.id] ?? 0;

                            return ListTile(
                              contentPadding: const EdgeInsets.only(
                                  left: 36, right: 8),
                              leading: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: childColor.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  AppIcons.fromName(child.iconName),
                                  color: childColor,
                                  size: 15,
                                ),
                              ),
                              title: Text(
                                child.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                '$cTasks tasks',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              onTap: () =>
                                  context.push('/labels/sub/${child.id}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 18),
                                    onPressed: () => _showLabelFormDialog(
                                      existingLabel: child,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 18, color: AppColors.error),
                                    onPressed: () =>
                                        _confirmDeleteLabel(context, child),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Focus Area'),
        onPressed: () => _showLabelFormDialog(),
      ),
    );
  }
}
