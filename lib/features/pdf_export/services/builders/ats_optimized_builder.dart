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
import 'package:career_flow/core/models/cv/skill.dart';
import 'package:career_flow/core/models/cv/interest.dart';
import 'package:career_flow/features/cv_builder/domain/models/language.dart';
import 'package:career_flow/features/auth/domain/models/user_profile.dart';
import '../pdf_generator_service.dart';

class AtsOptimizedBuilder {
  final UserProfile profile;
  final List<Education> education;
  final List<Experience> experience;
  final List<Project> projects;
  final List<SocialMediaAccount> socialMedia;
  final List<Community> communities;
  final List<Course> courses;
  final List<Skill> skills;
  final List<Language> languages;
  final List<Interest> interests;
  final ByteBuffer fontData;
  final CvLanguage language;

  AtsOptimizedBuilder({
    required this.profile,
    required this.education,
    required this.experience,
    required this.projects,
    required this.socialMedia,
    required this.communities,
    required this.courses,
    required this.skills,
    required this.languages,
    required this.interests,
    required this.fontData,
    required this.language,
  });

  String _label(String key) {
    final tr = {
      'summary': 'PROFİL',
      'experience': 'İŞ DENEYİMİ',
      'projects': 'PROJELER',
      'communities': 'TOPLULUKLAR VE GÖNÜLLÜLÜK',
      'skills_info': 'YETENEKLER VE EK BİLGİLER',
      'courses': 'SERTİFİKALAR VE KURSLAR',
      'education': 'EĞİTİM',
      'tech_skills': 'Teknik Yetenekler',
      'soft_skills': 'Kişisel Beceriler',
      'languages': 'Diller',
      'interests': 'İlgi Alanları',
      'technologies': 'Teknolojiler',
      'present': 'Devam Ediyor',
      'see_more': 'Daha fazla proje için portfolyomu ziyaret edin:',
    };
    final en = {
      'summary': 'PROFILE',
      'experience': 'WORK EXPERIENCE',
      'projects': 'PROJECTS',
      'communities': 'COMMUNITIES & VOLUNTEERING',
      'skills_info': 'SKILLS & ADDITIONAL INFO',
      'courses': 'CERTIFICATIONS & COURSES',
      'education': 'EDUCATION',
      'tech_skills': 'Technical Skills',
      'soft_skills': 'Soft Skills',
      'languages': 'Languages',
      'interests': 'Interests',
      'technologies': 'Technologies',
      'present': 'Present',
      'see_more': 'Visit my portfolio for more projects:',
    };
    return (language == CvLanguage.tr ? tr[key] : en[key]) ?? key;
  }

  Future<Uint8List> build() async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MM/yyyy');
    
    // Load Unicode font to support Turkish characters
    final ttf = pw.Font.ttf(fontData.asByteData());

