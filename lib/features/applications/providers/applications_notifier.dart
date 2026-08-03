import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/api_result.dart';
import '../../../data/auth_repository.dart';
import '../data/applications_repository.dart';
import '../domain/job_application.dart';

part 'applications_notifier.g.dart';

@riverpod
class ApplicationsNotifier extends _$ApplicationsNotifier {
  @override
  Future<List<JobApplication>> build() async {
    // Captured before the first await — see Part 5 of Assignment 3.3's
    // README: local variable capture of ref.read must happen before any
    // await so both reads observe a stable provider graph.
    final repository = ref.read(applicationsRepositoryProvider);
    final authRepository = ref.read(authRepositoryProvider);

    final cached = repository.readCache();
    if (cached.isNotEmpty) {
      state = AsyncValue.data(cached);
    }

    final result = await repository.getApplications();

    // A 401 means the stored token is no longer valid. Log out first so
    // secure storage is cleared, then throw — the auth state change fires
    // authStateListenableProvider, GoRouter redirects to /login before this
    // AsyncError has a chance to render as an error screen.
    if (result case Failure(statusCode: 401)) {
      await authRepository.logout();
      throw Exception('Your session has expired. Please sign in again.');
    }

    return switch (result) {
      Success(:final data) => data,
      Failure() when cached.isNotEmpty => cached,
      Failure(:final message) => throw Exception(message),
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
