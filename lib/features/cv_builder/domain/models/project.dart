import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';
part 'project.g.dart';

@freezed
class Project with _$Project {
  const factory Project({
    int? id,
    @JsonKey(name: 'profile_id') String? profileId,
    @JsonKey(name: 'github_repo_id') String? githubRepoId,
    required String name,
    @JsonKey(name: 'repo_url') String? repoUrl,
    @JsonKey(name: 'is_autonomous') @Default(false) bool isAutonomous,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'wakatime_hours') @Default(0) int wakatimeHours,
    @JsonKey(name: 'ai_summary') String? aiSummary,
    String? scope,
    String? description,
    String? technologies,
    @JsonKey(name: 'sort_order') int? orderIndex,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
}
