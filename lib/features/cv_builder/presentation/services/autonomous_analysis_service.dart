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

    // 3. Extract Description from README (First block of text)
    String description = repo.description ?? '';
    if (readme != null) {
      // Remove H1 and find first meaningful paragraph
      final cleanReadme = readme.replaceAll(RegExp(r'^#\s+.+$', multiLine: true), '').trim();
      final paragraphs = cleanReadme.split(RegExp(r'\n\s*\n'));
      if (paragraphs.isNotEmpty) {
        final firstPara = paragraphs.first.trim();
        if (firstPara.length > 20) {
          description = firstPara.replaceAll(RegExp(r'\[!\[.*\]\(.*\)\]\(.*\)'), '').trim(); // Remove badges
          if (description.length > 300) {
            description = '${description.substring(0, 297)}...';
          }
        }
      }
    }

    // 4. Technology Detection
    final technologies = <String>{};
    
    // Add top languages
    final sortedLangs = languagesMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (var lang in sortedLangs.take(3)) {
      technologies.add(lang.key);
    }

    // Simple keyword matching in README for more techs
    if (readme != null) {
      final keywords = {
        'Docker': ['docker'],
        'Firebase': ['firebase'],
        'Supabase': ['supabase'],
        'PostgreSQL': ['postgresql', 'postgres'],
        'MongoDB': ['mongodb', 'mongo'],
        'AWS': ['aws', 'amazon web services'],
        'React': ['react'],
        'Next.js': ['next.js', 'nextjs'],
        'Node.js': ['node.js', 'nodejs'],
        'Bloc': ['bloc'],
        'Riverpod': ['riverpod'],
        'Provider': ['provider'],
        'Redux': ['redux'],
      };

      final readmeLower = readme.toLowerCase();
      keywords.forEach((tech, triggers) {
        for (var trigger in triggers) {
          if (readmeLower.contains(trigger)) {
            technologies.add(tech);
            break;
          }
        }
      });
    }

    return AnalyzedProject(
      repoFullName: fullName,
      title: title,
      description: description,
      technologies: technologies.toList(),
      startDate: repo.createdAt,
      endDate: repo.updatedAt,
    );
  }
}
