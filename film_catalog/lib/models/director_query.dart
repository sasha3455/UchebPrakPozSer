class DirectorQuery {
  const DirectorQuery({
    this.search = '',
    this.country,
    this.sortField = 'name',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  final String search;
  final String? country;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;

  DirectorQuery copyWith({
    String? search,
    Object? country = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
    bool resetPage = true,
  }) {
    return DirectorQuery(
      search: search ?? this.search,
      country: country == _unset ? this.country : country as String?,
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
    if (country != null) parameters['country'] = country!;
    if (sortField != 'name' || !sortAscending) {
      parameters['sort'] = '$sortField,${sortAscending ? 'asc' : 'desc'}';
    }
    if (page != 1) parameters['page'] = '$page';
    if (size != 10) parameters['size'] = '$size';
    if (includeDeleted) parameters['deleted'] = 'true';
    return parameters;
  }

  factory DirectorQuery.fromUri(Uri uri) {
    final sort = uri.queryParameters['sort']?.split(',');
    int? parseInt(String? value) => int.tryParse(value ?? '');
    return DirectorQuery(
      search: uri.queryParameters['search'] ?? '',
      country: uri.queryParameters['country'],
      sortField: sort?.firstOrNull ?? 'name',
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
      other is DirectorQuery &&
      search == other.search &&
      country == other.country &&
      sortField == other.sortField &&
      sortAscending == other.sortAscending &&
      page == other.page &&
      size == other.size &&
      includeDeleted == other.includeDeleted;

  @override
  int get hashCode => Object.hash(
    search,
    country,
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
