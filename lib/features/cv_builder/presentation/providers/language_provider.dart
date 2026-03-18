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
    try {
      final repo = ref.read(languageRepositoryProvider);
      final newItem = await repo.createLanguage(language);
      if (state.hasValue) {
        final newList = [...state.value!, newItem];
        newList.sort((a, b) => (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0));
        state = AsyncValue.data(newList);
      } else {
        ref.invalidateSelf();
      }
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  Future<void> updateLanguage(Language language) async {
    if (!state.hasValue) return;
    
    // Optimistic update
    final currentList = state.value!;
    state = AsyncValue.data(
      currentList.map((e) => e.id == language.id ? language : e).toList(),
    );

    try {
      final repo = ref.read(languageRepositoryProvider);
      await repo.updateLanguage(language);
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  Future<void> deleteLanguage(int id) async {
    if (!state.hasValue) return;
    
    // Optimistic delete
    final currentList = state.value!;
    state = AsyncValue.data(currentList.where((e) => e.id != id).toList());

    try {
      final repo = ref.read(languageRepositoryProvider);
      await repo.deleteLanguage(id);
    } catch (e) {
      ref.invalidateSelf();
    }
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
