import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/cv/skill.dart';

final skillListProvider = StateNotifierProvider<SkillListNotifier, AsyncValue<List<Skill>>>((ref) {
  return SkillListNotifier();
});

class SkillListNotifier extends StateNotifier<AsyncValue<List<Skill>>> {
  SkillListNotifier() : super(const AsyncValue.loading()) {
    fetchSkills();
  }

  final _supabase = Supabase.instance.client;

  Future<void> fetchSkills({bool showLoading = true}) async {
    try {
      if (showLoading) {
        state = const AsyncValue.loading();
      }
      final user = _supabase.auth.currentUser;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final response = await _supabase
          .from('skills')
          .select()
          .eq('profile_id', user.id)
          .order('sort_order', ascending: true);

      final skills = (response as List)
          .map((json) => Skill.fromJson(json))
          .toList();
          
      state = AsyncValue.data(skills);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
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
      // Error handling by the UI
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
}
