// lib/screens/home_screen.dart
//
// This is the main screen, driven entirely by state instead of by data it owns.
// It no longer keeps a list of jobs. Instead it watches the providers and draws
// whatever they currently say:
//   while the jobs are loading  -> a spinner in the middle of the screen
//   if the load failed          -> an icon, a message, and a Retry button
//   once the jobs arrive        -> the responsive list or grid of cards
//   if the filter matched none  -> a short "nothing here" message, never a blank
//
// The list now comes from the network AND from Isar cache. The Retry button
// re-runs the real fetch by invalidating jobsProvider, and the error branch is
// what shows when the API is unreachable AND no cache exists.
//
// The two ref rules, applied strictly:
//   ref.watch inside build()    -> subscribe, so the UI rebuilds on change
//   ref.read inside a callback  -> read once and act, never subscribe

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/job.dart';
import '../providers/connectivity_provider.dart';
import '../providers/filter_notifier.dart';
import '../providers/job_providers.dart';
import '../providers/jobs_notifier.dart';
import '../widgets/job_card.dart';

// The width in pixels where the layout switches from a list to a grid.
const double kGridBreakpoint = 600;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch: this screen must repaint whenever the filtered result changes,
    // whether that is because the jobs finished loading or a chip was tapped.
    final AsyncValue<List<Job>> asyncJobs = ref.watch(filteredJobsProvider);

    // watch: the offline banner must appear/disappear automatically as
    // connectivity changes, with no user interaction needed.
    final isOffline = ref.watch(isOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CareerHub'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          if (isOffline) const _OfflineBanner(),

          // The chip row stays pinned above the scrolling area.
          const _FilterChipsRow(),

          // Expanded gives the area below a bounded height. Without it the Column
          // would offer unbounded height and any scrolling child would throw
          // "vertical viewport was given unbounded height".
          Expanded(
            // when() forces us to answer all three questions the async data can
            // ask: what do we draw while waiting, on failure, and on success?
            child: asyncJobs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _ErrorView(
                // read: this runs on a button press, not during a build, so it
                // must not subscribe. invalidate throws the cached jobs away and
                // makes the notifier fetch from the API again.
                onRetry: () => ref.invalidate(jobsProvider),
              ),
              data: (jobs) {
                // The fourth case hiding inside "data": the list can be empty. A
                // filter that matches nothing still arrives here successfully.
                // Without this check the user would stare at a blank white body.
                if (jobs.isEmpty) return const _EmptyView();

                return _ResponsiveJobs(jobs: jobs);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shown when the device has no active network connection. Appears and
// disappears automatically as isOfflineProvider changes — no tap required.
// ---------------------------------------------------------------------------
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: scheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.wifi_off, size: 16, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Text(
            'You are offline — showing cached data.',
            style: TextStyle(color: scheme.onErrorContainer, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The responsive list-or-grid, unchanged in spirit from Assignment 1.2.
// It receives its jobs as a parameter instead of owning them.
// ---------------------------------------------------------------------------
class _ResponsiveJobs extends StatelessWidget {
  final List<Job> jobs;

  const _ResponsiveJobs({required this.jobs});

  // One place that turns an index into a JobCard, shared by both layouts.
  Widget _buildCard(BuildContext context, int index) {
    final job = jobs[index];
    return JobCard(
      job: job,
      // push stacks the detail on top of the list, so the back button peels it
      // off and returns here. The URL is built from job.id, never the list
      // index, so it always points at this exact job regardless of the filter.
      onTap: () => context.push('/jobs/${job.id}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Narrow screen -> single-column list.
        if (constraints.maxWidth < kGridBreakpoint) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: jobs.length,
            itemBuilder: _buildCard,
          );
        }

        // Wide screen or tablet -> two-column grid.
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 340,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: jobs.length,
          itemBuilder: _buildCard,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// The filter chips. Each chip reads its selected look from the provider, so the
// provider is the single source of truth: there is no local "which one is
// picked" variable anywhere. filterProvider persists the selection to
// SharedPreferences, so it survives an app restart.
// ---------------------------------------------------------------------------
class _FilterChipsRow extends ConsumerWidget {
  const _FilterChipsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch: the chips must repaint when the selection changes.
    final selected = ref.watch(filterProvider);

    return SizedBox(
      height: 56,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            for (final label in kFilterLabels)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(label),
                  selected: label == selected,
                  onSelected: (_) {
                    // read: a tap is an action, not a paint. select() writes
                    // to SharedPreferences and updates state in one call.
                    ref.read(filterProvider.notifier).select(label);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shown when loading the jobs threw. Explains what happened and offers a way out.
// ---------------------------------------------------------------------------
class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // error is the M3 role for a failure state, so it adapts to dark mode.
            Icon(Icons.cloud_off_outlined, size: 48, color: scheme.error),
            const SizedBox(height: 16),
            Text(
              'We could not load the jobs',
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check that the CareerHub API is running, then try again.',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shown when the jobs loaded fine but the active filter matched none of them.
// A successful load with zero results is not an error, so it reads gently.
// ---------------------------------------------------------------------------
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 48,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No jobs match this filter',
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting All to see every listing.',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}