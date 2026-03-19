import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:career_flow/features/cv_builder/domain/models/education.dart';
import 'package:career_flow/features/cv_builder/domain/models/experience.dart';
import 'package:career_flow/features/cv_builder/domain/models/project.dart';
import 'package:career_flow/features/cv_builder/domain/models/social_media.dart';
import 'package:career_flow/features/cv_builder/domain/models/community.dart';
import 'package:career_flow/features/cv_builder/domain/models/course.dart';
import 'package:career_flow/features/auth/domain/models/user_profile.dart';

class AtsOptimizedBuilder {
  final UserProfile profile;
  final List<Education> education;
  final List<Experience> experience;
  final List<Project> projects;
  final List<SocialMediaAccount> socialMedia;
  final List<Community> communities;
  final List<Course> courses;
  final ByteBuffer fontData;

  AtsOptimizedBuilder({
    required this.profile,
    required this.education,
    required this.experience,
    required this.projects,
    required this.socialMedia,
    required this.communities,
    required this.courses,
    required this.fontData,
  });

  Future<Uint8List> build() async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MM/yyyy');
    
    // Load Unicode font to support Turkish characters
    final ttf = pw.Font.ttf(fontData.asByteData());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(base: ttf, bold: ttf, italic: ttf),
        build: (context) => [
          _buildHeader(),
          pw.SizedBox(height: 15),
          
          // Professional Summary
          _buildSectionTitle('PROFESSIONAL SUMMARY'),
          if (profile.aboutMe != null && profile.aboutMe!.isNotEmpty)
            pw.Paragraph(
              text: profile.aboutMe!,
              style: const pw.TextStyle(fontSize: 9.5),
            ),
          pw.SizedBox(height: 12),

          // Work Experience
          _buildSectionTitle('WORK EXPERIENCE'),
          if (experience.isNotEmpty)
            ...experience.map((exp) => _buildExperienceItem(exp, dateFormat))
          else
            _buildPlaceholderItem('Şirket Adı', 'Pozisyon', 'Başlangıç - Bitiş'),
          pw.SizedBox(height: 12),

          // Projects
          _buildSectionTitle('PROJECTS'),
          if (projects.isNotEmpty)
            ...projects.map((proj) => _buildProjectItem(proj, dateFormat))
          else
            _buildPlaceholderItem('Proje Adı', 'Proje Açıklaması', 'Repo Linki'),
          pw.SizedBox(height: 12),

          // Communities & Volunteering
          if (communities.isNotEmpty) ...[
            _buildSectionTitle('COMMUNITIES & VOLUNTEERING'),
            ...communities.map((comm) => _buildCommunityItem(comm, dateFormat)),
            pw.SizedBox(height: 12),
          ],

          // Certifications & Courses
          if (courses.isNotEmpty) ...[
            _buildSectionTitle('CERTIFICATIONS & COURSES'),
            ...courses.map((course) => _buildCourseItem(course)),
            pw.SizedBox(height: 12),
          ],

          // Education
          _buildSectionTitle('EDUCATION'),
          if (education.isNotEmpty)
            ...education.map((edu) => _buildEducationItem(edu, dateFormat))
          else
            _buildPlaceholderItem('Okul Adı', 'Bölüm / Derece', 'Mezuniyet Tarihi'),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader() {
    final name = (profile.firstName != null || profile.lastName != null) 
        ? '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.toUpperCase()
        : 'AD SOYAD';
        
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          name,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          [
            profile.city != null ? '${profile.district ?? ''}, ${profile.city}' : null,
            (profile.phone != null && profile.phone!.isNotEmpty) ? profile.phone! : null,
            (profile.email != null && profile.email!.isNotEmpty) ? profile.email! : null,
          ].whereType<String>().join(' | '),
          style: const pw.TextStyle(fontSize: 9),
        ),
        if (socialMedia.isNotEmpty) ...[
          pw.SizedBox(height: 3),
          pw.Text(
            socialMedia.map((s) {
              final handle = _extractHandle(s.url);
              return '${s.platform.displayName}: $handle';
            }).join(' | '),
            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.blue800),
          ),
        ],
      ],
    );
  }

  String _extractHandle(String url) {
    if (url.isEmpty) return '';
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (pathSegments.isEmpty) return url;
      return pathSegments.last;
    } catch (_) {
      // If parsing fails, try manual splitting as fallback
      final parts = url.split('/');
      return parts.lastWhere((p) => p.isNotEmpty, defaultValue: () => url);
    }
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
        ),
        pw.Divider(thickness: 0.5, color: PdfColors.black),
        pw.SizedBox(height: 6),
      ],
    );
  }

  pw.Widget _buildPlaceholderItem(String title, String subtitle, String date) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.grey500)),
            pw.Text(date, style: pw.TextStyle(fontSize: 8.5, color: PdfColors.grey500)),
          ],
        ),
        pw.Text(subtitle, style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 9, color: PdfColors.grey500)),
      ],
    );
  }

  pw.Widget _buildExperienceItem(Experience exp, DateFormat df) {
    final startStr = exp.startDate != null ? df.format(exp.startDate!) : '';
    final endStr = exp.endDate != null ? df.format(exp.endDate!) : 'Present';
    
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(exp.company, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
              pw.Text('$startStr - $endStr', style: const pw.TextStyle(fontSize: 8.5)),
            ],
          ),
          if (exp.role != null)
            pw.Text(exp.role!, style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 9)),
          if (exp.description != null && exp.description!.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 3, left: 10),
              child: pw.Text(
                exp.description!,
                style: const pw.TextStyle(fontSize: 8.5, lineHeight: 1.2),
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildProjectItem(Project proj, DateFormat df) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(proj.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
              if (proj.repoUrl != null) pw.Text(_extractHandle(proj.repoUrl!), style: const pw.TextStyle(fontSize: 8, color: PdfColors.blue700)),
            ],
          ),
          if (proj.description != null && proj.description!.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 1),
              child: pw.Text(proj.description!, style: const pw.TextStyle(fontSize: 8.5)),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildCommunityItem(Community comm, DateFormat df) {
    final startStr = comm.startDate != null ? df.format(comm.startDate!) : '';
    final endStr = comm.endDate != null ? df.format(comm.endDate!) : 'Present';

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(comm.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
              if (comm.role != null)
                pw.Text(comm.role!, style: const pw.TextStyle(fontSize: 8.5)),
            ],
          ),
          pw.Text('$startStr - $endStr', style: const pw.TextStyle(fontSize: 8.5)),
        ],
      ),
    );
  }

  pw.Widget _buildCourseItem(Course course) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(course.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
          if (course.issuer != null)
            pw.Text(course.issuer!, style: const pw.TextStyle(fontSize: 8.5, fontStyle: pw.FontStyle.italic)),
        ],
      ),
    );
  }

  pw.Widget _buildEducationItem(Education edu, DateFormat df) {
    final startStr = edu.startDate != null ? df.format(edu.startDate!) : '';
    final endStr = edu.endDate != null ? df.format(edu.endDate!) : 'Present';

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(edu.school, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
              if (edu.degree != null)
                pw.Text(edu.degree!, style: const pw.TextStyle(fontSize: 8.5)),
            ],
          ),
          pw.Text('$startStr - $endStr', style: const pw.TextStyle(fontSize: 8.5)),
        ],
      ),
    );
  }
}
