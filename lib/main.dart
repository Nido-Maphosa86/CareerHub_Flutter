// lib/main.dart
//
// FILE SUMMARY (easy English)
// This is the entry point of the app. It starts CareerHub and sets up the look.
// It now defines two themes from the same deep-green seed colour: a light one
// and a dark one. themeMode: ThemeMode.system tells the app to follow the
// phone's own setting, so if the user turns on dark mode in their phone
// settings, CareerHub switches to dark automatically. Because every widget uses
// theme colour roles instead of fixed colours, dark mode "just works" with no
// extra code. The actual screen content lives in HomeScreen, which has moved
// into its own file under lib/screens/.

import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const CareerHubApp());
}

class CareerHubApp extends StatelessWidget {
  const CareerHubApp({super.key});

  // The one deliberate brand colour. Green reads as growth and "go", the feel
  // of an open opportunity; a deep shade keeps a career app calm and trustworthy.
  // Both the light and dark palettes are generated from this same seed.
  static const Color _seed = Color(0xFF15803D);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareerHub',
      debugShowCheckedModeBanner: false,

      // Light palette derived from the seed.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        useMaterial3: true,
      ),

      // Dark palette derived from the SAME seed, just with dark brightness.
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      // Follow whatever the phone's system setting is (light or dark).
      themeMode: ThemeMode.system,

      home: const HomeScreen(),
    );
  }
}
