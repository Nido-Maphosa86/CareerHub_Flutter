import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/applications_repository.dart';
import '../domain/application_status.dart';

part 'filter_notifier.g.dart';

const String kFilterAll = 'All';
const _prefKey = 'application_filter';

@riverpod
class ApplicationFilterNotifier extends _$ApplicationFilterNotifier {
  @override
  String build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getString(_prefKey) ?? kFilterAll;
  }

  void select(String filter) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_prefKey, filter);
    state = filter;
  }
}
