// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      birthDate: json['birth_date'] == null
          ? null
          : DateTime.parse(json['birth_date'] as String),
      email: json['email'] as String?,
      aboutMe: json['about_me'] as String?,
      jobTitle: json['job_title'] as String?,
      portfolioUrl: json['portfolio_url'] as String?,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone': instance.phone,
      'city': instance.city,
      'district': instance.district,
      'birth_date': instance.birthDate?.toIso8601String(),
      'email': instance.email,
      'about_me': instance.aboutMe,
      'job_title': instance.jobTitle,
      'portfolio_url': instance.portfolioUrl,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
