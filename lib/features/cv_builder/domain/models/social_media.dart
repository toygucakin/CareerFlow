import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_media.freezed.dart';
part 'social_media.g.dart';

enum SocialMediaPlatform {
  linkedIn,
  github,
  medium,
  devto,
  hashnode,
  substack,
  x,
  instagram,
  facebook,
  youtube,
  behance,
  dribbble,
  website,
  other
}

@freezed
class SocialMediaAccount with _$SocialMediaAccount {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SocialMediaAccount({
    int? id,
    @JsonKey(name: 'profile_id') String? profileId,
    required SocialMediaPlatform platform,
    required String url,
  }) = _SocialMediaAccount;

  factory SocialMediaAccount.fromJson(Map<String, dynamic> json) =>
      _$SocialMediaAccountFromJson(json);
}

extension SocialMediaPlatformExtension on SocialMediaPlatform {
  String get displayName {
    switch (this) {
      case SocialMediaPlatform.linkedIn: return 'LinkedIn';
      case SocialMediaPlatform.github: return 'GitHub';
      case SocialMediaPlatform.medium: return 'Medium';
      case SocialMediaPlatform.devto: return 'Dev.to';
      case SocialMediaPlatform.hashnode: return 'Hashnode';
      case SocialMediaPlatform.substack: return 'Substack';
      case SocialMediaPlatform.x: return 'X (Twitter)';
      case SocialMediaPlatform.instagram: return 'Instagram';
      case SocialMediaPlatform.facebook: return 'Facebook';
      case SocialMediaPlatform.youtube: return 'YouTube';
      case SocialMediaPlatform.behance: return 'Behance';
      case SocialMediaPlatform.dribbble: return 'Dribbble';
      case SocialMediaPlatform.website: return 'Web Sitesi';
      case SocialMediaPlatform.other: return 'Diğer';
    }
  }

  // Not: İkonlar presentation katmanında MaterialIcons veya FontAwesome ile eşlenebilir.
}
