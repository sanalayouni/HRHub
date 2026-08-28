import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/decision_history/decision_history_screen.dart';
import 'screens/employees/employee_directory_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/request_detail/request_detail_screen.dart';
import 'screens/requests/requests_screen.dart';
import 'screens/shell/app_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // Bridges the auth state into something GoRouter can listen to, so logging
  // in or being 401'd re-runs the redirect.
  final authChanged = ValueNotifier(ref.read(authProvider));
  ref.listen(authProvider, (_, next) => authChanged.value = next);
  ref.onDispose(authChanged.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: authChanged,
    redirect: (context, state) {
      final loggedIn = ref.read(authProvider);
      final atLogin = state.matchedLocation == '/login';
      if (!loggedIn) return atLogin ? null : '/login';
      if (atLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', builder: (context, state) => const DashboardScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/requests', builder: (context, state) => const RequestsScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/decisions',
                builder: (context, state) => const DecisionHistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/employees',
                builder: (context, state) => const EmployeeDirectoryScreen(),
              ),
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
});
