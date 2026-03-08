import 'package:freezed_annotation/freezed_annotation.dart';

part 'education.freezed.dart';
part 'education.g.dart';

@freezed
class Education with _$Education {
  const factory Education({
    int? id,
    @JsonKey(name: 'profile_id') String? profileId,
    required String school,
    String? degree,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'sort_order') int? orderIndex,
  }) = _Education;

  factory Education.fromJson(Map<String, dynamic> json) => _$EducationFromJson(json);
}
