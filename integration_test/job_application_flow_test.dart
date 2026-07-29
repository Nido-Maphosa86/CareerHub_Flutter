// integration_test/job_application_flow_test.dart
//
// Patrol integration test that drives the complete job application user journey
// against the real running app and API. Unlike widget tests, this test runs
// on a real compiled APK on a real or emulated device — it can interact with
// native OS dialogs, the Material date picker, and real network calls.
//
// Prerequisites:
//   1. dart pub global activate patrol_cli
//   2. The CareerHub API running at 10.0.2.2:5000 (or the --dart-define value)
//   3. A connected Android emulator or device
//
// Run with:
//   patrol test --target integration_test/job_application_flow_test.dart \
//     --dart-define=API_BASE_URL=http://10.0.2.2:5000

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:careerhub/main.dart' as app;

void main() {
  patrolTest(
    'complete job application flow from cold launch to submission',
    ($) async {
      // ----------------------------------------------------------------
      // Step 1 — Cold launch. No stored token so GoRouter redirects to /login.
      // ----------------------------------------------------------------
      app.main();
      await $.pumpAndSettle();

      expect(find.text('CareerHub'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);

      // ----------------------------------------------------------------
      // Step 2 — Login with seed credentials.
      // ----------------------------------------------------------------
      await $(find.byType(TextField).first).enterText('alice@example.com');
      await $(find.byType(TextField).last).enterText('password123');
      await $('Sign in').tap();
      await $.pumpAndSettle();

      // ----------------------------------------------------------------
      // Step 3 — Jobs screen. At least one job card must be visible.
      // ----------------------------------------------------------------
      expect(find.text('CareerHub'), findsOneWidget);

      await $.pumpAndSettle(timeout: const Duration(seconds: 5));

      await $(find.byType(Card)).first.tap();
      await $.pumpAndSettle();

      // ----------------------------------------------------------------
      // Step 4 — Job detail screen.
      // ----------------------------------------------------------------
      expect(find.text('Job details'), findsOneWidget);

      // ----------------------------------------------------------------
      // Step 5 — Navigate to the apply screen.
      // ----------------------------------------------------------------
      await $('Apply for this job').tap();
      await $.pumpAndSettle();

      // ----------------------------------------------------------------
      // Step 6 — Apply screen. Email must be pre-populated from auth state.
      // ----------------------------------------------------------------
      expect(find.text('Apply for this job'), findsOneWidget);
      expect(find.textContaining('@'), findsOneWidget);

      // ----------------------------------------------------------------
      // Step 7 — Fill the required form fields.
      // ----------------------------------------------------------------
      await $(find.widgetWithText(
        TextField,
        'Full name',
      )).enterText('Test Applicant');

      await $(find.widgetWithText(
        TextField,
        'Cover letter',
      )).enterText(
        'I am very interested in this position and believe my skills '
        'in Flutter development make me an excellent candidate.',
      );

      await $(find.widgetWithText(
        TextField,
        'Years of experience',
      )).enterText('3');

      await $(find.widgetWithText(
        TextField,
        'Earliest start date',
      )).tap();
      await $.pumpAndSettle();
      await $('OK').tap();
      await $.pumpAndSettle();

      await $(find.byType(Checkbox)).last.tap();
      await $.pumpAndSettle();

      // ----------------------------------------------------------------
      // Step 8 — Submit the form.
      // ----------------------------------------------------------------
      await $('Submit application').tap();
      await $.pumpAndSettle();

      // ----------------------------------------------------------------
      // Step 9 — Confirmation SnackBar.
      // ----------------------------------------------------------------
      expect(find.text('Application submitted!'), findsOneWidget);
    },
  );
}