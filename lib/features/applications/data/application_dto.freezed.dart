// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'application_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApplicationDto {

 String get jobListingId; String get jobTitle; String get companyName; String get applicantId; String get applicantName; DateTime get submittedAt; String get status;
/// Create a copy of ApplicationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApplicationDtoCopyWith<ApplicationDto> get copyWith => _$ApplicationDtoCopyWithImpl<ApplicationDto>(this as ApplicationDto, _$identity);

  /// Serializes this ApplicationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApplicationDto&&(identical(other.jobListingId, jobListingId) || other.jobListingId == jobListingId)&&(identical(other.jobTitle, jobTitle) || other.jobTitle == jobTitle)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.applicantId, applicantId) || other.applicantId == applicantId)&&(identical(other.applicantName, applicantName) || other.applicantName == applicantName)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobListingId,jobTitle,companyName,applicantId,applicantName,submittedAt,status);

@override
String toString() {
  return 'ApplicationDto(jobListingId: $jobListingId, jobTitle: $jobTitle, companyName: $companyName, applicantId: $applicantId, applicantName: $applicantName, submittedAt: $submittedAt, status: $status)';
}


}

/// @nodoc
abstract mixin class $ApplicationDtoCopyWith<$Res>  {
  factory $ApplicationDtoCopyWith(ApplicationDto value, $Res Function(ApplicationDto) _then) = _$ApplicationDtoCopyWithImpl;
@useResult
$Res call({
 String jobListingId, String jobTitle, String companyName, String applicantId, String applicantName, DateTime submittedAt, String status
});




}
/// @nodoc
class _$ApplicationDtoCopyWithImpl<$Res>
    implements $ApplicationDtoCopyWith<$Res> {
  _$ApplicationDtoCopyWithImpl(this._self, this._then);

  final ApplicationDto _self;
  final $Res Function(ApplicationDto) _then;

/// Create a copy of ApplicationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jobListingId = null,Object? jobTitle = null,Object? companyName = null,Object? applicantId = null,Object? applicantName = null,Object? submittedAt = null,Object? status = null,}) {
  return _then(_self.copyWith(
jobListingId: null == jobListingId ? _self.jobListingId : jobListingId // ignore: cast_nullable_to_non_nullable
as String,jobTitle: null == jobTitle ? _self.jobTitle : jobTitle // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,applicantId: null == applicantId ? _self.applicantId : applicantId // ignore: cast_nullable_to_non_nullable
as String,applicantName: null == applicantName ? _self.applicantName : applicantName // ignore: cast_nullable_to_non_nullable
as String,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ApplicationDto].
extension ApplicationDtoPatterns on ApplicationDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApplicationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApplicationDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApplicationDto value)  $default,){
final _that = this;
switch (_that) {
case _ApplicationDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApplicationDto value)?  $default,){
final _that = this;
switch (_that) {
case _ApplicationDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String jobListingId,  String jobTitle,  String companyName,  String applicantId,  String applicantName,  DateTime submittedAt,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApplicationDto() when $default != null:
return $default(_that.jobListingId,_that.jobTitle,_that.companyName,_that.applicantId,_that.applicantName,_that.submittedAt,_that.status);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String jobListingId,  String jobTitle,  String companyName,  String applicantId,  String applicantName,  DateTime submittedAt,  String status)  $default,) {final _that = this;
switch (_that) {
case _ApplicationDto():
return $default(_that.jobListingId,_that.jobTitle,_that.companyName,_that.applicantId,_that.applicantName,_that.submittedAt,_that.status);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String jobListingId,  String jobTitle,  String companyName,  String applicantId,  String applicantName,  DateTime submittedAt,  String status)?  $default,) {final _that = this;
switch (_that) {
case _ApplicationDto() when $default != null:
return $default(_that.jobListingId,_that.jobTitle,_that.companyName,_that.applicantId,_that.applicantName,_that.submittedAt,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApplicationDto implements ApplicationDto {
  const _ApplicationDto({required this.jobListingId, required this.jobTitle, required this.companyName, required this.applicantId, required this.applicantName, required this.submittedAt, required this.status});
  factory _ApplicationDto.fromJson(Map<String, dynamic> json) => _$ApplicationDtoFromJson(json);

@override final  String jobListingId;
@override final  String jobTitle;
@override final  String companyName;
@override final  String applicantId;
@override final  String applicantName;
@override final  DateTime submittedAt;
@override final  String status;

/// Create a copy of ApplicationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApplicationDtoCopyWith<_ApplicationDto> get copyWith => __$ApplicationDtoCopyWithImpl<_ApplicationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApplicationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApplicationDto&&(identical(other.jobListingId, jobListingId) || other.jobListingId == jobListingId)&&(identical(other.jobTitle, jobTitle) || other.jobTitle == jobTitle)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.applicantId, applicantId) || other.applicantId == applicantId)&&(identical(other.applicantName, applicantName) || other.applicantName == applicantName)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobListingId,jobTitle,companyName,applicantId,applicantName,submittedAt,status);

@override
String toString() {
  return 'ApplicationDto(jobListingId: $jobListingId, jobTitle: $jobTitle, companyName: $companyName, applicantId: $applicantId, applicantName: $applicantName, submittedAt: $submittedAt, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ApplicationDtoCopyWith<$Res> implements $ApplicationDtoCopyWith<$Res> {
  factory _$ApplicationDtoCopyWith(_ApplicationDto value, $Res Function(_ApplicationDto) _then) = __$ApplicationDtoCopyWithImpl;
@override @useResult
$Res call({
 String jobListingId, String jobTitle, String companyName, String applicantId, String applicantName, DateTime submittedAt, String status
});




}
/// @nodoc
class __$ApplicationDtoCopyWithImpl<$Res>
    implements _$ApplicationDtoCopyWith<$Res> {
  __$ApplicationDtoCopyWithImpl(this._self, this._then);

  final _ApplicationDto _self;
  final $Res Function(_ApplicationDto) _then;

/// Create a copy of ApplicationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jobListingId = null,Object? jobTitle = null,Object? companyName = null,Object? applicantId = null,Object? applicantName = null,Object? submittedAt = null,Object? status = null,}) {
  return _then(_ApplicationDto(
jobListingId: null == jobListingId ? _self.jobListingId : jobListingId // ignore: cast_nullable_to_non_nullable
as String,jobTitle: null == jobTitle ? _self.jobTitle : jobTitle // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,applicantId: null == applicantId ? _self.applicantId : applicantId // ignore: cast_nullable_to_non_nullable
as String,applicantName: null == applicantName ? _self.applicantName : applicantName // ignore: cast_nullable_to_non_nullable
as String,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
