import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/education_provider.dart';
import 'education_form_screen.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/deletion_effect.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class EducationListScreen extends ConsumerStatefulWidget {
  final bool isWizardMode;
  const EducationListScreen({super.key, this.isWizardMode = false});

  @override
  ConsumerState<EducationListScreen> createState() => _EducationListScreenState();
}

class _EducationListScreenState extends ConsumerState<EducationListScreen> {
  late final TextEditingController _aboutMeController;
  final Set<int> _deletingIds = {};

  @override
  void initState() {
    super.initState();
    final profile = ref.read(currentUserProfileProvider).value;
    _aboutMeController = TextEditingController(text: profile?.aboutMe ?? '');
  }

  @override
  void dispose() {
    _aboutMeController.dispose();
    super.dispose();
  }

  Future<void> _saveAboutMe() async {
    final profile = ref.read(currentUserProfileProvider).value;
    if (profile == null) return;

    try {
      final updatedProfile = profile.copyWith(
        aboutMe: _aboutMeController.text.trim(),
        updatedAt: DateTime.now(),
      );
      await ref.read(authRepositoryProvider).updateProfile(updatedProfile);
      ref.invalidate(currentUserProfileProvider);
    } catch (e) {
      // Slient error as it's often auto-save or context switch
    }
  }

  @override
  Widget build(BuildContext context) {
    final educationsAsync = ref.watch(educationListProvider);

    return Scaffold(
      appBar: widget.isWizardMode
          ? null
          : AppBar(title: const Text('Eğitim Bilgileri')),
      body: CustomScrollView(
        slivers: [
          // Hakkımda Bölümü
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hakkımda',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kendinden kısaca bahset. Bu bilgi CV\'nin en başında görünecek.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _aboutMeController,
                    maxLines: 4,
                    maxLength: 600,
                    decoration: InputDecoration(
                      hintText: 'Örn: Tecrübeli bir yazılım geliştiricisiyim...',
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) => _saveAboutMe(),
                  ),
                  const Divider(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Eğitim Bilgileri',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.sort_rounded, color: Colors.blue),
                        tooltip: 'Tarihe Göre Sıralat',
                        onPressed: () => ref.read(educationListProvider.notifier).sortByDate(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          
          // Eğitim Listesi
          educationsAsync.when(
            data: (educations) {
              if (educations.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Text(
                        'Henüz eğitim bilgisi eklemediniz.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                );
              }

              return SliverReorderableList(
                itemCount: educations.length,
                onReorder: (oldIndex, newIndex) {
                  ref.read(educationListProvider.notifier).reorderEducations(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final edu = educations[index];
                  final dateFormat = DateFormat('MMM yyyy', 'tr_TR');

                  String dateString = '';
                  if (edu.startDate != null) {
                    dateString += dateFormat.format(edu.startDate!);
                    dateString += ' - ';
                    if (edu.endDate != null) {
                      dateString += dateFormat.format(edu.endDate!);
                    } else {
                      dateString += 'Devam Ediyor';
                    }
                  }

                  final isDeleting = edu.id != null && _deletingIds.contains(edu.id);

                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(edu.id ?? index),
                    index: index,
                    child: AnimatedSlide(
                      offset: isDeleting ? const Offset(-1.2, 0) : Offset.zero,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInCubic,
                      child: AnimatedOpacity(
                        opacity: isDeleting ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            edu.school,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              if (edu.degree != null && edu.degree!.isNotEmpty)
                                Text(edu.degree!, style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                dateString,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EducationFormScreen(educationToEdit: edu),
                                    ),
                                  );
                                },
                              ),
                              Builder(
                                  builder: (buttonContext) => IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Silmeyi Onayla'),
                                          content: const Text(
                                            'Bu eğitim bilgisini silmek istediğinize emin misiniz?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('İptal'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text(
                                                'Sil',
                                                style: TextStyle(color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true && edu.id != null) {
                                        final RenderBox renderBox = buttonContext
                                            .findRenderObject() as RenderBox;
                                        final position = renderBox.localToGlobal(
                                            renderBox.size.center(Offset.zero));
                                        
                                        // Start Animations
                                        DeletionEffect.show(context, position);
                                        setState(() {
                                          _deletingIds.add(edu.id!);
                                        });

                                        // Wait for slide animation to complete
                                        await Future.delayed(const Duration(milliseconds: 350));
                                        
                                        if (mounted) {
                                          await ref
                                              .read(educationListProvider.notifier)
                                              .deleteEducation(edu.id!);
                                          
                                          // Note: _deletingIds is cleaned up when the 
                                          // list item is removed from the DOM by provider
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ReorderableDragStartListener(
                                index: index,
                                child: const Icon(Icons.drag_indicator, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const SliverToBoxAdapter(
                child: Center(child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ))),
            error: (err, stack) => SliverToBoxAdapter(
                child: Center(child: Text('Hata oluştu: $err'))),
          ),
          
          // Bottom padding for FAB
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EducationFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
