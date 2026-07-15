// lib/data/jobs_repository.dart
//
// The whole network layer for jobs lives here and nothing above it knows. A dio
// provider builds one configured HTTP client (base URL read from the build
// environment, timeouts, and a LogInterceptor that prints every request and
// response to the terminal). A jobsRepository provider hands that client to
// JobsRepository. The repository itself is plain Dart: it takes a Dio in its
// constructor, calls the jobs endpoint, unwraps the paged envelope, turns each
// row into a JobDto and then a Job, and returns the list. Because the class only
// depends on Dio, swapping Dio for another client changes only this one file.


// the only file allowed to talk to the network

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/job.dart';
import 'job_dto.dart';

part 'jobs_repository.g.dart';

// Builds the shared Dio client. String.fromEnvironment reads the base URL at
// build time, defaulting to 10.0.2.2 (the Android emulator's alias for the host
// machine's localhost). Override per run with --dart-define=API_BASE_URL=...

//dio https client that can be used to make requests to the API
//talks to the API and returns the response
@riverpod
Dio dio(Ref ref) { //function that returns a Dio instance, which is a HTTP client that can be used to make requests to the API
  final client = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://10.0.2.2:5000',
      ),
      connectTimeout: const Duration(seconds: 5),//connection to the api

      receiveTimeout: const Duration(seconds: 5),//server taking too long to respond
    ),
  );

  // Logs the method, URL, headers, and body of every request and response, so
  // the network round-trip is visible while developing.
  client.interceptors.add(
    LogInterceptor(requestBody: true, responseBody: true),
  );

  return client; //return the configured Dio instance, baseurl, timeouts, and logging interceptor
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

  // Calls GET /api/jobs, unwraps the paged "data" array, and maps every row to a
  // Job through JobDto. Everything above this method only ever sees a List<Job>.
  Future<List<Job>> getJobs() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/jobs');

    // The list endpoint returns a paging envelope; the rows live under "data".
    final body = response.data ?? const <String, dynamic>{};
    final rows = (body['data'] as List<dynamic>?) ?? const [];

    return rows
        .map((row) => JobDto.fromJson(row as Map<String, dynamic>))
        .map(Job.fromDto)
        .toList();
  }
}
