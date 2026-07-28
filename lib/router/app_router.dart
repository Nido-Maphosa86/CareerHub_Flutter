// lib/router/app_router.dart
//
// The app router is now a @riverpod provider so it participates in the
// dependency graph and can watch authStateListenableProvider. When auth state
// changes (login, logout, token expiry), AuthStateListenable calls
// notifyListeners(), GoRouter re-evaluates the redirect callback, and the
// route changes automatically — no navigation code needed in the login screen
// or the logout button.
//
// The redirect callback uses ref.read (not ref.watch) for authProvider.
// ref.watch inside a callback that is called by GoRouter (not by Riverpod's
// build system) would subscribe the provider to Riverpod's listener graph but
// outside a widget build context, causing a rebuild cycle where every auth state
// change triggers another redirect triggers another state read triggers another
// redirect — the symptom is the app flickering between routes endlessly.
// ref.read reads the current value once without subscribing.

import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/auth_state.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_provider.dart';
import '../screens/home_screen.dart';
import '../screens/job_detail_screen.dart';
import '../screens/login_screen.dart';
import '../screens/saved_screen.dart';
import '../widgets/scaffold_with_nav_bar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  // Watch the ChangeNotifier bridge so GoRouter re-evaluates its redirect every
  // time auth state changes. refreshListenable accepts any Listenable — the
  // AuthStateListenable wraps authProvider in one.
  final listenable = ref.watch(authStateListenableProvider);

  return GoRouter(
    initialLocation: '/jobs',
    refreshListenable: listenable,
    redirect: (context, state) {
      // ref.read — not ref.watch — inside a redirect callback. See file header.
      final authAsync = ref.read(authProvider);

      // During the cold-boot token check, authProvider is loading.
      // Return null to stay on the current route and avoid premature navigation
      // to /login before the check has completed.
      if (authAsync.isLoading) return null;

      final authState = authAsync.hasValue ? authAsync.value : null;
      final isAuthenticated = authState is Authenticated;
      final isOnLogin = state.matchedLocation == '/login';

      // Not authenticated and not already on the login screen — redirect there.
      if (!isAuthenticated && !isOnLogin) return '/login';

      // Authenticated and sitting on the login screen — push to jobs.
      if (isAuthenticated && isOnLogin) return '/jobs';

      // No redirect needed.
      return null;
    },
    routes: [
      // The login screen lives OUTSIDE the StatefulShellRoute so it has no
      // bottom navigation bar. A user who is not authenticated should never
      // see the nav bar or be able to switch to other tabs.
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // The shell owns the two authenticated tabs. indexedStack keeps every
      // tab alive simultaneously so scroll position and navigation history
      // survive tab switches.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Jobs tab with the detail screen nested inside it.
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
                  ),
                ],
              ),
            ],
          ),

          // Branch 1: Saved tab.
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