    final displayProjects = projects.any((p) => p.isHighlighted) 
        ? projects.where((p) => p.isHighlighted).toList() 
        : projects.take(4).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 20, 40, 40),
        theme: pw.ThemeData.withFont(base: ttf, bold: ttf, italic: ttf),
        header: (context) => context.pageNumber == 1 ? _buildHeader() : pw.SizedBox.shrink(),
        build: (context) => [
          // Professional Summary
          if (profile.aboutMe != null && profile.aboutMe!.isNotEmpty)
            pw.Wrap(
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(_label('summary')),
                    pw.Paragraph(
                      text: profile.aboutMe!,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.SizedBox(height: 10),
                  ],
                ),
              ],
            ),

          // Work Experience
          if (experience.isNotEmpty)
            pw.Wrap(
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(_label('experience')),
                    ...experience.map((exp) => _buildExperienceItem(exp, dateFormat)),
                    pw.SizedBox(height: 10),
                  ],
                ),
              ],
            ),

          // Projects
          if (displayProjects.isNotEmpty)
            pw.Wrap(
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(_label('projects')),
                    ...displayProjects.map((proj) => _buildProjectItem(proj, dateFormat)),
                    // "See More" Link
                    if (projects.length > displayProjects.length)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 2, bottom: 8),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Text(
                              '${_label('see_more')} ',
                              style: const pw.TextStyle(fontSize: 9, color: PdfColors.black),
                            ),
                            pw.UrlLink(
                              destination: profile.portfolioUrl != null && profile.portfolioUrl!.isNotEmpty
                                  ? profile.portfolioUrl!
                                  : (socialMedia.any((s) => s.platform.name == 'github')
                                      ? socialMedia.firstWhere((s) => s.platform.name == 'github').url
                                      : ''),
                              child: pw.Text(
                                profile.portfolioUrl != null && profile.portfolioUrl!.isNotEmpty
                                    ? profile.portfolioUrl!
                                    : (socialMedia.any((s) => s.platform.name == 'github')
                                        ? socialMedia.firstWhere((s) => s.platform.name == 'github').url
                                        : ''),
                                style: const pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    pw.SizedBox(height: 10),
                  ],
                ),
              ],
            ),

          // Communities & Volunteering
          if (communities.isNotEmpty)
            pw.Wrap(
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(_label('communities')),
                    ...communities.map((comm) => _buildCommunityItem(comm, dateFormat)),
                    pw.SizedBox(height: 15),
                  ],
                ),
              ],
            ),

          // Certifications & Courses
          if (courses.isNotEmpty)
            pw.Wrap(
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(_label('courses')),
                    ...courses.map((course) => _buildCourseItem(course)),
                    pw.SizedBox(height: 10),
                  ],
                ),
              ],
            ),

          // Education
          if (education.isNotEmpty)
            pw.Wrap(
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(_label('education')),
                    ...education.map((edu) => _buildEducationItem(edu, dateFormat)),
                    pw.SizedBox(height: 10),
                  ],
                ),
              ],
            ),

          // Skills, Languages & Interests
          if (skills.isNotEmpty || languages.isNotEmpty || interests.isNotEmpty)
            pw.Wrap(
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(_label('skills_info')),
                    if (skills.isNotEmpty) _buildSkillsWrap(skills),
                    if (languages.isNotEmpty) _buildLanguagesWrap(languages),
                    if (interests.isNotEmpty) _buildInterestsWrap(interests),
                    pw.SizedBox(height: 10),
                  ],
                ),
              ],
            ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader() {
    final name = (profile.firstName != null || profile.lastName != null) 
        ? '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.toUpperCase()
        : 'AD SOYAD GİRİNİZ';
        
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.fromLTRB(0, 10, 0, 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            name,
            style: pw.TextStyle(
              fontSize: 24, 
              fontWeight: pw.FontWeight.bold, 
              color: PdfColors.black, // Changed name to black
            ),
          ),
          if (profile.jobTitle != null && profile.jobTitle!.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              profile.jobTitle!.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black, // Color of job title to black
              ),
            ),
          ],
          pw.SizedBox(height: 10),
          pw.Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: pw.WrapAlignment.center,
            crossAxisAlignment: pw.WrapCrossAlignment.center,
            children: [
              if (profile.city != null)
                pw.Text('${profile.district ?? ''}, ${profile.city}', 
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.black)),
                  
              if (profile.city != null && ((profile.phone != null && profile.phone!.isNotEmpty) || (profile.email != null && profile.email!.isNotEmpty)))
                pw.Text('|', style: const pw.TextStyle(fontSize: 10, color: PdfColors.black)),

              if (profile.phone != null && profile.phone!.isNotEmpty)
                pw.UrlLink(
                  destination: 'tel:${profile.phone}',
                  child: pw.Text(profile.phone!, 
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.black)),
                ),

              if (profile.phone != null && profile.phone!.isNotEmpty && profile.email != null && profile.email!.isNotEmpty)
                pw.Text('|', style: const pw.TextStyle(fontSize: 10, color: PdfColors.black)),

              if (profile.email != null && profile.email!.isNotEmpty)
                pw.UrlLink(
                  destination: 'mailto:${profile.email}',
                  child: pw.Text(profile.email!, 
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.black)),
                ),
            ],
          ),
          if (socialMedia.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Wrap(
              spacing: 15,
              runSpacing: 5,
              alignment: pw.WrapAlignment.center,
              children: () {
                final seenHandles = <String>{};
                final uniqueMedia = <SocialMediaAccount>[];
                for (final s in socialMedia) {
                  final handle = _extractHandle(s.url);
                  final key = '${s.platform.name}_$handle';
                  if (!seenHandles.contains(key)) {
                    seenHandles.add(key);
                    uniqueMedia.add(s);
                  }
                }
                
                return uniqueMedia.map((s) {
                  final handle = _extractHandle(s.url);
                  return pw.UrlLink(
                    destination: s.url,
                    child: pw.Text(
                      '${s.platform.displayName}: $handle',
                      style: const pw.TextStyle(
                        fontSize: 9, 
                        color: PdfColors.black,
                      ),
                    ),
                  );
                }).toList();
              }(),
            ),
          ],
        ],
      ),
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
      final parts = url.split('/');
      return parts.lastWhere((p) => p.isNotEmpty, orElse: () => url);
    }
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.only(bottom: 2),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey700, width: 0.5),
            ),
          ),
          child: pw.Text(
            title,
            style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
          ),
        ),
        pw.SizedBox(height: 4),
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
            pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.grey600)),
            pw.Text(date, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          ],
        ),
        pw.Text(subtitle, style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10, color: PdfColors.grey600)),
      ],
    );
  }

  pw.Widget _buildExperienceItem(Experience exp, DateFormat df) {
    final startStr = exp.startDate != null ? df.format(exp.startDate!) : '';
    final endStr = exp.endDate != null ? df.format(exp.endDate!) : _label('present');
    
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(text: exp.company, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.5)),
                    if (exp.role != null && exp.role!.isNotEmpty)
                      pw.TextSpan(text: ' - ${exp.role!}', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10.5)),
                  ],
                ),
              ),
              pw.Text('$startStr - $endStr', style: const pw.TextStyle(fontSize: 9.5)),
            ],
          ),
          if (exp.description != null && exp.description!.trim().isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 5),
              child: pw.Text(
                exp.description!.trim(),
                style: const pw.TextStyle(fontSize: 9.5),
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildProjectItem(Project proj, DateFormat df) {
    final startStr = proj.startDate != null ? df.format(proj.startDate!) : '';
    final endStr = proj.endDate != null ? df.format(proj.endDate!) : (proj.startDate != null ? _label('present') : '');
    final dateStr = (startStr.isNotEmpty || endStr.isNotEmpty) ? '$startStr - $endStr' : '';

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(text: proj.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.5)),
                    if (proj.role != null && proj.role!.isNotEmpty)
                      pw.TextSpan(text: ' - ${proj.role!}', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10.5)),
                    if (proj.repoUrl != null) 
                      pw.TextSpan(text: '  |  ${_extractHandle(proj.repoUrl!)}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.blue900)),
                  ],
                ),
              ),
              if (dateStr.isNotEmpty)
                pw.Text(dateStr, style: const pw.TextStyle(fontSize: 9.5)),
            ],
          ),
          if (proj.description != null && proj.description!.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 3),
              child: pw.Text(proj.description!, style: const pw.TextStyle(fontSize: 9.5)),
            ),
          if (proj.technologies != null && proj.technologies!.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 3),
              child: pw.Text('${_label('technologies')}: ${proj.technologies!}', style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildCommunityItem(Community comm, DateFormat df) {
    final startStr = comm.startDate != null ? df.format(comm.startDate!) : '';
    final endStr = comm.endDate != null ? df.format(comm.endDate!) : _label('present');

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(text: comm.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.5)),
                    if (comm.role != null && comm.role!.isNotEmpty)
                      pw.TextSpan(text: ' - ${comm.role!}', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10.5)),
                  ],
                ),
              ),
              pw.Text('$startStr - $endStr', style: const pw.TextStyle(fontSize: 9.5)),
            ],
          ),
          if (comm.description != null && comm.description!.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 3),
              child: pw.Text(comm.description!, style: const pw.TextStyle(fontSize: 9.5)),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildCourseItem(Course course) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(course.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          if (course.issuer != null)
            pw.Text(course.issuer!, style: const pw.TextStyle(fontSize: 9.5, fontStyle: pw.FontStyle.italic)),
        ],
      ),
    );
  }

  pw.Widget _buildEducationItem(Education edu, DateFormat df) {
    final startStr = edu.startDate != null ? df.format(edu.startDate!) : '';
    final endStr = edu.endDate != null ? df.format(edu.endDate!) : _label('present');

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(edu.school, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.5)),
              if (edu.degree != null)
                pw.Text(edu.degree!, style: const pw.TextStyle(fontSize: 9.5, fontStyle: pw.FontStyle.italic)),
            ],
          ),
          pw.Text('$startStr - $endStr', style: const pw.TextStyle(fontSize: 9.5)),
        ],
      ),
    );
  }

  pw.Widget _buildSkillsWrap(List<Skill> skills) {
    final techSkills = skills.where((s) => s.category != 'Soft Skills').map((s) => s.name).join(' • ');
    final softSkills = skills.where((s) => s.category == 'Soft Skills').map((s) => s.name).join(' • ');
    
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (techSkills.isNotEmpty) 
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(text: '${_label('tech_skills')}: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
                    pw.TextSpan(text: techSkills, style: const pw.TextStyle(fontSize: 9.5)),
                  ]
                )
              ),
            ),
          if (softSkills.isNotEmpty) 
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
              child: pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(text: '${_label('soft_skills')}: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
                    pw.TextSpan(text: softSkills, style: const pw.TextStyle(fontSize: 9.5)),
                  ]
                )
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildLanguagesWrap(List<Language> languages) {
    final langStr = languages.map((l) {
      final translatedName = _translateLanguage(l.name);
      final translatedProf = l.proficiency != null ? _translateProficiency(l.proficiency!) : null;
      return (translatedProf != null && translatedProf.isNotEmpty) 
          ? '$translatedName ($translatedProf)' 
          : translatedName;
    }).join(' • ');

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(text: '${_label('languages')}: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
            pw.TextSpan(text: langStr, style: const pw.TextStyle(fontSize: 9.5)),
          ]
        )
      ),
    );
  }

  String _translateLanguage(String name) {
    if (language == CvLanguage.tr) return name;
    final cleanName = name.trim();
    final map = {
      'İngilizce': 'English',
      'Almanca': 'German',
      'Fransızca': 'French',
      'İspanyolca': 'Spanish',
      'Türkçe': 'Turkish',
      'Rusça': 'Russian',
      'Arapça': 'Arabic',
      'İtalyanca': 'Italian',
      'Çince': 'Chinese',
      'Japonca': 'Japanese',
    };
    return map[cleanName] ?? cleanName;
  }

  String _translateProficiency(String prof) {
    if (language == CvLanguage.tr) return prof;

    // Extract CEFR code (A1, B2, etc.) if format is "B2 - Description"
    if (prof.contains(' - ')) {
      final parts = prof.split(' - ');
      final code = parts[0].trim();
      if (RegExp(r'^[A-C][1-2]$').hasMatch(code)) {
        return code;
      }
    }

    String result = prof;
    final translations = {
      'Başlangıç': 'Beginner',
      'Temel': 'Elementary',
      'Orta': 'Intermediate',
      'İyi Orta': 'Upper Intermediate',
      'İleri': 'Advanced',
      'Uzman': 'Expert',
      'Ana Dil': 'Native',
    };

    translations.forEach((tr, en) {
      result = result.replaceAll(tr, en);
    });

    return result;
  }

  pw.Widget _buildInterestsWrap(List<Interest> interests) {
    final intStr = interests.map((i) => i.name).join(' • ');
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(text: '${_label('interests')}: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
            pw.TextSpan(text: intStr, style: const pw.TextStyle(fontSize: 9.5)),
          ]
        )
      ),
    );
  }
}

