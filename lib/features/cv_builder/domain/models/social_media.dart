import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

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

  IconData get icon {
    switch (this) {
      case SocialMediaPlatform.linkedIn: return Icons.business_outlined;
      case SocialMediaPlatform.github: return Icons.code_outlined;
      case SocialMediaPlatform.medium:
      case SocialMediaPlatform.devto:
      case SocialMediaPlatform.hashnode:
      case SocialMediaPlatform.substack: return Icons.article_outlined;
      case SocialMediaPlatform.youtube: return Icons.play_circle_outline;
      case SocialMediaPlatform.instagram:
      case SocialMediaPlatform.facebook:
      case SocialMediaPlatform.x: return Icons.share_outlined;
      case SocialMediaPlatform.behance:
      case SocialMediaPlatform.dribbble: return Icons.palette_outlined;
      case SocialMediaPlatform.website: return Icons.language_outlined;
      default: return Icons.link_outlined;
    }
  }

  Color get color {
    switch (this) {
      case SocialMediaPlatform.linkedIn: return Color(0xFF0077B5);
      case SocialMediaPlatform.github: return Color(0xFF333333);
      case SocialMediaPlatform.medium: return Color(0xFF00AB6C);
      case SocialMediaPlatform.youtube: return Color(0xFFFF0000);
      case SocialMediaPlatform.instagram: return Color(0xFFE4405F);
      case SocialMediaPlatform.facebook: return Color(0xFF1877F2);
      case SocialMediaPlatform.x: return Color(0xFF000000);
      default: return Color(0xFF2196F3);
    }
  }
}
