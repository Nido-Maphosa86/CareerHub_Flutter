// lib/models/user.dart
//
// Represents the signed-in user decoded from the JWT access token. This class
// is populated once at login or on cold boot and lives in AuthState.Authenticated
// for the lifetime of the session. It is never serialised back to JSON and never
// stored in Isar — the token in secure storage is the source of truth; the User
// object is always reconstructed by decoding that token.

class User {
  // The subject claim from the JWT ("sub") — the server's unique identifier for
  // this user, used when calling personalised API endpoints.
  final String id;

  // The user's email address, shown in the UI and used as the login credential.
  final String email;

  // The human-readable name to show in the app bar or profile area. Falls back
  // to email if the server did not include a "name" claim in the token.
  final String displayName;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
  });
}
