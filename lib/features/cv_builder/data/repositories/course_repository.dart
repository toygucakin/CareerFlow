import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/course.dart';

class CourseRepository {
  final SupabaseClient _supabase;

  CourseRepository(this._supabase);

  Future<List<Course>> getCourses(String profileId) async {
    final response = await _supabase
        .from('courses')
        .select()
        .eq('profile_id', profileId)
        .order('sort_order', ascending: true);

    return (response as List).map((e) => Course.fromJson(e)).toList();
  }

  Future<Course> createCourse(Course course) async {
    final data = course.toJson()..remove('id');
    final response = await _supabase
        .from('courses')
        .insert(data)
        .select()
        .single();
    return Course.fromJson(response);
  }

  Future<Course> updateCourse(Course course) async {
    if (course.id == null)
      throw Exception('Course ID cannot be null for update');
    final response = await _supabase
        .from('courses')
        .update(course.toJson())
        .eq('id', course.id!)
        .select()
        .single();
    return Course.fromJson(response);
  }

  Future<void> updateCourseOrder(List<Course> courses) async {
    final List<Map<String, dynamic>> dataToUpdate = courses
        .map((e) => e.toJson())
        .toList();
    await _supabase.from('courses').upsert(dataToUpdate);
  }

  Future<void> deleteCourse(int id) async {
    await _supabase.from('courses').delete().eq('id', id);
  }
}
