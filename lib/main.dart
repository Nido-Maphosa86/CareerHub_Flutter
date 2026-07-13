// lib/main.dart
//
// FILE SUMMARY 
// This is the entry point of the app. Two jobs here.
//
// First, it wraps the whole app in a ProviderScope. That is the container where
// Riverpod keeps every provider's value. Without it, any widget that tries to
// read state would throw, because there would be nowhere for that state to live.
// It must sit above everything, so it goes around the root widget itself.
//
// Second, it sets up the look: a light theme and a dark theme built from the
// same deep-green seed colour, with themeMode: ThemeMode.system so the app
// follows whatever the phone is set to. Because every widget uses theme colour
// roles instead of fixed colours, dark mode needs no extra code anywhere else.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/home_screen.dart';

void main() {
  // ProviderScope holds the state for every provider in the app.
  runApp(const ProviderScope(child: CareerHubApp()));
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
