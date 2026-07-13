// lib/models/job.dart
//
// This file describes one job advert in CareerHub. It is a plain Dart class with
// no Flutter code inside it, so the same model works for the screen today and for
// real API data in Week 2 without changing shape. It now carries a stable integer
// id, which is the value used to build a job's URL (/jobs/<id>) and to look a job
// up again later, so a job is always identified by who it is rather than where it
// happens to sit in a list. It decides which fields are always present and which
// may be missing, offers two named constructors for the two special ways a job is
// created (closed and remote), and exposes three helpers the UI relies on:
// canApply, displaySalary, and toString.

class Job {
  // A stable, unique identifier for this job. Unlike a list position, it never
  // changes when the list is filtered or reordered, so it is safe to put in a URL.
  final int id;

  // Required fields: never missing, so non-nullable.
  final String title;
  final String company;
  final String location; // "Remote" is a valid value.
  final String employmentType;
  final bool isOpen;

  // Optional fields: may legitimately be absent, so nullable.
  final String? salary;
  final DateTime? closingDate;
  final String? description;

  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.employmentType,
    required this.isOpen,
    this.salary,
    this.closingDate,
    this.description,
  });

  // A closed listing: applications have stopped, but the advert stays visible.
  // Hard-sets isOpen to false so a closed job can never be built as still open.
  Job.closed({
    required int id,
    required String title,
    required String company,
    required String location,
    required String employmentType,
    String? salary,
    DateTime? closingDate,
    String? description,
  }) : this(
          id: id,
          title: title,
          company: company,
          location: location,
          employmentType: employmentType,
          isOpen: false,
          salary: salary,
          closingDate: closingDate,
          description: description,
        );

  // A fully remote listing: fixes location to "Remote" so remote adverts are
  // labelled consistently everywhere.
  Job.remote({
    required int id,
    required String title,
    required String company,
    required String employmentType,
    required bool isOpen,
    String? salary,
    DateTime? closingDate,
    String? description,
  }) : this(
          id: id,
          title: title,
          company: company,
          location: 'Remote',
          employmentType: employmentType,
          isOpen: isOpen,
          salary: salary,
          closingDate: closingDate,
          description: description,
        );

  // True only when the listing is open and its closing date has not passed.
  bool get canApply {
    if (!isOpen) return false;
    final deadline = closingDate;
    if (deadline == null) return true;
    return DateTime.now().isBefore(deadline);
  }

  // The only place salary text is decided: the stored range, or "Market-related"
  // when pay was kept confidential, so "null" never reaches the UI.
  String get displaySalary => salary ?? 'Market-related';

  @override
  String toString() {
    final status = isOpen ? 'OPEN' : 'CLOSED';
    final closing = closingDate == null
        ? 'no closing date'
        : 'closes ${_dateLabel(closingDate!)}';
    return 'Job(#$id $title @ $company | $location | $employmentType | '
        '$displaySalary | $status | $closing)';
  }

  static String _dateLabel(DateTime d) {
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$month-$day';
  }
}
