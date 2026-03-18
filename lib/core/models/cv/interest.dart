class Interest {
  final int? id;
  final String name;
  final int? orderIndex;

  Interest({
    this.id,
    required this.name,
    this.orderIndex,
  });

  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      orderIndex: json['sort_order'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (orderIndex != null) 'sort_order': orderIndex,
    };
  }

  Interest copyWith({
    int? id,
    String? name,
    int? orderIndex,
  }) {
    return Interest(
      id: id ?? this.id,
      name: name ?? this.name,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}
