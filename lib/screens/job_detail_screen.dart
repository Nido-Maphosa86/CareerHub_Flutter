// lib/screens/job_detail_screen.dart
//
// This screen shows the full details of one job. It does not receive a Job object
// through its constructor; it receives only an id taken from the URL, then looks
// the job up itself. That keeps the URL the single source of truth, so the very
// same screen works whether the user tapped a card or opened the app straight to
// /jobs/<id> from a notification. It now watches jobsProvider (the live,
// network-backed list) and finds the job by id inside it, so a job still resolves
// regardless of which filter chip is selected on the list screen. It handles the
// loading and error states of that fetch, and shows a calm "not found" screen if
// the id matches no job instead of crashing.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/job.dart';
import '../providers/jobs_notifier.dart';

class JobDetailScreen extends ConsumerWidget {
  // The id arrives from the URL as text. It is the API's Guid string, so it is a
  // String, not an int.
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the whole live list, then pick the one job out of it by id. Watching
    // the notifier (not the filtered list) means a link to a job resolves even
    // when a filter chip is active on the list screen.
    final AsyncValue<List<Job>> asyncJobs = ref.watch(jobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: asyncJobs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const _DetailMessage(
          icon: Icons.cloud_off_outlined,
          title: 'We could not load this job',
          message: 'Check that the CareerHub API is running and try again.',
        ),
        data: (jobs) {
          // Find the job whose id matches the URL. Returns null if none match.
          Job? found;
          for (final job in jobs) {
            if (job.id == jobId) {
              found = job;
              break;
            }
          }

          // Loaded fine, but the id matched no job (stale or mistyped URL).
          if (found == null) {
            return const _DetailMessage(
              icon: Icons.search_off_outlined,
              title: 'Job not found',
              message: 'This listing may have been closed or removed.',
            );
          }
          return _JobDetailBody(job: found);
        },
      ),
    );
  }
}

// The full details layout, shown once a real job has been found.
class _JobDetailBody extends StatelessWidget {
  final Job job;

  const _JobDetailBody({required this.job});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(job.title, style: textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          '${job.company}  \u00B7  ${job.location}',
          style: textTheme.titleMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),

        // Every meaningful field, one row each. Optional fields only appear when
        // they exist, so a missing value leaves no empty row.
        _DetailRow(label: 'Status', value: job.isOpen ? 'Open' : 'Closed'),
        _DetailRow(label: 'Employment type', value: job.employmentType),
        _DetailRow(label: 'Salary', value: job.displaySalary),
        _DetailRow(
          label: 'Applications',
          value: job.canApply ? 'Open for applications' : 'Not accepting applications',
        ),
        if (job.closingDate != null)
          _DetailRow(
            label: 'Closing date',
            value: _formatDate(job.closingDate!),
          ),

        if (job.description != null) ...[
          const SizedBox(height: 20),
          Text('About the role', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(job.description!, style: textTheme.bodyMedium),
        ],

        const SizedBox(height: 28),
        FilledButton(
          // Enabled only when the job can actually be applied to.
          onPressed: job.canApply ? () {} : null,
          child: const Text('Apply now'),
        ),
      ],
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// One labelled fact, e.g. "Salary: R55 000 - R75 000 per month".
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

// Shared centred message used for the error and not-found states.
class _DetailMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _DetailMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

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
            Icon(icon, size: 48, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(title, style: textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              message,
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