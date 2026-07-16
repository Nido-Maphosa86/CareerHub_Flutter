// lib/providers/job_providers.dart
//
// State that shapes the jobs list lives here. The job list itself is no longer in
// this file: it now comes from jobsProvider, which fetches real jobs over
// HTTP. This file keeps only the two filter pieces (the selected chip and the
// derived, always-recomputed filtered list) plus the small label constants and
// the one function that turns a chip label into a rule about a Job. _matchesFilter
// is now written as a switch expression (Dart 3): each arm maps a chip label
// straight to a bool, so the whole body reads as one expression.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/job.dart';
import 'jobs_notifier.dart';

// Filter labels shown by the chip row, kept next to the filter logic so labels
// and matching rules can never drift apart. These four employment-type labels
// mirror every value the backend's JobType enum can produce (see Job.fromDto's
// _employmentLabel, which is what turns the API's "FullTime" etc. into these
// exact strings) — so a chip here can never point at an employment type the
// data is incapable of having.
const String kFilterAll = 'All';
const String kFilterRemote = 'Remote';
const String kFilterFullTime = 'Full-time';
const String kFilterPartTime = 'Part-time';
const String kFilterContract = 'Contract';
const String kFilterInternship = 'Internship';

const List<String> kFilterLabels = [
  kFilterAll,
  kFilterRemote,
  kFilterFullTime,
  kFilterPartTime,
  kFilterContract,
  kFilterInternship,
];

// The currently selected filter label. A single plain value the UI sets on tap.
final selectedFilterProvider = StateProvider<String>((ref) => kFilterAll);

// The filtered list, derived from the live jobs and the selected filter. Never
// stored, always recomputed, so it can never fall out of step with either input.
// Because Job is now @freezed, two identical jobs are equal by value: Riverpod
// can therefore skip notifying listeners when a refresh returns a job list that
// has not actually changed.
final filteredJobsProvider = Provider<AsyncValue<List<Job>>>((ref) {
  final asyncJobs = ref.watch(jobsProvider);
  final filter = ref.watch(selectedFilterProvider);

  return asyncJobs.whenData((jobs) {
    if (filter == kFilterAll) return jobs;
    return jobs.where((job) => _matchesFilter(job, filter)).toList();
  });
});

// One switch expression, one arm per chip. The named constants (kFilterRemote,
// kFilterFullTime, ...) are compile-time constants, so they are valid constant
// patterns in a switch. The default arm (_) covers kFilterAll and any unknown
// label — a filter that does not name a specific field keeps every job.
bool _matchesFilter(Job job, String filter) => switch (filter) {
      kFilterRemote => job.location == kFilterRemote,
      kFilterFullTime => job.employmentType == kFilterFullTime,
      kFilterPartTime => job.employmentType == kFilterPartTime,
      kFilterContract => job.employmentType == kFilterContract,
      kFilterInternship => job.employmentType == kFilterInternship,
      _ => true,
    };
