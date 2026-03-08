import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/project.dart';
import '../../data/repositories/project_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(Supabase.instance.client);
});

final projectListProvider =
    AsyncNotifierProvider<ProjectListNotifier, List<Project>>(() {
      return ProjectListNotifier();
    });

class ProjectListNotifier extends AsyncNotifier<List<Project>> {
  @override
  Future<List<Project>> build() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return [];
    final repo = ref.read(projectRepositoryProvider);
    final list = await repo.getProjects(user.id);
    list.sort((a, b) {
      if (a.orderIndex != null && b.orderIndex != null)
        return a.orderIndex!.compareTo(b.orderIndex!);
      // Use date as fallback structure
      return (b.startDate ?? DateTime.now()).compareTo(
        a.startDate ?? DateTime.now(),
      );
    });
    return list;
  }

  Future<void> addProject(Project project) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(projectRepositoryProvider);
      final newItem = await repo.createProject(project);
      final currentList = state.value ?? [];
      final newList = [...currentList, newItem];
      newList.sort((a, b) {
        if (a.orderIndex != null && b.orderIndex != null)
          return a.orderIndex!.compareTo(b.orderIndex!);
        return (b.startDate ?? DateTime.now()).compareTo(
          a.startDate ?? DateTime.now(),
        );
      });
      return newList;
    });
  }

  Future<void> updateProject(Project project) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(projectRepositoryProvider);
      final updatedItem = await repo.updateProject(project);
      final currentList = state.value ?? [];
      final newList = currentList
          .map((e) => e.id == updatedItem.id ? updatedItem : e)
          .toList();
      newList.sort((a, b) {
        if (a.orderIndex != null && b.orderIndex != null)
          return a.orderIndex!.compareTo(b.orderIndex!);
        return (b.startDate ?? DateTime.now()).compareTo(
          a.startDate ?? DateTime.now(),
        );
      });
      return newList;
    });
  }

  Future<void> deleteProject(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(projectRepositoryProvider);
      await repo.deleteProject(id);
      final currentList = state.value ?? [];
      return currentList.where((e) => e.id != id).toList();
    });
  }

  Future<void> reorderProjects(int oldIndex, int newIndex) async {
    final currentList = state.value;
    if (currentList == null) return;

    final List<Project> newList = List.from(currentList);
    if (oldIndex < newIndex) newIndex -= 1;

    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);

    final List<Project> updatedList = [];
    for (int i = 0; i < newList.length; i++) {
      updatedList.add(newList[i].copyWith(orderIndex: i));
    }

    state = AsyncValue.data(updatedList);
    try {
      await ref.read(projectRepositoryProvider).updateProjectOrder(updatedList);
    } catch (e) {
      ref.invalidateSelf();
    }
  }
}
