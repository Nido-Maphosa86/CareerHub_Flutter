import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/api_result.dart';
import '../data/jobs_repository.dart';
import '../models/job.dart';

part 'jobs_notifier.g.dart';

@riverpod
class JobsNotifier extends _$JobsNotifier {
  @override
  Future<List<Job>> build() async {
    final repository = ref.read(jobsRepositoryProvider);
        
        //gets the cached jobs from the Isar database and sets the state to AsyncData with the cached jobs if they exist. This allows the app to display job listings even when offline, providing a better user experience.
    final cachedJobs = await repository.getCachedJobs();
    if (cachedJobs.isNotEmpty) {
      state = AsyncData(cachedJobs);
    }


     
    final result = await repository.getJobs();

    return switch (result) {
      Success(:final data) => data, //he fetch worked. Return the fresh list, which becomes the notifier's final value.

      //he fetch failed, but we already had cached jobs (from Stage 1). Rather than showing an error and yanking away data the user is currently looking at, just quietly keep showing what was already there. when cachedJobs.isNotEmpty is a guard clause — this arm only fires if that extra condition is also true.
      Failure(:final message) when cachedJobs.isNotEmpty => cachedJobs,
      Failure(:final message) => throw Exception(message),
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
