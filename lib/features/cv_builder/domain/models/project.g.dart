// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProjectImpl _$$ProjectImplFromJson(Map<String, dynamic> json) =>
    _$ProjectImpl(
      id: (json['id'] as num?)?.toInt(),
      profileId: json['profile_id'] as String?,
      githubRepoId: json['github_repo_id'] as String?,
      name: json['name'] as String,
      role: json['role'] as String?,
      repoUrl: json['repo_url'] as String?,
      isAutonomous: json['is_autonomous'] as bool? ?? false,
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      wakatimeHours: (json['wakatime_hours'] as num?)?.toInt() ?? 0,
      aiSummary: json['ai_summary'] as String?,
      scope: json['scope'] as String?,
      description: json['description'] as String?,
      technologies: json['technologies'] as String?,
      isHighlighted: json['is_highlighted'] as bool? ?? false,
      orderIndex: (json['sort_order'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ProjectImplToJson(_$ProjectImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'profile_id': instance.profileId,
      'github_repo_id': instance.githubRepoId,
      'name': instance.name,
      'role': instance.role,
      'repo_url': instance.repoUrl,
      'is_autonomous': instance.isAutonomous,
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'wakatime_hours': instance.wakatimeHours,
      'ai_summary': instance.aiSummary,
      'scope': instance.scope,
      'description': instance.description,
      'technologies': instance.technologies,
      'is_highlighted': instance.isHighlighted,
      'sort_order': instance.orderIndex,
    };
