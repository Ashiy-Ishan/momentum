import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
            currentPath: state.uri.path,
            body: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/today',
            builder: (context, state) => const TodayTasksScreen(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const AllTasksScreen(),
          ),
          GoRoute(
            path: '/tasks/new',
            builder: (context, state) => const TaskFormScreen(),
          ),
          GoRoute(
            path: '/tasks/:id/edit',
            builder: (context, state) {
              final taskId = state.pathParameters['id'];
              return TaskFormScreen(taskId: taskId);
            },
          ),
          GoRoute(
            path: '/labels',
            builder: (context, state) => const LabelsScreen(),
          ),
          GoRoute(
            path: '/labels/:id',
            builder: (context, state) {
              final labelId = state.pathParameters['id'] ?? '';
              return ParentLabelDashboardScreen(labelId: labelId);
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
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
