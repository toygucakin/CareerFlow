// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  String get id => throw _privateConstructorUsedError;
  String? get fullName => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  Map<String, dynamic>? get contact => throw _privateConstructorUsedError;
  Map<String, dynamic>? get links => throw _privateConstructorUsedError;
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  DateTime? get birthDate => throw _privateConstructorUsedError;
  String? get birthPlace => throw _privateConstructorUsedError;
  String? get cvLanguage => throw _privateConstructorUsedError;
  List<String>? get hobbies => throw _privateConstructorUsedError;
  List<String>? get languages => throw _privateConstructorUsedError;
  List<String>? get associations => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
    UserProfile value,
    $Res Function(UserProfile) then,
  ) = _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call({
    String id,
    String? fullName,
    String? title,
    String? location,
    Map<String, dynamic>? contact,
    Map<String, dynamic>? links,
    String? firstName,
    String? lastName,
    String? phone,
    String? city,
    DateTime? birthDate,
    String? birthPlace,
    String? cvLanguage,
    List<String>? hobbies,
    List<String>? languages,
    List<String>? associations,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = freezed,
    Object? title = freezed,
    Object? location = freezed,
    Object? contact = freezed,
    Object? links = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? phone = freezed,
    Object? city = freezed,
    Object? birthDate = freezed,
    Object? birthPlace = freezed,
    Object? cvLanguage = freezed,
    Object? hobbies = freezed,
    Object? languages = freezed,
    Object? associations = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            fullName: freezed == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            contact: freezed == contact
                ? _value.contact
                : contact // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            links: freezed == links
                ? _value.links
                : links // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            firstName: freezed == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastName: freezed == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            city: freezed == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String?,
            birthDate: freezed == birthDate
                ? _value.birthDate
                : birthDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            birthPlace: freezed == birthPlace
                ? _value.birthPlace
                : birthPlace // ignore: cast_nullable_to_non_nullable
                      as String?,
            cvLanguage: freezed == cvLanguage
                ? _value.cvLanguage
                : cvLanguage // ignore: cast_nullable_to_non_nullable
                      as String?,
            hobbies: freezed == hobbies
                ? _value.hobbies
                : hobbies // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            languages: freezed == languages
                ? _value.languages
                : languages // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            associations: freezed == associations
                ? _value.associations
                : associations // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
    _$UserProfileImpl value,
    $Res Function(_$UserProfileImpl) then,
  ) = __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? fullName,
    String? title,
    String? location,
    Map<String, dynamic>? contact,
    Map<String, dynamic>? links,
    String? firstName,
    String? lastName,
    String? phone,
    String? city,
    DateTime? birthDate,
    String? birthPlace,
    String? cvLanguage,
    List<String>? hobbies,
    List<String>? languages,
    List<String>? associations,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
    _$UserProfileImpl _value,
    $Res Function(_$UserProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = freezed,
    Object? title = freezed,
    Object? location = freezed,
    Object? contact = freezed,
    Object? links = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? phone = freezed,
    Object? city = freezed,
    Object? birthDate = freezed,
    Object? birthPlace = freezed,
    Object? cvLanguage = freezed,
    Object? hobbies = freezed,
    Object? languages = freezed,
    Object? associations = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$UserProfileImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: freezed == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        contact: freezed == contact
            ? _value._contact
            : contact // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        links: freezed == links
            ? _value._links
            : links // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        firstName: freezed == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastName: freezed == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        city: freezed == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String?,
        birthDate: freezed == birthDate
            ? _value.birthDate
            : birthDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        birthPlace: freezed == birthPlace
            ? _value.birthPlace
            : birthPlace // ignore: cast_nullable_to_non_nullable
                  as String?,
        cvLanguage: freezed == cvLanguage
            ? _value.cvLanguage
            : cvLanguage // ignore: cast_nullable_to_non_nullable
                  as String?,
        hobbies: freezed == hobbies
            ? _value._hobbies
            : hobbies // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        languages: freezed == languages
            ? _value._languages
            : languages // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        associations: freezed == associations
            ? _value._associations
            : associations // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl({
    required this.id,
    this.fullName,
    this.title,
    this.location,
    final Map<String, dynamic>? contact,
    final Map<String, dynamic>? links,
    this.firstName,
    this.lastName,
    this.phone,
    this.city,
    this.birthDate,
    this.birthPlace,
    this.cvLanguage,
    final List<String>? hobbies,
    final List<String>? languages,
    final List<String>? associations,
    this.updatedAt,
  }) : _contact = contact,
       _links = links,
       _hobbies = hobbies,
       _languages = languages,
       _associations = associations;

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String? fullName;
  @override
  final String? title;
  @override
  final String? location;
  final Map<String, dynamic>? _contact;
  @override
  Map<String, dynamic>? get contact {
    final value = _contact;
    if (value == null) return null;
    if (_contact is EqualUnmodifiableMapView) return _contact;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _links;
  @override
  Map<String, dynamic>? get links {
    final value = _links;
    if (value == null) return null;
    if (_links is EqualUnmodifiableMapView) return _links;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  final String? phone;
  @override
  final String? city;
  @override
  final DateTime? birthDate;
  @override
  final String? birthPlace;
  @override
  final String? cvLanguage;
  final List<String>? _hobbies;
  @override
  List<String>? get hobbies {
    final value = _hobbies;
    if (value == null) return null;
    if (_hobbies is EqualUnmodifiableListView) return _hobbies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _languages;
  @override
  List<String>? get languages {
    final value = _languages;
    if (value == null) return null;
    if (_languages is EqualUnmodifiableListView) return _languages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _associations;
  @override
  List<String>? get associations {
    final value = _associations;
    if (value == null) return null;
    if (_associations is EqualUnmodifiableListView) return _associations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'UserProfile(id: $id, fullName: $fullName, title: $title, location: $location, contact: $contact, links: $links, firstName: $firstName, lastName: $lastName, phone: $phone, city: $city, birthDate: $birthDate, birthPlace: $birthPlace, cvLanguage: $cvLanguage, hobbies: $hobbies, languages: $languages, associations: $associations, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(other._contact, _contact) &&
            const DeepCollectionEquality().equals(other._links, _links) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.birthPlace, birthPlace) ||
                other.birthPlace == birthPlace) &&
            (identical(other.cvLanguage, cvLanguage) ||
                other.cvLanguage == cvLanguage) &&
            const DeepCollectionEquality().equals(other._hobbies, _hobbies) &&
            const DeepCollectionEquality().equals(
              other._languages,
              _languages,
            ) &&
            const DeepCollectionEquality().equals(
              other._associations,
              _associations,
            ) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    fullName,
    title,
    location,
    const DeepCollectionEquality().hash(_contact),
    const DeepCollectionEquality().hash(_links),
    firstName,
    lastName,
    phone,
    city,
    birthDate,
    birthPlace,
    cvLanguage,
    const DeepCollectionEquality().hash(_hobbies),
    const DeepCollectionEquality().hash(_languages),
    const DeepCollectionEquality().hash(_associations),
    updatedAt,
  );

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(this);
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile({
    required final String id,
    final String? fullName,
    final String? title,
    final String? location,
    final Map<String, dynamic>? contact,
    final Map<String, dynamic>? links,
    final String? firstName,
    final String? lastName,
    final String? phone,
    final String? city,
    final DateTime? birthDate,
    final String? birthPlace,
    final String? cvLanguage,
    final List<String>? hobbies,
    final List<String>? languages,
    final List<String>? associations,
    final DateTime? updatedAt,
  }) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get id;
  @override
  String? get fullName;
  @override
  String? get title;
  @override
  String? get location;
  @override
  Map<String, dynamic>? get contact;
  @override
  Map<String, dynamic>? get links;
  @override
  String? get firstName;
  @override
  String? get lastName;
  @override
  String? get phone;
  @override
  String? get city;
  @override
  DateTime? get birthDate;
  @override
  String? get birthPlace;
  @override
  String? get cvLanguage;
  @override
  List<String>? get hobbies;
  @override
  List<String>? get languages;
  @override
  List<String>? get associations;
  @override
  DateTime? get updatedAt;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
