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

    final cachedJobs = await repository.getCachedJobs();
    if (cachedJobs.isNotEmpty) {
      state = AsyncData(cachedJobs);
    }

    final result = await repository.getJobs();

    return switch (result) {
      Success(:final data) => data,
      Failure(:final message) when cachedJobs.isNotEmpty => cachedJobs,
      Failure(:final message) => throw Exception(message),
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
