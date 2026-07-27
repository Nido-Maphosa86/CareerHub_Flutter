import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:careerhub/core/prefs_provider.dart';
import 'package:careerhub/main.dart';
import 'package:careerhub/models/job.dart';
import 'package:careerhub/providers/jobs_notifier.dart';

const Duration _pastTheDelay = Duration(seconds: 2);

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

class _FakeJobsNotifier extends JobsNotifier {
  @override
  Future<List<Job>> build() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return _fakeJobs;
  }
}

Future<Widget> _app() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      jobsProvider.overrideWith(_FakeJobsNotifier.new),
      prefsProvider.overrideWithValue(prefs),
    ],
    child: const CareerHubApp(),
  );
}

void main() {
  testWidgets('starts on the jobs tab and shows the nav bar', (tester) async {
    await tester.pumpWidget(await _app());

    expect(find.text('Jobs'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);

    await tester.pump(_pastTheDelay);
  });

  testWidgets('shows a spinner while loading, then hides it', (tester) async {
    await tester.pumpWidget(await _app());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(_pastTheDelay);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Senior Flutter Developer'), findsOneWidget);
  });

  testWidgets('renders all four job cards once loaded', (tester) async {
    await tester.pumpWidget(await _app());
    await tester.pump(_pastTheDelay);

    expect(find.text('Senior Flutter Developer'), findsOneWidget);
    expect(find.text('Junior Mobile Developer'), findsOneWidget);
    expect(find.text('Backend Engineer (.NET)'), findsOneWidget);
    expect(find.text('Flutter Developer'), findsOneWidget);
  });

  testWidgets('status badges reflect each job state', (tester) async {
    await tester.pumpWidget(await _app());
    await tester.pump(_pastTheDelay);

    expect(find.text('Closed'), findsOneWidget);
    expect(find.text('Open'), findsNWidgets(3));
  });

  testWidgets('salary and type pills render safely', (tester) async {
    await tester.pumpWidget(await _app());
    await tester.pump(_pastTheDelay);

    expect(find.text('Market-related'), findsOneWidget);
    expect(find.text('null'), findsNothing);
    expect(find.text('Internship'), findsOneWidget);
  });

  testWidgets('tapping a card opens its detail screen', (tester) async {
    await tester.pumpWidget(await _app());
    await tester.pump(_pastTheDelay);

    await tester.tap(find.text('Senior Flutter Developer'));
    await tester.pumpAndSettle();

    expect(find.text('Job details'), findsOneWidget);
    expect(find.text('About the role'), findsOneWidget);
  });
}
