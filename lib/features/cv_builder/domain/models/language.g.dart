// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LanguageImpl _$$LanguageImplFromJson(Map<String, dynamic> json) =>
    _$LanguageImpl(
      id: (json['id'] as num?)?.toInt(),
      profileId: json['profile_id'] as String?,
      name: json['name'] as String,
      proficiency: json['proficiency'] as String?,
      orderIndex: (json['sort_order'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$LanguageImplToJson(_$LanguageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'profile_id': instance.profileId,
      'name': instance.name,
      'proficiency': instance.proficiency,
      'sort_order': instance.orderIndex,
    };
