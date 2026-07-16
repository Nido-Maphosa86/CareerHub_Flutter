// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApplicationDto _$ApplicationDtoFromJson(Map<String, dynamic> json) =>
    _ApplicationDto(
      jobListingId: json['jobListingId'] as String,
      jobTitle: json['jobTitle'] as String,
      companyName: json['companyName'] as String,
      applicantId: json['applicantId'] as String,
      applicantName: json['applicantName'] as String,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      status: json['status'] as String,
    );

Map<String, dynamic> _$ApplicationDtoToJson(_ApplicationDto instance) =>
    <String, dynamic>{
      'jobListingId': instance.jobListingId,
      'jobTitle': instance.jobTitle,
      'companyName': instance.companyName,
      'applicantId': instance.applicantId,
      'applicantName': instance.applicantName,
      'submittedAt': instance.submittedAt.toIso8601String(),
      'status': instance.status,
    };
