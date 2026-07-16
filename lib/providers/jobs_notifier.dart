// lib/providers/jobs_notifier.dart
//
// The single provider the UI watches for the job list. build() reads the
// repository and pattern-matches on the ApiResult it hands back: Success
// destructures :data and returns the list, Failure destructures :message and
// throws an Exception with that line, which Riverpod surfaces as AsyncValue.error
// for the screen's when(error: ...) branch. Because ApiResult is sealed, the
// compiler enforces that both arms are handled — forgetting one is a compile
// error, not a runtime crash. refresh() lets a retry or pull-to-refresh re-run
// the fetch and await the fresh result before returning.

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/api_result.dart';
import '../data/jobs_repository.dart';
import '../models/job.dart';

part 'jobs_notifier.g.dart';

@riverpod
class JobsNotifier extends _$JobsNotifier {
  // Runs when first watched, and again after any invalidate/refresh. read (not
  // watch) because the client is stable and this should not rebuild if the
  // repository is rebuilt.
  @override
  Future<List<Job>> build() async {
    final repository = ref.read(jobsRepositoryProvider);
    final result = await repository.getJobs();

    // Sealed switch: the compiler checks this covers every ApiResult subclass.
    // Success carries the list; on Failure we throw so Riverpod's AsyncNotifier
    // machinery captures it into AsyncValue.error for the screen to display.
    return switch (result) {
      Success(:final data) => data,
      Failure(:final message) => throw Exception(message),
    };
  }

  // Throws the current jobs away, triggers build() again, and waits for the new
  // list so a caller can keep a spinner up until the reload actually finishes.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
