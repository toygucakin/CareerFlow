// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CourseImpl _$$CourseImplFromJson(Map<String, dynamic> json) => _$CourseImpl(
  id: (json['id'] as num?)?.toInt(),
  profileId: json['profile_id'] as String?,
  name: json['name'] as String,
  issuer: json['issuer'] as String?,
  description: json['description'] as String?,
  orderIndex: (json['sort_order'] as num?)?.toInt(),
);

Map<String, dynamic> _$$CourseImplToJson(_$CourseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'profile_id': instance.profileId,
      'name': instance.name,
      'issuer': instance.issuer,
      'description': instance.description,
      'sort_order': instance.orderIndex,
    };
