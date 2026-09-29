import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/time/local_date.dart';
import '../features/activities/presentation/activity_form_screen.dart';
import '../features/calendar/presentation/calendar_screen.dart';
import '../features/daily_summary/presentation/daily_summary_screen.dart';
import '../features/goals/presentation/goals_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'routes.dart';
import 'shell/app_shell.dart';

/// Navigator hosting full-screen routes above the bottom navigation.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// The app router: a stateful shell with three branches plus root routes.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.home,
    routes: [
      StatefulShellRoute(
        builder: (context, state, shell) => shell,
        navigatorContainerBuilder: (context, shell, children) =>
            AppShell(navigationShell: shell, children: children),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.calendar, builder: (context, state) => const CalendarScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.home, builder: (context, state) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.goals, builder: (context, state) => const GoalsScreen())],
          ),
        ],
      ),
      GoRoute(
        path: Routes.settings,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/activity/new',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final date = state.uri.queryParameters['date'];
          return ActivityFormScreen(
            initialName: state.uri.queryParameters['name'],
            initialDate: date == null ? null : LocalDate.parse(date),
          );
        },
      ),
      GoRoute(
        path: '/activity/:id/edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => ActivityFormScreen(activityId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/day/:date',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            DailySummaryScreen(date: LocalDate.parse(state.pathParameters['date']!)),
      ),
    ],
  );
});
