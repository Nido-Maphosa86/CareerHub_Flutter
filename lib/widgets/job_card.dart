// lib/widgets/job_card.dart
//
// FILE SUMMARY (easy English)
// This is the card that shows one job on the home screen. It takes a whole Job
// object (not loose fields) and draws it. The design is a full-height coloured
// stripe down the left edge that turns on for jobs you can still apply to and
// goes grey for closed ones, so a person scrolling can tell open from closed at
// a glance without reading. Salary always comes from job.displaySalary, so the
// card never shows the word "null". Fields that can be missing (the closing date
// and the description) are only drawn when they actually exist, using Dart's
// collection-if, so an absent field leaves no empty label and no gap behind.

import 'package:flutter/material.dart';

import '../models/job.dart';

class JobCard extends StatelessWidget {
  // The card is given one Job and reads everything it needs from it.
  final Job job;

  // const constructor: because a JobCard only depends on the Job passed in,
  // Flutter is allowed to cache it and skip rebuilding it when nothing changed.
  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // The visual state is driven by the model, never by hardcoded values.
    // canApply is true only for a job that is open and not past its deadline.
    final bool applicable = job.canApply;

    // The stripe and the status chip both read from this one decision, so they
    // can never disagree with each other.
    final Color stripeColor =
        applicable ? scheme.primary : scheme.outlineVariant;

    return Card(
      // antiAlias lets the coloured stripe sit flush against the rounded corner.
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: IntrinsicHeight(
        // IntrinsicHeight makes the left stripe stretch to match the tallest
        // side of the card so it is always a clean full-height bar.
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
                    // Title on the left, status chip on the right.
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
                        _StatusChip(applicable: applicable),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Company and location on one line, joined by a middle dot.
                    // location is always present (remote jobs read "Remote").
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
                            '${job.company}  \u00B7  ${job.location}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Two small pills: the salary (always shown via the getter)
                    // and the employment type. Wrap lets them fall onto a second
                    // line on narrow screens instead of overflowing.
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Pill(
                          text: job.displaySalary,
                          background: scheme.primaryContainer,
                          foreground: scheme.onPrimaryContainer,
                        ),
                        _Pill(
                          text: job.employmentType,
                          background: scheme.surfaceContainerHighest,
                          foreground: scheme.onSurfaceVariant,
                        ),
                      ],
                    ),

                    // collection-if: the description only appears when one exists.
                    // A draft with no description produces no preview and no gap.
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

                    // collection-if: the closing-date footer only appears when a
                    // date exists. No date means no "Closes:" label at all.
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
    );
  }

  // Turns a DateTime into a friendly label like "31 Dec 2026" without needing
  // an extra date-formatting package on Day 1.
  static String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// A small rounded label used for the salary and the employment type.
// Kept private to this file because nothing else needs it yet.
class _Pill extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;

  const _Pill({
    required this.text,
    required this.background,
    required this.foreground,
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
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// The Open / Closed chip in the top-right corner. It reads the same applicable
// flag as the stripe so the two can never contradict each other.
class _StatusChip extends StatelessWidget {
  final bool applicable;

  const _StatusChip({required this.applicable});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final Color background =
        applicable ? scheme.primary : scheme.surfaceContainerHighest;
    final Color foreground =
        applicable ? scheme.onPrimary : scheme.onSurfaceVariant;
    final String label = applicable ? 'Open' : 'Closed';

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
