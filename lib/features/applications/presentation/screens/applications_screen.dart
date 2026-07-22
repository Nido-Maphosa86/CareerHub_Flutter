import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/application_status.dart';
import '../../providers/applications_notifier.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/filter_notifier.dart';
import '../../providers/filtered_applications_provider.dart';
import '../widgets/application_card.dart';

class ApplicationsScreen extends ConsumerWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncApps = ref.watch(filteredApplicationsProvider);
    final selectedFilter = ref.watch(applicationFilterProvider);
    final isOffline = ref.watch(isOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          if (isOffline)
            Container(
              width: double.infinity,
              color: Colors.orange.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'You are offline. Showing cached data.',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          _FilterChipsRow(selectedFilter: selectedFilter, ref: ref),
          Expanded(
            child: asyncApps.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_outlined, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        error.toString().replaceFirst('Exception: ', ''),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => ref.invalidate(applicationsProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (apps) {
                if (apps.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined, size: 48),
                        SizedBox(height: 16),
                        Text('No applications match this filter.'),
                      ],
                    ),
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      return ListView.builder(
                        itemCount: apps.length,
                        itemBuilder: (context, index) =>
                            ApplicationCard(application: apps[index]),
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 160,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: apps.length,
                      itemBuilder: (context, index) =>
                          ApplicationCard(application: apps[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  final String selectedFilter;
  final WidgetRef ref;

  const _FilterChipsRow({required this.selectedFilter, required this.ref});

  @override
  Widget build(BuildContext context) {
    final filters = [
      kFilterAll,
      ...ApplicationStatus.values.map((s) => s.displayLabel),
    ];

    return SizedBox(
      height: 56,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: filters
              .map((label) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: selectedFilter == label,
                      onSelected: (_) => ref
                          .read(applicationFilterProvider.notifier)
                          .select(label),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}