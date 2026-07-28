// lib/data/auth_interceptor.dart
//
// A Dio interceptor that transparently manages Bearer token auth for every
// outgoing request and handles 401 responses by attempting a silent token
// refresh before any error reaches the UI.
//
// This file has NO Riverpod import. It is in the data layer and communicates
// with the provider layer exclusively through the onUnauthenticated callback
// injected at construction time. This prevents a circular dependency:
//   data layer -> providers layer -> data layer.
//
// The four-case onError handler processes 401s in this order:
//   Case 1: Not a 401 — pass through unchanged.
//   Case 2: 401 on the refresh endpoint itself — the refresh token is expired.
//           Drain the queue, clear storage, and call onUnauthenticated.
//   Case 3: 401 while a refresh is already in progress — queue this request
//           on a Completer and wait. When the refresh completes, the waiting
//           request retries with the new token automatically.
//   Case 4: 401 with no refresh in progress — perform the refresh. On success,
//           complete every waiting Completer with the new token and retry the
//           original request. On failure, drain the queue and call onUnauthenticated.

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// These constants must match the ones in auth_repository.dart exactly. If they
// diverge, the interceptor reads from a different storage slot than the
// repository writes to, and every request will be sent without a token.
const _accessTokenKey = 'access_token';
const _refreshTokenKey = 'refresh_token';

// The path segment that identifies the refresh endpoint. Used in Case 2 to
// detect when the refresh request itself received a 401, which means the
// refresh token is definitively expired and further refresh attempts are futile.
const _refreshPath = '/api/auth/refresh';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  // A second Dio instance used for the refresh call and for retrying the
  // original request after a successful refresh. This must NOT be the same Dio
  // that this interceptor is attached to — using the same instance would cause
  // the retry to pass through this interceptor again and potentially loop.
  final Dio _retryDio;

  // Called when a refresh definitively fails (expired refresh token or network
  // error). Triggers a rebuild of AuthNotifier, which finds empty storage and
  // returns Unauthenticated, which the router redirects to /login.
  final void Function() _onUnauthenticated;

  // Guards against multiple concurrent refresh attempts. Only one refresh
  // should ever be in flight at a time — see Case 3 for how waiting requests
  // are queued while a refresh is already in progress.
  bool _isRefreshing = false;

  // Requests that arrived during an in-progress refresh wait here. Each holds
  // a Completer<String> whose future the waiting request awaits. When the
  // refresh completes, all Completers in this list are completed with the new
  // access token so every waiting request can retry simultaneously.
  final List<Completer<String>> _queue = [];

  AuthInterceptor({
    required FlutterSecureStorage storage,
    required Dio retryDio,
    required void Function() onUnauthenticated,
  })  : _storage = storage,
        _retryDio = retryDio,
        _onUnauthenticated = onUnauthenticated;

  // Attaches the stored access token to every outgoing request as a Bearer
  // header. If no token is stored (e.g. on the login request itself), the
  // request is passed through without modification.
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: _accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Case 1 — Not a 401. Pass through to the normal error handling path.
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Case 2 — 401 on the refresh endpoint itself. The refresh token is
    // invalid or expired. Completing every queued Completer with an error
    // unblocks any waiting requests (they will resolve via handler.next with
    // the original error). Then clear storage and redirect to login.
    if (err.requestOptions.path.contains(_refreshPath)) {
      _drainQueue(err);
      await _storage.deleteAll();
      _onUnauthenticated();
      handler.next(err);
      return;
    }

    // Case 3 — 401 while a refresh is already in progress. Queue this request
    // on a new Completer and suspend it. The Completer is resolved in Case 4
    // when the refresh completes. If the refresh fails the Completer is
    // resolved with an error and the catch block falls through to handler.next.
    if (_isRefreshing) {
      final completer = Completer<String>();
      _queue.add(completer);
      try {
        final newToken = await completer.future;
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final response = await _retryDio.fetch(err.requestOptions);
        handler.resolve(response);
      } catch (_) {
        handler.next(err);
      }
      return;
    }

    // Case 4 — 401 with no refresh in progress. This request is the first to
    // notice the expired token. It performs the refresh on behalf of all
    // concurrent requests that will queue in Case 3 while this is in flight.
    _isRefreshing = true;
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) {
        _drainQueue(err);
        await _storage.deleteAll();
        _onUnauthenticated();
        handler.next(err);
        return;
      }

      // POST to the refresh endpoint using retryDio so this call bypasses this
      // interceptor and does not trigger another round of Case 1–4.
      final response = await _retryDio.post<Map<String, dynamic>>(
        _refreshPath,
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data!['accessToken'] as String;
      final newRefreshToken = response.data!['refreshToken'] as String?;

      await _storage.write(key: _accessTokenKey, value: newAccessToken);
      if (newRefreshToken != null) {
        await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
      }

      // Unblock every queued request with the new token. They will each attach
      // it to their headers and retry via retryDio.fetch inside Case 3.
      for (final c in _queue) {
        c.complete(newAccessToken);
      }
      _queue.clear();

      // Retry the original request that triggered this refresh.
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryResponse = await _retryDio.fetch(err.requestOptions);
      handler.resolve(retryResponse);
    } catch (e) {
      // Refresh failed — drain the queue so waiting requests do not hang
      // indefinitely, then clear storage and redirect to the login screen.
      _drainQueue(err);
      await _storage.deleteAll();
      _onUnauthenticated();
      handler.next(err);
    } finally {
      // Always reset _isRefreshing, even if an exception was thrown. Without
      // this, _isRefreshing stays true permanently and every subsequent 401
      // hits Case 3 forever, queuing but never resolving.
      _isRefreshing = false;
    }
  }

  // Completes every Completer in the queue with an error, then clears the list.
  // Calling completeError unblocks the awaiting future in Case 3, which falls
  // into the catch block and calls handler.next with the original error.
  void _drainQueue(DioException err) {
    for (final c in _queue) {
      c.completeError(err);
    }
    _queue.clear();
  }
}
