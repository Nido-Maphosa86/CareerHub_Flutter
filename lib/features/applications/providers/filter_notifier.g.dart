// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ApplicationFilterNotifier)
const applicationFilterProvider = ApplicationFilterNotifierProvider._();

final class ApplicationFilterNotifierProvider
    extends $NotifierProvider<ApplicationFilterNotifier, String> {
  const ApplicationFilterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'applicationFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$applicationFilterNotifierHash();

  @$internal
  @override
  ApplicationFilterNotifier create() => ApplicationFilterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$applicationFilterNotifierHash() =>
    r'226191a71f4e47e41e612cd1c6f2f2c1dc686c07';

abstract class _$ApplicationFilterNotifier extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
