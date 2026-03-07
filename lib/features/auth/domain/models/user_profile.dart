import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@Freezed(fieldRename: FieldRename.snake)
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    String? firstName,
    String? lastName,
    String? phone,
    String? city,
    String? district,
    DateTime? birthDate,
    String? cvLanguage,
    DateTime? updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}
