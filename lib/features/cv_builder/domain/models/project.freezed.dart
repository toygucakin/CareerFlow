// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Project _$ProjectFromJson(Map<String, dynamic> json) {
  return _Project.fromJson(json);
}

/// @nodoc
mixin _$Project {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_id')
  String? get profileId => throw _privateConstructorUsedError;
  @JsonKey(name: 'github_repo_id')
  String? get githubRepoId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'repo_url')
  String? get repoUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_autonomous')
  bool get isAutonomous => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  DateTime? get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'wakatime_hours')
  int get wakatimeHours => throw _privateConstructorUsedError;
  @JsonKey(name: 'ai_summary')
  String? get aiSummary => throw _privateConstructorUsedError;
  String? get scope => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get technologies => throw _privateConstructorUsedError;
  @JsonKey(name: 'sort_order')
  int? get orderIndex => throw _privateConstructorUsedError;

  /// Serializes this Project to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProjectCopyWith<Project> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProjectCopyWith<$Res> {
  factory $ProjectCopyWith(Project value, $Res Function(Project) then) =
      _$ProjectCopyWithImpl<$Res, Project>;
  @useResult
  $Res call({
    int? id,
    @JsonKey(name: 'profile_id') String? profileId,
    @JsonKey(name: 'github_repo_id') String? githubRepoId,
    String name,
    @JsonKey(name: 'repo_url') String? repoUrl,
    @JsonKey(name: 'is_autonomous') bool isAutonomous,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'wakatime_hours') int wakatimeHours,
    @JsonKey(name: 'ai_summary') String? aiSummary,
    String? scope,
    String? description,
    String? technologies,
    @JsonKey(name: 'sort_order') int? orderIndex,
  });
}

/// @nodoc
class _$ProjectCopyWithImpl<$Res, $Val extends Project>
    implements $ProjectCopyWith<$Res> {
  _$ProjectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? profileId = freezed,
    Object? githubRepoId = freezed,
    Object? name = null,
    Object? repoUrl = freezed,
    Object? isAutonomous = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? wakatimeHours = null,
    Object? aiSummary = freezed,
    Object? scope = freezed,
    Object? description = freezed,
    Object? technologies = freezed,
    Object? orderIndex = freezed,
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
            githubRepoId: freezed == githubRepoId
                ? _value.githubRepoId
                : githubRepoId // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            repoUrl: freezed == repoUrl
                ? _value.repoUrl
                : repoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            isAutonomous: null == isAutonomous
                ? _value.isAutonomous
                : isAutonomous // ignore: cast_nullable_to_non_nullable
                      as bool,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            wakatimeHours: null == wakatimeHours
                ? _value.wakatimeHours
                : wakatimeHours // ignore: cast_nullable_to_non_nullable
                      as int,
            aiSummary: freezed == aiSummary
                ? _value.aiSummary
                : aiSummary // ignore: cast_nullable_to_non_nullable
                      as String?,
            scope: freezed == scope
                ? _value.scope
                : scope // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            technologies: freezed == technologies
                ? _value.technologies
                : technologies // ignore: cast_nullable_to_non_nullable
                      as String?,
            orderIndex: freezed == orderIndex
                ? _value.orderIndex
                : orderIndex // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProjectImplCopyWith<$Res> implements $ProjectCopyWith<$Res> {
  factory _$$ProjectImplCopyWith(
    _$ProjectImpl value,
    $Res Function(_$ProjectImpl) then,
  ) = __$$ProjectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    @JsonKey(name: 'profile_id') String? profileId,
    @JsonKey(name: 'github_repo_id') String? githubRepoId,
    String name,
    @JsonKey(name: 'repo_url') String? repoUrl,
    @JsonKey(name: 'is_autonomous') bool isAutonomous,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'wakatime_hours') int wakatimeHours,
    @JsonKey(name: 'ai_summary') String? aiSummary,
    String? scope,
    String? description,
    String? technologies,
    @JsonKey(name: 'sort_order') int? orderIndex,
  });
}

