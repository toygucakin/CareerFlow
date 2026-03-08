import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/language.dart';
import '../../data/repositories/language_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final languageRepositoryProvider = Provider<LanguageRepository>((ref) {
  return LanguageRepository(Supabase.instance.client);
});

final languageListProvider =
    AsyncNotifierProvider<LanguageListNotifier, List<Language>>(() {
      return LanguageListNotifier();
    });

class LanguageListNotifier extends AsyncNotifier<List<Language>> {
  @override
  Future<List<Language>> build() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return [];
    final repo = ref.read(languageRepositoryProvider);
    final list = await repo.getLanguages(user.id);
    list.sort((a, b) => (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0));
    return list;
  }

  Future<void> addLanguage(Language language) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(languageRepositoryProvider);
      final newItem = await repo.createLanguage(language);
      final currentList = state.value ?? [];
      final newList = [...currentList, newItem];
      newList.sort((a, b) => (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0));
      return newList;
    });
  }

  Future<void> updateLanguage(Language language) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(languageRepositoryProvider);
      final updatedItem = await repo.updateLanguage(language);
      final currentList = state.value ?? [];
      final newList = currentList
          .map((e) => e.id == updatedItem.id ? updatedItem : e)
          .toList();
      newList.sort((a, b) => (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0));
      return newList;
    });
  }

  Future<void> deleteLanguage(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(languageRepositoryProvider);
      await repo.deleteLanguage(id);
      final currentList = state.value ?? [];
      return currentList.where((e) => e.id != id).toList();
    });
  }

  Future<void> reorderLanguages(int oldIndex, int newIndex) async {
    final currentList = state.value;
    if (currentList == null) return;

    final List<Language> newList = List.from(currentList);
    if (oldIndex < newIndex) newIndex -= 1;

    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);

    final List<Language> updatedList = [];
    for (int i = 0; i < newList.length; i++) {
      updatedList.add(newList[i].copyWith(orderIndex: i));
    }

    state = AsyncValue.data(updatedList);
    try {
      await ref
          .read(languageRepositoryProvider)
          .updateLanguageOrder(updatedList);
    } catch (e) {
      ref.invalidateSelf();
    }
  }
}
