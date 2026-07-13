// lib/providers/job_providers.dart
//
// FILE SUMMARY 
// This file holds all the app's state. The screen no longer owns the job list;
// it just watches these providers and draws whatever they say.
//
// There are three providers here, and each one has a different job:
//   1. jobsProvider      - fetches the list of jobs, slowly, like a real server
//                          would. It can be loading, it can fail, or it can hold
//                          data, and Riverpod tracks that for us.
//   2. selectedFilterProvider - remembers which filter chip is currently chosen.
//                          Just a piece of text like "All" or "Remote".
//   3. filteredJobsProvider - works out the visible list by combining the other
//                          two. It is never stored, always calculated, so it can
//                          never fall out of step with the jobs or the filter.
//
// The rule to remember: anything you can calculate from other state should be
// calculated, not saved. Saving it means keeping two copies in sync by hand,
// and eventually you forget one.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/job.dart';

// The filter labels the chip row shows. Kept here next to the filter logic so
// the labels and the matching rules can never drift apart.
const String kFilterAll = 'All';
const String kFilterRemote = 'Remote';
const String kFilterFullTime = 'Full-time';

const List<String> kFilterLabels = [
  kFilterAll,
  kFilterRemote,
  kFilterFullTime,
];

// Toggle for the error branch. Flip this to true and the jobs provider throws
// instead of returning data, which lets us see and test the error UI.
//the first value  is false
final shouldFailProvider = StateProvider<bool>((ref) => false);

// ---------------------------------------------------------------------------
// 1. THE JOB LIST (async)
// ---------------------------------------------------------------------------
// FutureProvider because the value arrives later and might fail. Riverpod wraps
// the result in an AsyncValue, which is either loading, error, or data. In
// other words, the screen can watch this one provider and get all three states
final jobsProvider = FutureProvider<List<Job>>((ref) async {

  // Watching this means flipping the switch re-runs the fetch automatically.
  final shouldFail = ref.watch(shouldFailProvider);

  // Pretend we are talking to a slow server so the loading spinner is visible.
  await Future.delayed(const Duration(milliseconds: 1500));

  if (shouldFail) {
    throw Exception('Could not reach the CareerHub server.');
  }

  return _seedJobs;
});

// ---------------------------------------------------------------------------
// 2. THE SELECTED FILTER (simple value)
// ---------------------------------------------------------------------------
// StateProvider because this is one plain value that the UI sets directly when
// a chip is tapped. There is no logic here beyond "remember what was chosen".
// The default is "All" so the first chip is selected when the app starts.
final selectedFilterProvider = StateProvider<String>((ref) => kFilterAll);

// ---------------------------------------------------------------------------
// 3. THE FILTERED LIST (derived)
// ---------------------------------------------------------------------------
// A plain Provider that watches the other two and recomputes whenever either
// changes. It hands back an AsyncValue so the screen can still show loading and
// error states through a single watch call.
//
// Note it never stores a list of its own. That is the whole point: a stored
// copy could go stale when the jobs reload while a filter is still active.
final filteredJobsProvider = Provider<AsyncValue<List<Job>>>((ref) {
  final asyncJobs = ref.watch(jobsProvider);
  final filter = ref.watch(selectedFilterProvider);

  // whenData rebuilds the AsyncValue with a new payload, keeping loading and
  // error states untouched and flowing straight through to the screen.
  return asyncJobs.whenData((jobs) {
    if (filter == kFilterAll) return jobs;
    return jobs.where((job) => _matchesFilter(job, filter)).toList();
  });
});

// The one place a filter label is turned into a rule about a Job. Each label
// checks a real field on the model, so a filter can never silently match nothing.
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

// ---------------------------------------------------------------------------
// THE DATA
// ---------------------------------------------------------------------------
// The four job variants, moved out of HomeScreen so the widget no longer owns
// any data. At least one job matches each filter label: Luno is Remote, and
// Yoco and BBD are Full-time.
final List<Job> _seedJobs = [
  // 1. Fully populated, open.
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

  // 3. Closed, via the named constructor.
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

  // 4. Remote, via the other named constructor.
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
