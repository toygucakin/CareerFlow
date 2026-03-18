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
    final previousState = state;
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final data = skill.toJson();
      data['profile_id'] = user.id;

      await _supabase.from('skills').insert(data);
      await fetchSkills(showLoading: false); // Refresh silently
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> updateSkill(Skill skill) async {
    final previousState = state;
    try {
      if (skill.id == null) throw Exception('Skill ID is null');
      
      // Optimistic update
      if (state.hasValue) {
        final currentList = state.value!;
        state = AsyncValue.data(
          currentList.map((s) => s.id == skill.id ? skill : s).toList(),
        );
      }

      await _supabase
          .from('skills')
          .update(skill.toJson())
          .eq('id', skill.id!);
          
      await fetchSkills(showLoading: false); // Refresh silently
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> deleteSkill(int id) async {
    final previousState = state;
    try {
      // Optimistic delete
      if (state.hasValue) {
        final currentList = state.value!;
        state = AsyncValue.data(
          currentList.where((s) => s.id != id).toList(),
        );
      }

      await _supabase.from('skills').delete().eq('id', id);
      // No need to fetchSkills(showLoading: false) here if we trust the delete was successful 
      // but it's safer to refresh silently.
      await fetchSkills(showLoading: false);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }
}
