class AnalyzedProject {
  final String repoFullName;
  final String title;
  final String description;
  final List<String> technologies;
  final DateTime? startDate;
  final DateTime? endDate;

  AnalyzedProject({
    required this.repoFullName,
    required this.title,
    required this.description,
    required this.technologies,
    this.startDate,
    this.endDate,
  });

  AnalyzedProject copyWith({
    String? title,
    String? description,
    List<String>? technologies,
  }) {
    return AnalyzedProject(
      repoFullName: repoFullName,
      title: title ?? this.title,
      description: description ?? this.description,
      technologies: technologies ?? this.technologies,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
