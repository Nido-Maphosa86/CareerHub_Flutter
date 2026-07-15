// test/widget_test.dart
//
// These tests check the real CareerHub app. In production jobsProvider
// calls the live API, but flutter test runs on machines with no server, so the
// real build() would throw a Dio connection error and every test would fail. The
// fix is to override jobsProvider inside each test's ProviderScope with a
// fake notifier that returns a fixed list of jobs after the same delay the app
// used to simulate. overrideWith swaps only the notifier that produces the list;
// the widgets, the router, and the filter providers all stay exactly as they are
// in the app, so these tests still exercise the real UI. The fake's list is now
// the single source of truth the assertions match against, since the hardcoded
// jobs no longer live in production code.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careerhub/main.dart';
import 'package:careerhub/models/job.dart';
import 'package:careerhub/providers/jobs_notifier.dart';

const Duration _pastTheDelay = Duration(seconds: 2);

// The fixed jobs the tests assert on. Kept identical in shape to the seed data
// the app shipped with in Assignment 1.4: three open, one closed; one with no
// salary (so "Market-related" is shown); one Internship.
final List<Job> _fakeJobs = [
  Job(
    id: '1',
    title: 'Senior Flutter Developer',
    company: 'Yoco',
    location: 'Cape Town',
    employmentType: 'Full-time',
    isOpen: true,
    salary: 'R55 000 – R75 000 per month',
    closingDate: DateTime(2026, 12, 31),
    description:
        'Build and ship customer-facing mobile features across iOS and Android.',
  ),
  const Job(
    id: '2',
    title: 'Junior Mobile Developer',
    company: 'Praelexis',
    location: 'Stellenbosch',
    employmentType: 'Internship',
    isOpen: true,
  ),
  Job.closed(
    id: '3',
    title: 'Backend Engineer (.NET)',
    company: 'BBD',
    location: 'Johannesburg',
    employmentType: 'Full-time',
    salary: 'R60 000 – R80 000 per month',
    closingDate: DateTime(2026, 3, 1),
    description: 'Design and maintain APIs powering a national payments platform.',
  ),
  Job.remote(
    id: '4',
    title: 'Flutter Developer',
    company: 'Luno',
    employmentType: 'Contract',
    isOpen: true,
    salary: 'R50 000 – R70 000 per month',
    closingDate: DateTime(2026, 9, 30),
    description: 'Join a distributed team building crypto wallet experiences.',
  ),
];

// A stand-in for the real JobsNotifier that never touches the network. It
// extends the generated JobsNotifier (which itself extends _$JobsNotifier) and
// fully overrides build(), so the repository is never called. The 1.5s delay
// preserves the loading-spinner assertion.
class _FakeJobsNotifier extends JobsNotifier {
  @override
  Future<List<Job>> build() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return _fakeJobs;
  }
}

// Wraps the app with the fake notifier installed in place of the real one.
Widget _app() => ProviderScope(
      overrides: [
        jobsProvider.overrideWith(_FakeJobsNotifier.new),
      ],
      child: const CareerHubApp(),
    );

void main() {
  testWidgets('starts on the jobs tab and shows the nav bar', (tester) async {
    await tester.pumpWidget(_app());

    // GoRouter's initialLocation is /jobs, so the list screen is already here.
    // The NavigationBar destinations are visible immediately, even before the
    // jobs finish loading.
    expect(find.text('Jobs'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);

    // The fake notifier still has a pending 1.5s timer at this point, because
    // nothing above has waited for it. Letting it complete here, before the
    // test ends, avoids "A Timer is still pending" when the tree is torn down.
    await tester.pump(_pastTheDelay);
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