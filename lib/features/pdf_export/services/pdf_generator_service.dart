import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:career_flow/features/auth/presentation/providers/auth_provider.dart';
import 'package:career_flow/features/cv_builder/presentation/providers/education_provider.dart';
import 'package:career_flow/features/cv_builder/presentation/providers/experience_provider.dart';
import 'package:career_flow/features/cv_builder/presentation/providers/project_provider.dart';
import 'package:career_flow/features/cv_builder/presentation/providers/social_media_provider.dart';
import 'package:career_flow/features/cv_builder/presentation/providers/community_provider.dart';
import 'package:career_flow/features/cv_builder/presentation/providers/course_provider.dart';
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
    final education = await _ref.read(educationListProvider.future);
    final experience = await _ref.read(experienceListProvider.future);
    final projects = await _ref.read(projectListProvider.future);
    final socialMedia = await _ref.read(socialMediaListProvider.future);
    final communities = await _ref.read(communityListProvider.future);
    final courses = await _ref.read(courseListProvider.future);

    if (profileAwait == null) throw Exception('Profil bulunamadı. Lütfen giriş yapın.');

    // Load font for Turkish characters
    final fontData = await rootBundle.load('assets/fonts/arial.ttf');

    switch (template) {
      case CvTemplate.atsOptimized:
        final builder = AtsOptimizedBuilder(
          profile: profileAwait,
          education: education,
          experience: experience,
          projects: projects,
          socialMedia: socialMedia,
          communities: communities,
          courses: courses,
          fontData: fontData.buffer,
        );
        return builder.build();
      default:
        final pdf = pw.Document();
        final ttf = pw.Font.ttf(fontData);
        pdf.addPage(
          pw.Page(
            theme: pw.ThemeData.withFont(base: ttf, bold: ttf, italic: ttf),
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Text(
                  'Bu CV tasarımı daha sonra eklenecektir.',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              );
            },
          ),
        );
        return pdf.save();
    }
  }
}
