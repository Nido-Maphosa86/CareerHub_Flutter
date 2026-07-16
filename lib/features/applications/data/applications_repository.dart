import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/api_result.dart';
import '../../../data/jobs_repository.dart';
import '../domain/application_status.dart';
import '../domain/job_application.dart';
import 'application_dto.dart';

part 'applications_repository.g.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main',
  );
});

@riverpod
ApplicationsRepository applicationsRepository(Ref ref) {
  return ApplicationsRepository(
    dio: ref.watch(dioProvider),
    prefs: ref.watch(sharedPreferencesProvider),
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

  Future<ApiResult<List<JobApplication>>> fetchAndCache(
    String bearerToken,
  ) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/api/applications/my',
        options: Options(headers: {'Authorization': 'Bearer $bearerToken'}),
      );

      final dtos = (response.data ?? [])
          .map((e) => ApplicationDto.fromJson(e as Map<String, dynamic>))
          .toList();

      final applications = dtos.map((d) => d.toDomain()).toList();
      await _writeCache(applications);
      return Success(applications);
    } on DioException catch (e) {
      return Failure(_message(e), statusCode: e.response?.statusCode);
    } catch (_) {
      return Failure('Something unexpected went wrong.');
    }
  }

  String _message(DioException e) {
    final status = e.response?.statusCode ?? 0;
    return switch (e.type) {
      DioExceptionType.connectionError =>
        'Could not reach the server. Check your connection.',
      DioExceptionType.badResponse when status >= 500 =>
        'The server is having trouble. Please try again later.',
      DioExceptionType.badResponse when status >= 400 =>
        'Request failed ($status).',
      _ => 'Something went wrong. Please try again.',
    };
  }
}
