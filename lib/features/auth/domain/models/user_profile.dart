import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    String? fullName,
    String? title,
    String? location,
    Map<String, dynamic>? contact,
    Map<String, dynamic>? links,
    String? firstName,
    String? lastName,
    String? phone,
    String? city,
    String? district,
    DateTime? birthDate,
    String? birthPlace,
    String? cvLanguage,
    List<String>? hobbies,
    List<String>? languages,
    List<String>? associations,
    DateTime? updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}
