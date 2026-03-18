import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/education.dart';
import '../../data/repositories/education_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final educationRepositoryProvider = Provider<EducationRepository>((ref) {
  return EducationRepository(Supabase.instance.client);
});

final educationListProvider =
    AsyncNotifierProvider<EducationListNotifier, List<Education>>(() {
      return EducationListNotifier();
    });

class EducationListNotifier extends AsyncNotifier<List<Education>> {
  @override
  Future<List<Education>> build() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return [];

    final repo = ref.read(educationRepositoryProvider);
    final list = await repo.getEducations(user.id);
    list.sort((a, b) {
      if (a.orderIndex != null && b.orderIndex != null) {
        return a.orderIndex!.compareTo(b.orderIndex!);
      }
      return (b.startDate ?? DateTime.now()).compareTo(
        a.startDate ?? DateTime.now(),
      );
    });
    return list;
  }

  Future<void> addEducation(Education education) async {
    final previousState = state;
    state = await AsyncValue.guard(() async {
      final repo = ref.read(educationRepositoryProvider);
      final newEdu = await repo.createEducation(education);
      final currentList = state.value ?? [];
      final newList = [...currentList, newEdu];
      newList.sort((a, b) {
        if (a.orderIndex != null && b.orderIndex != null) {
          return a.orderIndex!.compareTo(b.orderIndex!);
        }
        return (b.startDate ?? DateTime.now()).compareTo(
          a.startDate ?? DateTime.now(),
        );
      });
      return newList;
    });
    if (state.hasError) {
      state = previousState;
    }
  }

  Future<void> updateEducation(Education education) async {
    final previousState = state;
    
    if (!state.hasValue) return;

    final currentList = state.value!;
    state = AsyncValue.data(
      currentList.map((e) => e.id == education.id ? education : e).toList(),
    );

    try {
      final repo = ref.read(educationRepositoryProvider);
      await repo.updateEducation(education);
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  Future<void> deleteEducation(int id) async {
    if (!state.hasValue) return;

    final currentList = state.value!;
    state = AsyncValue.data(currentList.where((e) => e.id != id).toList());

    try {
      final repo = ref.read(educationRepositoryProvider);
      await repo.deleteEducation(id);
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  Future<void> reorderEducations(int oldIndex, int newIndex) async {
    final currentList = state.value;
    if (currentList == null) return;

    // Prevent UI jank by updating state immediately
    final List<Education> newList = List.from(currentList);

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final Education item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);

    // Assign sorted indexes
    final List<Education> updatedList = [];
    for (int i = 0; i < newList.length; i++) {
      updatedList.add(newList[i].copyWith(orderIndex: i));
    }

    // Save to state to skip loading screen flash
    state = AsyncValue.data(updatedList);

    try {
      final repo = ref.read(educationRepositoryProvider);
      await repo.updateEducationOrder(updatedList);
    } catch (e) {
      // Revert on failure
      ref.invalidateSelf();
    }
  }

  Future<void> sortByDate() async {
    final currentList = state.value;
    if (currentList == null) return;

    final List<Education> newList = List.from(currentList);
    
    // Sort by date: Newest first (descending)
    newList.sort((a, b) {
      final aDate = a.startDate ?? DateTime(1900);
      final bDate = b.startDate ?? DateTime(1900);
      return bDate.compareTo(aDate);
    });

    // Re-assign order indexes
    final List<Education> updatedList = [];
    for (int i = 0; i < newList.length; i++) {
      updatedList.add(newList[i].copyWith(orderIndex: i));
    }

    state = AsyncValue.data(updatedList);

    try {
      final repo = ref.read(educationRepositoryProvider);
      await repo.updateEducationOrder(updatedList);
    } catch (e) {
      ref.invalidateSelf();
    }
  }
}
