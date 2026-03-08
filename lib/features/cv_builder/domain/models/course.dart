import 'package:freezed_annotation/freezed_annotation.dart';

part 'course.freezed.dart';
part 'course.g.dart';

@freezed
class Course with _$Course {
  const factory Course({
    int? id,
    @JsonKey(name: 'profile_id') String? profileId,
    required String name,
    String? issuer,
    String? description,
    @JsonKey(name: 'sort_order') int? orderIndex,
  }) = _Course;

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
}
