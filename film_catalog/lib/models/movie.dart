class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.durationMinutes,
    required this.genre,
    required this.studio,
    required this.directorIds,
    required this.rating,
    required this.description,
    this.deletedAt,
  });

  final int id;
  final String title;
  final int year;
  final int durationMinutes;
  final String genre;
  final String studio;
  final List<int> directorIds;
  final double rating;
  final String description;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  Movie copyWith({
    String? title,
    int? year,
    int? durationMinutes,
    String? genre,
    String? studio,
    List<int>? directorIds,
    double? rating,
    String? description,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Movie(
      id: id,
      title: title ?? this.title,
      year: year ?? this.year,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      genre: genre ?? this.genre,
      studio: studio ?? this.studio,
      directorIds: directorIds ?? this.directorIds,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
