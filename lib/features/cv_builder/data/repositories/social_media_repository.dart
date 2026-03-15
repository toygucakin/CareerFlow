import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/social_media.dart';

class SocialMediaRepository {
  final SupabaseClient _supabase;

  SocialMediaRepository(this._supabase);

  Future<List<SocialMediaAccount>> getSocialMediaAccounts(String profileId) async {
    final response = await _supabase
        .from('social_media')
        .select()
        .eq('profile_id', profileId);

    return (response as List).map((e) => SocialMediaAccount.fromJson(e)).toList();
  }

  Future<SocialMediaAccount> createSocialMediaAccount(SocialMediaAccount account) async {
    final data = account.toJson()..remove('id');

    final response = await _supabase
        .from('social_media')
        .insert(data)
        .select()
        .single();

    return SocialMediaAccount.fromJson(response);
  }

  Future<SocialMediaAccount> updateSocialMediaAccount(SocialMediaAccount account) async {
    if (account.id == null) {
      throw Exception('Account ID cannot be null for update');
    }

    final response = await _supabase
        .from('social_media')
        .update(account.toJson())
        .eq('id', account.id!)
        .select()
        .single();

    return SocialMediaAccount.fromJson(response);
  }

  Future<void> deleteSocialMediaAccount(int id) async {
    await _supabase.from('social_media').delete().eq('id', id);
  }
}
