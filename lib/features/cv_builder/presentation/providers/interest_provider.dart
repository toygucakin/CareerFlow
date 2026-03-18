import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/cv/interest.dart';
import '../../data/repositories/interest_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final interestRepositoryProvider = Provider<InterestRepository>((ref) {
  return InterestRepository(Supabase.instance.client);
});

final interestListProvider =
    AsyncNotifierProvider<InterestListNotifier, List<Interest>>(() {
  return InterestListNotifier();
});

class InterestListNotifier extends AsyncNotifier<List<Interest>> {
  @override
  Future<List<Interest>> build() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return [];
    final repo = ref.read(interestRepositoryProvider);
    final list = await repo.getInterests(user.id);
    list.sort((a, b) => (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0));
    return list;
  }

  Future<void> addInterest(Interest interest) async {
    try {
      final repo = ref.read(interestRepositoryProvider);
      final newItem = await repo.createInterest(interest);
      if (state.hasValue) {
        state = AsyncValue.data([...state.value!, newItem]);
      } else {
        ref.invalidateSelf();
      }
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  Future<void> updateInterest(Interest interest) async {
    if (!state.hasValue) return;
    
    final currentList = state.value!;
    state = AsyncValue.data(
      currentList.map((e) => e.id == interest.id ? interest : e).toList(),
    );

    try {
      final repo = ref.read(interestRepositoryProvider);
      await repo.updateInterest(interest);
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  Future<void> deleteInterest(int id) async {
    if (!state.hasValue) return;

    final currentList = state.value!;
    state = AsyncValue.data(currentList.where((e) => e.id != id).toList());

    try {
      final repo = ref.read(interestRepositoryProvider);
      await repo.deleteInterest(id);
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  Future<void> reorderInterests(int oldIndex, int newIndex) async {
    final currentList = state.value;
    if (currentList == null) return;

    final List<Interest> newList = List.from(currentList);
    if (oldIndex < newIndex) newIndex -= 1;

    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);

    final List<Interest> updatedList = [];
    for (int i = 0; i < newList.length; i++) {
      updatedList.add(newList[i].copyWith(orderIndex: i));
    }

    state = AsyncValue.data(updatedList);
    try {
      await ref.read(interestRepositoryProvider).updateInterestOrder(updatedList);
    } catch (e) {
      ref.invalidateSelf();
    }
  }
}
