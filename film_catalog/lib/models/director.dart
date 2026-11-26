class Director {
  const Director({
    required this.id,
    required this.name,
    required this.country,
    required this.birthYear,
    required this.bio,
    this.deletedAt,
  });

  final int id;
  final String name;
  final String country;
  final int birthYear;
  final String bio;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  Director copyWith({
    String? name,
    String? country,
    int? birthYear,
    String? bio,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Director(
      id: id,
      name: name ?? this.name,
      country: country ?? this.country,
      birthYear: birthYear ?? this.birthYear,
      bio: bio ?? this.bio,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
