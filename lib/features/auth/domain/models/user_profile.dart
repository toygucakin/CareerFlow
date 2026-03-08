import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserProfile({
    required String id,
    String? firstName,
    String? lastName,
    String? phone,
    String? city,
    String? district,
    DateTime? birthDate,
    String? email,
    DateTime? updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}
