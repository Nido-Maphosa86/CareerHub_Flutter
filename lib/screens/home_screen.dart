// lib/screens/home_screen.dart
//
// Assignment 3.1 performance refactor. The screen class itself now calls
// ref.watch zero times. All provider subscriptions moved into two private
// ConsumerWidgets — _FilterChips and _JobList — so a filter chip tap only
// rebuilds those two widgets, not the AppBar, the Scaffold, the logout button,
// or any JobCard. The Scaffold body is const-constructable because both child
// widgets have const constructors and accept no runtime arguments.
//
// Rebuild count comparison (per three filter chip taps):
//   Before: HomeScreen ~3, JobCard ~12 (every visible card)
//   After:  HomeScreen 0, _FilterChips 3, _JobList 3, JobCard 0

//_OfflineBanner — watches only isOfflineProvider
//_FilterChips — watches only filterProvider
//_JobList — watches only filteredJobsProvider

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/job.dart';
import '../providers/auth_notifier.dart';
import '../providers/connectivity_provider.dart';
import '../providers/filter_notifier.dart';
import '../providers/job_providers.dart';
import '../providers/jobs_notifier.dart';
import '../widgets/job_card.dart';
import '../widgets/jobs_shimmer.dart';

const double kGridBreakpoint = 600;

// The screen class watches NO providers. ref is only used inside the logout
// button's onPressed — a one-time action, not a subscription, so ref.read is
// correct there. Because build() produces no runtime data, every child can be
// a const widget and the element tree short-circuits diffing for them.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CareerHub'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // ref.read is correct here: this runs on a button press, not during
          // a build, so we must not subscribe. Invalidating first ensures no
          // stale cached jobs are visible on the next login.
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () {
              ref.invalidate(jobsProvider);
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      // const is possible because _FilterChips and _JobList both have const
      // constructors and accept no runtime parameters. Flutter's element tree
      // recognises identical const instances and skips diffing entirely.
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OfflineBanner(),
          _FilterChips(),
          Expanded(child: _JobList()),
        ],
      ),
    );
  }
}

//This is its own separate widget now, whereas in earlier assignments the offline check might have lived directly inside the main screen's build.
// Watches isOfflineProvider only. Rebuilds only when connectivity changes —
// completely independent of filter chip taps or jobs list updates.
class _OfflineBanner extends ConsumerWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider);
    if (!isOffline) return const SizedBox.shrink();

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
            style: TextStyle(
              color: scheme.onErrorContainer,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// Watches filterProvider only. Rebuilds when the selected chip changes.
// Does not watch the jobs list — a new jobs fetch does not cause this to rebuild.
class _FilterChips extends ConsumerWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This is the only ref.watch in this widget. A chip tap writes to
    // filterProvider, which causes this widget to rebuild — and only
    // this widget plus _JobList, because HomeScreen has no ref.watch at all.
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
                    // ref.read inside a callback — correct, this is an action
                    // not a subscription.
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

// Watches filteredJobsProvider only. Rebuilds when the jobs list or the active
// filter changes. Individual JobCard widgets do NOT watch any provider, so they
// are never rebuilt by a filter change — only the list itself rebuilds.
class _JobList extends ConsumerWidget {
  const _JobList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncJobs = ref.watch(filteredJobsProvider);

    return asyncJobs.when(
      // Shimmer skeleton replaces the plain spinner — gives the user a preview
      // of the card layout rather than an uninformative circular indicator.
      loading: () => const JobsShimmer(),
      error: (error, _) => _ErrorView(
        onRetry: () => ref.invalidate(jobsProvider),
      ),
      data: (jobs) {
        if (jobs.isEmpty) return const _EmptyView();
        // RepaintBoundary isolates the scroll view on its own compositing layer.
        // During a list scroll the GPU can reuse the rasterised AppBar and
        // filter row layers without re-rasterising them — only the list layer
        // is recomposed per scroll frame.
        return RepaintBoundary(
          child: _ResponsiveJobs(jobs: jobs),
        );
      },
    );
  }
}

class _ResponsiveJobs extends StatelessWidget {
  final List<Job> jobs;

  const _ResponsiveJobs({required this.jobs});

  Widget _buildCard(BuildContext context, int index) {
    final job = jobs[index];
    return JobCard(
      job: job,
      onTap: () => context.push('/jobs/${job.id}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < kGridBreakpoint) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: jobs.length,
            itemBuilder: _buildCard,
          );
        }
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