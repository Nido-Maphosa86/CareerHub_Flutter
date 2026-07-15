// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jobs_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(JobsNotifier)
const jobsProvider = JobsNotifierProvider._();

final class JobsNotifierProvider
    extends $AsyncNotifierProvider<JobsNotifier, List<Job>> {
  const JobsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jobsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jobsNotifierHash();

  @$internal
  @override
  JobsNotifier create() => JobsNotifier();
}

String _$jobsNotifierHash() => r'2a51f76f3de38cefa76037e9200712440f3ae9fc';

abstract class _$JobsNotifier extends $AsyncNotifier<List<Job>> {
  FutureOr<List<Job>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Job>>, List<Job>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Job>>, List<Job>>,
              AsyncValue<List<Job>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
