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
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(courseRepositoryProvider);
      final newItem = await repo.createCourse(course);
      final currentList = state.value ?? [];
      final newList = [...currentList, newItem];
      newList.sort((a, b) => (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0));
      return newList;
    });
  }

  Future<void> updateCourse(Course course) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(courseRepositoryProvider);
      final updatedItem = await repo.updateCourse(course);
      final currentList = state.value ?? [];
      final newList = currentList
          .map((e) => e.id == updatedItem.id ? updatedItem : e)
          .toList();
      newList.sort((a, b) => (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0));
      return newList;
    });
  }

  Future<void> deleteCourse(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(courseRepositoryProvider);
      await repo.deleteCourse(id);
      final currentList = state.value ?? [];
      return currentList.where((e) => e.id != id).toList();
    });
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
