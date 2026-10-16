import 'package:flutter/material.dart';

import '../../core/constants/default_labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Card widget representing a category/project label in Momentum.
///
/// Displays:
/// - Label icon and theme color
/// - Label name & hierarchy indicator
/// - Count of active sub-labels
/// - Completion percentage & progress bar
/// - Concise KPI summary ("8/12 tasks completed • 67%")
/// - Tap to view label dashboard & action menu (Edit, Delete, Add Sub-label)
class LabelCard extends StatelessWidget {
  final Label label;
  final int childLabelCount;
  final int completedTaskCount;
  final int totalTaskCount;
  final ValueChanged<Label>? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAddSubLabel;
  final bool isSelected;

  const LabelCard({
    super.key,
    required this.label,
    this.childLabelCount = 0,
    this.completedTaskCount = 0,
    this.totalTaskCount = 0,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onAddSubLabel,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final labelColor = label.colorAsColor;
    final progress = totalTaskCount > 0
        ? (completedTaskCount / totalTaskCount).clamp(0.0, 1.0)
        : 0.0;
    final percent = (progress * 100).round();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
        side: BorderSide(
          color: isSelected
              ? labelColor
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap != null ? () => onTap!(label) : null,
        borderRadius: AppRadius.borderMd,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------------------------------------------------------------
              // Left Color Accent Bar
              // ---------------------------------------------------------------
              Container(
                width: 3.5,
                decoration: BoxDecoration(
                  color: labelColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: AppRadius.rMd,
                    bottomLeft: AppRadius.rMd,
                  ),
                ),
              ),

              // ---------------------------------------------------------------
              // Card Main Body
              // ---------------------------------------------------------------
              Expanded(
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Icon, Title, and Sub-label count
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceVariantDark
                                  : AppColors.surfaceVariantLight,
                              borderRadius: AppRadius.borderSm,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                                width: 1.0,
                              ),
                            ),
                            child: Icon(
                              label.iconData,
                              size: 18,
                              color: labelColor,
                            ),
                          ),
                          AppSpacing.hGapSm,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label.name,
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (label.isSubLabel)
                                  Text(
                                    'Sub-label',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (childLabelCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.surfaceVariantDark
                                    : AppColors.surfaceVariantLight,
                                borderRadius: AppRadius.borderSm,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.account_tree_outlined,
                                    size: 13,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  AppSpacing.hGapXxs,
                                  Text(
                                    '$childLabelCount',
                                    style: AppTypography.labelSmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (onEdit != null ||
                              onDelete != null ||
                              onAddSubLabel != null)
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              tooltip: 'Label actions',
                              onSelected: (val) {
                                if (val == 'add_sub') onAddSubLabel?.call();
                                if (val == 'edit') onEdit?.call();
                                if (val == 'delete') onDelete?.call();
                              },
                              itemBuilder: (context) => [
                                if (onAddSubLabel != null)
                                  const PopupMenuItem(
                                    value: 'add_sub',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.add_circle_outline_rounded,
                                          size: 18,
                                        ),
                                        SizedBox(width: AppSpacing.sm),
                                        Text('Add Sub-label'),
                                      ],
                                    ),
                                  ),
                                if (onEdit != null)
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined, size: 18),
                                        SizedBox(width: AppSpacing.sm),
                                        Text('Edit Label'),
                                      ],
                                    ),
                                  ),
                                if (onDelete != null)
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline_rounded,
                                          size: 18,
                                          color: AppColors.error,
                                        ),
                                        SizedBox(width: AppSpacing.sm),
                                        Text(
                                          'Delete Label',
                                          style: TextStyle(
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),

                      AppSpacing.vGapMd,

                      // ---------------------------------------------------------
                      // Progress Bar & KPI Summary
                      // ---------------------------------------------------------
                      ClipRRect(
                        borderRadius: AppRadius.borderSm,
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: isDark
                              ? AppColors.surfaceVariantDark
                              : AppColors.surfaceVariantLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0 ? AppColors.statusDone : labelColor,
                          ),
                        ),
                      ),

                      AppSpacing.vGapSm,

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            totalTaskCount > 0
                                ? '$completedTaskCount/$totalTaskCount tasks completed • $percent%'
                                : 'No tasks assigned',
                            style: AppTypography.bodySmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (totalTaskCount > 0 && progress >= 1.0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 14,
                                  color: AppColors.statusDone,
                                ),
                                AppSpacing.hGapXxs,
                                Text(
                                  'Complete',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.statusDone,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
