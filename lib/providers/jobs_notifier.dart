import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/api_result.dart';
import '../data/jobs_repository.dart';
import '../models/job.dart';

part 'jobs_notifier.g.dart';

// No 401 auto-logout pattern here (contrast with ApplicationsNotifier and
// ApplyNotifier) — job browsing on this API is not behind an authenticated
// endpoint, and adding an unconditional ref.read(authRepositoryProvider)
// here previously broke JobsNotifier's disposal semantics under
// ProviderContainer.dispose() in test/unit/jobs_notifier_test.dart. See the
// Part 5 section of README.md.
@riverpod
class JobsNotifier extends _$JobsNotifier {
  @override
  Future<List<Job>> build() async {
    final repository = ref.read(jobsRepositoryProvider);

    final cachedJobs = await repository.getCachedJobs();
    if (cachedJobs.isNotEmpty) {
      state = AsyncData(cachedJobs);
    }

    final result = await repository.getJobs();

    return switch (result) {
      Success(:final data) => data,
      Failure() when cachedJobs.isNotEmpty => cachedJobs,
      Failure(:final message) => throw Exception(message),
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
