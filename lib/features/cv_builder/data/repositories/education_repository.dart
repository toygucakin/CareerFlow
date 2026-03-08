import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/education.dart';

class EducationRepository {
  final SupabaseClient _supabase;

  EducationRepository(this._supabase);

  Future<List<Education>> getEducations(String profileId) async {
    final response = await _supabase
        .from('education')
        .select()
        .eq('profile_id', profileId)
        .order('start_date', ascending: false);

    return (response as List).map((e) => Education.fromJson(e)).toList();
  }

  Future<Education> createEducation(Education education) async {
    final data = education.toJson()..remove('id');
    
    final response = await _supabase
        .from('education')
        .insert(data)
        .select()
        .single();
        
    return Education.fromJson(response);
  }

  Future<Education> updateEducation(Education education) async {
    if (education.id == null) {
      throw Exception('Education ID cannot be null for update');
    }

    final response = await _supabase
        .from('education')
        .update(education.toJson())
        .eq('id', education.id!)
        .select()
        .single();

    return Education.fromJson(response);
  }

  Future<void> updateEducationOrder(List<Education> educations) async {
    // Supabase RPC or batch update might be ideal, but for simplicity, we do sequential updates.
    // Or we can use upsert. Upsert is cleaner for batch editing if we have all fields.
    final List<Map<String, dynamic>> dataToUpdate = educations.map((e) => e.toJson()).toList();
    
    await _supabase.from('education').upsert(dataToUpdate);
  }

  Future<void> deleteEducation(int id) async {
    await _supabase.from('education').delete().eq('id', id);
  }
}
