// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'applications_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ApplicationsNotifier)
const applicationsProvider = ApplicationsNotifierProvider._();

final class ApplicationsNotifierProvider
    extends $AsyncNotifierProvider<ApplicationsNotifier, List<JobApplication>> {
  const ApplicationsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'applicationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$applicationsNotifierHash();

  @$internal
  @override
  ApplicationsNotifier create() => ApplicationsNotifier();
}

String _$applicationsNotifierHash() =>
    r'f2efeb8bcbb730f5c70f559347bdf2f093ac94e4';

abstract class _$ApplicationsNotifier
    extends $AsyncNotifier<List<JobApplication>> {
  FutureOr<List<JobApplication>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<JobApplication>>, List<JobApplication>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<JobApplication>>,
                List<JobApplication>
              >,
              AsyncValue<List<JobApplication>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
