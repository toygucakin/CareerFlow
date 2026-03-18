import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/cv/interest.dart';

class InterestRepository {
  final SupabaseClient _supabase;

  InterestRepository(this._supabase);

  Future<List<Interest>> getInterests(String profileId) async {
    final response = await _supabase
        .from('interests')
        .select()
        .eq('profile_id', profileId)
        .order('sort_order', ascending: true);

    return (response as List).map((e) => Interest.fromJson(e)).toList();
  }

  Future<Interest> createInterest(Interest interest) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

    final data = interest.toJson()..remove('id');
    data['profile_id'] = user.id;

    final response = await _supabase
        .from('interests')
        .insert(data)
        .select()
        .single();
    return Interest.fromJson(response);
  }

  Future<Interest> updateInterest(Interest interest) async {
    if (interest.id == null) throw Exception('ID cannot be null');
    final response = await _supabase
        .from('interests')
        .update(interest.toJson())
        .eq('id', interest.id!)
        .select()
        .single();
    return Interest.fromJson(response);
  }

  Future<void> deleteInterest(int id) async {
    await _supabase.from('interests').delete().eq('id', id);
  }

  Future<void> updateInterestOrder(List<Interest> interests) async {
    final List<Map<String, dynamic>> dataToUpdate = interests
        .map((e) => e.toJson())
        .toList();
    await _supabase.from('interests').upsert(dataToUpdate);
  }
}
