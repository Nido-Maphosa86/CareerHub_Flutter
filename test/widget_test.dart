// test/widget_test.dart
//
// FILE SUMMARY (easy English)
// This replaces the default counter smoke test. It builds the real CareerHub
// app and checks the things that matter: the app bar title shows, a known job
// renders, the job with no salary reads "Market-related" and never "null", and
// there is one "Closed" badge alongside "Open" ones. It works whether the test
// window is narrow (list) or wide (grid), because it only checks the content of
// the cards, not the layout they sit in.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careerhub/main.dart';

void main() {
  testWidgets('CareerHub home screen renders the job list', (tester) async {
    await tester.pumpWidget(const CareerHubApp());
    await tester.pumpAndSettle();

    // Title proves the app is not "Flutter Demo".
    expect(find.text('CareerHub'), findsWidgets);

    // A known fully populated job is on screen.
    expect(find.text('Senior Flutter Developer'), findsOneWidget);

    // The no-salary job falls back to "Market-related", never "null".
    expect(find.text('Market-related'), findsOneWidget);
    expect(find.text('null'), findsNothing);

    // The closed job is flagged, so exactly one "Closed" badge exists.
    expect(find.text('Closed'), findsOneWidget);

    // Open jobs are flagged too.
    expect(find.text('Open'), findsWidgets);
  });
}
