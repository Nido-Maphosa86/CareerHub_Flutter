// lib/models/auth_state.dart
//
// The sealed AuthState type drives every authentication-related decision in the
// app. Because it is sealed, the Dart compiler knows every possible subtype and
// enforces exhaustiveness on switch expressions — missing a case is a compile
// error, not a runtime bug. No code generation is needed; sealed classes are a
// native Dart 3 feature.
//
// The four subtypes model the complete authentication lifecycle:
//   Unauthenticated -> Authenticating -> Authenticated
//                   -> AuthError
//
// A plain Dart enum cannot represent this hierarchy because Authenticated must
// carry a User payload and AuthError must carry a String payload. Enum variants
// cannot hold different data types — every value of an enum is the same type
// with no attached fields.

import 'user.dart';

// The sealed keyword means every subtype must be declared in this file. That
// file-location constraint is what lets the compiler enumerate all subtypes
// and guarantee exhaustiveness in switch expressions.
sealed class AuthState {
  const AuthState();
}

// No stored token was found in secure storage, or the refresh token has expired.
// This is the initial state at every cold boot until the token check completes.
final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

// A login() call is in progress. Emitted the moment login() is called, before
// any network request has been sent, so the UI can show a spinner immediately.
// Not used for the cold-boot token check — that is covered by the AsyncValue
// loading state wrapping AuthState.
final class Authenticating extends AuthState {
  const Authenticating();
}

// A valid, non-expired token exists, or login just succeeded. Carries the User
// decoded from the access token so every widget that needs user data can read it
// from this single source of truth without making its own network call.
final class Authenticated extends AuthState {
  final User user;
  const Authenticated({required this.user});
}

// Login failed due to bad credentials or a network error. Carries the
// human-readable message shown below the password field on the login screen.
final class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}
