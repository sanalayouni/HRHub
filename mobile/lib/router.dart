import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/decision_history/decision_history_screen.dart';
import 'screens/request_detail/request_detail_screen.dart';
import 'screens/shell/app_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/decisions', builder: (context, state) => const DecisionHistoryScreen()),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/requests/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => RequestDetailScreen(requestId: state.pathParameters['id']!),
    ),
  ],
);
