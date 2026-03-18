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
    ref.keepAlive();
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return [];

    final repo = ref.read(socialMediaRepositoryProvider);
    return await repo.getSocialMediaAccounts(user.id);
  }

  Future<void> addAccount(SocialMediaAccount account) async {
    try {
      final repo = ref.read(socialMediaRepositoryProvider);
      final newAccount = await repo.createSocialMediaAccount(account);
      if (state.hasValue) {
        state = AsyncValue.data([...state.value!, newAccount]);
      } else {
        ref.invalidateSelf();
      }
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  Future<void> updateAccount(SocialMediaAccount account) async {
    if (!state.hasValue) return;
    
    // Optimistic update
    final currentList = state.value!;
    state = AsyncValue.data(
      currentList.map((e) => e.id == account.id ? account : e).toList(),
    );

    try {
      final repo = ref.read(socialMediaRepositoryProvider);
      await repo.updateSocialMediaAccount(account);
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  Future<void> deleteAccount(int id) async {
    if (!state.hasValue) return;
    
    // Optimistic delete
    final currentList = state.value!;
    state = AsyncValue.data(currentList.where((e) => e.id != id).toList());

    try {
      final repo = ref.read(socialMediaRepositoryProvider);
      await repo.deleteSocialMediaAccount(id);
    } catch (e) {
      ref.invalidateSelf();
    }
  }
}
