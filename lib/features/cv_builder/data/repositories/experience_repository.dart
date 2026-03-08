import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/experience.dart';

class ExperienceRepository {
  final SupabaseClient _supabase;

  ExperienceRepository(this._supabase);

  Future<List<Experience>> getExperiences(String profileId) async {
    final response = await _supabase
        .from('experience')
        .select()
        .eq('profile_id', profileId)
        .order('sort_order', ascending: true);

    return (response as List).map((e) => Experience.fromJson(e)).toList();
  }

  Future<Experience> createExperience(Experience exp) async {
    final data = exp.toJson()..remove('id');
    final response = await _supabase
        .from('experience')
        .insert(data)
        .select()
        .single();
    return Experience.fromJson(response);
  }

  Future<Experience> updateExperience(Experience exp) async {
    if (exp.id == null) throw Exception('ID cannot be null');
    final response = await _supabase
        .from('experience')
        .update(exp.toJson())
        .eq('id', exp.id!)
        .select()
        .single();
    return Experience.fromJson(response);
  }

  Future<void> updateExperienceOrder(List<Experience> experiences) async {
    final List<Map<String, dynamic>> dataToUpdate = experiences
        .map((e) => e.toJson())
        .toList();
    await _supabase.from('experience').upsert(dataToUpdate);
  }

  Future<void> deleteExperience(int id) async {
    await _supabase.from('experience').delete().eq('id', id);
  }
}
