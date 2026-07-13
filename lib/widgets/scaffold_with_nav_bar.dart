// lib/widgets/scaffold_with_nav_bar.dart
//
// This is the frame that stays on screen while the user moves between tabs. It
// holds the NavigationBar at the bottom and shows whichever tab's content is
// currently active above it. It owns no state of its own: which tab looks
// selected comes from the router (navigationShell.currentIndex), not from a local
// variable, so the bar and the visible screen can never disagree. Tapping a tab
// asks the router to switch branches; tapping the tab you are already on resets
// that tab back to its root instead of doing nothing.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  // The shell hands us this object. It knows the current tab and how to switch.
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body is whatever screen the active branch is showing right now.
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        // Selected index comes straight from the router's state.
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Jobs',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
        ],
      ),
    );
  }

  void _onTap(int index) {
    // goBranch switches to the chosen tab. initialLocation resets that tab's own
    // history to its root, but only when the tapped tab is already the active one
    // (the standard "tap the current tab to go back to its start" behaviour).
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
