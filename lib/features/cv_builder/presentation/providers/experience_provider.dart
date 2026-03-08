import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/experience.dart';
import '../../data/repositories/experience_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final experienceRepositoryProvider = Provider<ExperienceRepository>((ref) {
  return ExperienceRepository(Supabase.instance.client);
});

final experienceListProvider =
    AsyncNotifierProvider<ExperienceListNotifier, List<Experience>>(() {
      return ExperienceListNotifier();
    });

class ExperienceListNotifier extends AsyncNotifier<List<Experience>> {
  @override
  Future<List<Experience>> build() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return [];
    final repo = ref.read(experienceRepositoryProvider);
    final list = await repo.getExperiences(user.id);
    list.sort((a, b) {
      if (a.orderIndex != null && b.orderIndex != null)
        return a.orderIndex!.compareTo(b.orderIndex!);
      return (b.startDate ?? DateTime.now()).compareTo(
        a.startDate ?? DateTime.now(),
      );
    });
    return list;
  }

  Future<void> addExperience(Experience experience) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(experienceRepositoryProvider);
      final newItem = await repo.createExperience(experience);
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

  Future<void> updateExperience(Experience experience) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(experienceRepositoryProvider);
      final updatedItem = await repo.updateExperience(experience);
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

  Future<void> deleteExperience(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(experienceRepositoryProvider);
      await repo.deleteExperience(id);
      final currentList = state.value ?? [];
      return currentList.where((e) => e.id != id).toList();
    });
  }

  Future<void> reorderExperiences(int oldIndex, int newIndex) async {
    final currentList = state.value;
    if (currentList == null) return;

    final List<Experience> newList = List.from(currentList);
    if (oldIndex < newIndex) newIndex -= 1;

    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);

    final List<Experience> updatedList = [];
    for (int i = 0; i < newList.length; i++) {
      updatedList.add(newList[i].copyWith(orderIndex: i));
    }

    state = AsyncValue.data(updatedList);
    try {
      await ref
          .read(experienceRepositoryProvider)
          .updateExperienceOrder(updatedList);
    } catch (e) {
      ref.invalidateSelf();
    }
  }
}
