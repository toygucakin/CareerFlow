import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/education.dart';
import '../../data/repositories/education_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final educationRepositoryProvider = Provider<EducationRepository>((ref) {
  return EducationRepository(Supabase.instance.client);
});

final educationListProvider = AsyncNotifierProvider<EducationListNotifier, List<Education>>(() {
  return EducationListNotifier();
});

class EducationListNotifier extends AsyncNotifier<List<Education>> {
  @override
  Future<List<Education>> build() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return [];
    
    final repo = ref.read(educationRepositoryProvider);
    return repo.getEducations(user.id);
  }

  Future<void> addEducation(Education education) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(educationRepositoryProvider);
      final newEdu = await repo.createEducation(education);
      final currentList = state.value ?? [];
      return [...currentList, newEdu]..sort((a, b) => (b.startDate ?? DateTime.now()).compareTo(a.startDate ?? DateTime.now()));
    });
  }

  Future<void> updateEducation(Education education) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(educationRepositoryProvider);
      final updatedEdu = await repo.updateEducation(education);
      
      final currentList = state.value ?? [];
      return currentList.map((e) => e.id == updatedEdu.id ? updatedEdu : e).toList()
        ..sort((a, b) => (b.startDate ?? DateTime.now()).compareTo(a.startDate ?? DateTime.now()));
    });
  }

  Future<void> deleteEducation(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(educationRepositoryProvider);
      await repo.deleteEducation(id);
      
      final currentList = state.value ?? [];
      return currentList.where((e) => e.id != id).toList();
    });
  }
}
