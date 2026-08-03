// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apply_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ApplyNotifier)
const applyProvider = ApplyNotifierProvider._();

final class ApplyNotifierProvider
    extends $AsyncNotifierProvider<ApplyNotifier, void> {
  const ApplyNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'applyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$applyNotifierHash();

  @$internal
  @override
  ApplyNotifier create() => ApplyNotifier();
}

String _$applyNotifierHash() => r'eadfc74989af37ae87b4ce5f9b6fbf1f8541b43d';

abstract class _$ApplyNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
