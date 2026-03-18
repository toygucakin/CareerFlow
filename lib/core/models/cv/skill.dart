class Skill {
  final int? id;
  final String category; // 'Programming', 'Web', 'Databases', 'Tools', 'Office', 'Soft Skills'
  final String name;
  final bool isActiveDevelopment;
  final int? orderIndex;

  Skill({
    this.id,
    required this.category,
    required this.name,
    this.isActiveDevelopment = false,
    this.orderIndex,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as int?,
      category: json['category'] as String? ?? '',
      name: json['name'] as String? ?? '',
      isActiveDevelopment: json['is_active_development'] as bool? ?? false,
      orderIndex: json['sort_order'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'category': category,
      'name': name,
      'is_active_development': isActiveDevelopment,
      if (orderIndex != null) 'sort_order': orderIndex,
    };
  }

  Skill copyWith({
    int? id,
    String? category,
    String? name,
    bool? isActiveDevelopment,
    int? orderIndex,
  }) {
    return Skill(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      isActiveDevelopment: isActiveDevelopment ?? this.isActiveDevelopment,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}
