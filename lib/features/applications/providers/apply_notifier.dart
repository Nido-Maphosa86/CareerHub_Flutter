// lib/features/applications/providers/apply_notifier.dart
//
// Owns the submit action for ApplyScreen. Separated from ApplicationsNotifier
// because submitting a new application and loading the existing list are
// different operations with different lifecycles — build() here does no
// network call at all; submit() is only ever invoked by a user tap.

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/api_result.dart';
import '../../../data/auth_repository.dart';
import '../data/applications_repository.dart';

part 'apply_notifier.g.dart';

@riverpod
class ApplyNotifier extends _$ApplyNotifier {
  @override
  Future<void> build() async {}

  Future<void> submit({
    required String jobId,
    required Map<String, dynamic> payload,
  }) async {
    // Captured before the first await, same pattern as every other
    // authenticated-endpoint notifier in this app.
    final repository = ref.read(applicationsRepositoryProvider);
    final authRepository = ref.read(authRepositoryProvider);

    state = const AsyncLoading();

    final result = await repository.submitApplication(
      jobId: jobId,
      payload: payload,
    );

    if (result case Failure(statusCode: 401)) {
      await authRepository.logout();
      final error = Exception('Your session has expired. Please sign in again.');
      state = AsyncError(error, StackTrace.current);
      throw error;
    }

    switch (result) {
      case Success():
        state = const AsyncData(null);
      case Failure(:final message):
        final error = Exception(message);
        state = AsyncError(error, StackTrace.current);
        throw error;
    }
  }
}
