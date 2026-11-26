import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../state/movie_list_notifier.dart';
import 'movie_list_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({required this.id, super.key});

  final int id;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Movie? _movie;
  bool _loading = true;
  bool _saving = false;
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _year = TextEditingController();
  final _duration = TextEditingController();
  final _rating = TextEditingController();
  final _description = TextEditingController();
  final _directorIds = TextEditingController();
  String _genre = movieGenres.first;
  String _studio = movieStudios.first;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final movie = widget.id == 0
        ? null
        : await context.read<MovieListNotifier>().findById(widget.id);
    if (!mounted) return;
    if (movie != null) {
      _movie = movie;
      _title.text = movie.title;
      _year.text = '${movie.year}';
      _duration.text = '${movie.durationMinutes}';
      _rating.text = '${movie.rating}';
      _description.text = movie.description;
      _directorIds.text = movie.directorIds.join(', ');
      _genre = movie.genre;
      _studio = movie.studio;
    } else if (widget.id == 0) {
      _year.text = '2024';
      _duration.text = '120';
      _rating.text = '7.0';
      _description.text = 'Описание фильма';
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final movie = Movie(
      id: _movie?.id ?? 0,
      title: _title.text.trim(),
      year: int.parse(_year.text),
      durationMinutes: int.parse(_duration.text),
      genre: _genre,
      studio: _studio,
      directorIds: _directorIds.text
          .split(',')
          .map((value) => int.tryParse(value.trim()))
          .whereType<int>()
          .toList(),
      rating: double.parse(_rating.text.replaceAll(',', '.')),
      description: _description.text.trim(),
      deletedAt: _movie?.deletedAt,
    );
    await context.read<MovieListNotifier>().save(movie);
    if (mounted) context.go('/movies');
  }

  Future<void> _hardDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить фильм навсегда?'),
        content: Text(
          '«${_movie?.title}» будет удалён без возможности восстановления.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<MovieListNotifier>().hardDelete(_movie!.id);
      if (mounted) context.go('/movies');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == 0 ? 'Новый фильм' : 'Карточка фильма'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_movie != null) _MovieSummary(movie: _movie!),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Название'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Введите название'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) => Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: constraints.maxWidth < 520
                              ? constraints.maxWidth
                              : 180,
                          child: TextFormField(
                            controller: _year,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Год'),
                            validator: _numberValidator,
                          ),
                        ),
                        SizedBox(
                          width: constraints.maxWidth < 520
                              ? constraints.maxWidth
                              : 180,
                          child: TextFormField(
                            controller: _duration,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Длительность, мин.',
                            ),
                            validator: _numberValidator,
                          ),
                        ),
                        SizedBox(
                          width: constraints.maxWidth < 520
                              ? constraints.maxWidth
                              : 180,
                          child: TextFormField(
                            controller: _rating,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Рейтинг',
                            ),
                            validator: (value) =>
                                double.tryParse(
                                      (value ?? '').replaceAll(',', '.'),
                                    ) ==
                                    null
                                ? 'Введите число'
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) => Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: constraints.maxWidth < 520
                              ? constraints.maxWidth
                              : 280,
                          child: DropdownButtonFormField<String>(
                            initialValue: _genre,
                            decoration: const InputDecoration(
                              labelText: 'Жанр',
                            ),
                            items: movieGenres
                                .map(
                                  (genre) => DropdownMenuItem(
                                    value: genre,
                                    child: Text(genre),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _genre = value ?? _genre),
                          ),
                        ),
                        SizedBox(
                          width: constraints.maxWidth < 520
                              ? constraints.maxWidth
                              : 280,
                          child: DropdownButtonFormField<String>(
                            initialValue: _studio,
                            decoration: const InputDecoration(
                              labelText: 'Студия',
                            ),
                            items: movieStudios
                                .map(
                                  (studio) => DropdownMenuItem(
                                    value: studio,
                                    child: Text(studio),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _studio = value ?? _studio),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _directorIds,
                    decoration: const InputDecoration(
                      labelText: 'ID режиссёров',
                      hintText: 'Например: 1, 2',
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _description,
                    minLines: 3,
                    maxLines: 6,
                    decoration: const InputDecoration(labelText: 'Описание'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Добавьте описание'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(_saving ? 'Сохранение…' : 'Сохранить'),
                  ),
                  if (_movie != null) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _hardDelete,
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Удалить навсегда'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _numberValidator(String? value) =>
      int.tryParse(value ?? '') == null ? 'Введите целое число' : null;

  @override
  void dispose() {
    _title.dispose();
    _year.dispose();
    _duration.dispose();
    _rating.dispose();
    _description.dispose();
    _directorIds.dispose();
    super.dispose();
  }
}

class _MovieSummary extends StatelessWidget {
  const _MovieSummary({required this.movie});
  final Movie movie;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.primaryContainer,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(radius: 28, child: Text(movie.title.substring(0, 1))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${movie.year} · ${movie.genre} · рейтинг ${movie.rating.toStringAsFixed(1)}',
                ),
              ],
            ),
          ),
          if (movie.isDeleted) const Chip(label: Text('Удалён')),
        ],
      ),
    ),
  );
}
