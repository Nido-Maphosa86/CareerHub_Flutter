import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/api_result.dart';
import '../data/applications_repository.dart';
import '../domain/job_application.dart';

part 'applications_notifier.g.dart';

const _token =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhcHBsaWNhbnQxIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQXBwbGljYW50IiwiQXBwbGljYW50SWQiOiJhMDAwMDAwMC0wMDAwLTAwMDAtMDAwMC0wMDAwMDAwMDAwMDEiLCJleHAiOjE3ODQyMjU3ODN9.KW40cbinI2W7nNczN22zbjpPlLPi7L5w0SQllPRz6No';

@riverpod
class ApplicationsNotifier extends _$ApplicationsNotifier {
  @override
  Future<List<JobApplication>> build() async {
    final repository = ref.read(applicationsRepositoryProvider);

    final cached = repository.readCache();
    if (cached.isNotEmpty) {
      state = AsyncValue.data(cached);
    }

    final result = await repository.fetchAndCache(_token);

    return switch (result) {
      Success(:final data) => data,
      Failure(:final message) when cached.isNotEmpty => cached,
      Failure(:final message) => throw Exception(message),
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
