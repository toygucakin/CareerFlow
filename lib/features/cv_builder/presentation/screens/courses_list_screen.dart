import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/course_provider.dart';
import 'course_form_screen.dart';

class CoursesListScreen extends ConsumerWidget {
  final bool isWizardMode;

  const CoursesListScreen({super.key, this.isWizardMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(courseListProvider);

    return Scaffold(
      appBar: isWizardMode
          ? null
          : AppBar(title: const Text('Kurslarım ve Sertifikalarım')),
      body: coursesAsync.when(
        data: (courses) {
          if (courses.isEmpty) {
            return const Center(
              child: Text(
                'Henüz kurs veya sertifika eklemediniz.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            onReorder: (oldIndex, newIndex) {
              ref
                  .read(courseListProvider.notifier)
                  .reorderCourses(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final course = courses[index];

              return Card(
                key: ValueKey(course.id ?? index),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    course.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      if (course.issuer != null && course.issuer!.isNotEmpty)
                        Text(
                          course.issuer!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      if (course.description != null &&
                          course.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          course.description!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
                                  CourseFormScreen(courseToEdit: course),
                            ),
                          );
                        },
                      ),
                      IconButton(
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
                                'Bu kursu silmek istediğinize emin misiniz?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('İptal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Sil',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && course.id != null) {
                            ref
                                .read(courseListProvider.notifier)
                                .deleteCourse(course.id!);
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
            MaterialPageRoute(builder: (context) => const CourseFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
