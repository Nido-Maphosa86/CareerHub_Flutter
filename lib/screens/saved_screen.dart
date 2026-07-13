// lib/screens/saved_screen.dart
//
// The second tab. It is intentionally minimal for now: it exists so the app has a
// real second destination in the NavigationBar, which is what lets us prove that
// each tab keeps its own separate history and that switching tabs preserves the
// state of the one you left. Real saved-jobs functionality comes later.

import 'package:flutter/material.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved'),
        backgroundColor: scheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bookmark_outline, size: 48, color: scheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text('No saved jobs yet', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Jobs you save will appear here.',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
