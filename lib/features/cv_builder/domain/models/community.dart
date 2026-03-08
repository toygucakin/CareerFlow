import 'package:freezed_annotation/freezed_annotation.dart';

part 'community.freezed.dart';
part 'community.g.dart';

@freezed
class Community with _$Community {
  const factory Community({
    int? id,
    @JsonKey(name: 'profile_id') String? profileId,
    required String name,
    String? role,
    @JsonKey(name: 'sort_order') int? orderIndex,
  }) = _Community;

  factory Community.fromJson(Map<String, dynamic> json) =>
      _$CommunityFromJson(json);
}
