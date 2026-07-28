// lib/main.dart
//
// App entry point. main() is async because three I/O operations must complete
// before the first widget builds: the documents directory lookup (needed by
// Isar), the Isar database open, and the SharedPreferences load. Both the Isar
// instance and the SharedPreferences instance are injected into the provider
// graph via overrideWithValue so every provider that needs them receives the
// already-initialised object rather than trying to open it lazily.
//
// The root widget changed from StatelessWidget to ConsumerWidget in this
// assignment so it can watch appRouterProvider. The router is now a @riverpod
// provider so it participates in the Riverpod dependency graph and rebuilds
// its redirect logic whenever authStateListenableProvider notifies listeners.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/isar_provider.dart';
import 'core/prefs_provider.dart';
import 'data/job_cache.dart';
import 'router/app_router.dart';

Future<void> main() async {
  // Must be the very first statement in an async main(). Creates the
  // WidgetsBinding singleton that manages the Dart-to-platform message channel.
  // Without it, any platform channel call (getApplicationDocumentsDirectory,
  // Isar.open, SharedPreferences.getInstance) throws immediately.
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();

  final isar = await Isar.open(
    [JobCacheSchema],
    directory: dir.path,
  );

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Replace the placeholder providers with the real, opened instances
        // before any widget or provider reads them.
        isarProvider.overrideWithValue(isar),
        prefsProvider.overrideWithValue(prefs),
      ],
      child: const CareerHubApp(),
    ),
  );
}

// ConsumerWidget so it can call ref.watch(appRouterProvider). The router is a
// @riverpod provider that watches authStateListenableProvider — when auth state
// changes the router rebuilds its redirect callback and the route updates.
class CareerHubApp extends ConsumerWidget {
  const CareerHubApp({super.key});

  static const Color _seed = Color(0xFF15803D);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'CareerHub',
      debugShowCheckedModeBanner: false,
      // Watch the router provider so the app picks up any router rebuild
      // (triggered by auth state changes) without needing a hot restart.
      routerConfig: ref.watch(appRouterProvider),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
    );
  }
}
