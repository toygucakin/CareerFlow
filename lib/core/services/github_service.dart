import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/github/github_repo.dart';

class GithubService {
  final Dio _dio;
  final String? _accessToken;

  GithubService(this._accessToken)
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://api.github.com',
          headers: {
            'Accept': 'application/vnd.github.v3+json',
            if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
          },
        ));

  Future<List<GithubRepo>> fetchUserRepos() async {
    try {
      final response = await _dio.get('/user/repos', queryParameters: {
        'sort': 'updated',
        'per_page': 100,
      });

      final List<dynamic> data = response.data;
      return data.map((json) => GithubRepo.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, int>> fetchRepoLanguages(String fullName) async {
    try {
      final response = await _dio.get('/repos/$fullName/languages');
      return Map<String, int>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String?> fetchRepoReadme(String fullName) async {
    try {
      final response = await _dio.get('/repos/$fullName/readme');
      final content = response.data['content'] as String;
      // GitHub base64 kodlanmış ve satır sonu karakterleri içeren bir string döner
      final cleanContent = content.replaceAll('\n', '');
      return utf8.decode(base64.decode(cleanContent));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // README yoksa hata fırlatma, null dön
      }
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response?.statusCode == 401) {
      return Exception('GitHub yetkisi geçersiz veya süresi dolmuş.');
    }
    return Exception('GitHub hatası: ${e.message}');
  }
}
