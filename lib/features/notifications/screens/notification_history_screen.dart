import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../domain/models/notification_history_item.dart';
import '../providers/notification_history_provider.dart';
import '../services/notification_service.dart';

class NotificationHistoryScreen extends ConsumerStatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  ConsumerState<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState
    extends ConsumerState<NotificationHistoryScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final history = ref.watch(notificationHistoryProvider);
    final notifier = ref.read(notificationHistoryProvider.notifier);

    final unreadCount = history.where((n) => !n.isRead).length;

    final filtered = history.where((item) {
      if (_selectedFilter == 'unread') return !item.isRead;
      if (_selectedFilter == 'tasks') {
        return item.type == NotificationType.taskReminder ||
            item.type == NotificationType.hourlyNudge;
      }
      if (_selectedFilter == 'reports') {
        return item.type == NotificationType.dailyReport ||
            item.type == NotificationType.streakMilestone ||
            item.type == NotificationType.creatorCadence;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification History'),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text('Mark all read'),
              onPressed: () {
                notifier.markAllAsRead();
                context.showSnackBar('All notifications marked as read');
              },
            ),
          IconButton(
            icon: const Icon(Icons.notification_add_outlined, size: 20),
            tooltip: 'Send Test Notification',
            onPressed: () => _sendTestNotification(context),
          ),
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, size: 20),
              tooltip: 'Clear history',
              onPressed: () => _confirmClearHistory(context),
            ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All', 'all', history.length),
                const SizedBox(width: 8),
                _buildFilterChip('Unread', 'unread', unreadCount),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Task Alerts',
                  'tasks',
                  history
                      .where((n) =>
                          n.type == NotificationType.taskReminder ||
                          n.type == NotificationType.hourlyNudge)
                      .length,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Reports & Streaks',
                  'reports',
                  history
                      .where((n) =>
                          n.type == NotificationType.dailyReport ||
                          n.type == NotificationType.streakMilestone ||
                          n.type == NotificationType.creatorCadence)
                      .length,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(context, isDark)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _buildNotificationTile(
                          context, item, isDark, notifier);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Text('$label ($count)'),
      onSelected: (_) => setState(() => _selectedFilter = value),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    NotificationHistoryItem item,
    bool isDark,
    NotificationHistoryNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final typeColor = _colorForType(item.type);
    final iconData = _iconForType(item.type);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.statusCancelled.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.statusCancelled),
      ),
      onDismissed: (_) {
        notifier.deleteNotification(item.id);
        context.showSnackBar('Notification deleted');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: item.isRead
              ? (isDark ? AppColors.cardDark : AppColors.cardLight)
              : (isDark
                  ? AppColors.surfaceVariantDark.withValues(alpha: 0.4)
                  : AppColors.surfaceVariantLight.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: !item.isRead
                ? AppColors.primary.withValues(alpha: 0.35)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: !item.isRead ? 1.2 : 1.0,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () {
            if (!item.isRead) {
              notifier.markAsRead(item.id);
            }
            if (item.payload != null && item.payload!.isNotEmpty) {
              context.push(item.payload!);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(iconData, color: typeColor, size: 20),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    item.title,
                                    style: TextStyle(
                                      fontWeight: item.isRead
                                          ? FontWeight.w600
                                          : FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (!item.isRead) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            _formatRelativeTime(item.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          height: 1.3,
                        ),
                      ),
                      if (item.payload != null && item.payload!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              'Tap to view destination',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: typeColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 12, color: typeColor),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  onSelected: (val) {
                    if (val == 'toggle_read') {
                      notifier.markAsRead(item.id);
                    } else if (val == 'delete') {
                      notifier.deleteNotification(item.id);
                    }
                  },
                  itemBuilder: (ctx) => [
                    if (!item.isRead)
                      const PopupMenuItem(
                        value: 'toggle_read',
                        child: Text('Mark as read'),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariantLight)
                    .withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'You have no alerts matching this filter. All caught up!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.notification_add_outlined, size: 18),
              label: const Text('Send Test Alert'),
              onPressed: () => _sendTestNotification(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendTestNotification(BuildContext context) async {
    const title = 'Momentum Test Alert';
    const body = 'Your notification pipeline is working smoothly!';

    await NotificationService.instance.showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: title,
      body: body,
      payload: '/today',
    );

    await ref.read(notificationHistoryProvider.notifier).addNotification(
          title: title,
          body: body,
          type: NotificationType.system,
          payload: '/today',
        );

    if (context.mounted) {
      context.showSnackBar('Sent test notification and added to history');
    }
  }

  Future<void> _confirmClearHistory(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Notification History?'),
        content: const Text(
          'This will permanently delete all archived notifications from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.statusCancelled,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(notificationHistoryProvider.notifier).clearAll();
      if (context.mounted) {
        context.showSnackBar('Notification history cleared');
      }
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case NotificationType.taskReminder:
      case NotificationType.hourlyNudge:
        return AppColors.secondary;
      case NotificationType.dailyReport:
        return AppColors.tertiary;
      case NotificationType.streakMilestone:
      case NotificationType.creatorCadence:
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case NotificationType.taskReminder:
        return Icons.task_alt_rounded;
      case NotificationType.hourlyNudge:
        return Icons.alarm_rounded;
      case NotificationType.dailyReport:
        return Icons.auto_graph_rounded;
      case NotificationType.streakMilestone:
        return Icons.local_fire_department_rounded;
      case NotificationType.creatorCadence:
        return Icons.bolt_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  String _formatRelativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }
}
