// lib/screens/home_screen.dart
//
// FILE SUMMARY (easy English)
// This is the main screen. It owns the list of jobs and decides how to show it.
// A row of filter chips stays pinned at the top (they are decoration only for
// now; the filtering logic comes in Day 3). Below the chips the screen measures
// how much width it has: on a narrow phone (under 600 pixels) it shows a single
// scrolling column of cards, and on a wider screen or a tablet (600 pixels or
// more) it shows a two-column grid. Both layouts build their cards through the
// exact same _buildCard method, so there is no duplicated code. The job list is
// created once as a static field, not rebuilt every time the screen redraws.

import 'package:flutter/material.dart';

import '../models/job.dart';
import '../widgets/job_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // The width in pixels where the layout switches from a list to a grid.
  static const double _gridBreakpoint = 600;

  // The jobs are defined once at class level (static final), so the list is not
  // rebuilt on every screen redraw. 
  static final List<Job> _jobs = [
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

    // 2. Open with no salary: only the required fields are given.
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

  // One place that turns an index into a JobCard. Both the list and the grid
  // call this, so the card-building logic is never duplicated.
  Widget _buildCard(BuildContext context, int index) {
    return JobCard(job: _jobs[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CareerHub'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // The filter row is a sibling ABOVE the scrolling area, so it stays
          // pinned while the cards scroll. It is not inside the LayoutBuilder.
          const _FilterChipsRow(),

          // Expanded is the fix from Question 1: it gives the scrolling area a
          // bounded height (the space left under the chip row). Without it, the
          // Column would hand the list an unbounded height and Flutter would
          // throw "vertical viewport was given unbounded height".
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Narrow screen -> single-column list.
                if (constraints.maxWidth < _gridBreakpoint) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _jobs.length,
                    itemBuilder: _buildCard,
                  );
                }

                // Wide screen or tablet -> two-column grid.
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    // Justified in the README (Q2): sized for the tallest card
                    // at the narrowest grid width so nothing overflows.
                    childAspectRatio: 1.3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _jobs.length,
                  itemBuilder: _buildCard,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// The pinned row of filter chips. Visual only for now: tapping does nothing
// until Day 3 wires it to state. "All" is shown as the selected chip.
class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow();

  @override
  Widget build(BuildContext context) {
    // The categories that match the current job data.
    const filters = ['All', 'Remote', 'Full-time'];

    return SizedBox(
      height: 56,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            for (final label in filters)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(label),
                  selected: label == 'All',
                  onSelected: (_) {}, // no filtering yet (Day 3)
                ),
              ),
          ],
        ),
      ),
    );
  }
}
