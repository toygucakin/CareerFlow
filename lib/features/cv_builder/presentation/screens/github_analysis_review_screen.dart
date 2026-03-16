import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analysis_provider.dart';
import '../../../../core/models/github/analyzed_project.dart';
import '../providers/project_provider.dart';
import '../providers/skill_provider.dart';
import '../../domain/models/project.dart';
import '../../../../core/models/cv/skill.dart';

import '../../../../core/models/github/github_repo.dart';

class GitHubAnalysisReviewScreen extends ConsumerStatefulWidget {
  final List<GithubRepo> selectedRepos;
  
  const GitHubAnalysisReviewScreen({super.key, required this.selectedRepos});

  @override
  ConsumerState<GitHubAnalysisReviewScreen> createState() => _GitHubAnalysisReviewScreenState();
}

class _GitHubAnalysisReviewScreenState extends ConsumerState<GitHubAnalysisReviewScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger analysis when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analysisNotifierProvider.notifier).analyzeRepositories(widget.selectedRepos);
    });
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(analysisNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analiz Sonuçlarını İncele'),
        elevation: 0,
      ),
      body: analysisState.when(
        data: (projects) => _buildProjectList(context, ref, projects),
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('README ve Kodlar Analiz Ediliyor...'),
            ],
          ),
        ),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
      bottomNavigationBar: analysisState.maybeWhen(
        data: (projects) => projects.isNotEmpty ? _buildFooter(context, ref, projects) : null,
        orElse: () => null,
      ),
    );
  }

  Widget _buildProjectList(BuildContext context, WidgetRef ref, List<AnalyzedProject> projects) {
    if (projects.isEmpty) {
      return const Center(child: Text('Analiz edilecek proje bulunamadı.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectCard(context, ref, index, project);
      },
    );
  }

  Widget _buildProjectCard(BuildContext context, WidgetRef ref, int index, AnalyzedProject project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: project.title,
                    decoration: const InputDecoration(
                      labelText: 'Proje Başlığı',
                      border: InputBorder.none,
                      labelStyle: TextStyle(color: Colors.blue),
                    ),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    onChanged: (val) {
                      ref.read(analysisNotifierProvider.notifier).updateProject(
                        index, project.copyWith(title: val),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => ref.read(analysisNotifierProvider.notifier).removeProject(index),
                ),
              ],
            ),
            TextFormField(
              initialValue: project.scope,
              decoration: const InputDecoration(
                labelText: 'Proje Kapsamı (Örn: Mobil Uygulama)',
                border: InputBorder.none,
                labelStyle: TextStyle(color: Colors.blue),
                prefixIcon: Icon(Icons.category_outlined, size: 16),
              ),
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
              onChanged: (val) {
                ref.read(analysisNotifierProvider.notifier).updateProject(
                  index, project.copyWith(scope: val),
                );
              },
            ),
            const Divider(),
            TextFormField(
              initialValue: project.description,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Proje Açıklaması (README\'den özetlendi)',
                border: InputBorder.none,
                labelStyle: TextStyle(color: Colors.blue),
              ),
              onChanged: (val) {
                ref.read(analysisNotifierProvider.notifier).updateProject(
                  index, project.copyWith(description: val),
                );
              },
            ),
            const SizedBox(height: 12),
            const Text(
              'Tespit Edilen Teknolojiler:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: project.technologies.map((tech) => Chip(
                label: Text(tech, style: const TextStyle(fontSize: 10)),
                padding: EdgeInsets.zero,
                backgroundColor: Colors.blue.withOpacity(0.1),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref, List<AnalyzedProject> analyzedProjects) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: ElevatedButton(
        onPressed: () => _importToCV(context, ref, analyzedProjects),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Onayla ve CV\'ye Aktar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _importToCV(BuildContext context, WidgetRef ref, List<AnalyzedProject> analyzedProjects) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final projectNotifier = ref.read(projectListProvider.notifier);
      final skillNotifier = ref.read(skillListProvider.notifier);

      for (final ap in analyzedProjects) {
        // 1. Add as Project
        await projectNotifier.addProject(Project(
          name: ap.title, // 'title' was changed to 'name' in Project model
          scope: ap.scope, // Save the AI generated scope
          description: ap.description,
          technologies: ap.technologies.join(', '), // Convert List<String> to String
          startDate: ap.startDate,
          endDate: ap.endDate,
          isAutonomous: true, // Mark as autonomously added
          repoUrl: 'https://github.com/${ap.repoFullName}',
        ));

        // 2. Add technologies as Skills if they don't exist
        for (final tech in ap.technologies) {
          await skillNotifier.addSkill(Skill(
            category: 'Programlama', // Default
            name: tech,
            isActiveDevelopment: true,
          ));
        }
      }

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veriler başarıyla CV\'ye aktarıldı!')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aktarım sırasında hata: $e')),
        );
      }
    }
  }
}
