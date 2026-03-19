import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:career_flow/features/cv_builder/domain/models/education.dart';
import 'package:career_flow/features/cv_builder/domain/models/experience.dart';
import 'package:career_flow/features/cv_builder/domain/models/project.dart';
import 'package:career_flow/features/cv_builder/domain/models/social_media.dart';
import 'package:career_flow/features/auth/domain/models/user_profile.dart';

class AtsOptimizedBuilder {
  final UserProfile profile;
  final List<Education> education;
  final List<Experience> experience;
  final List<Project> projects;
  final List<SocialMediaAccount> socialMedia;

  AtsOptimizedBuilder({
    required this.profile,
    required this.education,
    required this.experience,
    required this.projects,
    required this.socialMedia,
  });

  Future<Uint8List> build() async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MM/yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader(),
          pw.SizedBox(height: 20),
          
          // Professional Summary
          _buildSectionTitle('PROFESSIONAL SUMMARY'),
          if (profile.aboutMe != null && profile.aboutMe!.isNotEmpty)
            pw.Paragraph(
              text: profile.aboutMe!,
              style: const pw.TextStyle(fontSize: 10),
            )
          else
            _buildPlaceholderText('Kısa bir profesyonel özet ekleyin...'),
          pw.SizedBox(height: 15),

          // Work Experience
          _buildSectionTitle('WORK EXPERIENCE'),
          if (experience.isNotEmpty)
            ...experience.map((exp) => _buildExperienceItem(exp, dateFormat))
          else
            _buildPlaceholderItem('Şirket Adı', 'Pozisyon', 'Başlangıç - Bitiş'),
          pw.SizedBox(height: 15),

          // Projects
          _buildSectionTitle('PROJECTS'),
          if (projects.isNotEmpty)
            ...projects.map((proj) => _buildProjectItem(proj, dateFormat))
          else
            _buildPlaceholderItem('Proje Adı', 'Proje Açıklaması', 'Repo Linki'),
          pw.SizedBox(height: 15),

          // Education
          _buildSectionTitle('EDUCATION'),
          if (education.isNotEmpty)
            ...education.map((edu) => _buildEducationItem(edu, dateFormat))
          else
            _buildPlaceholderItem('Okul Adı', 'Bölüm / Derece', 'Mezuniyet Tarihi'),
          pw.SizedBox(height: 15),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader() {
    final name = (profile.firstName != null || profile.lastName != null) 
        ? '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.toUpperCase()
        : 'AD SOYAD GİRİNİZ';
        
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          name,
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          [
            profile.city != null ? '${profile.district ?? ''}, ${profile.city}' : 'Konum Bilgisi',
            profile.phone.isNotEmpty ? profile.phone : 'Telefon No',
            profile.email.isNotEmpty ? profile.email : 'E-posta Adresi',
          ].join(' | '),
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 5),
        if (socialMedia.isNotEmpty)
          pw.Text(
            socialMedia.map((s) => '${s.platform.displayName}: ${s.url}').join(' | '),
            style: const pw.TextStyle(fontSize: 9),
          )
        else
          pw.Text(
            'LinkedIn | GitHub | Portfolio Linklerini Ekleyin',
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey),
          ),
      ],
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
        ),
        pw.Divider(thickness: 0.8, color: PdfColors.black),
        pw.SizedBox(height: 8),
      ],
    );
  }

  pw.Widget _buildPlaceholderText(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey, fontStyle: pw.FontStyle.italic),
    );
  }

  pw.Widget _buildPlaceholderItem(String title, String subtitle, String date) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.grey400)),
            pw.Text(date, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey400)),
          ],
        ),
        pw.Text(subtitle, style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10, color: PdfColors.grey400)),
        pw.SizedBox(height: 4),
        pw.Container(height: 6, width: double.infinity, color: PdfColors.grey100),
      ],
    );
  }

  pw.Widget _buildExperienceItem(Experience exp, DateFormat df) {
    final startStr = exp.startDate != null ? df.format(exp.startDate!) : '';
    final endStr = exp.endDate != null ? df.format(exp.endDate!) : 'Present';
    
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(exp.company, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
              pw.Text('$startStr - $endStr', style: const pw.TextStyle(fontSize: 9)),
            ],
          ),
          if (exp.role != null)
            pw.Text(exp.role!, style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10)),
          if (exp.description != null && exp.description!.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4, left: 10),
              child: pw.Text(
                exp.description!,
                style: const pw.TextStyle(fontSize: 9, lineHeight: 1.2),
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildProjectItem(Project proj, DateFormat df) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(proj.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
              if (proj.repoUrl != null) pw.Text(proj.repoUrl!, style: const pw.TextStyle(fontSize: 8, color: PdfColors.blue)),
            ],
          ),
          if (proj.description != null && proj.description!.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2),
              child: pw.Text(proj.description!, style: const pw.TextStyle(fontSize: 9)),
            ),
          if (proj.aiSummary != null && proj.aiSummary!.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4, left: 10),
              child: pw.Text(
                '• ${proj.aiSummary!}',
                style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildEducationItem(Education edu, DateFormat df) {
    final startStr = edu.startDate != null ? df.format(edu.startDate!) : '';
    final endStr = edu.endDate != null ? df.format(edu.endDate!) : 'Present';

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(edu.school, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
              if (edu.degree != null)
                pw.Text(edu.degree!, style: const pw.TextStyle(fontSize: 9)),
            ],
          ),
          pw.Text('$startStr - $endStr', style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }
}
