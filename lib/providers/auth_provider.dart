// lib/providers/auth_provider.dart
//
// Two plain providers that exist solely to break dependency cycles.
//
// onUnauthenticatedProvider — AuthInterceptor (data layer) needs to trigger a
// rebuild of AuthNotifier when a refresh definitively fails. But auth_interceptor
// cannot import auth_notifier (data importing providers), and auth_notifier
// cannot import auth_interceptor (circular). The solution is a plain callback
// provider: auth_interceptor imports only this file (which has no Riverpod
// annotation and no code generation), reads the callback, and calls it. The
// callback itself imports auth_notifier, but that is fine because it lives here
// in the providers layer.
//
// authStateListenableProvider — GoRouter's refreshListenable expects a
// ChangeNotifier, not a Riverpod provider. AuthStateListenable wraps
// authProvider in a ChangeNotifier so the router rebuilds its redirect
// logic whenever auth state changes, without the router itself needing to import
// Riverpod internals.

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