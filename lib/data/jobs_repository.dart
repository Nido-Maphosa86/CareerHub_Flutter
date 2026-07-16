// lib/data/jobs_repository.dart
//
// The whole network layer for jobs lives here and nothing above it knows. A dio
// provider builds one configured HTTP client (base URL read from the build
// environment, timeouts, and a LogInterceptor that prints every request and
// response to the terminal). A jobsRepository provider hands that client to
// JobsRepository. The repository itself is plain Dart: it takes a Dio in its
// constructor, calls the jobs endpoint, unwraps the paged envelope, turns each
// row into a JobDto and then a Job, and now returns an ApiResult wrapping the
// list. On a DioException the switch expression below (with guard clauses on
// the response status) chooses a human-readable message, so the notifier and
// the widget never see a raw exception or a stack trace.

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/job.dart';
import 'api_result.dart';
import 'job_dto.dart';

part 'jobs_repository.g.dart';

// Builds the shared Dio client. String.fromEnvironment reads the base URL at
// build time, defaulting to 10.0.2.2 (the Android emulator's alias for the host
// machine's localhost). Override per run with --dart-define=API_BASE_URL=...
@riverpod
Dio dio(Ref ref) {
  final client = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://10.0.2.2:5000',
      ),
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  // Logs the method, URL, headers, and body of every request and response, so
  // the network round-trip is visible while developing.
  client.interceptors.add(
    LogInterceptor(requestBody: true, responseBody: true),
  );

  return client;
}

// Hands the configured Dio to the repository. Callers watch this, never Dio.
@riverpod
JobsRepository jobsRepository(Ref ref) {
  return JobsRepository(ref.watch(dioProvider));
}

// Plain Dart. It receives Dio through its constructor and imports nothing from
// Riverpod, so it can be reused or unit-tested without a ProviderScope.
class JobsRepository {
  final Dio _dio;

  JobsRepository(this._dio);

  // Calls GET /api/jobs and returns an ApiResult wrapping the parsed list.
  // Every path exits with either Success or Failure — callers never catch
  // exceptions and never see a DioException.
  Future<ApiResult<List<Job>>> getJobs() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/jobs');

      // The list endpoint returns a paging envelope; the rows live under "data".
      final body = response.data ?? const <String, dynamic>{};
      final rows = (body['data'] as List<dynamic>?) ?? const [];

      // Named-record destructuring at the call site. _parseRows returns both
      // the raw DTOs and the mapped Jobs; the UI only needs the Jobs today,
      // but the DTOs are already there if a future feature (search matching,
      // audit logging) ever needs them.
      final (dtos: _, :jobs) = _parseRows(rows);

      return Success(jobs);
    } on DioException catch (e) {
      // A raw DioException would land in the widget as a stack trace. Instead
      // we build a short readable line here and hand it back as a Failure.
      return Failure(
        _friendlyErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      // Any non-Dio problem (JSON shape wrong, cast failure, ...) is still
      // caught so nothing leaks to the UI as an exception.
      return Failure('Something unexpected went wrong loading jobs.');
    }
  }

  // Returns both the DTOs and the domain-mapped Jobs from one pass over the
  // rows. The named-record return type lets the call site pick out whichever
  // it needs by name — (dtos: ..., jobs: ...) — instead of relying on tuple
  // order. Positional tuples make it easy to swap parameters silently at the
  // call site; named records do not.
  ({List<JobDto> dtos, List<Job> jobs}) _parseRows(List<dynamic> rows) {
    final dtos = rows
        .map((row) => JobDto.fromJson(row as Map<String, dynamic>))
        .toList();
    final jobs = dtos.map(Job.fromDto).toList();
    return (dtos: dtos, jobs: jobs);
  }

  // Picks a readable line for each kind of DioException. Written as a switch
  // expression on e.type; the two badResponse arms use `when` guard clauses
  // so a 5xx and a 4xx can point at different messages while still matching
  // the same DioExceptionType. The trailing _ arm covers cancellations and
  // any other exception type we did not name explicitly.
  String _friendlyErrorMessage(DioException e) {
    final status = e.response?.statusCode ?? 0;
    return switch (e.type) {
      DioExceptionType.connectionTimeout =>
        'The server took too long to accept the connection.',
      DioExceptionType.sendTimeout =>
        'The request took too long to send.',
      DioExceptionType.receiveTimeout =>
        'The server took too long to respond.',
      DioExceptionType.connectionError =>
        'Could not reach the server. Check that the CareerHub API is running.',
      DioExceptionType.badResponse when status >= 500 =>
        'The server is having trouble right now. Please try again later.',
      DioExceptionType.badResponse when status >= 400 =>
        'The request could not be completed ($status).',
      _ => 'Something went wrong. Please try again.',
    };
  }
}
