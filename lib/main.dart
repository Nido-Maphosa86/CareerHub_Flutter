// lib/main.dart
//
// This is the entry point of the app. It wraps everything in a ProviderScope so
// Riverpod state has a home, and it now hands routing over to GoRouter through
// MaterialApp.router. There is no home: property any more, because which screen
// shows is decided by the current URL and the router, not by a single fixed home
// widget. The light and dark themes are unchanged: both come from the same green
// seed and the app follows the phone's system setting.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: CareerHubApp()));
}

class CareerHubApp extends StatelessWidget {
  const CareerHubApp({super.key});

  // The one deliberate brand colour. Both palettes are generated from this seed.
  static const Color _seed = Color(0xFF15803D);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CareerHub',
      debugShowCheckedModeBanner: false,

      // Routing configuration replaces home:. The router decides the screen.
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
