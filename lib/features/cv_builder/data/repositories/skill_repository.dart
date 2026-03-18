import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/cv/skill.dart';

class SkillRepository {
  final SupabaseClient _supabase;

  SkillRepository(this._supabase);

  Future<List<Skill>> getSkills(String profileId) async {
    final response = await _supabase
        .from('skills')
        .select()
        .eq('profile_id', profileId)
        .order('sort_order', ascending: true);

    return (response as List).map((e) => Skill.fromJson(e)).toList();
  }

  Future<Skill> createSkill(Skill skill) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

    final data = skill.toJson()..remove('id');
    data['profile_id'] = user.id;

    final response = await _supabase
        .from('skills')
        .insert(data)
        .select()
        .single();
    return Skill.fromJson(response);
  }

  Future<Skill> updateSkill(Skill skill) async {
    if (skill.id == null) throw Exception('ID cannot be null');
    final response = await _supabase
        .from('skills')
        .update(skill.toJson())
        .eq('id', skill.id!)
        .select()
        .single();
    return Skill.fromJson(response);
  }

  Future<void> deleteSkill(int id) async {
    await _supabase.from('skills').delete().eq('id', id);
  }

  Future<void> updateSkillOrder(List<Skill> skills) async {
    final List<Map<String, dynamic>> dataToUpdate = skills
        .map((e) => e.toJson())
        .toList();
    await _supabase.from('skills').upsert(dataToUpdate);
  }
}
