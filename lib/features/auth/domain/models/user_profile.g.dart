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
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
