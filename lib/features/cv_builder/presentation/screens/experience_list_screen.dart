import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/experience_provider.dart';
import 'experience_form_screen.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/deletion_effect.dart';

class ExperienceListScreen extends ConsumerStatefulWidget {
  final bool isWizardMode;
  const ExperienceListScreen({super.key, this.isWizardMode = false});

  @override
  ConsumerState<ExperienceListScreen> createState() => _ExperienceListScreenState();
}

class _ExperienceListScreenState extends ConsumerState<ExperienceListScreen> {
  final Set<int> _deletingIds = {};

  @override
  Widget build(BuildContext context) {
    final experienceAsync = ref.watch(experienceListProvider);

    return Scaffold(
      appBar: widget.isWizardMode
          ? null
          : AppBar(title: const Text('İş Deneyimlerim')),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: experienceAsync.when(
          data: (experiences) {
            if (experiences.isEmpty) {
              return const Center(
                key: ValueKey('empty'),
                child: Text(
                  'Henüz iş deneyimi eklemediniz.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ReorderableListView.builder(
              key: const ValueKey('list'),
              padding: const EdgeInsets.all(16),
              itemCount: experiences.length,
              onReorder: (oldIndex, newIndex) {
                ref
                    .read(experienceListProvider.notifier)
                    .reorderExperiences(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final exp = experiences[index];
                final dateFormat = DateFormat('MMM yyyy', 'tr_TR');
                final isDeleting = exp.id != null && _deletingIds.contains(exp.id);

                String dateString = '';
                if (exp.startDate != null) {
                  dateString += dateFormat.format(exp.startDate!);
                  dateString += ' - ';
                  if (exp.endDate != null) {
                    dateString += dateFormat.format(exp.endDate!);
                  } else {
                    dateString += 'Devam Ediyor';
                  }
                }

                return AnimatedSlide(
                  key: ValueKey(exp.id ?? index),
                  offset: isDeleting ? const Offset(-1.2, 0) : Offset.zero,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInCubic,
                  child: AnimatedOpacity(
                    opacity: isDeleting ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          exp.company,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            if (exp.role != null && exp.role!.isNotEmpty)
                              Text(exp.role!, style: const TextStyle(fontSize: 14)),
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
                                        ExperienceFormScreen(experienceToEdit: exp),
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
                                        'Bu iş deneyimini silmek istediğinize emin misiniz?',
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

                                  if (confirm == true && exp.id != null) {
                                    final RenderBox renderBox = buttonContext
                                        .findRenderObject() as RenderBox;
                                    final position = renderBox.localToGlobal(
                                        renderBox.size.center(Offset.zero));
                                    
                                    DeletionEffect.show(context, position);
                                    setState(() {
                                      _deletingIds.add(exp.id!);
                                    });

                                    await Future.delayed(const Duration(milliseconds: 350));
                                    
                                    if (mounted) {
                                      await ref
                                          .read(experienceListProvider.notifier)
                                          .deleteExperience(exp.id!);
                                    }
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.drag_indicator, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            key: ValueKey('loading'),
            child: CircularProgressIndicator(),
          ),
          error: (err, stack) => Center(
            key: const ValueKey('error'),
            child: Text('Hata oluştu: $err'),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ExperienceFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
