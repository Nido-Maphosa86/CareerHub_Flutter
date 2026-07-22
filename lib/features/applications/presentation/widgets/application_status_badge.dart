import 'package:flutter/material.dart';
import '../../domain/application_status.dart';

class ApplicationStatusBadge extends StatelessWidget {
  final ApplicationStatus status;

  const ApplicationStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (color, label) = switch (status) {
      ApplicationStatus.submitted => (scheme.primary, status.displayLabel),
      ApplicationStatus.underReview => (scheme.tertiary, status.displayLabel),
      ApplicationStatus.shortlisted => (Colors.green, status.displayLabel),
      ApplicationStatus.rejected => (scheme.error, status.displayLabel),
      ApplicationStatus.offered => (Colors.amber.shade700, status.displayLabel),
    };

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }
}