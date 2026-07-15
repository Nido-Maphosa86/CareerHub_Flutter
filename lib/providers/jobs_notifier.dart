// lib/providers/jobs_notifier.dart
//
// The single provider the UI watches for the job list. build() holds no data or
// delay of its own any more: it asks the repository for jobs and returns them,
// so the notifier stays thin and every network detail lives one layer down.
// Riverpod's generator reads the @riverpod class and writes the matching
// provider plus the _$JobsNotifier base class into the .g.dart part, which is why
// the red underline on _$JobsNotifier is normal until build_runner runs.
// refresh() lets a retry or pull-to-refresh re-run the fetch and await the fresh
// result before returning.

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/jobs_repository.dart';
import '../models/job.dart';

part 'jobs_notifier.g.dart';

@riverpod
class JobsNotifier extends _$JobsNotifier {
  // Runs when first watched, and again after any invalidate/refresh. It only
  // orchestrates: read the repository, return its jobs. read (not watch) because
  // the client is stable and this should not rebuild if the client is rebuilt.
  @override
  Future<List<Job>> build() async {
    final repository = ref.read(jobsRepositoryProvider);
    return repository.getJobs();
  }

  // Throws the current jobs away, triggers build() again, and waits for the new
  // list so a caller can keep a spinner up until the reload actually finishes.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
