// lib/models/job.dart
//
// This file describes one job advert in CareerHub. It is a plain Dart class with
// no Flutter code inside it, so the same model works for the screen and for real
// API data without changing shape. It carries a stable string id, which is the
// value used to build a job's URL (/jobs/<id>) and to look a job up again later,
// so a job is always identified by who it is rather than where it sits in a list.
// The id is a String because the CareerHub API identifies jobs with a Guid. It
// decides which fields are always present and which may be missing, offers two
// named constructors for the two special ways a job is created (closed and
// remote), exposes three helpers the UI relies on (canApply, displaySalary,
// toString), and provides Job.fromDto, the one place API names are translated
// into the model's names.



//translating the DTO into what the UI wants
import '../data/job_dto.dart';

class Job {
  // A stable, unique identifier for this job. It comes from the API as a Guid
  // string. Unlike a list position it never changes when the list is filtered or
  // reordered, so it is safe to put in a URL.
  final String id;

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
    required String id,
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
    required String id,
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

  // Builds a UI Job from an API DTO. This is the one translation point between
  // the API's names and the model's names: companyName -> company, isActive ->
  // isOpen, salaryDisplay -> salary, and the type enum string ("FullTime") ->
  // the label the UI and filter chips use ("Full-time").

  //translating the DTO into what the UI wants
  //what we receive from the API is a JobDto, and we want to convert it into a Job model that the UI can use. This method takes a JobDto and returns a Job instance with the appropriate fields mapped.
  factory Job.fromDto(JobDto dto) {
    return Job(
      id: dto.id,
      title: dto.title,
      company: dto.companyName,
      location: dto.location,
      employmentType: _employmentLabel(dto.type),
      isOpen: dto.isActive,
      salary: dto.salaryDisplay,
      closingDate: dto.closingDate,
      description: dto.description,
    );
  }

  // Turns the API's enum spelling into the human label the chips filter on.
  static String _employmentLabel(String apiType) {
    switch (apiType) {
      case 'FullTime':
        return 'Full-time';
      case 'PartTime':
        return 'Part-time';
      case 'Contract':
        return 'Contract';
      case 'Internship':
        return 'Internship';
      default:
        return apiType; // unknown value passes through unchanged
    }
  }

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
