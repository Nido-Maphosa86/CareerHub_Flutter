// lib/widgets/job_card.dart
//
// This is the card that shows one job. It takes a whole Job object and draws it.
// A full-height coloured stripe runs down the left edge: it lights up for jobs
// you can still apply to and goes muted for closed ones, so open versus closed
// is readable at a glance. Salary always comes from job.displaySalary, so the
// word "null" can never appear. Fields that can be missing (description and the
// closing date) are only drawn when they exist, using Dart's collection-if, so
// an absent field leaves no empty label and no gap. Every colour is a theme
// colour role and every text size is a theme text style, so the card looks
// correct in light and dark mode without any hardcoded values. The Open/Closed
// pill lives in its own JobStatusBadge widget. The card can be given an optional
// onTap so the screen decides where a tap goes (here, to the job's detail URL),

// while the card itself stays a plain presentational widget.

import 'package:flutter/material.dart';

import '../models/job.dart';
import 'job_status_badge.dart';

class JobCard extends StatelessWidget {
  final Job job;

  // What happens when the card is tapped. Optional, so the card is still usable
  // in places where it is not meant to navigate.
  final VoidCallback? onTap;

  const JobCard({super.key, required this.job, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // The visual state is driven by the model, never by hardcoded values.
    final bool applicable = job.canApply;

    // The stripe and the badge read the same flag, so they can never disagree.
    final Color stripeColor =
        applicable ? scheme.primary : scheme.outlineVariant;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // InkWell gives the tap a ripple and calls onTap. Placed inside the Card so
      // the ripple is clipped to the rounded corners.
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // The status stripe. Colour alone communicates open vs closed.
            Container(width: 6, color: stripeColor),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title (titleMedium) on the left, status badge on the right.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            job.title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // The extracted widget, fed by the model's canApply rule.
                        JobStatusBadge(isOpen: applicable),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Company (bodyMedium, onSurfaceVariant).
                    Row(
                      children: [
                        Icon(
                          Icons.apartment_outlined,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            job.company,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Location (bodySmall). "Remote" is a normal value here.
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            job.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Salary (bodyMedium) and employment type (bodySmall) as pills.
                    // Wrap lets them fall to a second line instead of overflowing.
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Pill(
                          text: job.displaySalary, // always safe, never "null"
                          background: scheme.primaryContainer,
                          foreground: scheme.onPrimaryContainer,
                          textStyle: textTheme.bodyMedium,
                        ),
                        _Pill(
                          text: job.employmentType,
                          background: scheme.surfaceContainerHighest,
                          foreground: scheme.onSurfaceVariant,
                          textStyle: textTheme.bodySmall,
                        ),
                      ],
                    ),

                    // collection-if: description only appears when one exists.
                    if (job.description != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        job.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],

                    // collection-if: closing-date footer only when a date exists.
                    if (job.closingDate != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 16,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Closes ${_formatDate(job.closingDate!)}',
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  // Turns a DateTime into a friendly label like "31 Dec 2026".
  static String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// A small rounded label used for the salary and the employment type.
// Presentational only, private to this file. Its text style is passed in so it
// always uses a theme text style rather than a hardcoded size.
class _Pill extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;
  final TextStyle? textStyle;

  const _Pill({
    required this.text,
    required this.background,
    required this.foreground,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: textStyle?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
