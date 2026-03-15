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

  Future<void> fetchSkills() async {
    try {
      state = const AsyncValue.loading();
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
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final data = skill.toJson();
      data['profile_id'] = user.id;

      await _supabase.from('skills').insert(data);
      await fetchSkills(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSkill(Skill skill) async {
    try {
      if (skill.id == null) throw Exception('Skill ID is null');
      
      await _supabase
          .from('skills')
          .update(skill.toJson())
          .eq('id', skill.id!);
          
      await fetchSkills(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSkill(int id) async {
    try {
      await _supabase.from('skills').delete().eq('id', id);
      await fetchSkills(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }
}
