import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/social_media.dart';
import '../../data/repositories/social_media_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final socialMediaRepositoryProvider = Provider<SocialMediaRepository>((ref) {
  return SocialMediaRepository(Supabase.instance.client);
});

final socialMediaListProvider =
    AsyncNotifierProvider<SocialMediaListNotifier, List<SocialMediaAccount>>(() {
  return SocialMediaListNotifier();
});

class SocialMediaListNotifier extends AsyncNotifier<List<SocialMediaAccount>> {
  @override
  Future<List<SocialMediaAccount>> build() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return [];

    final repo = ref.read(socialMediaRepositoryProvider);
    return await repo.getSocialMediaAccounts(user.id);
  }

  Future<void> addAccount(SocialMediaAccount account) async {
    final previousState = state;
    state = await AsyncValue.guard(() async {
      final repo = ref.read(socialMediaRepositoryProvider);
      final newAccount = await repo.createSocialMediaAccount(account);
      final currentList = state.value ?? [];
      return [...currentList, newAccount];
    });
    if (state.hasError) {
      state = previousState;
    }
  }

  Future<void> updateAccount(SocialMediaAccount account) async {
    final previousState = state;
    
    // Optimistic update
    if (state.hasValue) {
      final currentList = state.value!;
      state = AsyncValue.data(
        currentList.map((e) => e.id == account.id ? account : e).toList(),
      );
    }

    state = await AsyncValue.guard(() async {
      final repo = ref.read(socialMediaRepositoryProvider);
      final updatedAccount = await repo.updateSocialMediaAccount(account);

      final currentList = state.value ?? [];
      return currentList
          .map((e) => e.id == updatedAccount.id ? updatedAccount : e)
          .toList();
    });

    if (state.hasError) {
      state = previousState;
    }
  }

  Future<void> deleteAccount(int id) async {
    final previousState = state;
    
    // Optimistic delete
    if (state.hasValue) {
      final currentList = state.value!;
      state = AsyncValue.data(currentList.where((e) => e.id != id).toList());
    }

    final result = await AsyncValue.guard(() async {
      final repo = ref.read(socialMediaRepositoryProvider);
      await repo.deleteSocialMediaAccount(id);
      return state.value ?? [];
    });

    if (result.hasError) {
      state = previousState;
    }
  }
}
