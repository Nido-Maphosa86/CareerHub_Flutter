// lib/data/auth_repository.dart
//
// The authentication data layer. All JWT handling, token storage, and auth API
// calls live here. Nothing above this file needs to know about FlutterSecureStorage
// or the auth endpoint details.
//
// Two design decisions are mandatory:
// 1. This file creates its own plain Dio (no interceptors, except LogInterceptor
//    for debugging). Using the app-wide dioProvider would cause an infinite
//    loop: a 401 on the refresh endpoint would trigger AuthInterceptor, which
//    would call tryRefresh(), which would send to the refresh endpoint, which
//    would get a 401, which would trigger AuthInterceptor again — forever.
// 2. JWT decoding is a private static method so it can be called from both
//    isTokenExpired() and decodeUser() without duplicating the Base64URL logic.
//
// NOTE: the backend's /api/auth/login and /api/auth/refresh endpoints return
// a single field named "token" — not "accessToken" — and no refresh token at
// all. The field name below is matched to what the API actually sends.

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/auth_state.dart';
import '../models/user.dart';
import 'api_result.dart';

part 'auth_repository.g.dart';

// Storage keys used in both this file and auth_interceptor.dart. Keep them in
// sync — if they diverge the interceptor reads from a different slot than the
// one the repository writes to.
const _accessTokenKey = 'access_token';
const _refreshTokenKey = 'refresh_token';

// This provider deliberately does NOT watch dioProvider. It creates a plain Dio
// with only a baseUrl so it is never intercepted by AuthInterceptor.
@riverpod
AuthRepository authRepository(Ref ref) {
  final baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );
  final dio = Dio(BaseOptions(baseUrl: baseUrl));
  // Debugging interceptor — prints the full request/response for every auth
  // call so login failures are visible in the terminal.
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  return AuthRepository(
    dio: dio,
    storage: const FlutterSecureStorage(),
  );
}

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  const AuthRepository({required Dio dio, required FlutterSecureStorage storage})
      : _dio = dio,
        _storage = storage;

  // Reads the access token from the secure enclave. Returns null if nothing
  // has been stored yet (first install, or after a logout/deleteAll call).
  Future<String?> readAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  // Returns true if the token's exp claim is in the past, or if the token
  // cannot be decoded for any reason. Returning true on decode failure forces a
  // refresh attempt, which is safer than assuming a malformed token is valid.
  bool isTokenExpired(String token) {
    try {
      final payload = _decodePayload(token);
      final exp = payload['exp'];
      if (exp == null) return false;
      final expiry = DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
      return DateTime.now().isAfter(expiry);
    } catch (_) {
      return true;
    }
  }

  // Constructs a User from the token's claims. The "name" claim is optional —
  // if absent, the email is used as the display name so the UI always has
  // something human-readable to show.
  User decodeUser(String token) {
    final payload = _decodePayload(token);
    final email = payload['email'] as String? ?? '';
    return User(
      id: payload['sub'] as String? ?? '',
      email: email,
      displayName: payload['name'] as String? ?? email,
    );
  }

  // Authenticates the user. On success writes the token to secure storage and
  // returns the decoded User. On 400/401 returns a Failure with a credential
  // error message. On any other network error returns a Failure with a generic
  // message.
  //
  // The backend returns {"token": "..."} — a single JWT, no separate refresh
  // token — so only the access token key is written here.
  Future<ApiResult<User>> login(String email, String password) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/login',
        data: {'username': email, 'password': password},
      );

      final data = response.data!;
      final accessToken = data['token'] as String;

      await _storage.write(key: _accessTokenKey, value: accessToken);

      return Success(decodeUser(accessToken));
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0;
      if (status == 400 || status == 401) {
        return Failure('Invalid email or password. Please try again.');
      }
      return Failure('Could not sign in. Check your connection and try again.');
    } catch (_) {
      return Failure('Something unexpected went wrong. Please try again.');
    }
  }

  // Attempts a silent token refresh using the stored refresh token. On success
  // writes the new token and returns the decoded User. On any failure (network
  // error, expired refresh token, missing token) clears secure storage entirely
  // and returns null — the caller must treat null as "session ended".
  //
  // NOTE: since the backend does not currently issue a refresh token at login,
  // _refreshTokenKey will normally be empty and this method will return null
  // immediately. This is expected until the backend supports refresh tokens.
  Future<User?> tryRefresh() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) return null;

      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data!;
      final newAccessToken = data['token'] as String;

      await _storage.write(key: _accessTokenKey, value: newAccessToken);

      return decodeUser(newAccessToken);
    } catch (_) {
      // Any failure — expired token, network issue, bad response — means the
      // session is definitively over. Wipe storage so the next cold boot finds
      // nothing and routes straight to the login screen.
      await _storage.deleteAll();
      return null;
    }
  }

  // Clears both tokens from secure storage. Called by AuthNotifier.logout().
  // After this call, readAccessToken() returns null and tryRefresh() returns
  // null, so the next build() run returns Unauthenticated.
  Future<void> logout() {
    return _storage.deleteAll();
  }

  // Decodes the payload segment of a JWT. JWT format is header.payload.signature
  // where each segment is Base64URL-encoded. Base64URL uses - and _ instead of
  // + and /. The payload length may not be a multiple of four — the formula
  // (4 - length % 4) % 4 pads it to the nearest multiple of four before
  // standard Base64 decoding.
  static Map<String, dynamic> _decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw FormatException('Not a JWT: $token');

    var payload = parts[1]
        .replaceAll('-', '+')
        .replaceAll('_', '/');

    // Add padding so the length is a multiple of four.
    final padLength = (4 - payload.length % 4) % 4;
    payload += '=' * padLength;

    final bytes = base64Decode(payload);
    return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  }
}