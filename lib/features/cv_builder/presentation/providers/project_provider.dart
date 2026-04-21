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
      return (b.startDate ?? DateTime.now()).compareTo(
        a.startDate ?? DateTime.now(),
      );
    });
    return list;
  }

  Future<void> addProject(Project project) async {
    try {
      final repo = ref.read(projectRepositoryProvider);
      final newItem = await repo.createProject(project);
      if (state.hasValue) {
        final newList = [...state.value!, newItem];
        newList.sort((a, b) {
          if (a.orderIndex != null && b.orderIndex != null)
            return a.orderIndex!.compareTo(b.orderIndex!);
          return (b.startDate ?? DateTime.now()).compareTo(
            a.startDate ?? DateTime.now(),
          );
        });
        state = AsyncValue.data(newList);
      } else {
        ref.invalidateSelf();
      }
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  Future<void> updateProject(Project project) async {
    if (!state.hasValue) return;
    
    final currentList = state.value!;
    state = AsyncValue.data(
      currentList.map((e) => e.id == project.id ? project : e).toList(),
    );

    try {
      final repo = ref.read(projectRepositoryProvider);
      await repo.updateProject(project);
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  Future<void> deleteProject(int id) async {
    if (!state.hasValue) return;

    final currentList = state.value!;
    state = AsyncValue.data(currentList.where((e) => e.id != id).toList());

    try {
      final repo = ref.read(projectRepositoryProvider);
      await repo.deleteProject(id);
    } catch (e) {
      ref.invalidateSelf();
    }
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

  Future<void> toggleProjectHighlight(Project project) async {
    if (!state.hasValue) return;
    
    final currentList = state.value!;
    final isActivating = !project.isHighlighted;
    
    if (isActivating) {
      final highlightedCount = currentList.where((p) => p.isHighlighted).length;
      if (highlightedCount >= 4) {
        throw Exception('Maksimum 4 proje öne çıkarılabilir.');
      }
    }

    final updatedProject = project.copyWith(isHighlighted: isActivating);
    
    // Optimistic update
    state = AsyncValue.data(
      currentList.map((e) => e.id == project.id ? updatedProject : e).toList(),
    );

    try {
      final repo = ref.read(projectRepositoryProvider);
      await repo.updateProject(updatedProject);
    } catch (e) {
      ref.invalidateSelf();
      rethrow;
    }
  }
}
