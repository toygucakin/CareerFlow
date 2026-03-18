import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/models/github/github_repo.dart';
import '../../../../core/models/github/analyzed_project.dart';
import '../../../../core/services/github_service.dart';

class AutonomousAnalysisService {
  final GithubService _githubService;

  AutonomousAnalysisService(this._githubService);

  Future<AnalyzedProject> analyzeRepository(GithubRepo repo) async {
    final fullName = repo.fullName;
    
    // 1. Fetch README and Languages in parallel
    final results = await Future.wait([
      _githubService.fetchRepoReadme(fullName),
      _githubService.fetchRepoLanguages(fullName),
    ].cast<Future<dynamic>>());

    final String? readme = results[0] as String?;
    final Map<String, int> languagesMap = results[1] as Map<String, int>;

    // 2. Extract Title from README (H1)
    String title = repo.name;
    if (readme != null) {
      final h1Match = RegExp(r'^#\s+(.+)$', multiLine: true).firstMatch(readme);
      if (h1Match != null) {
        title = h1Match.group(1)!.trim();
      }
    }

    // 3. Extract Description and Scope using AI (Gemini) or fallback
    String description = repo.description ?? '';
    String scope = '';
    
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
      );
      
      final truncatedReadme = (readme != null && readme.length > 5000) ? readme.substring(0, 5000) : (readme ?? 'README dosyası bulunamadı.');

      final prompt = '''
      Aşağıdaki GitHub README dosyasını ve proje detaylarını incele. 
      Bana bu proje için bir "Proje Kapsamı" (scope) ve "Proje Tanımı" (description) oluştur.
      
      Kurallar:
      1. SADECE geçerli bir JSON formatında yanıt ver, markdown işaretleri (```json vb.) KULLANMA.
      2. "scope" alanı projenin türünü belirtsin. (Örn: "Mobil Uygulama", "Web Platformu", "Masaüstü Aracı", "CLI Aracı", "Kütüphane" vb. en fazla 3 kelime)
      3. "description" alanı projenin ne işe yaradığını, problemini ve çözümünü anlatsın. Eğer bilgi yetersizse sadece eldeki verilerle (proje adı/açıklaması) mantıklı bir özet çıkar. (Profesyonel, akıcı ve maksimum 3-4 cümlelik Türkçe bir özet)

      Örnek Çıktı Formatı:
      {
        "scope": "Kariyer Yönetimi Mobil Uygulaması",
        "description": "Yazılım geliştiriciler için özel olarak tasarlanmış olan bu platform..."
      }

      Proje Orijinal Adı: ${repo.name}
      Proje Orijinal Açıklaması: ${repo.description ?? 'Yok'}
      
      README:
      $truncatedReadme
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      if (response.text != null && response.text!.isNotEmpty) {
        String responseText = response.text!.trim();
        if (responseText.startsWith('```json')) {
          responseText = responseText.replaceFirst('```json', '');
          if (responseText.endsWith('```')) {
            responseText = responseText.substring(0, responseText.length - 3);
          }
        } else if (responseText.startsWith('```')) {
          responseText = responseText.replaceFirst('```', '');
          if (responseText.endsWith('```')) {
            responseText = responseText.substring(0, responseText.length - 3);
          }
        }
        
        final jsonMap = jsonDecode(responseText.trim());
        scope = jsonMap['scope']?.toString() ?? 'Yazılım Projesi';
        description = jsonMap['description']?.toString() ?? (repo.description ?? 'Açıklama bulunamadı.');
        description = description.replaceAll('**', '');
      }
    } catch (e) {
      print('Gemini API Error: $e');
      // AI Fallback
      scope = 'Yazılım Projesi';
      if (readme != null) {
        final cleanReadme = readme.replaceAll(RegExp(r'^#\s+.+$', multiLine: true), '').trim();
        final paragraphs = cleanReadme.split(RegExp(r'\n\s*\n'));
        if (paragraphs.isNotEmpty) {
          final firstPara = paragraphs.first.trim();
          if (firstPara.length > 20) {
            description = firstPara.replaceAll(RegExp(r'\[!\[.*\]\(.*\)\]\(.*\)'), '').trim();
            if (description.length > 300) {
              description = '${description.substring(0, 297)}...';
            }
          }
        }
      } else {
        description = repo.description ?? 'Açıklama bulunamadı.';
      }
    }

    // 4. Technology Detection - Top 4 Languages with Percentages
    final technologies = <String>{};
    
    // Calculate total bytes for percentage calculation
    final totalBytes = languagesMap.values.fold(0, (sum, val) => sum + val);

    final sortedLangs = languagesMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (var lang in sortedLangs.take(4)) {
      if (totalBytes > 0) {
        final percentage = ((lang.value / totalBytes) * 100).round();
        technologies.add('${lang.key} (%$percentage)');
      } else {
        technologies.add(lang.key);
      }
    }

    return AnalyzedProject(
      repoFullName: fullName,
      title: title,
      scope: scope,
      description: description,
      technologies: technologies.toList(),
      startDate: repo.createdAt,
      endDate: repo.updatedAt,
    );
  }
}
