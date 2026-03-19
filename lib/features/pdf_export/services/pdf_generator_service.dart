import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:career_flow/features/auth/presentation/providers/auth_provider.dart';
import 'package:career_flow/features/cv_builder/presentation/providers/education_provider.dart';
import 'package:career_flow/features/cv_builder/presentation/providers/experience_provider.dart';
import 'package:career_flow/features/cv_builder/presentation/providers/project_provider.dart';
import 'package:career_flow/features/cv_builder/presentation/providers/social_media_provider.dart';
import 'package:career_flow/features/pdf_export/services/builders/ats_optimized_builder.dart';

enum CvTemplate {
  modernTech,
  professional,
  creativeGrid,
  minimalist,
  atsOptimized,
}

final pdfGeneratorServiceProvider = Provider((ref) => PdfGeneratorService(ref));

class PdfGeneratorService {
  final Ref _ref;

  PdfGeneratorService(this._ref);

  Future<Uint8List> generateCv(CvTemplate template) async {
    final profileAwait = await _ref.read(currentUserProfileProvider.future);
    final education = _ref.read(educationListProvider).value ?? [];
    final experience = _ref.read(experienceListProvider).value ?? [];
    final projects = _ref.read(projectListProvider).value ?? [];
    final socialMedia = _ref.read(socialMediaListProvider).value ?? [];

    if (profileAwait == null) throw Exception('Profil bulunamadı. Lütfen giriş yapın.');

    switch (template) {
      case CvTemplate.atsOptimized:
        final builder = AtsOptimizedBuilder(
          profile: profileAwait,
          education: education,
          experience: experience,
          projects: projects,
          socialMedia: socialMedia,
        );
        return builder.build();
      default:
        // Default to ATS Optimized for now
        final builder = AtsOptimizedBuilder(
          profile: profileAwait,
          education: education,
          experience: experience,
          projects: projects,
          socialMedia: socialMedia,
        );
        return builder.build();
    }
  }
}
