// test/widget/job_card_test.dart
//
// Widget tests for JobCard. JobCard is a plain StatelessWidget that receives
// all data as constructor parameters and reads no providers — no ProviderScope
// is needed. Two distinct fixtures confirm the card renders its data parameter,
// not hardcoded strings.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careerhub/models/job.dart';
import 'package:careerhub/widgets/job_card.dart';

// Two fixtures with deliberately different field values so tests can assert
// that the card renders the correct data and not a static string.
final _jobA = Job(
  id: '1',
  title: 'Senior Flutter Developer',
  company: 'Yoco',
  location: 'Cape Town',
  employmentType: 'Full-time',
  isOpen: true,
  salary: 'R55 000 – R75 000',
  closingDate: DateTime(2027, 12, 31),
);

final _jobB = Job(
  id: '2',
  title: 'Junior Mobile Developer',
  company: 'Praelexis',
  location: 'Stellenbosch',
  employmentType: 'Internship',
  isOpen: false,
);

// Helper that pumps a JobCard inside a minimal MaterialApp so Theme and
// Directionality are available. No ProviderScope needed — JobCard has no
// provider dependencies.
Future<void> pumpCard(WidgetTester tester, Job job) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: JobCard(
          job: job,
          onTap: () {},
        ),
      ),
    ),
  );
}

void main() {
  group('JobCard', () {
    testWidgets('renders job title and company name', (tester) async {
      await pumpCard(tester, _jobA);

      // The card must display the job title from the fixture, not a placeholder.
      expect(find.text(_jobA.title), findsOneWidget);

      // The company name must also be visible.
      expect(find.text(_jobA.company), findsOneWidget);
    });

    testWidgets('renders different content for a different fixture',
        (tester) async {
      await pumpCard(tester, _jobB);

      // The second fixture's title must be present.
      expect(find.text(_jobB.title), findsOneWidget);

      // The first fixture's title must NOT be present — confirms the card is
      // rendering its data parameter, not a hardcoded string.
      expect(find.text(_jobA.title), findsNothing);

      // The second fixture's company name must be visible.
      expect(find.text(_jobB.company), findsOneWidget);
    });

    testWidgets('displays the employment type chip', (tester) async {
      await pumpCard(tester, _jobA);

      // The employment type chip text must match the fixture value exactly.
      // If the chip renders a different string (hardcoded or wrong field),
      // this test fails.
      expect(find.text(_jobA.employmentType), findsOneWidget);

      // Pump a second card with a different employment type and confirm the
      // chip text changes — proves the chip is data-driven, not static.
      await pumpCard(tester, _jobB);
      expect(find.text(_jobB.employmentType), findsOneWidget);
      expect(find.text(_jobA.employmentType), findsNothing);
    });
  });
}
