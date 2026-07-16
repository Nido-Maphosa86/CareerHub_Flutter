// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_JobDto _$JobDtoFromJson(Map<String, dynamic> json) => _JobDto(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  companyName: json['companyName'] as String,
  location: json['location'] as String,
  type: json['type'] as String,
  salaryMin: (json['salaryMin'] as num?)?.toDouble(),
  salaryMax: (json['salaryMax'] as num?)?.toDouble(),
  salaryDisplay: json['salaryDisplay'] as String,
  postedAt: DateTime.parse(json['postedAt'] as String),
  isActive: json['isActive'] as bool,
  applicationCount: (json['applicationCount'] as num).toInt(),
  closingDate: DateTime.parse(json['closingDate'] as String),
  status: json['status'] as String,
);

Map<String, dynamic> _$JobDtoToJson(_JobDto instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'companyName': instance.companyName,
  'location': instance.location,
  'type': instance.type,
  'salaryMin': instance.salaryMin,
  'salaryMax': instance.salaryMax,
  'salaryDisplay': instance.salaryDisplay,
  'postedAt': instance.postedAt.toIso8601String(),
  'isActive': instance.isActive,
  'applicationCount': instance.applicationCount,
  'closingDate': instance.closingDate.toIso8601String(),
  'status': instance.status,
};
