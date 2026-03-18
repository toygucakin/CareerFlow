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
    try {
      final repo = ref.read(educationRepositoryProvider);
      final newItem = await repo.createEducation(education);
      if (state.hasValue) {
        final newList = [...state.value!, newItem];
        newList.sort((a, b) {
          if (a.orderIndex != null && b.orderIndex != null) {
            return a.orderIndex!.compareTo(b.orderIndex!);
          }
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

  Future<void> updateEducation(Education education) async {
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

    final List<Education> newList = List.from(currentList);
    if (oldIndex < newIndex) newIndex -= 1;

    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);

    final List<Education> updatedList = [];
    for (int i = 0; i < newList.length; i++) {
      updatedList.add(newList[i].copyWith(orderIndex: i));
    }

    state = AsyncValue.data(updatedList);
    try {
      await ref
          .read(educationRepositoryProvider)
          .updateEducationOrder(updatedList);
    } catch (e) {
      ref.invalidateSelf();
    }
  }
}
