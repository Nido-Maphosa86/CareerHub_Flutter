// test/unit/jobs_notifier_test.dart
//
// Unit tests for JobsNotifier. Uses mocktail to stub JobsRepository so
// we can control what getJobs() and getCachedJobs() return without any
// network, Isar, or FlutterSecureStorage involved.
//
// Why mocktail here (not subclass-override): we need to verify that getJobs()
// is called exactly once — a call count the subclass-override pattern cannot
// detect because it bypasses the real build() entirely.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:careerhub/data/api_result.dart';
import 'package:careerhub/data/jobs_repository.dart';
import 'package:careerhub/models/job.dart';
import 'package:careerhub/providers/jobs_notifier.dart';

// Single-line mock declaration — no code generation required. mocktail uses
// noSuchMethod under the hood to intercept every method call.
class MockJobsRepository extends Mock implements JobsRepository {}

// Shared test fixtures declared at the top level so they are created once and
// reused across all tests. Creating fixtures inside individual test functions
// risks silent divergence when the Job model changes.
final _jobA = Job(
  id: 'a',
  title: 'Flutter Developer',
  company: 'Yoco',
  location: 'Cape Town',
  employmentType: 'Full-time',
  isOpen: true,
  salary: 'R55 000 – R75 000',
  closingDate: DateTime(2027, 1, 1),
);

final _jobB = Job(
  id: 'b',
  title: 'Backend Engineer',
  company: 'BBD',
  location: 'Johannesburg',
  employmentType: 'Contract',
  isOpen: true,
  salary: 'R60 000 – R80 000',
  closingDate: DateTime(2027, 3, 1),
);

final _fakeJobs = [_jobA, _jobB];

void main() {
  late MockJobsRepository mockRepo;

  setUp(() {
    mockRepo = MockJobsRepository();
    // getCachedJobs() is called first in build(). Return an empty list by
    // default so tests that only care about getJobs() are not affected by
    // cached state.
    when(() => mockRepo.getCachedJobs()).thenAnswer((_) async => []);
  });

  // Helper that builds a fresh ProviderContainer with the mock repository
  // injected and registers teardown so the container is always disposed after
  // the test — even if the test throws. Without disposal, onDispose callbacks
  // (such as the connectivity stream subscription) accumulate across tests and
  // leak memory.
  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        jobsRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('JobsNotifier', () {
    test(
        'transitions from loading to data '
        'when getJobs returns Success', () async {
      // Stub getJobs() to return a known list.
      when(() => mockRepo.getJobs())
          .thenAnswer((_) async => Success(_fakeJobs));

      final container = makeContainer();

      // Immediately after creation the provider is AsyncLoading — build() has
      // been kicked off but the Future has not yet resolved.
      expect(
        container.read(jobsProvider),
        isA<AsyncLoading<List<Job>>>(),
      );

      // Await the future to let build() run to completion.
      await container.read(jobsProvider.future);

      // After the future resolves, the provider must hold the exact list
      // returned by the stub.
      expect(
        container.read(jobsProvider).value,
        equals(_fakeJobs),
      );

      // Verify the repository was called exactly once — a call count the
      // subclass-override pattern cannot detect.
      verify(() => mockRepo.getJobs()).called(1);
    });

    test(
        'transitions from loading to error '
        'when getJobs returns Failure', () async {
      when(() => mockRepo.getJobs()).thenAnswer(
        (_) async => Failure('Network error'),
      );

      final container = makeContainer();

      expect(
        container.read(jobsProvider),
        isA<AsyncLoading<List<Job>>>(),
      );

      // build() re-throws the Failure message as an Exception so Riverpod
      // stores it as AsyncError. expectLater asserts the future rejects.
      await expectLater(
        container.read(jobsProvider.future),
        throwsA(isA<Exception>()),
      );

      // After rejection, the provider must be in the AsyncError state.
      expect(
        container.read(jobsProvider),
        isA<AsyncError<List<Job>>>(),
      );

      verify(() => mockRepo.getJobs()).called(1);
    });

    test(
        'recovers to data after refresh() '
        'following an error', () async {
      // Control return value by call order. First call fails, second succeeds.
      var callCount = 0;
      when(() => mockRepo.getJobs()).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) return Failure('Network error');
        return Success(_fakeJobs);
      });

      final container = makeContainer();

      // First build — should land in error state.
      await expectLater(
        container.read(jobsProvider.future),
        throwsA(isA<Exception>()),
      );
      expect(container.read(jobsProvider), isA<AsyncError<List<Job>>>());

      // refresh() invalidates the notifier and awaits the new build() — after
      // this returns the provider must be in the data state with the jobs list.
      await container.read(jobsProvider.notifier).refresh();

      expect(
        container.read(jobsProvider).value,
        equals(_fakeJobs),
      );

      // getJobs() must have been called exactly twice — once for the first
      // failed build, once for the refresh.
      verify(() => mockRepo.getJobs()).called(2);
    });
  });
}
