import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/education_provider.dart';
import 'education_form_screen.dart';
import 'package:intl/intl.dart';

class EducationListScreen extends ConsumerWidget {
  const EducationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final educationsAsync = ref.watch(educationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eğitim Bilgileri'),
      ),
      body: educationsAsync.when(
        data: (educations) {
          if (educations.isEmpty) {
            return const Center(
              child: Text(
                'Henüz eğitim bilgisi eklemediniz.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
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

              return Card(
                key: ValueKey(edu.id ?? index),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    edu.school,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EducationFormScreen(educationToEdit: edu),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Silmeyi Onayla'),
                              content: const Text('Bu eğitim bilgisini silmek istediğinize emin misiniz?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('İptal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Sil', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirm == true && edu.id != null) {
                            ref.read(educationListProvider.notifier).deleteEducation(edu.id!);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.drag_indicator, color: Colors.grey),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata oluştu: $err')),
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
