import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/autonomous_analysis_service.dart';
import '../providers/github_provider.dart';
import '../../../../core/models/github/github_repo.dart';
import '../../../../core/models/github/analyzed_project.dart';

part 'analysis_provider.g.dart';

@riverpod
AutonomousAnalysisService autonomousAnalysisService(AutonomousAnalysisServiceRef ref) {
  final github = ref.watch(githubServiceProvider);
  return AutonomousAnalysisService(github);
}

@riverpod
class AnalysisNotifier extends _$AnalysisNotifier {
  @override
  FutureOr<List<AnalyzedProject>> build() => [];

  Future<void> analyzeRepositories(List<GithubRepo> repos) async {
    state = const AsyncValue.loading();
    
    try {
      final analysisService = ref.read(autonomousAnalysisServiceProvider);
      final List<AnalyzedProject> results = [];
      
      for (final repo in repos) {
        final result = await analysisService.analyzeRepository(repo);
        results.add(result);
      }
      
      state = AsyncValue.data(results);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void updateProject(int index, AnalyzedProject updated) {
    state.whenData((projects) {
      final newList = List<AnalyzedProject>.from(projects);
      newList[index] = updated;
      state = AsyncValue.data(newList);
    });
  }

  void removeProject(int index) {
    state.whenData((projects) {
      final newList = List<AnalyzedProject>.from(projects);
      newList.removeAt(index);
      state = AsyncValue.data(newList);
    });
  }
}
