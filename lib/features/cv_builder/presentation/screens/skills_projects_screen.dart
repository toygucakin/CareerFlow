import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';
import '../providers/community_provider.dart';
import '../../../../core/widgets/deletion_effect.dart';
import 'project_form_screen.dart';
import 'community_form_screen.dart';
import '../../domain/models/project.dart';
import '../../domain/models/community.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/models/user_profile.dart';

class SkillsProjectsScreen extends ConsumerStatefulWidget {
  final bool isWizardMode;
  const SkillsProjectsScreen({super.key, this.isWizardMode = false});

  @override
  ConsumerState<SkillsProjectsScreen> createState() => _SkillsProjectsScreenState();
}

class _SkillsProjectsScreenState extends ConsumerState<SkillsProjectsScreen> {
  final Set<int> _deletingIds = {};

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
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectListProvider);
    final communitiesAsync = ref.watch(communityListProvider);

    return Scaffold(
      appBar: widget.isWizardMode
          ? null
          : AppBar(title: const Text('Projeler ve Topluluklar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PortfolioLinkSection(),
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

  Widget _buildProjectList(
      BuildContext context, WidgetRef ref, List<Project> list) {
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'Proje bilgisi eklenmemiş.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      onReorder: (oldIndex, newIndex) {
        ref
            .read(projectListProvider.notifier)
            .reorderProjects(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final proj = list[index];
        final isDeleting = proj.id != null && _deletingIds.contains(proj.id);

        return AnimatedSlide(
          key: ValueKey(proj.id ?? index),
          offset: isDeleting ? const Offset(-1.2, 0) : Offset.zero,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInCubic,
          child: AnimatedOpacity(
            opacity: isDeleting ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  proj.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      _formatDateRange(proj.startDate, proj.endDate),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message: proj.isHighlighted ? 'CV\'den çıkar' : 'CV\'ye dahil et',
                      child: Switch(
                        value: proj.isHighlighted,
                        activeColor: Colors.amber,
                        onChanged: (val) async {
                          try {
                            await ref.read(projectListProvider.notifier).toggleProjectHighlight(proj);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString().replaceAll('Exception: ', '')),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProjectFormScreen(projectToEdit: proj),
                        ),
                      ),
                    ),
                    Builder(
                      builder: (buttonContext) => IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          final RenderBox renderBox =
                              buttonContext.findRenderObject() as RenderBox;
                          final position = renderBox.localToGlobal(
                              renderBox.size.center(Offset.zero));
                          
                          DeletionEffect.show(context, position);
                          setState(() {
                            _deletingIds.add(proj.id!);
                          });

                          await Future.delayed(const Duration(milliseconds: 350));
                          
                          if (mounted) {
                            ref
                                .read(projectListProvider.notifier)
                                .deleteProject(proj.id!);
                          }
                        },
                      ),
                    ),
                    ReorderableDragStartListener(
                      index: index,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.drag_indicator, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommunityList(
      BuildContext context, WidgetRef ref, List<Community> list) {
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'Topluluk bilgisi eklenmemiş.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      onReorder: (oldIndex, newIndex) {
        ref
            .read(communityListProvider.notifier)
            .reorderCommunities(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final club = list[index];
        final isDeleting = club.id != null && _deletingIds.contains(club.id);

        return AnimatedSlide(
          key: ValueKey(club.id ?? index),
          offset: isDeleting ? const Offset(-1.2, 0) : Offset.zero,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInCubic,
          child: AnimatedOpacity(
            opacity: isDeleting ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CommunityFormScreen(communityToEdit: club),
                        ),
                      ),
                    ),
                    Builder(
                      builder: (buttonContext) => IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          final RenderBox renderBox =
                              buttonContext.findRenderObject() as RenderBox;
                          final position = renderBox.localToGlobal(
                              renderBox.size.center(Offset.zero));
                          
                          DeletionEffect.show(context, position);
                          setState(() {
                            _deletingIds.add(club.id!);
                          });

                          await Future.delayed(const Duration(milliseconds: 350));
                          
                          if (mounted) {
                            ref
                                .read(communityListProvider.notifier)
                                .deleteCommunity(club.id!);
                          }
                        },
                      ),
                    ),
                    ReorderableDragStartListener(
                      index: index,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.drag_indicator, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PortfolioLinkSection extends ConsumerStatefulWidget {
  const _PortfolioLinkSection();

  @override
  ConsumerState<_PortfolioLinkSection> createState() => _PortfolioLinkSectionState();
}

class _PortfolioLinkSectionState extends ConsumerState<_PortfolioLinkSection> {
  late TextEditingController _urlController;
  bool _isSaving = false;
  bool _localIsExpanded = false;
  bool _hasInitialized = false;
  UserProfile? _lastProfile;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveUrl(UserProfile profile, String newUrl) async {
    setState(() => _isSaving = true);
    try {
      final updatedProfile = profile.copyWith(portfolioUrl: newUrl);
      await ref.read(authRepositoryProvider).updateProfile(updatedProfile);
      ref.invalidate(currentUserProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(newUrl.isEmpty ? 'Portfolyo linki kaldırıldı.' : 'Portfolyo linki güncellendi.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();
        
        final hasValidUrl = profile.portfolioUrl != null && profile.portfolioUrl!.isNotEmpty;

        if (!_hasInitialized) {
          _urlController.text = profile.portfolioUrl ?? '';
          _localIsExpanded = hasValidUrl;
          _hasInitialized = true;
        }

        if (_lastProfile?.portfolioUrl != profile.portfolioUrl && !_isSaving) {
           _urlController.text = profile.portfolioUrl ?? '';
           _localIsExpanded = (profile.portfolioUrl != null && profile.portfolioUrl!.isNotEmpty);
           _lastProfile = profile;
        }

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              CheckboxListTile(
                title: const Text('Daha Fazla Proje Linki', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('CV\'nizin altında görünür', style: TextStyle(fontSize: 12)),
                value: _localIsExpanded,
                activeColor: Colors.blue,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                onChanged: (val) async {
                  if (val == true) {
                    setState(() => _localIsExpanded = true);
                  } else {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Emin misiniz?'),
                        content: const Text('Portfolyo linkiniz CV\'den kaldırılacaktır. Onaylıyor musunuz?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true), 
                            child: const Text('Evet, Kaldır', style: TextStyle(color: Colors.red))
                          ),
                        ],
                      )
                    );
                    if (confirm == true) {
                      setState(() => _localIsExpanded = false);
                      _urlController.clear();
                      await _saveUrl(profile, '');
                    }
                  }
                },
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity, height: 0),
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      TextField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          labelText: 'Portfolyo / Kişisel Web Sitesi',
                          hintText: 'https://...',
                          prefixIcon: Icon(Icons.link),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : () => _saveUrl(profile, _urlController.text.trim()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: _isSaving 
                              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Kaydet'),
                        ),
                      ),
                    ],
                  ),
                ),
                crossFadeState: _localIsExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}


