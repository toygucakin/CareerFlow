import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/language_provider.dart';
import '../providers/project_provider.dart';
import '../providers/community_provider.dart';
import 'language_form_screen.dart';
import 'project_form_screen.dart';
import 'community_form_screen.dart';
import 'package:intl/intl.dart';

class SkillsProjectsScreen extends ConsumerWidget {
  final bool isWizardMode;

  const SkillsProjectsScreen({super.key, this.isWizardMode = false});

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null) return '';
    final dateFormat = DateFormat('MMM yyyy', 'tr_TR');
    String range = dateFormat.format(start);
    range += ' - ';
    if (end != null) {
      range += dateFormat.format(end);
    } else {
      range += 'Devam Ediyor';
    }
    return range;
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languagesAsync = ref.watch(languageListProvider);
    final projectsAsync = ref.watch(projectListProvider);
    final communitiesAsync = ref.watch(communityListProvider);

    return Scaffold(
      appBar: isWizardMode
          ? null
          : AppBar(title: const Text('Yetenekler ve Projeler')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              'Yabancı Diller',
              Icons.language,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageFormScreen(),
                ),
              ),
            ),
            languagesAsync.when(
              data: (list) => _buildLanguageList(context, ref, list),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Hata: $e'),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(
              context,
              'Projeler',
              Icons.assignment_outlined,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectFormScreen(),
                ),
              ),
            ),
            projectsAsync.when(
              data: (list) => _buildProjectList(context, ref, list),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Hata: $e'),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(
              context,
              'Topluluklar ve Kulüpler',
              Icons.groups_outlined,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CommunityFormScreen(),
                ),
              ),
            ),
            communitiesAsync.when(
              data: (list) => _buildCommunityList(context, ref, list),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Hata: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onAdd,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        IconButton(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
        ),
      ],
    );
  }

  Widget _buildLanguageList(BuildContext context, WidgetRef ref, List list) {
    if (list.isEmpty)
      return const Text(
        'Dil bilgisi eklenmemiş.',
        style: TextStyle(color: Colors.grey),
      );
    return Column(
      children: list
          .map(
            (lang) => Card(
              child: ListTile(
                title: Text(
                  lang.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(lang.proficiency ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => ref
                      .read(languageListProvider.notifier)
                      .deleteLanguage(lang.id!),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LanguageFormScreen(languageToEdit: lang),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildProjectList(BuildContext context, WidgetRef ref, List list) {
    if (list.isEmpty)
      return const Text(
        'Proje bilgisi eklenmemiş.',
        style: TextStyle(color: Colors.grey),
      );
    return Column(
      children: list
          .map(
            (proj) => Card(
              child: ListTile(
                title: Text(
                  proj.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (proj.scope != null && proj.scope!.isNotEmpty)
                      Text(proj.scope!),
                    const SizedBox(height: 2),
                    Text(
                      _formatDateRange(proj.startDate, proj.endDate),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => ref
                      .read(projectListProvider.notifier)
                      .deleteProject(proj.id!),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProjectFormScreen(projectToEdit: proj),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCommunityList(BuildContext context, WidgetRef ref, List list) {
    if (list.isEmpty)
      return const Text(
        'Topluluk bilgisi eklenmemiş.',
        style: TextStyle(color: Colors.grey),
      );
    return Column(
      children: list
          .map(
            (club) => Card(
              child: ListTile(
                title: Text(
                  club.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (club.role != null && club.role!.isNotEmpty)
                      Text(club.role!),
                    const SizedBox(height: 2),
                    Text(
                      _formatDateRange(club.startDate, club.endDate),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => ref
                      .read(communityListProvider.notifier)
                      .deleteCommunity(club.id!),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CommunityFormScreen(communityToEdit: club),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
