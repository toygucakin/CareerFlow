// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social_media.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SocialMediaAccount _$SocialMediaAccountFromJson(Map<String, dynamic> json) {
  return _SocialMediaAccount.fromJson(json);
}

/// @nodoc
mixin _$SocialMediaAccount {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_id')
  String? get profileId => throw _privateConstructorUsedError;
  SocialMediaPlatform get platform => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;

  /// Serializes this SocialMediaAccount to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SocialMediaAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SocialMediaAccountCopyWith<SocialMediaAccount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SocialMediaAccountCopyWith<$Res> {
  factory $SocialMediaAccountCopyWith(
    SocialMediaAccount value,
    $Res Function(SocialMediaAccount) then,
  ) = _$SocialMediaAccountCopyWithImpl<$Res, SocialMediaAccount>;
  @useResult
  $Res call({
    int? id,
    @JsonKey(name: 'profile_id') String? profileId,
    SocialMediaPlatform platform,
    String url,
  });
}

/// @nodoc
class _$SocialMediaAccountCopyWithImpl<$Res, $Val extends SocialMediaAccount>
    implements $SocialMediaAccountCopyWith<$Res> {
  _$SocialMediaAccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SocialMediaAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? profileId = freezed,
    Object? platform = null,
    Object? url = null,
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
            platform: null == platform
                ? _value.platform
                : platform // ignore: cast_nullable_to_non_nullable
                      as SocialMediaPlatform,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SocialMediaAccountImplCopyWith<$Res>
    implements $SocialMediaAccountCopyWith<$Res> {
  factory _$$SocialMediaAccountImplCopyWith(
    _$SocialMediaAccountImpl value,
    $Res Function(_$SocialMediaAccountImpl) then,
  ) = __$$SocialMediaAccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    @JsonKey(name: 'profile_id') String? profileId,
    SocialMediaPlatform platform,
    String url,
  });
}

/// @nodoc
class __$$SocialMediaAccountImplCopyWithImpl<$Res>
    extends _$SocialMediaAccountCopyWithImpl<$Res, _$SocialMediaAccountImpl>
    implements _$$SocialMediaAccountImplCopyWith<$Res> {
  __$$SocialMediaAccountImplCopyWithImpl(
    _$SocialMediaAccountImpl _value,
    $Res Function(_$SocialMediaAccountImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SocialMediaAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? profileId = freezed,
    Object? platform = null,
    Object? url = null,
  }) {
    return _then(
      _$SocialMediaAccountImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        profileId: freezed == profileId
            ? _value.profileId
            : profileId // ignore: cast_nullable_to_non_nullable
                  as String?,
        platform: null == platform
            ? _value.platform
            : platform // ignore: cast_nullable_to_non_nullable
                  as SocialMediaPlatform,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$SocialMediaAccountImpl extends _SocialMediaAccount {
  const _$SocialMediaAccountImpl({
    this.id,
    @JsonKey(name: 'profile_id') this.profileId,
    required this.platform,
    required this.url,
  }) : super._();

  factory _$SocialMediaAccountImpl.fromJson(Map<String, dynamic> json) =>
      _$$SocialMediaAccountImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'profile_id')
  final String? profileId;
  @override
  final SocialMediaPlatform platform;
  @override
  final String url;

  @override
  String toString() {
    return 'SocialMediaAccount(id: $id, profileId: $profileId, platform: $platform, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SocialMediaAccountImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.profileId, profileId) ||
                other.profileId == profileId) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.url, url) || other.url == url));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, profileId, platform, url);

  /// Create a copy of SocialMediaAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SocialMediaAccountImplCopyWith<_$SocialMediaAccountImpl> get copyWith =>
      __$$SocialMediaAccountImplCopyWithImpl<_$SocialMediaAccountImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SocialMediaAccountImplToJson(this);
  }
}

abstract class _SocialMediaAccount extends SocialMediaAccount {
  const factory _SocialMediaAccount({
    final int? id,
    @JsonKey(name: 'profile_id') final String? profileId,
    required final SocialMediaPlatform platform,
    required final String url,
  }) = _$SocialMediaAccountImpl;
  const _SocialMediaAccount._() : super._();

  factory _SocialMediaAccount.fromJson(Map<String, dynamic> json) =
      _$SocialMediaAccountImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'profile_id')
  String? get profileId;
  @override
  SocialMediaPlatform get platform;
  @override
  String get url;

  /// Create a copy of SocialMediaAccount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SocialMediaAccountImplCopyWith<_$SocialMediaAccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
