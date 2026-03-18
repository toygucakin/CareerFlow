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

  Future<void> fetchInterests({bool showLoading = true}) async {
    try {
      if (showLoading) {
        state = const AsyncValue.loading();
      }
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
      await fetchInterests(showLoading: false);
    } catch (e) {
      await fetchInterests(showLoading: false);
    }
  }

  Future<void> updateInterest(Interest interest) async {
    if (!state.hasValue) return;
    
    // Optimistic update
    final currentList = state.value!;
    state = AsyncValue.data(
      currentList.map((i) => i.id == interest.id ? interest : i).toList(),
    );

    try {
      if (interest.id == null) throw Exception('Interest ID is null');
      await _supabase
          .from('interests')
          .update(interest.toJson())
          .eq('id', interest.id!);
    } catch (e) {
      await fetchInterests(showLoading: false);
    }
  }

  Future<void> deleteInterest(int id) async {
    if (!state.hasValue) return;

    // Optimistic delete
    final currentList = state.value!;
    state = AsyncValue.data(currentList.where((i) => i.id != id).toList());

    try {
      await _supabase.from('interests').delete().eq('id', id);
    } catch (e) {
      await fetchInterests(showLoading: false);
    }
  }
}
