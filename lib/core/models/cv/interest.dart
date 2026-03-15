class Interest {
  final int? id;
  final String name;

  Interest({
    this.id,
    required this.name,
  });

  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
    };
  }

  Interest copyWith({
    int? id,
    String? name,
  }) {
    return Interest(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
