import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/course.dart';
import '../../data/repositories/course_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepository(Supabase.instance.client);
});

final courseListProvider =
    AsyncNotifierProvider<CourseListNotifier, List<Course>>(() {
      return CourseListNotifier();
    });

class CourseListNotifier extends AsyncNotifier<List<Course>> {
  @override
  Future<List<Course>> build() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return [];
    final repo = ref.read(courseRepositoryProvider);
    final list = await repo.getCourses(user.id);
    list.sort((a, b) => (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0));
    return list;
  }

  Future<void> addCourse(Course course) async {
    try {
      final repo = ref.read(courseRepositoryProvider);
      final newItem = await repo.createCourse(course);
      if (state.hasValue) {
        final newList = [...state.value!, newItem];
        newList.sort((a, b) => (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0));
        state = AsyncValue.data(newList);
      } else {
        ref.invalidateSelf();
      }
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  Future<void> updateCourse(Course course) async {
    if (!state.hasValue) return;
    
    final currentList = state.value!;
    state = AsyncValue.data(
      currentList.map((e) => e.id == course.id ? course : e).toList(),
    );

    try {
      final repo = ref.read(courseRepositoryProvider);
      await repo.updateCourse(course);
      // Data will be sorted correctly on next build/fetch if needed, 
      // but here we just update for UI.
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  Future<void> deleteCourse(int id) async {
    if (!state.hasValue) return;
    
    final currentList = state.value!;
    state = AsyncValue.data(currentList.where((e) => e.id != id).toList());

    try {
      final repo = ref.read(courseRepositoryProvider);
      await repo.deleteCourse(id);
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  Future<void> reorderCourses(int oldIndex, int newIndex) async {
    final currentList = state.value;
    if (currentList == null) return;

    final List<Course> newList = List.from(currentList);
    if (oldIndex < newIndex) newIndex -= 1;

    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);

    final List<Course> updatedList = [];
    for (int i = 0; i < newList.length; i++) {
      updatedList.add(newList[i].copyWith(orderIndex: i));
    }

    state = AsyncValue.data(updatedList);
    try {
      await ref.read(courseRepositoryProvider).updateCourseOrder(updatedList);
    } catch (e) {
      ref.invalidateSelf();
    }
  }
}
