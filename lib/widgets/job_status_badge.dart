// lib/widgets/job_status_badge.dart
//
// FILE SUMMARY 
// This is the small "Open" or "Closed" pill that sits in the corner of a job
// card. It was pulled out of JobCard into its own file so it can be reused on
// other screens later (a job detail page, an applications list) and tested on
// its own. It knows nothing about the Job model; you just hand it a single
// true/false for whether the job can be applied to, and it draws the right
// label and colours. Every colour comes from the app theme, so it looks correct
// in both light and dark mode with no extra work.

import 'package:flutter/material.dart';

class JobStatusBadge extends StatelessWidget {
  // true  -> the job is open and can be applied to  -> green "Open" pill
  // false -> the job is closed                      -> muted "Closed" pill
  // Named isOpen to read naturally; JobCard passes job.canApply into it, which
  // is the model's single source of truth for whether applications are allowed.
  final bool isOpen;

  // const so the badge can be cached when its value has not changed.
  const JobStatusBadge({super.key, required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Colour roles, not raw colours, so dark mode adapts automatically.
    // primary/onPrimary  -> the main positive, actionable state (Open).
    // surfaceContainerHighest/onSurfaceVariant -> a muted, inactive state (Closed).
    final Color background =
        isOpen ? scheme.primary : scheme.surfaceContainerHighest;
    final Color foreground =
        isOpen ? scheme.onPrimary : scheme.onSurfaceVariant;
    final String label = isOpen ? 'Open' : 'Closed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
      ),
    );
  }
}
