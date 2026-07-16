// lib/data/job_dto.dart
//
// The DTO is a plain mirror of exactly what the CareerHub API sends back for one
// job. It is now an @freezed class with json_serializable attached, so the
// hand-written fromJson from Assignment 2.1 is gone: the generator writes a
// fromJson that reads every field the const factory constructor declares. The
// Dart field names line up with the API's JSON keys one for one, so no
// @JsonKey annotations are needed — if the API ever adds a key like "salaryMax"
// we would only add the matching Dart field. Turning a DTO into a UI Job still
// happens in Job.fromDto, not here.

import 'package:freezed_annotation/freezed_annotation.dart';

// Two part directives. .freezed.dart carries the ==/hashCode/copyWith/toString
// mixin from Freezed; .g.dart carries the fromJson/toJson from json_serializable.
part 'job_dto.freezed.dart';
part 'job_dto.g.dart';

@freezed
abstract class JobDto with _$JobDto {
  // Every field from the API is declared once, here, as a named parameter with
  // its Dart type. That declaration is what the generator reads to write both
  // ==/hashCode and the JSON parser: String stays as-is, num? is widened to
  // double?, DateTime strings are handed to DateTime.parse. Fields the UI does
  // not surface yet (salaryMin, salaryMax, postedAt, applicationCount, status)
  // are captured anyway so a future screen needs no network-layer change.
  const factory JobDto({
    required String id, // Guid string from the API
    required String title,
    required String description,
    required String companyName, // API name; the model calls this "company"
    required String location,
    required String type, // enum serialised as a string, e.g. "FullTime"
    required double? salaryMin,
    required double? salaryMax,
    required String salaryDisplay, // pre-formatted range; model calls it "salary"
    required DateTime postedAt,
    required bool isActive, // API name; the model calls this "isOpen"
    required int applicationCount,
    required DateTime closingDate,
    required String status, // "Active" / "Closed"; captured, derived elsewhere
  }) = _JobDto;

  // One-line delegation to the generator. Every parsing rule lives in the
  // generated _$JobDtoFromJson, so this file no longer changes when the API
  // adds a field — the field just gets a new line in the factory above.
  factory JobDto.fromJson(Map<String, dynamic> json) => _$JobDtoFromJson(json);
}
