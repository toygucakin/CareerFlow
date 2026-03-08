import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/community.dart';
import '../../data/repositories/community_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository(Supabase.instance.client);
});

final communityListProvider =
    AsyncNotifierProvider<CommunityListNotifier, List<Community>>(() {
      return CommunityListNotifier();
    });

class CommunityListNotifier extends AsyncNotifier<List<Community>> {
  @override
  Future<List<Community>> build() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return [];
    final repo = ref.read(communityRepositoryProvider);
    final list = await repo.getCommunities(user.id);
    list.sort((a, b) => (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0));
    return list;
  }

  Future<void> addCommunity(Community community) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(communityRepositoryProvider);
      final newItem = await repo.createCommunity(community);
      final currentList = state.value ?? [];
      final newList = [...currentList, newItem];
      newList.sort((a, b) => (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0));
      return newList;
    });
  }

  Future<void> updateCommunity(Community community) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(communityRepositoryProvider);
      final updatedItem = await repo.updateCommunity(community);
      final currentList = state.value ?? [];
      final newList = currentList
          .map((e) => e.id == updatedItem.id ? updatedItem : e)
          .toList();
      newList.sort((a, b) => (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0));
      return newList;
    });
  }

  Future<void> deleteCommunity(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(communityRepositoryProvider);
      await repo.deleteCommunity(id);
      final currentList = state.value ?? [];
      return currentList.where((e) => e.id != id).toList();
    });
  }

  Future<void> reorderCommunities(int oldIndex, int newIndex) async {
    final currentList = state.value;
    if (currentList == null) return;

    final List<Community> newList = List.from(currentList);
    if (oldIndex < newIndex) newIndex -= 1;

    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);

    final List<Community> updatedList = [];
    for (int i = 0; i < newList.length; i++) {
      updatedList.add(newList[i].copyWith(orderIndex: i));
    }

    state = AsyncValue.data(updatedList);
    try {
      await ref
          .read(communityRepositoryProvider)
          .updateCommunityOrder(updatedList);
    } catch (e) {
      ref.invalidateSelf();
    }
  }
}
