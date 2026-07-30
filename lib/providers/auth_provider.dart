//What this file is for
//Two small providers that exist purely to solve plumbing problems — 
//connecting pieces of the app that can't directly import each other without creating a broken circular dependency.
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_state.dart';
import 'auth_notifier.dart';

// Returns a void callback that invalidates authProvider. Calling it
// causes build() to run again, which finds empty storage and returns
// Unauthenticated, which the router picks up and redirects to /login.
final onUnauthenticatedProvider = Provider<void Function()>((ref) {
  return () => ref.invalidate(authProvider);
});

// Wraps authProvider in a ChangeNotifier so GoRouter can subscribe to
// auth state changes via refreshListenable. Every time the auth provider emits
// a new value, notifyListeners() fires, GoRouter re-evaluates its redirect
// callback, and the route changes if necessary.
class AuthStateListenable extends ChangeNotifier {
  // Holds the subscription so we can cancel it when this object is disposed.
  // Without cancellation, the listener would call notifyListeners() on a
  // disposed ChangeNotifier, causing a framework assertion error.
  late final ProviderSubscription<AsyncValue<AuthState>> _sub;

  AuthStateListenable(Ref ref) {
    _sub = ref.listen<AsyncValue<AuthState>>(
      authProvider,
      (_, __) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

// Plain Provider — no @riverpod, no part directive. GoRouter reads this once
// to set refreshListenable. onDispose ensures the ChangeNotifier is disposed
// (which in turn closes the subscription) when the ProviderScope is torn down.
final authStateListenableProvider = Provider<AuthStateListenable>((ref) {
  final listenable = AuthStateListenable(ref);
  ref.onDispose(listenable.dispose);
  return listenable;
});