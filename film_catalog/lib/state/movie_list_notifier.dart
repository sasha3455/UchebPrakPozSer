import 'package:flutter/foundation.dart';

import '../models/movie.dart';
import '../models/movie_query.dart';
import '../models/page_result.dart';
import '../repositories/movie_repository.dart';
import 'load_status.dart';

class MovieListNotifier extends ChangeNotifier {
  MovieListNotifier(this._repository);

  final MovieRepository _repository;
  MovieQuery _query = const MovieQuery();
  PageResult<Movie> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = {};
  bool _disposed = false;

  MovieQuery get query => _query;
  PageResult<Movie> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;
  Set<int> get selected => Set.unmodifiable(_selected);
  bool get hasSelection => _selected.isNotEmpty;

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    _safeNotify();
    try {
      _result = await _repository.find(_query);
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить фильмы: $e';
      _status = LoadStatus.error;
    }
    _safeNotify();
  }

  Future<void> applyQuery(MovieQuery next) async {
    if (_query == next && _status == LoadStatus.success) return;
    _query = next;
    _selected.clear();
    await load();
  }

  void toggleSelection(int id) {
    _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
    _safeNotify();
  }

  void clearSelection() {
    _selected.clear();
    _safeNotify();
  }

  Future<void> deleteSelected() async {
    await _repository.deleteMany(_selected.toList());
    _selected.clear();
    await load();
  }

  Future<void> softDelete(int id) async {
    await _repository.softDelete(id);
    await load();
  }

  Future<void> hardDelete(int id) async {
    await _repository.hardDelete(id);
    await load();
  }

  Future<void> restore(int id) async {
    await _repository.restore(id);
    await load();
  }

  Future<Movie?> findById(int id) => _repository.findById(id);

  Future<Movie> save(Movie movie) async {
    final saved = movie.id == 0
        ? await _repository.create(movie)
        : await _repository.update(movie);
    await load();
    return saved;
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
