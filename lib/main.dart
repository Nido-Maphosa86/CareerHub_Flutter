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
        isarProvider.overrideWithValue(isar),
        prefsProvider.overrideWithValue(prefs),
      ],
      child: const CareerHubApp(),
    ),
  );
}

class CareerHubApp extends StatelessWidget {
  const CareerHubApp({super.key});

  static const Color _seed = Color(0xFF15803D);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CareerHub',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
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
