import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/breakpoints.dart';
import '../models/movie.dart';
import '../models/movie_query.dart';
import '../state/load_status.dart';
import '../state/movie_list_notifier.dart';
import '../widgets/entity_table.dart';
import '../widgets/load_state_view.dart';
import '../widgets/pagination_bar.dart';

const movieGenres = [
  'Боевик',
  'Военный',
  'Вестерн',
  'Драма',
  'Исторический',
  'Комедия',
  'Криминал',
  'Мелодрама',
  'Приключения',
  'Спорт',
  'Триллер',
  'Фантастика',
  'Фэнтези',
];
const movieStudios = [
  '20th Century Fox',
  'Columbia Pictures',
  'DreamWorks',
  'Focus Features',
  'Fox Searchlight',
  'Miramax',
  'New Line Cinema',
  'Paramount Pictures',
  'Sony Pictures',
  'The Weinstein Company',
  'TriStar Pictures',
  'Universal Pictures',
  'Warner Bros.',
];

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({required this.uri, super.key});

  final Uri uri;

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final _searchController = TextEditingController();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  Timer? _debounce;
  bool _showFilters = false;
  bool _settingControllers = false;
  String? _genre;
  String? _studio;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncQuery(widget.uri));
  }

  @override
  void didUpdateWidget(covariant MovieListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uri.toString() != widget.uri.toString()) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _syncQuery(widget.uri),
      );
    }
  }

  void _syncQuery(Uri uri) {
    if (!mounted) return;
    final query = MovieQuery.fromUri(uri);
    final notifier = context.read<MovieListNotifier>();
    _settingControllers = true;
    _searchController.text = query.search;
    _fromController.text = query.yearFrom?.toString() ?? '';
    _toController.text = query.yearTo?.toString() ?? '';
    _genre = query.genre;
    _studio = query.studio;
    _settingControllers = false;
    if (notifier.query != query) unawaited(notifier.applyQuery(query));
  }

  void _onSearchChanged() {
    if (_settingControllers) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final notifier = context.read<MovieListNotifier>();
      _go(notifier.query.copyWith(search: _searchController.text));
    });
  }

  void _go(MovieQuery query) => context.go(query.toUri('/movies').toString());

  void _applyFilters() {
    final notifier = context.read<MovieListNotifier>();
    _go(
      notifier.query.copyWith(
        genre: _genre,
        studio: _studio,
        yearFrom: int.tryParse(_fromController.text),
        yearTo: int.tryParse(_toController.text),
      ),
    );
  }

  void _sort(String field) {
    final current = context.read<MovieListNotifier>().query;
    _go(
      current.copyWith(
        sortField: field,
        sortAscending: field == current.sortField
            ? !current.sortAscending
            : true,
      ),
    );
  }

  void _reset() => _go(const MovieQuery());

  Future<void> _confirmDelete(Movie movie, {bool hard = false}) async {
    final notifier = context.read<MovieListNotifier>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          hard
              ? 'Удалить навсегда?'
              : (movie.isDeleted ? 'Восстановить фильм?' : 'Скрыть фильм?'),
        ),
        content: Text(
          hard
              ? '«${movie.title}» будет удалён без возможности восстановления.'
              : movie.isDeleted
              ? 'Фильм снова появится в каталоге.'
              : 'Фильм получит deletedAt и исчезнет из обычной выборки.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              hard
                  ? 'Удалить'
                  : movie.isDeleted
                  ? 'Восстановить'
                  : 'Скрыть',
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    if (hard) {
      await notifier.hardDelete(movie.id);
    } else if (movie.isDeleted) {
      await notifier.restore(movie.id);
    } else {
      await notifier.softDelete(movie.id);
    }
  }

  Future<void> _deleteSelected() async {
    final notifier = context.read<MovieListNotifier>();
    final count = notifier.selected.length;
    if (count == 0) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Скрыть выбранные фильмы?'),
        content: Text('Будет скрыто записей: $count.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Скрыть'),
          ),
        ],
      ),
    );
    if (confirmed == true) await notifier.deleteSelected();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Каталог фильмов'),
      actions: [
        IconButton(
          tooltip: 'О проекте',
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.info_outline),
        ),
        IconButton(
          tooltip: 'Добавить фильм',
          onPressed: () => context.go('/movies/0'),
          icon: const Icon(Icons.add),
        ),
      ],
    ),
    body: Consumer<MovieListNotifier>(
      builder: (context, notifier, _) => Column(
        children: [
          _buildToolbar(context, notifier),
          Expanded(child: _buildContent(context, notifier)),
          if (notifier.status == LoadStatus.success)
            PaginationBar<Movie>(
              result: notifier.result,
              onPage: (page) =>
                  _go(notifier.query.copyWith(page: page, resetPage: false)),
              onSize: (size) => _go(notifier.query.copyWith(size: size)),
            ),
        ],
      ),
    ),
  );

  Widget _buildToolbar(
    BuildContext context,
    MovieListNotifier notifier,
  ) => Material(
    color: Theme.of(context).colorScheme.surface,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Поиск по названию, студии или описанию',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                tooltip: 'Фильтры',
                onPressed: () => setState(() => _showFilters = !_showFilters),
                icon: Icon(
                  _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                ),
              ),
            ],
          ),
          if (_showFilters) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 190,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(_genre),
                    initialValue: _genre,
                    decoration: const InputDecoration(
                      labelText: 'Жанр',
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Все жанры'),
                      ),
                      ...movieGenres.map(
                        (g) => DropdownMenuItem(value: g, child: Text(g)),
                      ),
                    ],
                    onChanged: (value) => setState(() => _genre = value),
                  ),
                ),
                SizedBox(
                  width: 210,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(_studio),
                    initialValue: _studio,
                    decoration: const InputDecoration(
                      labelText: 'Студия',
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Все студии'),
                      ),
                      ...movieStudios.map(
                        (s) => DropdownMenuItem(value: s, child: Text(s)),
                      ),
                    ],
                    onChanged: (value) => setState(() => _studio = value),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: _fromController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Год от',
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: _toController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Год до',
                      isDense: true,
                    ),
                  ),
                ),
                FilledButton.tonal(
                  onPressed: _applyFilters,
                  child: const Text('Применить'),
                ),
                TextButton(onPressed: _reset, child: const Text('Сбросить')),
                FilterChip(
                  label: const Text('Показать удалённые'),
                  selected: notifier.query.includeDeleted,
                  onSelected: (value) =>
                      _go(notifier.query.copyWith(includeDeleted: value)),
                ),
              ],
            ),
          ],
          if (notifier.hasSelection) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Выбрано: ${notifier.selected.length}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _deleteSelected,
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Скрыть выбранные'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: notifier.clearSelection,
                  child: const Text('Снять выделение'),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );

  Widget _buildContent(BuildContext context, MovieListNotifier notifier) =>
      LoadStateView(
        status: notifier.status,
        error: notifier.error,
        onRetry: notifier.load,
        emptyLabel: 'Фильмы не найдены',
        child: notifier.result.items.isEmpty
            ? LoadStateView.empty(context, 'Фильмы не найдены', _reset)
            : screenSizeOf(context) == ScreenSize.compact
            ? EntityCardList<Movie>(
                items: notifier.result.items,
                builder: _buildMovieCard,
              )
            : EntityTable<Movie>(
                items: notifier.result.items,
                idOf: (movie) => movie.id,
                selected: notifier.selected,
                onToggleSelect: notifier.toggleSelection,
                sortField: notifier.query.sortField,
                sortAscending: notifier.query.sortAscending,
                onSort: _sort,
                columns: [
                  TableColumnSpec(
                    label: 'Название',
                    sortField: 'title',
                    build: (movie) => Text(
                      movie.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  TableColumnSpec(
                    label: 'Год',
                    sortField: 'year',
                    numeric: true,
                    build: (movie) => Text('${movie.year}'),
                  ),
                  TableColumnSpec(
                    label: 'Жанр',
                    build: (movie) => Text(movie.genre),
                  ),
                  TableColumnSpec(
                    label: 'Студия',
                    sortField: 'studio',
                    build: (movie) => Text(movie.studio),
                  ),
                  TableColumnSpec(
                    label: 'Рейтинг',
                    sortField: 'rating',
                    numeric: true,
                    build: (movie) => Text(movie.rating.toStringAsFixed(1)),
                  ),
                ],
                actions: (movie) => _movieActions(context, movie),
              ),
      );

  List<Widget> _movieActions(BuildContext context, Movie movie) => [
    IconButton(
      tooltip: 'Открыть карточку',
      onPressed: () => context.go('/movies/${movie.id}'),
      icon: const Icon(Icons.open_in_new),
    ),
    IconButton(
      tooltip: movie.isDeleted ? 'Восстановить' : 'Скрыть',
      onPressed: () => _confirmDelete(movie),
      icon: Icon(movie.isDeleted ? Icons.restore : Icons.delete_outline),
    ),
  ];

  Widget _buildMovieCard(BuildContext context, Movie movie) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: context.read<MovieListNotifier>().selected.contains(
                  movie.id,
                ),
                onChanged: (_) =>
                    context.read<MovieListNotifier>().toggleSelection(movie.id),
              ),
              Expanded(
                child: Text(
                  movie.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => context.go('/movies/${movie.id}'),
                icon: const Icon(Icons.open_in_new),
              ),
            ],
          ),
          const Divider(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('${movie.year}')),
              Chip(label: Text(movie.genre)),
              Chip(label: Text(movie.studio)),
              Chip(
                avatar: const Icon(Icons.star, size: 16),
                label: Text(movie.rating.toStringAsFixed(1)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(movie.description, maxLines: 2, overflow: TextOverflow.ellipsis),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _confirmDelete(movie),
              icon: Icon(
                movie.isDeleted ? Icons.restore : Icons.delete_outline,
              ),
              label: Text(movie.isDeleted ? 'Восстановить' : 'Скрыть'),
            ),
          ),
        ],
      ),
    ),
  );

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }
}
