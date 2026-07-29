// lib/screens/job_detail_screen.dart
//
// Shows the full details of one job. Receives only a job ID from the URL and
// looks the job up in the live list, so the URL is the single source of truth.
// Assignment 3.1 adds an Apply button that navigates to /jobs/:id/apply using
// GoRouter's context.push so the back button returns to this screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/job.dart';
import '../providers/jobs_notifier.dart';

class JobDetailScreen extends ConsumerWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          Job? found;
          for (final job in jobs) {
            if (job.id == jobId) {
              found = job;
              break;
            }
          }

          if (found == null) {
            return const _DetailMessage(
              icon: Icons.search_off_outlined,
              title: 'Job not found',
              message: 'This listing may have been closed or removed.',
            );
          }
          return _JobDetailBody(job: found, jobId: jobId);
        },
      ),
    );
  }
}

class _JobDetailBody extends StatelessWidget {
  final Job job;
  final String jobId;

  const _JobDetailBody({required this.job, required this.jobId});

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
        _DetailRow(label: 'Status', value: job.isOpen ? 'Open' : 'Closed'),
        _DetailRow(label: 'Employment type', value: job.employmentType),
        _DetailRow(label: 'Salary', value: job.displaySalary),
        _DetailRow(
          label: 'Applications',
          value: job.canApply
              ? 'Open for applications'
              : 'Not accepting applications',
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
        // Navigates to /jobs/:id/apply using GoRouter push so the back button
        // returns to this detail screen. Disabled when the job is closed or
        // the closing date has passed (job.canApply returns false).
        FilledButton(
          onPressed: job.canApply
              ? () => context.push('/jobs/$jobId/apply')
              : null,
          child: const Text('Apply for this job'),
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
            Text(title,
                style: textTheme.titleMedium, textAlign: TextAlign.center),
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
