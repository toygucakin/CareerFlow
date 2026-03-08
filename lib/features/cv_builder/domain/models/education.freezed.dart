// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'education.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Education _$EducationFromJson(Map<String, dynamic> json) {
  return _Education.fromJson(json);
}

/// @nodoc
mixin _$Education {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_id')
  String? get profileId => throw _privateConstructorUsedError;
  String get school => throw _privateConstructorUsedError;
  String? get degree => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  DateTime? get endDate => throw _privateConstructorUsedError;

  /// Serializes this Education to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Education
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EducationCopyWith<Education> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EducationCopyWith<$Res> {
  factory $EducationCopyWith(Education value, $Res Function(Education) then) =
      _$EducationCopyWithImpl<$Res, Education>;
  @useResult
  $Res call({
    int? id,
    @JsonKey(name: 'profile_id') String? profileId,
    String school,
    String? degree,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
  });
}

/// @nodoc
class _$EducationCopyWithImpl<$Res, $Val extends Education>
    implements $EducationCopyWith<$Res> {
  _$EducationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Education
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? profileId = freezed,
    Object? school = null,
    Object? degree = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            profileId: freezed == profileId
                ? _value.profileId
                : profileId // ignore: cast_nullable_to_non_nullable
                      as String?,
            school: null == school
                ? _value.school
                : school // ignore: cast_nullable_to_non_nullable
                      as String,
            degree: freezed == degree
                ? _value.degree
                : degree // ignore: cast_nullable_to_non_nullable
                      as String?,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EducationImplCopyWith<$Res>
    implements $EducationCopyWith<$Res> {
  factory _$$EducationImplCopyWith(
    _$EducationImpl value,
    $Res Function(_$EducationImpl) then,
  ) = __$$EducationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    @JsonKey(name: 'profile_id') String? profileId,
    String school,
    String? degree,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
  });
}

/// @nodoc
class __$$EducationImplCopyWithImpl<$Res>
    extends _$EducationCopyWithImpl<$Res, _$EducationImpl>
    implements _$$EducationImplCopyWith<$Res> {
  __$$EducationImplCopyWithImpl(
    _$EducationImpl _value,
    $Res Function(_$EducationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Education
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? profileId = freezed,
    Object? school = null,
    Object? degree = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
  }) {
    return _then(
      _$EducationImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        profileId: freezed == profileId
            ? _value.profileId
            : profileId // ignore: cast_nullable_to_non_nullable
                  as String?,
        school: null == school
            ? _value.school
            : school // ignore: cast_nullable_to_non_nullable
                  as String,
        degree: freezed == degree
            ? _value.degree
            : degree // ignore: cast_nullable_to_non_nullable
                  as String?,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EducationImpl implements _Education {
  const _$EducationImpl({
    this.id,
    @JsonKey(name: 'profile_id') this.profileId,
    required this.school,
    this.degree,
    @JsonKey(name: 'start_date') this.startDate,
    @JsonKey(name: 'end_date') this.endDate,
  });

  factory _$EducationImpl.fromJson(Map<String, dynamic> json) =>
      _$$EducationImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'profile_id')
  final String? profileId;
  @override
  final String school;
  @override
  final String? degree;
  @override
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @override
  @JsonKey(name: 'end_date')
  final DateTime? endDate;

  @override
  String toString() {
    return 'Education(id: $id, profileId: $profileId, school: $school, degree: $degree, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EducationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.profileId, profileId) ||
                other.profileId == profileId) &&
            (identical(other.school, school) || other.school == school) &&
            (identical(other.degree, degree) || other.degree == degree) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    profileId,
    school,
    degree,
    startDate,
    endDate,
  );

  /// Create a copy of Education
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EducationImplCopyWith<_$EducationImpl> get copyWith =>
      __$$EducationImplCopyWithImpl<_$EducationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EducationImplToJson(this);
  }
}

abstract class _Education implements Education {
  const factory _Education({
    final int? id,
    @JsonKey(name: 'profile_id') final String? profileId,
    required final String school,
    final String? degree,
    @JsonKey(name: 'start_date') final DateTime? startDate,
    @JsonKey(name: 'end_date') final DateTime? endDate,
  }) = _$EducationImpl;

  factory _Education.fromJson(Map<String, dynamic> json) =
      _$EducationImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'profile_id')
  String? get profileId;
  @override
  String get school;
  @override
  String? get degree;
  @override
  @JsonKey(name: 'start_date')
  DateTime? get startDate;
  @override
  @JsonKey(name: 'end_date')
  DateTime? get endDate;

  /// Create a copy of Education
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EducationImplCopyWith<_$EducationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
