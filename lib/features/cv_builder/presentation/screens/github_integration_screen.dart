import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/github_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class GitHubIntegrationScreen extends ConsumerStatefulWidget {
  const GitHubIntegrationScreen({super.key});

  @override
  ConsumerState<GitHubIntegrationScreen> createState() => _GitHubIntegrationScreenState();
}

class _GitHubIntegrationScreenState extends ConsumerState<GitHubIntegrationScreen> {
  final Set<String> _selectedRepos = {};

  @override
  Widget build(BuildContext context) {
    final reposAsync = ref.watch(githubReposProvider);
    final authRepo = ref.watch(authRepositoryProvider);
    final isConnected = authRepo.providerToken != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Entegrasyonu'),
        elevation: 0,
      ),
      body: !isConnected 
          ? _buildConnectPrompt()
          : reposAsync.when(
              data: (repos) => _buildRepoList(repos),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _buildErrorView(err.toString()),
            ),
      bottomNavigationBar: isConnected && _selectedRepos.isNotEmpty
          ? _buildBottomAction()
          : null,
    );
  }

  Widget _buildConnectPrompt() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          const Icon(Icons.code, size: 80, color: Colors.blue),
          const SizedBox(height: 24),
          const Text(
            'GitHub Hesabınızı Bağlayın',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Projelerinizi ve teknoloji yeteneklerinizi GitHub üzerinden otomatik olarak CV\'nize çekmek için hesabınızı bağlamanız gerekiyor.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _connectGitHub,
            icon: const Icon(Icons.login),
            label: const Text('GitHub ile Bağlan ve Yetki Ver'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildRepoList(repos) {
    if (repos.isEmpty) {
      return const Center(child: Text('Hiç repo bulunamadı.'));
    }

    return ListView.builder(
      itemCount: repos.length,
      itemBuilder: (context, index) {
        final repo = repos[index];
        final isSelected = _selectedRepos.contains(repo.fullName);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: CheckboxListTile(
            value: isSelected,
            activeColor: Colors.blue,
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    repo.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (repo.isPrivate)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.lock, size: 14, color: Colors.grey),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (repo.description != null)
                  Text(
                    repo.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (repo.language != null) ...[
                      const Icon(Icons.circle, size: 10, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(repo.language!, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 16),
                    ],
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${repo.stargazersCount}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _selectedRepos.add(repo.fullName);
                } else {
                  _selectedRepos.remove(repo.fullName);
                }
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorView(String error) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Hata oluştu: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(githubReposProvider),
            child: const Text('Tekrar Dene'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _connectGitHub,
            child: const Text('Bağlantıyı Yenile / Yetki Ver'),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: ElevatedButton(
        onPressed: _syncSelectedRepos,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        child: Text('${_selectedRepos.length} Repoyu Analiz Et ve Aktar'),
      ),
    );
  }

  Future<void> _connectGitHub() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.github,
        scopes: 'repo', // Private repolar için gerekli
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bağlantı hatası: $e')),
        );
      }
    }
  }

  Future<void> _syncSelectedRepos() async {
    // Gelecekte analiz ve CV'ye aktarma mantığı buraya gelecek.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seçilen repolar analiz ediliyor... (Geliştirilme aşamasında)')),
    );
  }
}
