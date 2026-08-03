import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/prefs_provider.dart';

part 'filter_notifier.g.dart';

const String kFilterAll = 'All';
const _prefKey = 'application_filter';

@riverpod
class ApplicationFilterNotifier extends _$ApplicationFilterNotifier {
  @override
  String build() {
    final prefs = ref.read(prefsProvider);
    return prefs.getString(_prefKey) ?? kFilterAll;
  }

  void select(String filter) {
    final prefs = ref.read(prefsProvider);
    prefs.setString(_prefKey, filter);
    state = filter;
  }
}
