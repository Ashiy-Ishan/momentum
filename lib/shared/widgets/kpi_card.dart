import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/enums/enums.dart';
import '../../domain/models/models.dart';

/// Reusable KPI metric tracking card.
///
/// Displays:
/// - KPI Name & Description
/// - Target value vs Current value
/// - Progress bar and circular indicator
/// - Percentage completed
/// - Period badge (Daily / Weekly / Monthly)
/// - Metric type badge (Count / Rate / Time)
/// - Target reached celebration state
class KpiCard extends StatelessWidget {
  final KpiDefinition kpi;
  final double currentValue;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showCircularProgress;

  const KpiCard({
    super.key,
    required this.kpi,
    this.currentValue = 0.0,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showCircularProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final target = kpi.targetValue;
    final progress = target > 0 ? (currentValue / target).clamp(0.0, 1.0) : 0.0;
    final percentage = target > 0 ? ((currentValue / target) * 100).round() : 0;
    final isTargetReached = target > 0 && currentValue >= target;

    // Determine indicator color
    final progressColor = isTargetReached
        ? AppColors.statusDone
        : (percentage >= 50 ? AppColors.primary : AppColors.secondary);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
        side: BorderSide(
          color: isTargetReached
              ? (isDark
                  ? AppColors.statusDone.withAlpha(120)
                  : AppColors.statusDone.withAlpha(100))
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isTargetReached ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderMd,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------------------------------------------------
              // Header: Period & Type Badges + Actions Menu
              // ---------------------------------------------------------------
              Row(
                children: [
                  _KpiBadge(
                    icon: _periodIcon(kpi.period),
                    label: kpi.period.displayName,
                    color: isDark
                        ? AppColors.primaryLight
                        : AppColors.primary,
                    backgroundColor: isDark
                        ? AppColors.primaryContainerDark
                        : AppColors.primaryContainerLight,
                  ),
                  AppSpacing.hGapXs,
                  _KpiBadge(
                    icon: _typeIcon(kpi.kpiType),
                    label: kpi.kpiType.displayName,
                    color: isDark
                        ? AppColors.secondaryLight
                        : AppColors.secondary,
                    backgroundColor: isDark
                        ? AppColors.secondaryContainerDark
                        : AppColors.secondaryContainerLight,
                  ),
                  const Spacer(),
                  if (isTargetReached)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.statusDoneContainerDark
                            : AppColors.statusDoneContainerLight,
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: isDark
                                ? AppColors.onStatusDoneDark
                                : AppColors.onStatusDoneLight,
                          ),
                          AppSpacing.hGapXxs,
                          Text(
                            'Goal Met',
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.onStatusDoneDark
                                  : AppColors.onStatusDoneLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: 'KPI Actions',
                      onSelected: (val) {
                        if (val == 'edit') onEdit?.call();
                        if (val == 'delete') onDelete?.call();
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18),
                                SizedBox(width: AppSpacing.sm),
                                Text('Edit KPI'),
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
                                  'Delete KPI',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),

              AppSpacing.vGapSm,

              // ---------------------------------------------------------------
              // KPI Title & Description
              // ---------------------------------------------------------------
              Text(
                kpi.name,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              if (kpi.description != null && kpi.description!.isNotEmpty) ...[
                AppSpacing.vGapXxs,
                Text(
                  kpi.description!,
                  style: AppTypography.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              AppSpacing.vGapMd,

              // ---------------------------------------------------------------
              // Values & Progress Indicator
              // ---------------------------------------------------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _formatValue(currentValue, kpi.kpiType),
                              style: AppTypography.headlineSmall.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            AppSpacing.hGapXs,
                            Text(
                              '/ ${_formatValue(target, kpi.kpiType)}',
                              style: AppTypography.bodyMedium.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.vGapSm,
                        ClipRRect(
                          borderRadius: AppRadius.borderSm,
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: isDark
                                ? AppColors.surfaceVariantDark
                                : AppColors.surfaceVariantLight,
                            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (showCircularProgress) ...[
                    AppSpacing.hGapLg,
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 4.5,
                            backgroundColor: isDark
                                ? AppColors.surfaceVariantDark
                                : AppColors.surfaceVariantLight,
                            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                          ),
                          Text(
                            '$percentage%',
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatValue(double val, KpiType type) {
    switch (type) {
      case KpiType.count:
        return val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
      case KpiType.rate:
        return '${val.toStringAsFixed(0)}%';
      case KpiType.time:
        return AppDateUtils.formatDuration(Duration(minutes: val.toInt()));
    }
  }

  IconData _periodIcon(KpiPeriod period) {
    switch (period) {
      case KpiPeriod.daily:
        return Icons.today_rounded;
      case KpiPeriod.weekly:
        return Icons.view_week_rounded;
      case KpiPeriod.monthly:
        return Icons.calendar_month_rounded;
      case KpiPeriod.custom:
        return Icons.tune_rounded;
    }
  }

  IconData _typeIcon(KpiType type) {
    switch (type) {
      case KpiType.count:
        return Icons.pin_rounded;
      case KpiType.rate:
        return Icons.percent_rounded;
      case KpiType.time:
        return Icons.timer_outlined;
    }
  }
}

class _KpiBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;

  const _KpiBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3.0,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          AppSpacing.hGapXxs,
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
