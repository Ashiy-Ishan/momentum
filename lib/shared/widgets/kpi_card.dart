import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../domain/enums/enums.dart';
import '../../domain/models/models.dart';

/// Next-Generation Dual-Horizon KPI Card for Creator & Platform Output.
///
/// Distinctive Features (Non-AI Aesthetics):
/// - Authentic Platform Identity badge (YouTube, Instagram, X/Twitter, Blog, LinkedIn).
/// - Metric Category tag: Video Generation, Post Publication, Blog Publication, Audience Growth.
/// - Dual-Horizon Progress:
///   1. Short-Term Cadence: Weekly / Monthly target run-rate (e.g., 2/3 videos this week).
///   2. Long-Term Milestone: Milestone tracker (e.g., 1,420 / 10,000 subscribers • 14.2%).
/// - Tactile Interactive Controls:
///   - "+1 Log" instant action button.
///   - "Update Count" numeric dialog for subscribers / followers.
/// - Status pill ("Cadence Met", "Ahead of Pace", "On Track", "Needs Focus").
class KpiCard extends StatelessWidget {
  final KpiDefinition kpi;
  final double? currentValue;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onIncrement;
  final ValueChanged<double>? onUpdateValue;
  final bool showCircularProgress;

  const KpiCard({
    super.key,
    required this.kpi,
    this.currentValue,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onIncrement,
    this.onUpdateValue,
    this.showCircularProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveCurrent = currentValue ?? kpi.currentValue;
    final shortTarget = kpi.targetValue;
    final shortProgress =
        shortTarget > 0 ? (effectiveCurrent / shortTarget).clamp(0.0, 1.0) : 0.0;
    final shortPct =
        shortTarget > 0 ? ((effectiveCurrent / shortTarget) * 100).round() : 0;
    final isShortTargetReached = shortTarget > 0 && effectiveCurrent >= shortTarget;

    // Long term milestone
    final hasLongTerm = kpi.hasLongTermTarget;
    final longTarget = kpi.longTermTarget ?? 0.0;
    final longProgress = (hasLongTerm && longTarget > 0)
        ? (effectiveCurrent / longTarget).clamp(0.0, 1.0)
        : 0.0;
    final longPct = (hasLongTerm && longTarget > 0)
        ? ((effectiveCurrent / longTarget) * 100).toStringAsFixed(1)
        : '0.0';

    final platformColor = AppColors.forPlatform(kpi.platform);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: isShortTargetReached
              ? AppColors.statusDone.withValues(alpha: isDark ? 0.45 : 0.6)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isShortTargetReached ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderMd,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------------------------------------------------
              // Header: Platform Badge + Metric Category + Menu
              // ---------------------------------------------------------------
              Row(
                children: [
                  if (kpi.platform != 'general') ...[
                    _PlatformBadge(
                      platform: kpi.platform,
                      color: platformColor,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                  ],
                  _PeriodTag(
                    period: kpi.period,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 6),
                  _TypeOrCategoryTag(
                    category: kpi.metricCategory,
                    kpiType: kpi.kpiType,
                    isDark: isDark,
                  ),
                  const Spacer(),
                  if (isShortTargetReached)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.statusDoneContainerDark
                            : AppColors.statusDoneContainerLight,
                        borderRadius: AppRadius.borderSm,
                        border: Border.all(
                          color: AppColors.statusDone.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 13,
                            color: AppColors.statusDone,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            kpi.metricCategory == 'video_generation' ||
                                    kpi.metricCategory == 'post_publication' ||
                                    kpi.metricCategory == 'blog_publication'
                                ? 'Cadence Met'
                                : 'Goal Met',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.statusDone,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_horiz_rounded,
                        size: 20,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      itemBuilder: (ctx) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 16),
                                SizedBox(width: 8),
                                Text('Edit KPI Target'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline,
                                    size: 16, color: AppColors.error),
                                SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(color: AppColors.error)),
                              ],
                            ),
                          ),
                      ],
                      onSelected: (val) {
                        if (val == 'edit') onEdit?.call();
                        if (val == 'delete') onDelete?.call();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // ---------------------------------------------------------------
              // KPI Name & Description
              // ---------------------------------------------------------------
              Text(
                kpi.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              if (kpi.description != null && kpi.description!.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  kpi.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 14),

              // ---------------------------------------------------------------
              // HORIZON 1: Short-Term Cadence Run-Rate
              // ---------------------------------------------------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatValue(effectiveCurrent, kpi.kpiType),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    kpi.kpiType == KpiType.time
                        ? '/ ${_formatValue(shortTarget, kpi.kpiType)}'
                        : '/ ${_formatValue(shortTarget)} ${kpi.unit}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: platformColor.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Text(
                      '$shortPct%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: platformColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Short-term segmented progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: shortProgress,
                  minHeight: 8,
                  backgroundColor: isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariantLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isShortTargetReached ? AppColors.statusDone : platformColor,
                  ),
                ),
              ),

              // ---------------------------------------------------------------
              // HORIZON 2: Long-Term Milestone Track (Subscribers / Catalog)
              // ---------------------------------------------------------------
              if (hasLongTerm) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark.withValues(alpha: 0.6)
                        : AppColors.surfaceVariantLight.withValues(alpha: 0.7),
                    borderRadius: AppRadius.borderSm,
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark.withValues(alpha: 0.5)
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.flag_outlined,
                                size: 14,
                                color: isDark
                                    ? AppColors.primaryLight
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Macro Milestone',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${_formatValue(effectiveCurrent)} / ${_formatValue(longTarget)} ($longPct%)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: longProgress,
                          minHeight: 5,
                          backgroundColor: isDark
                              ? AppColors.surfaceVariantDark
                              : AppColors.borderLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ---------------------------------------------------------------
              // Quick Actions: "+1 Quick Log" & "Update Count"
              // ---------------------------------------------------------------
              if (onIncrement != null || onUpdateValue != null) ...[
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (onIncrement != null)
                      FilledButton.tonalIcon(
                        icon: const Icon(Icons.add_circle_outline, size: 15),
                        label: Text(
                          _quickIncrementLabel(kpi.metricCategory, kpi.unit),
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: onIncrement,
                      ),
                    const SizedBox(width: 8),
                    if (onUpdateValue != null)
                      OutlinedButton.icon(
                        icon: const Icon(Icons.tune_rounded, size: 14),
                        label: const Text(
                          'Update Count',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () =>
                            _showUpdateCountDialog(context, effectiveCurrent),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdateCountDialog(BuildContext context, double current) {
    final controller = TextEditingController(
      text: current.toStringAsFixed(current.truncateToDouble() == current ? 0 : 1),
    );

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update ${kpi.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the latest recorded metric value (${kpi.unit}):',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Current Value (${kpi.unit})',
                suffixText: kpi.unit,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final val = double.tryParse(controller.text.trim());
              if (val != null) {
                onUpdateValue?.call(val);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save Count'),
          ),
        ],
      ),
    );
  }

  String _formatValue(double value, [KpiType? type]) {
    if (type == KpiType.time) {
      final totalMinutes = value.toInt();
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      if (hours > 0 && minutes > 0) {
        return '${hours}h ${minutes}m';
      } else if (hours > 0) {
        return '${hours}h';
      } else {
        return '${minutes}m';
      }
    }
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    } else if (value.truncateToDouble() == value) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  String _quickIncrementLabel(String category, String unit) {
    switch (category) {
      case 'video_generation':
        return '+1 Video';
      case 'post_publication':
        return '+1 Post';
      case 'blog_publication':
        return '+1 Article';
      case 'subscriber_growth':
        return '+10 Subs';
      case 'follower_growth':
        return '+10 Followers';
      default:
        return '+1 $unit';
    }
  }
}

// =============================================================================
// SUB-WIDGETS: PLATFORM BADGE & CATEGORY TAGS
// =============================================================================

class _PlatformBadge extends StatelessWidget {
  final String platform;
  final Color color;
  final bool isDark;

  const _PlatformBadge({
    required this.platform,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, label) = _getPlatformMeta(platform);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.12),
        borderRadius: AppRadius.borderSm,
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  (IconData, String) _getPlatformMeta(String p) {
    switch (p.toLowerCase()) {
      case 'youtube':
        return (Icons.play_circle_filled_rounded, 'YouTube');
      case 'instagram':
        return (Icons.camera_alt_rounded, 'Instagram');
      case 'twitter':
      case 'x':
        return (Icons.tag_rounded, 'X / Twitter');
      case 'blog':
      case 'medium':
      case 'devto':
        return (Icons.article_rounded, 'Blog / Writing');
      case 'linkedin':
        return (Icons.business_center_rounded, 'LinkedIn');
      case 'tiktok':
        return (Icons.music_video_rounded, 'TikTok');
      default:
        return (Icons.insights_rounded, 'Focus Metric');
    }
  }
}

class _PeriodTag extends StatelessWidget {
  final KpiPeriod period;
  final bool isDark;

  const _PeriodTag({
    required this.period,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        period.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}

class _TypeOrCategoryTag extends StatelessWidget {
  final String category;
  final KpiType kpiType;
  final bool isDark;

  const _TypeOrCategoryTag({
    required this.category,
    required this.kpiType,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final label = category != 'output'
        ? _categoryDisplayName(category)
        : kpiType.displayName;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  String _categoryDisplayName(String cat) {
    switch (cat) {
      case 'video_generation':
        return 'Video Production';
      case 'post_publication':
        return 'Publishing Cadence';
      case 'blog_publication':
        return 'Articles';
      case 'subscriber_growth':
        return 'Audience';
      case 'follower_growth':
        return 'Followers';
      case 'time_invested':
        return 'Time Invested';
      default:
        return 'Output';
    }
  }
}
