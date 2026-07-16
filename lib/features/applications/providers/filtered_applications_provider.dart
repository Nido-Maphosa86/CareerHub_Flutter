import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/application_status.dart';
import '../domain/job_application.dart';
import 'applications_notifier.dart';
import 'filter_notifier.dart';

final filteredApplicationsProvider = Provider<AsyncValue<List<JobApplication>>>(
  (ref) {
    final asyncApps = ref.watch(applicationsProvider);
    final filter = ref.watch(applicationFilterProvider);

    return asyncApps.whenData((apps) {
      if (filter == kFilterAll) return apps;
      return apps.where((a) => a.status.displayLabel == filter).toList();
    });
  },
);
