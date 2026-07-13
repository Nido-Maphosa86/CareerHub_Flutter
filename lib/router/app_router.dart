// lib/router/app_router.dart
//
// This file defines every screen the app can show and the URL that reaches it.
// It builds one GoRouter that starts at /jobs. A StatefulShellRoute gives the app
// its two persistent tabs (Jobs and Saved): each tab keeps its own separate
// navigation history, so switching tabs never throws away where you were. The job
// detail route (/jobs/:id) is nested inside the Jobs tab, which is why the bottom
// bar stays visible on a detail screen and why the back button returns to the
// list. The :id in the path is a placeholder filled in with a real job id at
// navigation time.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/job_detail_screen.dart';
import '../screens/saved_screen.dart';
import '../widgets/scaffold_with_nav_bar.dart';

// A single app-wide router instance.
final GoRouter appRouter = GoRouter(
  initialLocation: '/jobs',
  routes: [
    // The shell owns the tabs. indexedStack keeps every tab alive at once, so a
    // tab's scroll position and stack survive while another tab is on screen.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // The frame (nav bar + current tab) is drawn by the shell widget.
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: the Jobs tab, with the detail screen nested underneath it.
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/jobs',
              builder: (context, state) => const HomeScreen(),
              routes: [
                // Nested, so it lives "inside" /jobs. Back from here returns to
                // the list even when the app was opened straight to this URL.
                GoRoute(
                  path: ':id', // full path is /jobs/:id
                  builder: (context, state) {
                    // Read the id out of the URL. It arrives as text, so parse it
                    // to an int; if it is missing or not a number, fall back to a
                    // value no job has (-1) so the screen shows its not-found UI
                    // rather than crashing.
                    final idText = state.pathParameters['id'];
                    final id = int.tryParse(idText ?? '') ?? -1;
                    return JobDetailScreen(jobId: id);
                  },
                ),
              ],
            ),
          ],
        ),

        // Branch 1: the Saved tab.
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
