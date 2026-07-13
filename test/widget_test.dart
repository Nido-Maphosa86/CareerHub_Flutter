// test/widget_test.dart
//
// 
// These tests check the real CareerHub screen. Two things changed from the last
// assignment, and both were predicted in Question 4 of the README.
//
// First, HomeScreen is now a ConsumerWidget, so it needs Riverpod's state
// container above it in the tree. Every pumped widget is therefore wrapped in a
// ProviderScope, or the test would throw before drawing anything.
//
// Second, the jobs now arrive after a simulated 1.5 second delay. A freshly
// pumped widget only shows the loading spinner, so any test that wants to see
// job cards must first push fake time forward past that delay with
// tester.pump(Duration(...)). Tests run on a fake clock, so this takes no real
// time at all.
//
// The tests cover: the spinner appears then disappears, all four cards render,
// the status badges are correct, the salary and type pills render, and tapping
// a filter chip narrows the list.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careerhub/main.dart';

// Anything longer than the provider's 1500ms delay will do.
const Duration _pastTheDelay = Duration(seconds: 2);

// Every test pumps the app through this, so the ProviderScope is never missed.
Widget _app() => const ProviderScope(child: CareerHubApp());

void main() {
  testWidgets('shows a spinner while loading, then hides it', (tester) async {
    await tester.pumpWidget(_app());

    // First frame: the future has not completed, so we are in the loading state.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Push fake time past the simulated network delay.
    await tester.pump(_pastTheDelay);

    // The spinner is gone and real content has taken its place.
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

    // Exactly one job in the list is closed; the other three are open.
    expect(find.text('Closed'), findsOneWidget);
    expect(find.text('Open'), findsNWidgets(3));
  });

  testWidgets('salary and employment type pills render safely', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pump(_pastTheDelay);

    // The job with no salary falls back to the getter's default.
    expect(find.text('Market-related'), findsOneWidget);
    // The raw word "null" must never reach the screen.
    expect(find.text('null'), findsNothing);
    // The employment type pill of the internship job.
    expect(find.text('Internship'), findsOneWidget);
  });

  testWidgets('tapping Remote filters the list, All restores it',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pump(_pastTheDelay);

    // Start with everything visible.
    expect(find.text('Senior Flutter Developer'), findsOneWidget);

    // Tap the Remote chip. Only the Luno job is remote.
    await tester.tap(find.widgetWithText(ChoiceChip, 'Remote'));
    await tester.pump();

    expect(find.text('Flutter Developer'), findsOneWidget);
    expect(find.text('Senior Flutter Developer'), findsNothing);
    expect(find.text('Backend Engineer (.NET)'), findsNothing);

    // Tap All to bring the full list back.
    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pump();

    expect(find.text('Senior Flutter Developer'), findsOneWidget);
    expect(find.text('Backend Engineer (.NET)'), findsOneWidget);
  });
}
