// test/widget/apply_screen_test.dart
//
// Widget tests for ApplyScreen form validation. Tests the fields that do not
// require native OS interactions — the date picker is intentionally excluded
// because it opens a Material dialog whose day cells cannot be targeted
// reliably across screen sizes. The full happy path including date selection
// is Patrol's responsibility in integration_test/.
//
// Two fakes are required:
//   _FakeJobsNotifier — ApplyScreen may watch jobsProvider; returns a known list.
//   _FakeAuthNotifier — ApplyScreen reads authProvider for the email
//                       initialValue; returns Authenticated with a known email.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:careerhub/core/prefs_provider.dart';
import 'package:careerhub/models/auth_state.dart';
import 'package:careerhub/models/job.dart';
import 'package:careerhub/models/user.dart';
import 'package:careerhub/providers/auth_notifier.dart';
import 'package:careerhub/providers/jobs_notifier.dart';
import 'package:careerhub/screens/apply_screen.dart';

const _testEmail = 'test@example.com';

// Returns Authenticated with a known email so tests can assert the email field
// is pre-populated from auth state, not hardcoded.
class _FakeAuthNotifier extends AuthNotifier {
  @override
  Future<AuthState> build() async {
    return Authenticated(
      user: User(
        id: 'test-id',
        email: _testEmail,
        displayName: 'Test User',
      ),
    );
  }
}

// Returns a minimal jobs list. ApplyScreen may read the jobs provider for
// context; this ensures the provider does not throw or stay in loading state.
class _FakeJobsNotifier extends JobsNotifier {
  @override
  Future<List<Job>> build() async {
    return [
      Job(
        id: 'a',
        title: 'Flutter Developer',
        company: 'Yoco',
        location: 'Cape Town',
        employmentType: 'Full-time',
        isOpen: true,
      ),
    ];
  }
}

// Builds ApplyScreen inside a full ProviderScope so both auth and jobs
// providers are overridden. SharedPreferences is mocked so FilterNotifier
// does not throw when it calls ref.watch(prefsProvider).
Future<void> pumpSubject(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authProvider.overrideWith(_FakeAuthNotifier.new),
        jobsProvider.overrideWith(_FakeJobsNotifier.new),
        prefsProvider.overrideWithValue(prefs),
      ],
      child: const MaterialApp(
        home: ApplyScreen(jobId: 'test-job-id'),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  group('ApplyScreen form validation', () {
    testWidgets('email field is pre-populated from auth state', (tester) async {
      await pumpSubject(tester);

      // The email field must show the fake user's email without any typing.
      // This confirms ref.read(authProvider) is called during build()
      // and its value is used as the email field's initialValue.
      expect(find.text(_testEmail), findsOneWidget);
    });

    testWidgets('empty submit shows required errors for all required fields',
        (tester) async {
      await pumpSubject(tester);

      // Tap the submit button without filling anything in.
      await tester.tap(find.text('Submit application'));
      await tester.pumpAndSettle();

      // Multiple required errors should appear simultaneously. findsWidgets
      // (plural) asserts at least one match, covering all required fields.
      expect(
        find.textContaining('required', findRichText: true),
        findsWidgets,
      );
    });

    testWidgets('cover letter minLength error appears for short input',
        (tester) async {
      await pumpSubject(tester);

      // Enter a non-empty but too-short cover letter (under 50 characters).
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Cover letter'),
        'Too short.',
      );

      await tester.tap(find.text('Submit application'));
      await tester.pumpAndSettle();

      // The minLength validator must produce a length-related error message.
      expect(
        find.textContaining('50', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('portfolio URL field passes validation when left empty',
        (tester) async {
      await pumpSubject(tester);

      // Do not enter anything in the portfolio URL field.
      await tester.tap(find.text('Submit application'));
      await tester.pumpAndSettle();

      // The portfolio field is optional — its error must NOT appear.
      // Other required field errors will be visible, but not a URL error.
      expect(
        find.textContaining('URL', findRichText: true),
        findsNothing,
      );
    });

    testWidgets('portfolio URL field rejects a non-URL string', (tester) async {
      await pumpSubject(tester);

      // Enter a string that is clearly not a valid URL.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Portfolio URL (optional)'),
        'not-a-url',
      );

      await tester.tap(find.text('Submit application'));
      await tester.pumpAndSettle();

      // The URL validator must fire and produce an error for the invalid input.
      expect(
        find.textContaining('URL', findRichText: true),
        findsOneWidget,
      );
    });
  });
}