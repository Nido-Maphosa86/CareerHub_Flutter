// lib/providers/job_providers.dart
//
// State that shapes the jobs list lives here. The job list itself is no longer in
// this file: it now comes from jobsProvider, which fetches real jobs over
// HTTP. This file keeps only the two filter pieces (the selected chip and the
// derived, always-recomputed filtered list) plus the small label constants and
// the one function that turns a chip label into a rule about a Job.

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
// It now watches jobsProvider (the network-backed list) in place of the
// old hardcoded FutureProvider, but its shape (AsyncValue<List<Job>>) is
// unchanged, so the screen that watches it did not have to change.
final filteredJobsProvider = Provider<AsyncValue<List<Job>>>((ref) {
  final asyncJobs = ref.watch(jobsProvider);
  final filter = ref.watch(selectedFilterProvider);

  return asyncJobs.whenData((jobs) {
    if (filter == kFilterAll) return jobs;
    return jobs.where((job) => _matchesFilter(job, filter)).toList();
  });
});

// The one place a filter label becomes a rule about a Job. Each label checks a
// real field on the model, so a filter can never silently match nothing. The
// four employment-type cases are deliberately identical in shape — each just
// compares job.employmentType to its own label — so adding a fifth employment
// type later is a one-line addition here, not a new code path.
bool _matchesFilter(Job job, String filter) {
  switch (filter) {
    case kFilterRemote:
      return job.location == kFilterRemote;
    case kFilterFullTime:
      return job.employmentType == kFilterFullTime;
    case kFilterPartTime:
      return job.employmentType == kFilterPartTime;
    case kFilterContract:
      return job.employmentType == kFilterContract;
    case kFilterInternship:
      return job.employmentType == kFilterInternship;
    default:
      return true;
  }
}