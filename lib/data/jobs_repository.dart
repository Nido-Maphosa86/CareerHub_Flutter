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

@riverpod /// builds a JobsRepository provider that can be injected into other providers or widgets. It takes a Ref object as an argument, which allows it to read other providers.
JobsRepository jobsRepository(Ref ref) {
  return JobsRepository(
    dio: ref.watch(dioProvider), //https client for making network requests to the API. It is provided by the dio provider.
    isar: ref.watch(isarProvider),// Isar database instance for caching job data locally. It is provided by the isarProvider.
  );
}

class JobsRepository {
  final Dio _dio;
  final Isar _isar;

  JobsRepository({required Dio dio, required Isar isar})
      : _dio = dio,
        _isar = isar;
 

 //accesses the Isar database to retrieve all cached jobs, 
 //converts them from JobCache objects to Job objects, and returns them as a list. 
 //This allows the app to display job listings even when offline.
 //no network requests are made in this method; it only interacts with the local cache.
  Future<List<Job>> getCachedJobs() async {
    final cached = await _isar.jobCaches.where().findAll();
    return cached.map(_cacheToJob).toList();
  }
   
   //Sends the real GET request, unwraps the paging envelope, parses rows into Job objects
  Future<ApiResult<List<Job>>> getJobs() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/jobs');

      final body = response.data ?? const <String, dynamic>{};
      final rows = (body['data'] as List<dynamic>?) ?? const [];

      final (dtos: _, :jobs) = _parseRows(rows);

      await _isar.writeTxn(() async {
        await _isar.jobCaches.clear();//wipes the cache before saving the new jobs to ensure that the cache always reflects the latest data from the API. This prevents stale or outdated job listings from being displayed to the user.
        await _isar.jobCaches.putAll(jobs.map(_jobToCache).toList());//saves the newly fetched jobs to the Isar cache. Each Job object is converted to a JobCache object before being stored, allowing for offline access to the job listings.
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
