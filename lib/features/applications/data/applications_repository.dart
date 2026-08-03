import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/prefs_provider.dart';
import '../../../data/api_result.dart';
import '../../../data/jobs_repository.dart';
import '../domain/application_status.dart';
import '../domain/job_application.dart';
import 'application_dto.dart';

part 'applications_repository.g.dart';

@riverpod
ApplicationsRepository applicationsRepository(Ref ref) {
  return ApplicationsRepository(
    dio: ref.watch(dioProvider),
    prefs: ref.watch(prefsProvider),
  );
}

class ApplicationsRepository {
  final Dio _dio;
  final SharedPreferences _prefs;
  static const _cacheKey = 'cached_applications';

  ApplicationsRepository({required Dio dio, required SharedPreferences prefs})
    : _dio = dio,
      _prefs = prefs;

  List<JobApplication> readCache() {
    final raw = _prefs.getString(_cacheKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return JobApplication(
        id: m['id'] as String,
        jobTitle: m['jobTitle'] as String,
        companyName: m['companyName'] as String,
        submittedAt: DateTime.parse(m['submittedAt'] as String),
        status: ApplicationStatus.fromApi(m['status'] as String),
      );
    }).toList();
  }

  Future<void> _writeCache(List<JobApplication> apps) async {
    final list = apps
        .map(
          (a) => {
            'id': a.id,
            'jobTitle': a.jobTitle,
            'companyName': a.companyName,
            'submittedAt': a.submittedAt.toIso8601String(),
            'status': a.status.name,
          },
        )
        .toList();
    await _prefs.setString(_cacheKey, jsonEncode(list));
  }

  // Fetches the JobSeeker's own applications. No bearer token is passed
  // explicitly — _dio is the shared, AuthInterceptor-wrapped client, which
  // attaches the stored access token to every request and refreshes it on a
  // transparent 401 automatically, exactly like JobsRepository.getJobs().
  Future<ApiResult<List<JobApplication>>> getApplications() async {
    try {
      final response = await _dio.get<List<dynamic>>('/api/applications/my');

      final dtos = (response.data ?? [])
          .map((e) => ApplicationDto.fromJson(e as Map<String, dynamic>))
          .toList();

      final applications = dtos.map((d) => d.toDomain()).toList();
      await _writeCache(applications);
      return Success(applications);
    } on DioException catch (e) {
      return Failure(_networkFailureMessage(e), statusCode: e.response?.statusCode);
    } catch (_) {
      return Failure('Something unexpected went wrong.');
    }
  }

  // Submits a new application for jobId with the form fields collected on
  // ApplyScreen. Returns Success(null) on 201. Every other status the
  // endpoint can return (400/401/409/422, plus network-level failures) maps
  // to a specific, user-facing message rather than one generic string.
  Future<ApiResult<void>> submitApplication({
    required String jobId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/api/applications',
        data: {'jobId': jobId, ...payload},
      );
      return const Success(null);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final message = switch (status) {
        400 => 'The submission contained invalid data. Please check the '
            'highlighted fields and try again.',
        401 => 'Your session has expired. Please sign in again.',
        409 => 'You have already applied for this position.',
        422 => 'This listing is no longer accepting applications.',
        _ => _networkFailureMessage(e),
      };
      return Failure(message, statusCode: status);
    } catch (_) {
      return Failure('Something unexpected went wrong. Please try again.');
    }
  }

  // Shared network-level mapping (null statusCode, or 503) reused by both
  // getApplications() and submitApplication() so a timeout or an unreachable
  // server reads the same regardless of which endpoint failed.
  String _networkFailureMessage(DioException e) {
    final status = e.response?.statusCode;

    if (status == null) {
      return switch (e.type) {
        DioExceptionType.connectionError =>
          'Could not reach the server. Check your network connection.',
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout =>
          'The connection timed out. Please try again.',
        _ => 'Something went wrong. Please try again.',
      };
    }

    if (status == 503) {
      return 'The server is temporarily unavailable. Please try again later.';
    }

    return 'The request could not be completed ($status).';
  }
}
