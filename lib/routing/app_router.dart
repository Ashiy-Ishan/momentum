import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/models/models.dart';
import '../features/analytics/screens/analytics_screen.dart';
import '../features/calendar/screens/calendar_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/labels/screens/labels_screen.dart';
import '../features/labels/screens/parent_label_dashboard_screen.dart';
import '../features/labels/screens/sub_label_dashboard_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/tasks/screens/all_tasks_screen.dart';
import '../features/tasks/screens/task_form_screen.dart';
import '../features/tasks/screens/today_tasks_screen.dart';
import '../shared/widgets/app_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppScaffold(
            key: const ValueKey('shell_scaffold'),
            currentPath: state.uri.path,
            body: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/today',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const TodayTasksScreen(),
            ),
          ),
          GoRoute(
            path: '/tasks',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const AllTasksScreen(),
            ),
          ),
          GoRoute(
            path: '/tasks/new',
            builder: (context, state) {
              Task? initialTask;
              String? parentLabelId;
              String? subLabelId;
              DateTime? defaultScheduledDate;
              String? taskId;

              final extra = state.extra;
              if (extra is Task) {
                initialTask = extra;
              } else if (extra is Map) {
                if (extra['initialTask'] is Task) {
                  initialTask = extra['initialTask'] as Task;
                } else if (extra['task'] is Task) {
                  initialTask = extra['task'] as Task;
                }

                parentLabelId = extra['parentLabelId']?.toString() ??
                    extra['defaultParentLabelId']?.toString();

                subLabelId = extra['subLabelId']?.toString() ??
                    extra['defaultLabelId']?.toString() ??
                    extra['labelId']?.toString();

                final dateVal =
                    extra['defaultScheduledDate'] ?? extra['scheduledDate'];
                if (dateVal is DateTime) {
                  defaultScheduledDate = dateVal;
                } else if (dateVal is String) {
                  defaultScheduledDate = DateTime.tryParse(dateVal);
                }

                taskId = extra['taskId']?.toString();
              } else if (extra is DateTime) {
                defaultScheduledDate = extra;
              }

              // Fallback to query parameters if extra was not provided
              parentLabelId ??= state.uri.queryParameters['parentLabelId'] ??
                  state.uri.queryParameters['defaultParentLabelId'];
              subLabelId ??= state.uri.queryParameters['subLabelId'] ??
                  state.uri.queryParameters['defaultLabelId'] ??
                  state.uri.queryParameters['labelId'];
              if (defaultScheduledDate == null) {
                final dateParam =
                    state.uri.queryParameters['defaultScheduledDate'] ??
                        state.uri.queryParameters['scheduledDate'] ??
                        state.uri.queryParameters['date'];
                if (dateParam != null) {
                  defaultScheduledDate = DateTime.tryParse(dateParam);
                }
              }

              return TaskFormScreen(
                taskId: taskId,
                initialTask: initialTask,
                defaultParentLabelId: parentLabelId,
                defaultLabelId: subLabelId,
                defaultScheduledDate: defaultScheduledDate,
              );
            },
          ),
          GoRoute(
            path: '/tasks/edit/:id',
            builder: (context, state) {
              final taskId = state.pathParameters['id'];
              final task = state.extra is Task ? state.extra as Task : null;
              return TaskFormScreen(
                taskId: taskId,
                initialTask: task,
              );
            },
          ),
          GoRoute(
            path: '/tasks/:id/edit',
            builder: (context, state) {
              final taskId = state.pathParameters['id'];
              final task = state.extra is Task ? state.extra as Task : null;
              return TaskFormScreen(
                taskId: taskId,
                initialTask: task,
              );
            },
          ),
          GoRoute(
            path: '/labels',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const LabelsScreen(),
            ),
          ),
          GoRoute(
            path: '/labels/parent/:id',
            builder: (context, state) {
              final labelId = state.pathParameters['id'] ?? '';
              return ParentLabelDashboardScreen(labelId: labelId);
            },
          ),
          GoRoute(
            path: '/labels/sub/:id',
            builder: (context, state) {
              final subLabelId = state.pathParameters['id'] ?? '';
              return SubLabelDashboardScreen(labelId: subLabelId);
            },
          ),
          GoRoute(
            path: '/labels/:parentId/sub/:id',
            builder: (context, state) {
              final subLabelId = state.pathParameters['id'] ?? '';
              return SubLabelDashboardScreen(labelId: subLabelId);
            },
          ),
          GoRoute(
            path: '/labels/:id',
            builder: (context, state) {
              final labelId = state.pathParameters['id'] ?? '';
              return ParentLabelDashboardScreen(labelId: labelId);
            },
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const AnalyticsScreen(),
            ),
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CalendarScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => NotFoundScreen(path: state.uri.path),
  );
});

/// User-friendly, Material 3 404 Page Not Found view wrapped inside [AppScaffold].
class NotFoundScreen extends StatelessWidget {
  final String path;

  const NotFoundScreen({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      key: const ValueKey('error_scaffold'),
      currentPath: path,
      showFab: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color:
                        theme.colorScheme.errorContainer.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.explore_off_outlined,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Page Not Found',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'The requested page "$path" could not be found or may have moved.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.dashboard_outlined),
                      label: const Text('Return to Dashboard'),
                      onPressed: () => context.go('/'),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Go Back'),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
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
}
