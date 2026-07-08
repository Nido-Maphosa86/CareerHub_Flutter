// lib/main.dart
//
// FILE SUMMARY (easy English)
// This is the entry point of the app. It starts CareerHub, sets up the Material
// 3 theme from a single deep-green seed colour, and shows the HomeScreen.
// HomeScreen holds a hardcoded list of four jobs chosen to cover every tricky
// case from the assignment: a fully filled open job, an open job with no salary,
// a closed job (built with Job.closed), and a remote job (built with Job.remote).
// Each job is handed to a JobCard to draw. Because the list lives here, changing
// a job's isOpen value and pressing hot reload updates its card instantly.

import 'package:flutter/material.dart';

import 'models/job.dart';
import 'widgets/job_card.dart';

void main() {
  runApp(const CareerHubApp());
}

// The root widget. It configures the theme and points at the first screen.
class CareerHubApp extends StatelessWidget {
  const CareerHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // A real title, not "Flutter Demo": this is a job platform.
      title: 'CareerHub',
      theme: ThemeData(
        // A deliberate deep-green seed. Green reads as growth and "go", the feel
        // of an open opportunity, and a deep shade keeps a career app calm and
        // trustworthy rather than loud. Material 3 derives the whole palette
        // (primary, containers, on-colours) from this one colour.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF15803D),
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

// The first screen. It owns the hardcoded job list for Day 1. In Week 2 this
// list is replaced by live API data, but the JobCard and Job shapes stay the same.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // The four job variants required by the assignment.
  // Kept as a getter so the list is easy to read and each case is labelled.
  List<Job> get _jobs => [
        // 1. Fully populated, open: every field set, salary present.
        Job(
          title: 'Senior Flutter Developer',
          company: 'Yoco',
          location: 'Cape Town',
          employmentType: 'Full-time',
          isOpen: true,
          salary: 'R55 000 \u2013 R75 000 per month',
          closingDate: DateTime(2026, 12, 31),
          description:
              'Build and ship customer-facing mobile features across iOS and '
              'Android, and help shape the design system the whole team uses.',
        ),

        // 2. Open with no salary: only the required fields are given, so
        //    salary, closingDate and description are all absent.
        const Job(
          title: 'Junior Mobile Developer',
          company: 'Praelexis',
          location: 'Stellenbosch',
          employmentType: 'Internship',
          isOpen: true,
        ),

        // 3. Closed: built with the named constructor, which forces isOpen false.
        Job.closed(
          title: 'Backend Engineer (.NET)',
          company: 'BBD',
          location: 'Johannesburg',
          employmentType: 'Full-time',
          salary: 'R60 000 \u2013 R80 000 per month',
          closingDate: DateTime(2026, 3, 1),
          description:
              'Design and maintain APIs powering a national payments platform.',
        ),

        // 4. Remote: built with the named constructor, which fixes location.
        Job.remote(
          title: 'Flutter Developer',
          company: 'Luno',
          employmentType: 'Contract',
          isOpen: true,
          salary: 'R50 000 \u2013 R70 000 per month',
          closingDate: DateTime(2026, 9, 30),
          description:
              'Join a distributed team building crypto wallet experiences for '
              'a global audience.',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final jobs = _jobs;

    // A small live count that reads canApply, so the header always matches the
    // cards below it even if a job's status changes.
    final openCount = jobs.where((job) => job.canApply).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CareerHub'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Lead-in line summarising how many roles are open right now.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              '$openCount of ${jobs.length} roles open',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          // collection-for: turn each Job in the list into a JobCard.
          for (final job in jobs) JobCard(job: job),
        ],
      ),
    );
  }
}
