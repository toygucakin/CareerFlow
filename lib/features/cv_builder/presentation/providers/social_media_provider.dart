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
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(socialMediaRepositoryProvider);
      final newAccount = await repo.createSocialMediaAccount(account);
      final currentList = state.value ?? [];
      return [...currentList, newAccount];
    });
  }

  Future<void> updateAccount(SocialMediaAccount account) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(socialMediaRepositoryProvider);
      final updatedAccount = await repo.updateSocialMediaAccount(account);

      final currentList = state.value ?? [];
      return currentList
          .map((e) => e.id == updatedAccount.id ? updatedAccount : e)
          .toList();
    });
  }

  Future<void> deleteAccount(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(socialMediaRepositoryProvider);
      await repo.deleteSocialMediaAccount(id);

      final currentList = state.value ?? [];
      return currentList.where((e) => e.id != id).toList();
    });
  }
}
