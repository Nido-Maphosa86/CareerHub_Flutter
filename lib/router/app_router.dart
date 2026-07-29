// lib/router/app_router.dart
//
// Assignment 3.1 adds the /jobs/:id/apply route as a child of the detail
// route. The full path is /jobs/:id/apply. The literal segment 'apply' is
// matched before any parameterised segment at the same level, so it does not
// conflict with ':id'.

import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/auth_state.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_provider.dart';
import '../screens/apply_screen.dart';
import '../screens/home_screen.dart';
import '../screens/job_detail_screen.dart';
import '../screens/login_screen.dart';
import '../screens/saved_screen.dart';
import '../widgets/scaffold_with_nav_bar.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final listenable = ref.watch(authStateListenableProvider);

  return GoRouter(
    initialLocation: '/jobs',
    refreshListenable: listenable,
    redirect: (context, state) {
      final authAsync = ref.read(authProvider);
      if (authAsync.isLoading) return null;

      final authState = authAsync.hasValue ? authAsync.value : null;
      final isAuthenticated = authState is Authenticated;
      final isOnLogin = state.matchedLocation == '/login';

      if (!isAuthenticated && !isOnLogin) return '/login';
      if (isAuthenticated && isOnLogin) return '/jobs';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/jobs',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return JobDetailScreen(jobId: id);
                    },
                    routes: [
                      // Apply route nested inside the detail route so the job
                      // ID is available in pathParameters. The id is passed
                      // explicitly to ApplyScreen so it can reference the job
                      // without re-fetching the entire list.
                      GoRoute(
                        path: 'apply',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return ApplyScreen(jobId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/saved',
                builder: (context, state) => const SavedScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}