// test/widget_test.dart
//
// These tests check the real CareerHub app. Because the app now uses
// MaterialApp.router, the widget tree is built by GoRouter from its
// initialLocation of /jobs, so pumping the app lands straight on the jobs list
// with no navigation needed. Each test still wraps the app in a ProviderScope so
// Riverpod has a home, and still advances fake time past the simulated 1.5 second
// load before checking for job cards. New in this assignment: the NavigationBar
// destinations ("Jobs" and "Saved") are now text in the tree, so they are
// asserted too.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careerhub/main.dart';

const Duration _pastTheDelay = Duration(seconds: 2);

Widget _app() => const ProviderScope(child: CareerHubApp());

void main() {
  testWidgets('starts on the jobs tab and shows the nav bar', (tester) async {
    await tester.pumpWidget(_app());

    // GoRouter's initialLocation is /jobs, so the list screen is already here.
    // The NavigationBar destinations are visible immediately.
    expect(find.text('Jobs'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('shows a spinner while loading, then hides it', (tester) async {
    await tester.pumpWidget(_app());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(_pastTheDelay);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Senior Flutter Developer'), findsOneWidget);
  });

  testWidgets('renders all four job cards once loaded', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pump(_pastTheDelay);

    expect(find.text('Senior Flutter Developer'), findsOneWidget);
    expect(find.text('Junior Mobile Developer'), findsOneWidget);
    expect(find.text('Backend Engineer (.NET)'), findsOneWidget);
    expect(find.text('Flutter Developer'), findsOneWidget);
  });

  testWidgets('status badges reflect each job state', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pump(_pastTheDelay);

    expect(find.text('Closed'), findsOneWidget);
    expect(find.text('Open'), findsNWidgets(3));
  });

  testWidgets('salary and type pills render safely', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pump(_pastTheDelay);

    expect(find.text('Market-related'), findsOneWidget);
    expect(find.text('null'), findsNothing);
    expect(find.text('Internship'), findsOneWidget);
  });

  testWidgets('tapping a card opens its detail screen', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pump(_pastTheDelay);

    // Tap the first job card.
    await tester.tap(find.text('Senior Flutter Developer'));
    await tester.pumpAndSettle();

    // The detail screen shows its own app bar title and the full description.
    expect(find.text('Job details'), findsOneWidget);
    expect(find.text('About the role'), findsOneWidget);
  });
}
