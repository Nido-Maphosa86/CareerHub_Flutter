// lib/models/job.dart
//
// This file describes one job advert in CareerHub. It is now an @freezed class,
// which means ==, hashCode, copyWith and toString are all generated from the
// fields declared in the const factory constructor below — two Jobs with the
// same field values are now equal, and Riverpod can therefore skip rebuilds
// when a refresh returns the same data. It is NOT json_serializable, because
// JSON parsing lives one layer down in JobDto; Job.fromDto is still the one
// translation point between API names and model names. Job.fromDto, Job.closed
// and Job.remote are now static methods rather than factory constructors,
// because Freezed reserves factory constructors for union variants — the call
// sites remain syntactically identical.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/job_dto.dart';

// One part directive. No .g.dart: this class is never read from raw JSON.
part 'job.freezed.dart';

@freezed
abstract class Job with _$Job {
  // Freezed's mixin needs a constructor it can call. A private, no-argument
  // constructor also unlocks custom getters and static methods on the class —
  // canApply and displaySalary below both rely on this being here.
  const Job._();

  // The one place the shape of a Job is declared. The generator reads these
  // fields to write ==, hashCode, copyWith and toString.
  const factory Job({
    required String id, // Guid string, stable across filters and reorders
    required String title,
    required String company,
    required String location, // "Remote" is a valid value
    required String employmentType,
    required bool isOpen,
    String? salary,
    DateTime? closingDate,
    String? description,
  }) = _Job;

  // fromDto is a static method (was a factory in 2.1). Freezed would otherwise
  // interpret a factory as a union variant of Job, but its behaviour is a plain
  // mapping — accept a DTO, return a Job — so a static method fits. The call
  // site Job.fromDto(dto) is unchanged: Dart calls static methods with the same
  // syntax as constructors.
  static Job fromDto(JobDto dto) {
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

  // A closed listing: applications have stopped, but the advert stays visible.
  // Was Job.closed as a redirecting constructor; now a static method so Freezed
  // does not read it as a union variant. Hard-sets isOpen to false so a closed
  // job can never be built as still open.
  static Job closed({
    required String id,
    required String title,
    required String company,
    required String location,
    required String employmentType,
    String? salary,
    DateTime? closingDate,
    String? description,
  }) {
    return Job(
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
  }

  // A fully remote listing: fixes location to "Remote" so remote adverts are
  // labelled consistently everywhere. Static method for the same reason as
  // closed() above.
  static Job remote({
    required String id,
    required String title,
    required String company,
    required String employmentType,
    required bool isOpen,
    String? salary,
    DateTime? closingDate,
    String? description,
  }) {
    return Job(
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
  }

  // Turns the API's enum spelling into the human label the chips filter on.
  // Now written as a switch expression (Dart 3): each arm maps a single input
  // to a single output, so the multi-line switch statement collapses into one
  // expression body. The trailing _ (wildcard pattern) makes the switch
  // exhaustive; any unrecognised value passes through unchanged.
  static String _employmentLabel(String apiType) => switch (apiType) {
        'FullTime' => 'Full-time',
        'PartTime' => 'Part-time',
        'Contract' => 'Contract',
        'Internship' => 'Internship',
        _ => apiType,
      };

  // True only when the listing is open and its closing date has not passed.
  // Lives on the model because the same rule holds everywhere the UI reads it.
  bool get canApply {
    if (!isOpen) return false;
    final deadline = closingDate;
    if (deadline == null) return true;
    return DateTime.now().isBefore(deadline);
  }

  // The only place salary text is decided: the stored range, or "Market-related"
  // when pay was kept confidential, so "null" never reaches the UI.
  String get displaySalary => salary ?? 'Market-related';
}