/// @nodoc
class __$$ProjectImplCopyWithImpl<$Res>
    extends _$ProjectCopyWithImpl<$Res, _$ProjectImpl>
    implements _$$ProjectImplCopyWith<$Res> {
  __$$ProjectImplCopyWithImpl(
    _$ProjectImpl _value,
    $Res Function(_$ProjectImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? profileId = freezed,
    Object? githubRepoId = freezed,
    Object? name = null,
    Object? repoUrl = freezed,
    Object? isAutonomous = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? wakatimeHours = null,
    Object? aiSummary = freezed,
    Object? scope = freezed,
    Object? description = freezed,
    Object? technologies = freezed,
    Object? orderIndex = freezed,
  }) {
    return _then(
      _$ProjectImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        profileId: freezed == profileId
            ? _value.profileId
            : profileId // ignore: cast_nullable_to_non_nullable
                  as String?,
        githubRepoId: freezed == githubRepoId
            ? _value.githubRepoId
            : githubRepoId // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        repoUrl: freezed == repoUrl
            ? _value.repoUrl
            : repoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        isAutonomous: null == isAutonomous
            ? _value.isAutonomous
            : isAutonomous // ignore: cast_nullable_to_non_nullable
                  as bool,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        wakatimeHours: null == wakatimeHours
            ? _value.wakatimeHours
            : wakatimeHours // ignore: cast_nullable_to_non_nullable
                  as int,
        aiSummary: freezed == aiSummary
            ? _value.aiSummary
            : aiSummary // ignore: cast_nullable_to_non_nullable
                  as String?,
        scope: freezed == scope
            ? _value.scope
            : scope // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        technologies: freezed == technologies
            ? _value.technologies
            : technologies // ignore: cast_nullable_to_non_nullable
                  as String?,
        orderIndex: freezed == orderIndex
            ? _value.orderIndex
            : orderIndex // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProjectImpl implements _Project {
  const _$ProjectImpl({
    this.id,
    @JsonKey(name: 'profile_id') this.profileId,
    @JsonKey(name: 'github_repo_id') this.githubRepoId,
    required this.name,
    @JsonKey(name: 'repo_url') this.repoUrl,
    @JsonKey(name: 'is_autonomous') this.isAutonomous = false,
    @JsonKey(name: 'start_date') this.startDate,
    @JsonKey(name: 'end_date') this.endDate,
    @JsonKey(name: 'wakatime_hours') this.wakatimeHours = 0,
    @JsonKey(name: 'ai_summary') this.aiSummary,
    this.scope,
    this.description,
    this.technologies,
    @JsonKey(name: 'sort_order') this.orderIndex,
  });

  factory _$ProjectImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProjectImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'profile_id')
  final String? profileId;
  @override
  @JsonKey(name: 'github_repo_id')
  final String? githubRepoId;
  @override
  final String name;
  @override
  @JsonKey(name: 'repo_url')
  final String? repoUrl;
  @override
  @JsonKey(name: 'is_autonomous')
  final bool isAutonomous;
  @override
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @override
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  @override
  @JsonKey(name: 'wakatime_hours')
  final int wakatimeHours;
  @override
  @JsonKey(name: 'ai_summary')
  final String? aiSummary;
  @override
  final String? scope;
  @override
  final String? description;
  @override
  final String? technologies;
  @override
  @JsonKey(name: 'sort_order')
  final int? orderIndex;

  @override
  String toString() {
    return 'Project(id: $id, profileId: $profileId, githubRepoId: $githubRepoId, name: $name, repoUrl: $repoUrl, isAutonomous: $isAutonomous, startDate: $startDate, endDate: $endDate, wakatimeHours: $wakatimeHours, aiSummary: $aiSummary, scope: $scope, description: $description, technologies: $technologies, orderIndex: $orderIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProjectImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.profileId, profileId) ||
                other.profileId == profileId) &&
            (identical(other.githubRepoId, githubRepoId) ||
                other.githubRepoId == githubRepoId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.repoUrl, repoUrl) || other.repoUrl == repoUrl) &&
            (identical(other.isAutonomous, isAutonomous) ||
                other.isAutonomous == isAutonomous) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.wakatimeHours, wakatimeHours) ||
                other.wakatimeHours == wakatimeHours) &&
            (identical(other.aiSummary, aiSummary) ||
                other.aiSummary == aiSummary) &&
            (identical(other.scope, scope) || other.scope == scope) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.technologies, technologies) ||
                other.technologies == technologies) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    profileId,
    githubRepoId,
    name,
    repoUrl,
    isAutonomous,
    startDate,
    endDate,
    wakatimeHours,
    aiSummary,
    scope,
    description,
    technologies,
    orderIndex,
  );

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProjectImplCopyWith<_$ProjectImpl> get copyWith =>
      __$$ProjectImplCopyWithImpl<_$ProjectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProjectImplToJson(this);
  }
}

abstract class _Project implements Project {
  const factory _Project({
    final int? id,
    @JsonKey(name: 'profile_id') final String? profileId,
    @JsonKey(name: 'github_repo_id') final String? githubRepoId,
    required final String name,
    @JsonKey(name: 'repo_url') final String? repoUrl,
    @JsonKey(name: 'is_autonomous') final bool isAutonomous,
    @JsonKey(name: 'start_date') final DateTime? startDate,
    @JsonKey(name: 'end_date') final DateTime? endDate,
    @JsonKey(name: 'wakatime_hours') final int wakatimeHours,
    @JsonKey(name: 'ai_summary') final String? aiSummary,
    final String? scope,
    final String? description,
    final String? technologies,
    @JsonKey(name: 'sort_order') final int? orderIndex,
  }) = _$ProjectImpl;

  factory _Project.fromJson(Map<String, dynamic> json) = _$ProjectImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'profile_id')
  String? get profileId;
  @override
  @JsonKey(name: 'github_repo_id')
  String? get githubRepoId;
  @override
  String get name;
  @override
  @JsonKey(name: 'repo_url')
  String? get repoUrl;
  @override
  @JsonKey(name: 'is_autonomous')
  bool get isAutonomous;
  @override
  @JsonKey(name: 'start_date')
  DateTime? get startDate;
  @override
  @JsonKey(name: 'end_date')
  DateTime? get endDate;
  @override
  @JsonKey(name: 'wakatime_hours')
  int get wakatimeHours;
  @override
  @JsonKey(name: 'ai_summary')
  String? get aiSummary;
  @override
  String? get scope;
  @override
  String? get description;
  @override
  String? get technologies;
  @override
  @JsonKey(name: 'sort_order')
  int? get orderIndex;

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProjectImplCopyWith<_$ProjectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
