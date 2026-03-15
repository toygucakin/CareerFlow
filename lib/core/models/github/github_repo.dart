class GithubRepo {
  final String name;
  final String fullName;
  final String? description;
  final String? language;
  final int stargazersCount;
  final bool fork;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String htmlUrl;
  final bool isPrivate;

  GithubRepo({
    required this.name,
    required this.fullName,
    this.description,
    this.language,
    required this.stargazersCount,
    required this.fork,
    required this.createdAt,
    required this.updatedAt,
    required this.htmlUrl,
    required this.isPrivate,
  });

  factory GithubRepo.fromJson(Map<String, dynamic> json) {
    return GithubRepo(
      name: json['name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      description: json['description'] as String?,
      language: json['language'] as String?,
      stargazersCount: json['stargazers_count'] as int? ?? 0,
      fork: json['fork'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      htmlUrl: json['html_url'] as String? ?? '',
      isPrivate: json['private'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'full_name': fullName,
      'description': description,
      'language': language,
      'stargazers_count': stargazersCount,
      'fork': fork,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'html_url': htmlUrl,
      'private': isPrivate,
    };
  }
}
