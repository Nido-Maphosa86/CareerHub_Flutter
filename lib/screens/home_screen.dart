// lib/screens/home_screen.dart
//
// The main jobs list screen. Two changes from Assignment 2.3:
// 1. The AppBar now has a logout action. The logout button invalidates
//    jobsProvider BEFORE calling logout() on the auth notifier. The
//    order is deliberate: invalidating the jobs provider while the user is
//    still authenticated tears down any in-flight network fetch cleanly. If
//    logout() ran first and the router redirected to /login before the
//    invalidation happened, a background fetch could complete and write stale
//    data into the jobs notifier that a future session would see on first load.
// 2. The root app widget became a ConsumerWidget and now watches appRouterProvider
//    so the router rebuilds when auth state changes. This screen itself is
//    unchanged except for the logout button.

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

const double kGridBreakpoint = 600;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Job>> asyncJobs = ref.watch(filteredJobsProvider);
    final isOffline = ref.watch(isOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CareerHub'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Logout button. Invalidating jobsProvider first ensures
          // the jobs cache does not hold data from this user's session when
          // the next user (or the same user on next login) opens the app.
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
      body: Column(
        children: [
          if (isOffline) const _OfflineBanner(),
          const _FilterChipsRow(),
          Expanded(
            child: asyncJobs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _ErrorView(
                onRetry: () => ref.invalidate(jobsProvider),
              ),
              data: (jobs) {
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

class _FilterChipsRow extends ConsumerWidget {
  const _FilterChipsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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