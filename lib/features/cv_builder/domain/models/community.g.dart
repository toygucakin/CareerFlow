// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommunityImpl _$$CommunityImplFromJson(Map<String, dynamic> json) =>
    _$CommunityImpl(
      id: (json['id'] as num?)?.toInt(),
      profileId: json['profile_id'] as String?,
      name: json['name'] as String,
      role: json['role'] as String?,
      orderIndex: (json['sort_order'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CommunityImplToJson(_$CommunityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'profile_id': instance.profileId,
      'name': instance.name,
      'role': instance.role,
      'sort_order': instance.orderIndex,
    };
