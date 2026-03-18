import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';
import '../providers/community_provider.dart';
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
    final projectsAsync = ref.watch(projectListProvider);
    final communitiesAsync = ref.watch(communityListProvider);

    return Scaffold(
      appBar: isWizardMode
          ? null
          : AppBar(title: const Text('Projeler ve Topluluklar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: projectsAsync.when(
                data: (list) => _buildProjectList(context, ref, list),
                loading: () => const Center(
                  key: ValueKey('projects_loading'),
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, s) => Center(
                  key: const ValueKey('projects_error'),
                  child: Text('Hata: $e'),
                ),
              ),
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: communitiesAsync.when(
                data: (list) => _buildCommunityList(context, ref, list),
                loading: () => const Center(
                  key: ValueKey('communities_loading'),
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, s) => Center(
                  key: const ValueKey('communities_error'),
                  child: Text('Hata: $e'),
                ),
              ),
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
