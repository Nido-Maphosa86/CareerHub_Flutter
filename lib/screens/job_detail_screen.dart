// lib/screens/job_detail_screen.dart
//
// This screen shows the full details of one job. It does not receive a Job object
// passed in through its constructor; it receives only an id taken from the URL,
// then looks the job up itself. That keeps the URL the single source of truth, so
// the very same screen works whether the user tapped a card or opened the app
// straight to /jobs/<id> from a notification. It watches the raw, unfiltered jobs
// so a job can always be found by id even when the list screen has a filter
// applied, handles the loading and error states of that fetch, and shows a calm
// "not found" screen if the id matches no job instead of crashing.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/job.dart';
import '../providers/job_providers.dart';

class JobDetailScreen extends ConsumerWidget {
  final int jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the RAW jobs by id, not the filtered list: a link to a job must
    // resolve regardless of which filter chip happens to be selected, otherwise
    // opening /jobs/1 while "Remote" is active would find nothing.
    final AsyncValue<Job?> asyncJob = ref.watch(jobByIdProvider(jobId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: asyncJob.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const _DetailMessage(
          icon: Icons.cloud_off_outlined,
          title: 'We could not load this job',
          message: 'Check your connection and try again.',
        ),
        data: (job) {
          // Loaded fine, but the id matched no job (stale or mistyped URL).
          if (job == null) {
            return const _DetailMessage(
              icon: Icons.search_off_outlined,
              title: 'Job not found',
              message: 'This listing may have been closed or removed.',
            );
          }
          return _JobDetailBody(job: job);
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
