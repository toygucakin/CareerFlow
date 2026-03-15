import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/cv/interest.dart';

final interestListProvider = StateNotifierProvider<InterestListNotifier, AsyncValue<List<Interest>>>((ref) {
  return InterestListNotifier();
});

class InterestListNotifier extends StateNotifier<AsyncValue<List<Interest>>> {
  InterestListNotifier() : super(const AsyncValue.loading()) {
    fetchInterests();
  }

  final _supabase = Supabase.instance.client;

  Future<void> fetchInterests() async {
    try {
      state = const AsyncValue.loading();
      final user = _supabase.auth.currentUser;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final response = await _supabase
          .from('interests')
          .select()
          .eq('profile_id', user.id)
          .order('sort_order', ascending: true);

      final interests = (response as List)
          .map((json) => Interest.fromJson(json))
          .toList();
          
      state = AsyncValue.data(interests);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addInterest(Interest interest) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final data = interest.toJson();
      data['profile_id'] = user.id;

      await _supabase.from('interests').insert(data);
      await fetchInterests(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateInterest(Interest interest) async {
    try {
      if (interest.id == null) throw Exception('Interest ID is null');
      
      await _supabase
          .from('interests')
          .update(interest.toJson())
          .eq('id', interest.id!);
          
      await fetchInterests(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteInterest(int id) async {
    try {
      await _supabase.from('interests').delete().eq('id', id);
      await fetchInterests(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }
}
