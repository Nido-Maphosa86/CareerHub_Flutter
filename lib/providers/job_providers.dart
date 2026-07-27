// lib/providers/job_providers.dart
//
// Filtering logic for the jobs list. filteredJobsProvider watches both the
// live jobs data (from Isar cache + network) and the currently selected
// filter chip (persisted to SharedPreferences), and returns only the jobs
// that match.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/job.dart';
import 'filter_notifier.dart';
import 'jobs_notifier.dart';

export 'filter_notifier.dart'
    show
        kFilterAll,
        kFilterRemote,
        kFilterFullTime,
        kFilterPartTime,
        kFilterContract,
        kFilterInternship,
        kFilterLabels;

final filteredJobsProvider = Provider<AsyncValue<List<Job>>>((ref) {
  final asyncJobs = ref.watch(jobsProvider);
  final filter = ref.watch(filterProvider);

  return asyncJobs.whenData((jobs) {
    if (filter == kFilterAll) return jobs;
    return jobs.where((job) => _matchesFilter(job, filter)).toList();
  });
});

bool _matchesFilter(Job job, String filter) => switch (filter) {
      kFilterRemote => job.location == kFilterRemote,
      kFilterFullTime => job.employmentType == kFilterFullTime,
      kFilterPartTime => job.employmentType == kFilterPartTime,
      kFilterContract => job.employmentType == kFilterContract,
      kFilterInternship => job.employmentType == kFilterInternship,
      _ => true,
    };