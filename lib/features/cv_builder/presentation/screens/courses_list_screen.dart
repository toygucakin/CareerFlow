import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/course_provider.dart';
import 'course_form_screen.dart';
import '../../../../core/widgets/deletion_effect.dart';

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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: coursesAsync.when(
          key: ValueKey(coursesAsync.hasValue ? 'data' : 'loading'),
          data: (courses) {
            if (courses.isEmpty) {
              return const Center(
                key: ValueKey('empty'),
                child: Text(
                  'Henüz kurs veya sertifika eklemediniz.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ReorderableListView.builder(
              key: const ValueKey('list'),
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
                                    'Bu kursu silmek istediğinize emin misiniz?',
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

                              if (confirm == true && course.id != null) {
                                final RenderBox renderBox = buttonContext
                                    .findRenderObject() as RenderBox;
                                final position = renderBox.localToGlobal(
                                    renderBox.size.center(Offset.zero));
                                DeletionEffect.show(context, position);
                                ref
                                    .read(courseListProvider.notifier)
                                    .deleteCourse(course.id!);
                              }
                            },
                          ),
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
            MaterialPageRoute(builder: (context) => const CourseFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
