//This is the single source of truth for whether someone is logged in. 
//Every screen that needs to know the current auth status watches this one provider.
import 'package:careerhub/data/api_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/auth_repository.dart';
import '../models/auth_state.dart';
import '../models/user.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthState> build() async {
    // ref.read (not ref.watch) because the repository itself never changes —
    // there is nothing to react to. ref.watch inside build() would rebuild the
    // notifier any time the repository provider rebuilds, which is never the
    // right behaviour here.
    final repo = ref.read(authRepositoryProvider);

    final token = await repo.readAccessToken();

    // No token in storage — user has never logged in or last session was cleared.
    if (token == null) return const Unauthenticated();

    // Token exists but has expired — attempt a silent background refresh.
    if (repo.isTokenExpired(token)) {
      final user = await repo.tryRefresh();
      if (user == null) return const Unauthenticated();
      return Authenticated(user: user);
    }

    // Token exists and is still valid — decode it and restore the session.
    return Authenticated(user: repo.decodeUser(token));
  }

  // Called from the login screen's submit handler. Sets Authenticating
  // immediately so the UI can show a spinner before any async work begins.
  Future<void> login(String email, String password) async {
    // Emit Authenticating synchronously before the first await so the spinner
    // appears in the same frame as the tap. If we awaited first, the UI would
    // freeze on the old state until the network call returned.
    state = const AsyncData(Authenticating());

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.login(email, password);

    state = switch (result) {
      Success(:final data) => AsyncData(Authenticated(user: data)),
      Failure(:final message) => AsyncData(AuthError(message)),
    };
  }

  // Clears secure storage and returns to Unauthenticated. The caller must
  // invalidate any data providers that hold user-specific state before calling
  // this method, so no stale data is visible after the redirect to /login.
  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AsyncData(Unauthenticated());
  }
}
