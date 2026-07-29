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
//Runs once, the first time anything reads this provider. ref.watch(prefsProvider) 
//grabs the real SharedPreferences instance. prefs.getString('selected_filter') 
//looks for whatever was saved last time. ?? kFilterAll falls back to "All" if nothing was ever saved — first-ever launch.
class FilterNotifier extends _$FilterNotifier {
  @override
  String build() {
    final prefs = ref.watch(prefsProvider);
    return prefs.getString('selected_filter') ?? kFilterAll;
  }

//Called whenever a chip is tapped. ref.read (not watch) — correct here since this is a one-time action, not a build-time subscription.
  void select(String value) {
    final prefs = ref.read(prefsProvider);
    prefs.setString('selected_filter', value);//save the choice to te device
    state = value;
  }
}
