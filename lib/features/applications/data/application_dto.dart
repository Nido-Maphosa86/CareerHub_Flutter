import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/application_status.dart';
import '../domain/job_application.dart';

part 'application_dto.freezed.dart';
part 'application_dto.g.dart';

@freezed
abstract class ApplicationDto with _$ApplicationDto {
  const factory ApplicationDto({
    required String jobListingId,
    required String jobTitle,
    required String companyName,
    required String applicantId,
    required String applicantName,
    required DateTime submittedAt,
    required String status,
  }) = _ApplicationDto;

  factory ApplicationDto.fromJson(Map<String, dynamic> json) =>
      _$ApplicationDtoFromJson(json);
}

extension ApplicationDtoMapper on ApplicationDto {
  JobApplication toDomain() {
    return JobApplication(
      id: jobListingId,
      jobTitle: jobTitle,
      companyName: companyName,
      submittedAt: submittedAt,
      status: ApplicationStatus.fromApi(status),
    );
  }
}
