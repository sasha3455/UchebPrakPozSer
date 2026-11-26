class MovieQuery {
  const MovieQuery({
    this.search = '',
    this.genre,
    this.studio,
    this.yearFrom,
    this.yearTo,
    this.sortField = 'title',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  final String search;
  final String? genre;
  final String? studio;
  final int? yearFrom;
  final int? yearTo;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;

  MovieQuery copyWith({
    String? search,
    Object? genre = _unset,
    Object? studio = _unset,
    Object? yearFrom = _unset,
    Object? yearTo = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
    bool resetPage = true,
  }) {
    return MovieQuery(
      search: search ?? this.search,
      genre: genre == _unset ? this.genre : genre as String?,
      studio: studio == _unset ? this.studio : studio as String?,
      yearFrom: yearFrom == _unset ? this.yearFrom : yearFrom as int?,
      yearTo: yearTo == _unset ? this.yearTo : yearTo as int?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: resetPage ? 1 : (page ?? this.page),
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }

  Uri toUri(String path) => Uri(path: path, queryParameters: _parameters());

  Map<String, String> _parameters() {
    final parameters = <String, String>{};
    if (search.trim().isNotEmpty) parameters['search'] = search.trim();
    if (genre != null) parameters['genre'] = genre!;
    if (studio != null) parameters['studio'] = studio!;
    if (yearFrom != null) parameters['yearFrom'] = '$yearFrom';
    if (yearTo != null) parameters['yearTo'] = '$yearTo';
    if (sortField != 'title' || !sortAscending) {
      parameters['sort'] = '$sortField,${sortAscending ? 'asc' : 'desc'}';
    }
    if (page != 1) parameters['page'] = '$page';
    if (size != 10) parameters['size'] = '$size';
    if (includeDeleted) parameters['deleted'] = 'true';
    return parameters;
  }

  factory MovieQuery.fromUri(Uri uri) {
    final sort = uri.queryParameters['sort']?.split(',');
    int? parseInt(String? value) => int.tryParse(value ?? '');
    return MovieQuery(
      search: uri.queryParameters['search'] ?? '',
      genre: uri.queryParameters['genre'],
      studio: uri.queryParameters['studio'],
      yearFrom: parseInt(uri.queryParameters['yearFrom']),
      yearTo: parseInt(uri.queryParameters['yearTo']),
      sortField: sort?.firstOrNull ?? 'title',
      sortAscending: sort?.elementAtOrNull(1) != 'desc',
      page: parseInt(uri.queryParameters['page']) ?? 1,
      size: [10, 25, 50].contains(parseInt(uri.queryParameters['size']))
          ? parseInt(uri.queryParameters['size'])!
          : 10,
      includeDeleted: uri.queryParameters['deleted'] == 'true',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MovieQuery &&
      search == other.search &&
      genre == other.genre &&
      studio == other.studio &&
      yearFrom == other.yearFrom &&
      yearTo == other.yearTo &&
      sortField == other.sortField &&
      sortAscending == other.sortAscending &&
      page == other.page &&
      size == other.size &&
      includeDeleted == other.includeDeleted;

  @override
  int get hashCode => Object.hash(
    search,
    genre,
    studio,
    yearFrom,
    yearTo,
    sortField,
    sortAscending,
    page,
    size,
    includeDeleted,
  );

  static const _unset = Object();
}

extension on List<String> {
  String? get firstOrNull => isEmpty ? null : first;
  String? elementAtOrNull(int index) =>
      index < length ? elementAt(index) : null;
}
