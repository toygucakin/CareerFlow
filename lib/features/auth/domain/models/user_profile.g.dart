// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      fullName: json['fullName'] as String?,
      title: json['title'] as String?,
      location: json['location'] as String?,
      contact: json['contact'] as Map<String, dynamic>?,
      links: json['links'] as Map<String, dynamic>?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      birthDate: json['birthDate'] == null
          ? null
          : DateTime.parse(json['birthDate'] as String),
      cvLanguage: json['cvLanguage'] as String?,
      hobbies: (json['hobbies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      associations: (json['associations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'title': instance.title,
      'location': instance.location,
      'contact': instance.contact,
      'links': instance.links,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phone': instance.phone,
      'city': instance.city,
      'district': instance.district,
      'birthDate': instance.birthDate?.toIso8601String(),
      'cvLanguage': instance.cvLanguage,
      'hobbies': instance.hobbies,
      'languages': instance.languages,
      'associations': instance.associations,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
