import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/cv/skill.dart';
import '../../data/repositories/skill_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final skillRepositoryProvider = Provider<SkillRepository>((ref) {
  return SkillRepository(Supabase.instance.client);
});

final skillListProvider =
    AsyncNotifierProvider<SkillListNotifier, List<Skill>>(() {
  return SkillListNotifier();
});

class SkillListNotifier extends AsyncNotifier<List<Skill>> {
  @override
  Future<List<Skill>> build() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return [];
    final repo = ref.read(skillRepositoryProvider);
    final list = await repo.getSkills(user.id);
    list.sort((a, b) => (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0));
    return list;
  }

  Future<void> addSkill(Skill skill) async {
    try {
      final repo = ref.read(skillRepositoryProvider);
      final newItem = await repo.createSkill(skill);
      if (state.hasValue) {
        state = AsyncValue.data([...state.value!, newItem]);
      } else {
        ref.invalidateSelf();
      }
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  Future<void> updateSkill(Skill skill) async {
    if (!state.hasValue) return;
    
    // Optimistic update
    final currentList = state.value!;
    state = AsyncValue.data(
      currentList.map((e) => e.id == skill.id ? skill : e).toList(),
    );

    try {
      final repo = ref.read(skillRepositoryProvider);
      await repo.updateSkill(skill);
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  Future<void> deleteSkill(int id) async {
    if (!state.hasValue) return;
    
    // Optimistic delete
    final currentList = state.value!;
    state = AsyncValue.data(currentList.where((e) => e.id != id).toList());

    try {
      final repo = ref.read(skillRepositoryProvider);
      await repo.deleteSkill(id);
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  Future<void> reorderSkills(int oldIndex, int newIndex) async {
    final currentList = state.value;
    if (currentList == null) return;

    final List<Skill> newList = List.from(currentList);
    if (oldIndex < newIndex) newIndex -= 1;

    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);

    final List<Skill> updatedList = [];
    for (int i = 0; i < newList.length; i++) {
      updatedList.add(newList[i].copyWith(orderIndex: i));
    }

    state = AsyncValue.data(updatedList);
    try {
      await ref.read(skillRepositoryProvider).updateSkillOrder(updatedList);
    } catch (e) {
      ref.invalidateSelf();
    }
  }
}
