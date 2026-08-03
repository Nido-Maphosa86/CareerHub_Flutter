// lib/data/jobs_repository.dart
//
// The only file allowed to talk to the jobs network endpoint. dioProvider now
// includes an AuthInterceptor that attaches Bearer tokens to every request and
// silently refreshes them on 401. JobsRepository itself is unchanged — it still
// takes a Dio and an Isar in its constructor and knows nothing about auth.

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar_community/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/app_config.dart';
import '../core/isar_provider.dart';
import '../models/job.dart';
import '../providers/auth_provider.dart';
import 'api_result.dart';
import 'auth_interceptor.dart';
import 'job_cache.dart';
import 'job_dto.dart';

part 'jobs_repository.g.dart';

// The app-wide authenticated Dio client. Every request sent through this client
// automatically carries a Bearer token (from AuthInterceptor.onRequest) and
// transparently refreshes the token on 401 (from AuthInterceptor.onError).
@riverpod
Dio dio(Ref ref) {
  final baseUrl = AppConfig.apiBaseUrl;

  final client = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  // Request/response body logging only in dev — a prod build must never print
  // Bearer tokens or applicant PII to a device log.
  if (AppConfig.environment == 'dev') {
    // LogInterceptor first so every outgoing request and incoming response is
    // printed to the terminal before AuthInterceptor adds/modifies headers.
    client.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  // A second plain Dio used by the interceptor for the refresh call and for
  // retrying requests after a successful refresh. It must be separate from
  // the main client so that retried requests bypass this interceptor and do
  // not trigger another onError round.
  final retryDio = Dio(BaseOptions(baseUrl: baseUrl));

  // AuthInterceptor reads the callback from onUnauthenticatedProvider via
  // ref.read. The callback invalidates authNotifierProvider, which causes
  // build() to run again, find empty storage, and return Unauthenticated.
  client.interceptors.add(
    AuthInterceptor(
      storage: const FlutterSecureStorage(),
      retryDio: retryDio,
      onUnauthenticated: ref.read(onUnauthenticatedProvider),
    ),
  );

  return client;
}

@riverpod
JobsRepository jobsRepository(Ref ref) {
  return JobsRepository(
    dio: ref.watch(dioProvider),
    isar: ref.watch(isarProvider),
  );
}

class JobsRepository {
  final Dio _dio;
  final Isar _isar;

  JobsRepository({required Dio dio, required Isar isar})
      : _dio = dio,
        _isar = isar;

  // Reads every cached job from Isar. No network call. Returns an empty list
  // if the cache has never been populated (first install, or after a clear).
  Future<List<Job>> getCachedJobs() async {
    final cached = await _isar.jobCaches.where().findAll();
    return cached.map(_cacheToJob).toList();
  }

  // Fetches the jobs list from the API, writes it to Isar, and returns an
  // ApiResult. The AuthInterceptor attached to _dio handles token attachment
  // and 401 recovery transparently — this method never deals with auth directly.
  Future<ApiResult<List<Job>>> getJobs() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/jobs');

      final body = response.data ?? const <String, dynamic>{};
      final rows = (body['data'] as List<dynamic>?) ?? const [];

      final (dtos: _, :jobs) = _parseRows(rows);

      // Atomically replace the cached jobs so stale entries from a previous
      // response never mix with the fresh list.
      await _isar.writeTxn(() async {
        await _isar.jobCaches.clear();
        await _isar.jobCaches.putAll(jobs.map(_jobToCache).toList());
      });

      return Success(jobs);
    } on DioException catch (e) {
      return Failure<List<Job>>(
        _friendlyErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      return Failure('Something unexpected went wrong loading jobs.');
    }
  }

  // Converts a stored Isar row back into a Job domain object.
  Job _cacheToJob(JobCache c) {
    return Job(
      id: c.jobId,
      title: c.title,
      company: c.company,
      location: c.location,
      employmentType: c.employmentType,
      isOpen: c.isOpen,
      salary: c.salary,
      closingDate: c.closingDate,
      description: c.description,
    );
  }

  // Converts a Job domain object into a JobCache row ready for Isar storage.
  JobCache _jobToCache(Job job) {
    return JobCache()
      ..jobId = job.id
      ..title = job.title
      ..company = job.company
      ..location = job.location
      ..employmentType = job.employmentType
      ..isOpen = job.isOpen
      ..salary = job.salary
      ..closingDate = job.closingDate
      ..description = job.description;
  }

  // Parses raw JSON rows into DTOs then maps each DTO to a domain Job. The
  // named-record return type lets the call site pick out whichever it needs
  // without relying on positional tuple order.
  ({List<JobDto> dtos, List<Job> jobs}) _parseRows(List<dynamic> rows) {
    final dtos = rows
        .map((row) => JobDto.fromJson(row as Map<String, dynamic>))
        .toList();
    final jobs = dtos.map(Job.fromDto).toList();
    return (dtos: dtos, jobs: jobs);
  }

  // Maps a DioException to a human-readable message. A null statusCode means
  // no HTTP response was ever received (transport-level failure) — the
  // DioExceptionType tells us whether that was a flat-out unreachable server
  // or a timeout partway through. A non-null statusCode means the server did
  // respond, and each status code gets its own specific message rather than
  // a single generic string for every non-200 response.
  String _friendlyErrorMessage(DioException e) {
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

    return switch (status) {
      401 => 'Your session has expired. Please sign in again.',
      404 => 'No jobs were found.',
      503 => 'The server is temporarily unavailable. Please try again later.',
      _ => 'The request could not be completed ($status).',
    };
  }
}
