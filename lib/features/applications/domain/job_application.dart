import 'package:freezed_annotation/freezed_annotation.dart';
import 'application_status.dart';

part 'job_application.freezed.dart';

@freezed
abstract class JobApplication with _$JobApplication {
  const factory JobApplication({
    required String id,
    required String jobTitle,
    required String companyName,
    required DateTime submittedAt,
    required ApplicationStatus status,
  }) = _JobApplication;
}
