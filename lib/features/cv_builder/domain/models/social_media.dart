import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      case SocialMediaPlatform.linkedIn: return FontAwesomeIcons.linkedinIn;
      case SocialMediaPlatform.github: return FontAwesomeIcons.github;
      case SocialMediaPlatform.medium: return FontAwesomeIcons.medium;
      case SocialMediaPlatform.devto: return FontAwesomeIcons.dev;
      case SocialMediaPlatform.hashnode: return FontAwesomeIcons.hashnode;
      case SocialMediaPlatform.substack: return Icons.article_outlined;
      case SocialMediaPlatform.x: return FontAwesomeIcons.xTwitter;
      case SocialMediaPlatform.instagram: return FontAwesomeIcons.instagram;
      case SocialMediaPlatform.facebook: return FontAwesomeIcons.facebookF;
      case SocialMediaPlatform.youtube: return FontAwesomeIcons.youtube;
      case SocialMediaPlatform.behance: return FontAwesomeIcons.behance;
      case SocialMediaPlatform.dribbble: return FontAwesomeIcons.dribbble;
      case SocialMediaPlatform.website: return FontAwesomeIcons.globe;
      default: return FontAwesomeIcons.link;
    }
  }

  Color get color {
    switch (this) {
      case SocialMediaPlatform.linkedIn: return const Color(0xFF0077B5);
      case SocialMediaPlatform.github: return const Color(0xFF333333);
      case SocialMediaPlatform.medium: return const Color(0xFF00AB6C);
      case SocialMediaPlatform.youtube: return const Color(0xFFFF0000);
      case SocialMediaPlatform.instagram: return const Color(0xFFE4405F);
      case SocialMediaPlatform.facebook: return const Color(0xFF1877F2);
      case SocialMediaPlatform.x: return const Color(0xFF000000);
      case SocialMediaPlatform.behance: return const Color(0xFF1769FF);
      case SocialMediaPlatform.dribbble: return const Color(0xFFEA4C89);
      default: return const Color(0xFF2196F3);
    }
  }
}
