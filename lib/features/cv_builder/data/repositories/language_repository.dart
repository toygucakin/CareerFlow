import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/language.dart';

class LanguageRepository {
  final SupabaseClient _supabase;

  LanguageRepository(this._supabase);

  Future<List<Language>> getLanguages(String profileId) async {
    final response = await _supabase
        .from('languages')
        .select()
        .eq('profile_id', profileId)
        .order('sort_order', ascending: true);

    return (response as List).map((e) => Language.fromJson(e)).toList();
  }

  Future<Language> createLanguage(Language language) async {
    final data = language.toJson()..remove('id');
    final response = await _supabase
        .from('languages')
        .insert(data)
        .select()
        .single();
    return Language.fromJson(response);
  }

  Future<Language> updateLanguage(Language language) async {
    if (language.id == null) throw Exception('ID cannot be null');
    final response = await _supabase
        .from('languages')
        .update(language.toJson())
        .eq('id', language.id!)
        .select()
        .single();
    return Language.fromJson(response);
  }

  Future<void> updateLanguageOrder(List<Language> languages) async {
    final List<Map<String, dynamic>> dataToUpdate = languages
        .map((e) => e.toJson())
        .toList();
    await _supabase.from('languages').upsert(dataToUpdate);
  }

  Future<void> deleteLanguage(int id) async {
    await _supabase.from('languages').delete().eq('id', id);
  }
}
