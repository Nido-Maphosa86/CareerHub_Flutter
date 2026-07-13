// lib/providers/job_providers.dart
//
// This file holds all the app's state. The screen no longer owns the job list;
// it watches these providers and draws whatever they say. There are the three
// providers from Assignment 1.3 (the async job list, the selected filter, and the
// derived filtered list), plus one small addition for navigation: a family
// provider that finds a single job by its id. That lookup is what the detail
// screen uses to turn an id from the URL back into a real Job. Every job in the
// seed data has a unique, stable integer id.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/job.dart';

// Filter labels shown by the chip row, kept next to the filter logic so labels
// and matching rules can never drift apart.
const String kFilterAll = 'All';
const String kFilterRemote = 'Remote';
const String kFilterFullTime = 'Full-time';

const List<String> kFilterLabels = [kFilterAll, kFilterRemote, kFilterFullTime];

// Flip to true to make the jobs load fail, so the error UI can be seen and tested.
final shouldFailProvider = StateProvider<bool>((ref) => false);

// The job list, loaded asynchronously. FutureProvider wraps the result in an
// AsyncValue carrying loading, error, and data states. In Week 2 the body becomes
// a real API call and nothing else changes.
final jobsProvider = FutureProvider<List<Job>>((ref) async {
  final shouldFail = ref.watch(shouldFailProvider);
  await Future.delayed(const Duration(milliseconds: 1500));
  if (shouldFail) {
    throw Exception('Could not reach the CareerHub server.');
  }
  return _seedJobs;
});

// The currently selected filter label. A single plain value the UI sets on tap.
final selectedFilterProvider = StateProvider<String>((ref) => kFilterAll);

// The filtered list, derived from the jobs and the filter. Never stored, always
// recomputed, so it can never fall out of step with either input.
final filteredJobsProvider = Provider<AsyncValue<List<Job>>>((ref) {
  final asyncJobs = ref.watch(jobsProvider);
  final filter = ref.watch(selectedFilterProvider);

  return asyncJobs.whenData((jobs) {
    if (filter == kFilterAll) return jobs;
    return jobs.where((job) => _matchesFilter(job, filter)).toList();
  });
});

// Finds one job by its id. This is a family provider: it takes an argument (the
// id) and returns the matching job, or null if no job has that id. The detail
// screen uses this to turn the id from the URL back into a real Job. It watches
// the raw jobsProvider, so a job can be found by id regardless of the current
// filter. Returns an AsyncValue so the detail screen can still show loading and
// error states through a single watch.
final jobByIdProvider = Provider.family<AsyncValue<Job?>, int>((ref, id) {
  final asyncJobs = ref.watch(jobsProvider);
  return asyncJobs.whenData((jobs) {
    for (final job in jobs) {
      if (job.id == id) return job;
    }
    return null; // no job with this id (e.g. a stale or mistyped URL)
  });
});

// The one place a filter label becomes a rule about a Job. Each label checks a
// real field on the model, so a filter can never silently match nothing.
bool _matchesFilter(Job job, String filter) {
  switch (filter) {
    case kFilterRemote:
      return job.location == kFilterRemote;
    case kFilterFullTime:
      return job.employmentType == kFilterFullTime;
    default:
      return true;
  }
}

// The seed data, moved out of the screen. Each job has a unique, stable id. At
// least one job matches each filter label: Luno is Remote; Yoco and BBD are
// Full-time.
final List<Job> _seedJobs = [
  Job(
    id: 1,
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
  const Job(
    id: 2,
    title: 'Junior Mobile Developer',
    company: 'Praelexis',
    location: 'Stellenbosch',
    employmentType: 'Internship',
    isOpen: true,
  ),
  Job.closed(
    id: 3,
    title: 'Backend Engineer (.NET)',
    company: 'BBD',
    location: 'Johannesburg',
    employmentType: 'Full-time',
    salary: 'R60 000 \u2013 R80 000 per month',
    closingDate: DateTime(2026, 3, 1),
    description:
        'Design and maintain APIs powering a national payments platform.',
  ),
  Job.remote(
    id: 4,
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
