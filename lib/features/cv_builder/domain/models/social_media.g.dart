// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_media.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SocialMediaAccountImpl _$$SocialMediaAccountImplFromJson(
  Map<String, dynamic> json,
) => _$SocialMediaAccountImpl(
  id: (json['id'] as num?)?.toInt(),
  profileId: json['profile_id'] as String?,
  platform: $enumDecode(_$SocialMediaPlatformEnumMap, json['platform']),
  url: json['url'] as String,
);

Map<String, dynamic> _$$SocialMediaAccountImplToJson(
  _$SocialMediaAccountImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'profile_id': instance.profileId,
  'platform': _$SocialMediaPlatformEnumMap[instance.platform]!,
  'url': instance.url,
};

const _$SocialMediaPlatformEnumMap = {
  SocialMediaPlatform.linkedIn: 'linkedIn',
  SocialMediaPlatform.github: 'github',
  SocialMediaPlatform.medium: 'medium',
  SocialMediaPlatform.devto: 'devto',
  SocialMediaPlatform.hashnode: 'hashnode',
  SocialMediaPlatform.substack: 'substack',
  SocialMediaPlatform.x: 'x',
  SocialMediaPlatform.instagram: 'instagram',
  SocialMediaPlatform.facebook: 'facebook',
  SocialMediaPlatform.youtube: 'youtube',
  SocialMediaPlatform.behance: 'behance',
  SocialMediaPlatform.dribbble: 'dribbble',
  SocialMediaPlatform.website: 'website',
  SocialMediaPlatform.other: 'other',
};
