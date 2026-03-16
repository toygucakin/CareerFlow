import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/project.dart';

class ProjectRepository {
  final SupabaseClient _supabase;

  ProjectRepository(this._supabase);

  Future<List<Project>> getProjects(String profileId) async {
    final response = await _supabase
        .from('projects')
        .select()
        .eq('profile_id', profileId)
        .order('sort_order', ascending: true);

    return (response as List).map((e) => Project.fromJson(e)).toList();
  }

  Future<Project> createProject(Project project) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

    final data = project.toJson()..remove('id');
    data['profile_id'] = user.id;

    final response = await _supabase
        .from('projects')
        .insert(data)
        .select()
        .single();
    return Project.fromJson(response);
  }

  Future<Project> updateProject(Project project) async {
    if (project.id == null) throw Exception('ID cannot be null');
    final response = await _supabase
        .from('projects')
        .update(project.toJson())
        .eq('id', project.id!)
        .select()
        .single();
    return Project.fromJson(response);
  }

  Future<void> updateProjectOrder(List<Project> projects) async {
    final List<Map<String, dynamic>> dataToUpdate = projects
        .map((e) => e.toJson())
        .toList();
    await _supabase.from('projects').upsert(dataToUpdate);
  }

  Future<void> deleteProject(int id) async {
    await _supabase.from('projects').delete().eq('id', id);
  }
}
