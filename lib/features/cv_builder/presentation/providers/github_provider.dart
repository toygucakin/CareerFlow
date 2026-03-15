import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/github_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/models/github/github_repo.dart';

part 'github_provider.g.dart';

@riverpod
GithubService githubService(GithubServiceRef ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final token = authRepo.providerToken;
  return GithubService(token);
}

@riverpod
Future<List<GithubRepo>> githubRepos(GithubReposRef ref) async {
  final service = ref.watch(githubServiceProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  
  if (authRepo.currentUser == null || authRepo.providerToken == null) {
    return [];
  }

  return service.fetchUserRepos();
}
