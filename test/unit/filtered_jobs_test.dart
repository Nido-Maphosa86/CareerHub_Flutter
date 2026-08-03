// test/unit/filtered_jobs_test.dart
//
// Unit tests for filteredJobsProvider. No mocktail here — the subclass-override
// pattern is the right tool because we are testing observable state transitions,
// not call counts on a dependency. The fake notifier returns a fixed list
// synchronously so the tests run without any async waiting on network or Isar.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careerhub/models/job.dart';
import 'package:careerhub/providers/filter_notifier.dart';
import 'package:careerhub/providers/job_providers.dart';
import 'package:careerhub/providers/jobs_notifier.dart';

// Three fixtures with two distinct employment types so every filter test
// produces a non-trivial, verifiable subset.
final _fullTimeA = Job(
  id: '1',
  title: 'Flutter Developer',
  company: 'Yoco',
  location: 'Cape Town',
  employmentType: 'Full-time',
  isOpen: true,
);

final _fullTimeB = Job(
  id: '2',
  title: 'Backend Engineer',
  company: 'BBD',
  location: 'Johannesburg',
  employmentType: 'Full-time',
  isOpen: true,
);

final _contract = Job(
  id: '3',
  title: 'Mobile Developer',
  company: 'Luno',
  location: 'Remote',
  employmentType: 'Contract',
  isOpen: true,
);

// Fake notifier returns all three jobs synchronously. The subclass-override
// pattern bypasses the real build() entirely — no repository, no Isar, no
// network call.
class _FakeJobsNotifier extends JobsNotifier {
  @override
  Future<List<Job>> build() async {
    return [_fullTimeA, _fullTimeB, _contract];
  }
}

// Helper that builds a fresh container with the fake notifier injected and
// registers disposal so onDispose callbacks do not accumulate between tests.
ProviderContainer _makeContainer() {
  final container = ProviderContainer(
    overrides: [
      jobsProvider.overrideWith(_FakeJobsNotifier.new),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('filteredJobsProvider', () {
    test('returns all jobs when filter is All', () async {
      final container = _makeContainer();

      // Wait for the fake notifier's build() to complete.
      await container.read(jobsProvider.future);

      final result = container.read(filteredJobsProvider);

      // whenData unwraps the AsyncValue — if the provider is in an error or
      // loading state this assertion fails, which is the correct behaviour.
      result.whenData((jobs) {
        expect(jobs.length, equals(3));
        expect(jobs, containsAll([_fullTimeA, _fullTimeB, _contract]));
      });
    });

    test('returns only matching jobs when a specific filter is set', () async {
      final container = _makeContainer();
      await container.read(jobsProvider.future);

      // Write a new filter value directly into the StateProvider. This is the
      // same mechanism the chip row uses — no UI interaction needed.
      container.read(filterProvider.notifier).select(kFilterFullTime);

      final result = container.read(filteredJobsProvider);

      result.whenData((jobs) {
        expect(jobs.length, equals(2));
        expect(jobs, containsAll([_fullTimeA, _fullTimeB]));
        expect(jobs, isNot(contains(_contract)));
      });
    });

    test('updates result when filter changes', () async {
      final container = _makeContainer();
      await container.read(jobsProvider.future);

      // First read with All filter — should return all three jobs.
      final allResult = container.read(filteredJobsProvider);
      List<Job> allJobs = [];
      allResult.whenData((jobs) => allJobs = jobs);
      expect(allJobs.length, equals(3));

      // Change filter to Contract — should return only the contract job.
      container.read(filterProvider.notifier).select(kFilterContract);

      final contractResult = container.read(filteredJobsProvider);
      List<Job> contractJobs = [];
      contractResult.whenData((jobs) => contractJobs = jobs);

      expect(contractJobs.length, equals(1));
      expect(contractJobs.first, equals(_contract));

      // The two lists must be different — this confirms the filter actually
      // changed the output, not that both reads returned the same value.
      expect(allJobs, isNot(equals(contractJobs)));
    });
  });
}