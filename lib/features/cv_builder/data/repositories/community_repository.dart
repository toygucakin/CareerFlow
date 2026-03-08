import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/community.dart';

class CommunityRepository {
  final SupabaseClient _supabase;

  CommunityRepository(this._supabase);

  Future<List<Community>> getCommunities(String profileId) async {
    final response = await _supabase
        .from('communities')
        .select()
        .eq('profile_id', profileId)
        .order('sort_order', ascending: true);

    return (response as List).map((e) => Community.fromJson(e)).toList();
  }

  Future<Community> createCommunity(Community community) async {
    final data = community.toJson()..remove('id');
    final response = await _supabase
        .from('communities')
        .insert(data)
        .select()
        .single();
    return Community.fromJson(response);
  }

  Future<Community> updateCommunity(Community community) async {
    if (community.id == null) throw Exception('ID cannot be null');
    final response = await _supabase
        .from('communities')
        .update(community.toJson())
        .eq('id', community.id!)
        .select()
        .single();
    return Community.fromJson(response);
  }

  Future<void> updateCommunityOrder(List<Community> communities) async {
    final List<Map<String, dynamic>> dataToUpdate = communities
        .map((e) => e.toJson())
        .toList();
    await _supabase.from('communities').upsert(dataToUpdate);
  }

  Future<void> deleteCommunity(int id) async {
    await _supabase.from('communities').delete().eq('id', id);
  }
}
