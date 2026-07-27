import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/prefs_provider.dart';

part 'filter_notifier.g.dart';

const String kFilterAll = 'All';
const String kFilterRemote = 'Remote';
const String kFilterFullTime = 'Full-time';
const String kFilterPartTime = 'Part-time';
const String kFilterContract = 'Contract';
const String kFilterInternship = 'Internship';

const List<String> kFilterLabels = [
  kFilterAll,
  kFilterRemote,
  kFilterFullTime,
  kFilterPartTime,
  kFilterContract,
  kFilterInternship,
];

@riverpod
class FilterNotifier extends _$FilterNotifier {
  @override
  String build() {
    final prefs = ref.watch(prefsProvider);
    return prefs.getString('selected_filter') ?? kFilterAll;
  }

  void select(String value) {
    final prefs = ref.read(prefsProvider);
    prefs.setString('selected_filter', value);
    state = value;
  }
}
