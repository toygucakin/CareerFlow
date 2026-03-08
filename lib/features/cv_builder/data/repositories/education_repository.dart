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
    final response = await _supabase
        .from('education')
        .insert(education.toJson())
        .select()
        .single();
        
    return Education.fromJson(response);
  }

  Future<Education> updateEducation(Education education) async {
    if (education.id == null) {
      throw Exception('Education ID cannot be null for update');
    }

    // Filter out null values so we don't accidentally overwrite with nulls
    // unless explicitly needed. But Freezed toJson handles this mostly.
    final response = await _supabase
        .from('education')
        .update(education.toJson())
        .eq('id', education.id!)
        .select()
        .single();

    return Education.fromJson(response);
  }

  Future<void> deleteEducation(int id) async {
    await _supabase.from('education').delete().eq('id', id);
  }
}
