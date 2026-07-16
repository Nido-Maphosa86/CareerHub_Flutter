// lib/data/api_result.dart
//
// A tiny sealed type that the repository returns instead of raw jobs or raw
// exceptions. Every caller must handle both arms: Success carries the data,
// Failure carries a human-readable message and the HTTP status code if one is
// known. Because ApiResult is sealed, the Dart compiler knows every subclass
// (they live in this file, and only this file), so a switch expression on an
// ApiResult<T> is checked for exhaustiveness at compile time. Missing the
// Failure arm becomes a compile error, not a runtime crash. No Freezed here,
// no build_runner — the whole type is 20 lines of hand-written Dart.

// The sealed modifier says: the only subclasses of ApiResult<T> are the ones
// declared in this library. The compiler uses that guarantee to check switch
// exhaustiveness on ApiResult<T> at compile time.
sealed class ApiResult<T> {
  const ApiResult();
}

// The happy path. data holds whatever the repository was asked to fetch —
// List<Job>, a single Job, whatever T resolves to at the call site.
final class Success<T> extends ApiResult<T> {
  final T data;
  const Success(this.data);
}

// The failure path. message is the human-readable line the UI shows (never a
// raw exception or stack trace). statusCode is optional because a network
// error (no response) has no HTTP status; a server-side 500 does.
// Failure<T> keeps the T even though it never stores one, because a
// Future<ApiResult<List<Job>>> can only accept a Failure that also parameterises
// itself as <List<Job>> — that is how the sealed hierarchy stays typed.
final class Failure<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;
  const Failure(this.message, {this.statusCode});
}
