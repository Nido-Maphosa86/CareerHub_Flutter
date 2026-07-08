// lib/models/job.dart
//
// FILE SUMMARY
// This file describes one job advert in CareerHub. It is a plain Dart class
// with no Flutter code inside it, so the very same model works for the screen
// today and for real API data in Week 2 without changing shape. It decides
// which fields must always be present and which are allowed to be missing,
// gives two named constructors for the two special ways a job can be created
// (a closed listing and a fully remote listing), and provides three helpers the
// screen relies on: canApply (may a seeker apply right now?), displaySalary
// (the exact salary text to show), and toString (a readable line for debugging).

class Job {
  // ---------- REQUIRED FIELDS ----------
  // These can never be missing, so they are non-nullable.
  final String title; // The role name, e.g. "Flutter Developer".
  final String company; // The employer hiring for the role.
  final String location; // Where the work happens. "Remote" is a valid value.
  final String employmentType; // e.g. Full-time, Part-time, Contract.
  final bool isOpen; // true while applications are still being accepted.

  // ---------- OPTIONAL FIELDS ----------
  // These may legitimately be absent on a real listing, so they are nullable.
  final String? salary; // A ready-to-show pay range, or null if confidential.
  final DateTime? closingDate; // Last day to apply, or null if there is no deadline.
  final String? description; // Full advert text, or null while the listing is a draft.

  // ---------- DEFAULT CONSTRUCTOR ----------
  // Marked const so Flutter can build and cache Job objects cheaply when every
  // value is known ahead of time.
  const Job({
    required this.title,
    required this.company,
    required this.location,
    required this.employmentType,
    required this.isOpen,
    this.salary,
    this.closingDate,
    this.description,
  });

  // ---------- NAMED CONSTRUCTOR 1: a closed listing ----------
  // Business reason: an employer has stopped accepting applications, but the
  // advert must still appear (in their own dashboard, or in a seeker's history).
  // This constructor hard-sets isOpen to false by redirecting into the default
  // constructor, so a closed job can never be created by accident as still open.
  // The caller never passes isOpen for a closed job.
  Job.closed({
    required String title,
    required String company,
    required String location,
    required String employmentType,
    String? salary,
    DateTime? closingDate,
    String? description,
  }) : this(
          title: title,
          company: company,
          location: location,
          employmentType: employmentType,
          isOpen: false,
          salary: salary,
          closingDate: closingDate,
          description: description,
        );

  // ---------- NAMED CONSTRUCTOR 2: a fully remote listing ----------
  // Business reason: a remote role has no physical office, so its location is
  // always "Remote". This constructor fixes location to "Remote" so remote
  // adverts are labelled the same way everywhere, instead of drifting between
  // "remote", "WFH" and "Remote". The caller never passes a location.
  Job.remote({
    required String title,
    required String company,
    required String employmentType,
    required bool isOpen,
    String? salary,
    DateTime? closingDate,
    String? description,
  }) : this(
          title: title,
          company: company,
          location: 'Remote',
          employmentType: employmentType,
          isOpen: isOpen,
          salary: salary,
          closingDate: closingDate,
          description: description,
        );

  // ---------- GETTER: canApply ----------
  // The single source of truth for "can a job seeker apply to this?".
  // A seeker may apply only when the listing is open AND its closing date has
  // not already passed. A listing with no closing date has no deadline, so it
  // stays applicable while it is open. Keeping this rule on the model means the
  // widget never has to re-invent it.
  bool get canApply {
    if (!isOpen) return false;
    final deadline = closingDate;
    if (deadline == null) return true; // No deadline was set.
    return DateTime.now().isBefore(deadline); // Still before the closing date.
  }

  // ---------- GETTER: displaySalary ----------
  // The single source of truth for salary text. If a salary was provided, show
  // it exactly as stored (it is already a formatted range). If it is missing,
  // the employer kept pay confidential, so show "Market-related" rather than
  // letting "null" ever reach the screen.
  String get displaySalary => salary ?? 'Market-related';

  // ---------- toString ----------
  // A short, readable line that identifies a job at a glance during development.
  // It pulls in status and the closing date so a single print tells the full story.
  @override
  String toString() {
    final status = isOpen ? 'OPEN' : 'CLOSED';
    final closing = closingDate == null
        ? 'no closing date'
        : 'closes ${_dateLabel(closingDate!)}';
    return 'Job($title @ $company | $location | $employmentType | '
        '$displaySalary | $status | $closing)';
  }

  // Small private helper: turns a DateTime into a plain YYYY-MM-DD label so the
  // debug output stays tidy and predictable.
  static String _dateLabel(DateTime d) {
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$month-$day';
  }
}
