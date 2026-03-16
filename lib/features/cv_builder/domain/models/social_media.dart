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

  const SocialMediaAccount._();

  factory SocialMediaAccount.fromJson(Map<String, dynamic> json) =>
      _$SocialMediaAccountFromJson(json);

  String get username {
    if (url.isEmpty) return '';
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments.where((s) => s.isNotEmpty).toList();

      switch (platform) {
        case SocialMediaPlatform.linkedIn:
          if (pathSegments.isEmpty) return url;
          // https://www.linkedin.com/in/username/
          if (pathSegments.length >= 2 && pathSegments[0] == 'in') {
            return pathSegments[1];
          }
          return pathSegments.last;
        case SocialMediaPlatform.github:
        case SocialMediaPlatform.instagram:
        case SocialMediaPlatform.medium:
        case SocialMediaPlatform.x:
        case SocialMediaPlatform.behance:
        case SocialMediaPlatform.dribbble:
        case SocialMediaPlatform.devto:
        case SocialMediaPlatform.hashnode:
          if (pathSegments.isEmpty) return url;
          // https://platform.com/username
          return pathSegments.first;
        case SocialMediaPlatform.facebook:
          if (pathSegments.isEmpty) return url;
          // https://facebook.com/username or https://facebook.com/profile.php?id=...
          if (pathSegments.first == 'profile.php') {
            return uri.queryParameters['id'] ?? pathSegments.first;
          }
          return pathSegments.first;
        case SocialMediaPlatform.youtube:
          if (pathSegments.isEmpty) return url;
          // https://youtube.com/@username
          if (pathSegments.first.startsWith('@')) {
            return pathSegments.first.substring(1);
          }
          return pathSegments.first;
        case SocialMediaPlatform.website:
          // https://toygucakin.com -> toygucakin.com
          // kariyer.net -> kariyer.net
          String host = uri.host.toLowerCase();
          if (host.isEmpty) {
            // Eğer tam URL parse edilemediyse (örn: protocol yoksa) temizleyip döndür
            host = url.replaceAll(RegExp(r'https?://'), '').replaceAll('www.', '');
            if (host.endsWith('/')) host = host.substring(0, host.length - 1);
          } else {
            if (host.startsWith('www.')) host = host.substring(4);
          }
          return host.isNotEmpty ? host : url;
        default:
          if (pathSegments.isEmpty) return url;
          return pathSegments.last;
      }
    } catch (e) {
      return url;
    }
  }
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
