import 'package:dio/dio.dart';
import 'package:isar_community/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/isar_provider.dart';
import '../models/job.dart';
import 'api_result.dart';
import 'job_cache.dart';
import 'job_dto.dart';

part 'jobs_repository.g.dart';

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
  client.interceptors.add(
    LogInterceptor(requestBody: true, responseBody: true),
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

  Future<List<Job>> getCachedJobs() async {
    final cached = await _isar.jobCaches.where().findAll();
    return cached.map(_cacheToJob).toList();
  }

  Future<ApiResult<List<Job>>> getJobs() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/jobs');

      final body = response.data ?? const <String, dynamic>{};
      final rows = (body['data'] as List<dynamic>?) ?? const [];

      final (dtos: _, :jobs) = _parseRows(rows);

      await _isar.writeTxn(() async {
        await _isar.jobCaches.clear();
        await _isar.jobCaches.putAll(jobs.map(_jobToCache).toList());
      });

      return Success(jobs);
    } on DioException catch (e) {
      return Failure(
        _friendlyErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      return Failure('Something unexpected went wrong loading jobs.');
    }
  }

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

  ({List<JobDto> dtos, List<Job> jobs}) _parseRows(List<dynamic> rows) {
    final dtos = rows
        .map((row) => JobDto.fromJson(row as Map<String, dynamic>))
        .toList();
    final jobs = dtos.map(Job.fromDto).toList();
    return (dtos: dtos, jobs: jobs);
  }

  String _friendlyErrorMessage(DioException e) {
    final status = e.response?.statusCode ?? 0;
    return switch (e.type) {
      DioExceptionType.connectionTimeout =>
        'The server took too long to accept the connection.',
      DioExceptionType.sendTimeout => 'The request took too long to send.',
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
