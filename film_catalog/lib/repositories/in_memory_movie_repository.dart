import '../models/movie.dart';
import '../models/movie_query.dart';
import '../models/page_result.dart';
import 'movie_repository.dart';

class InMemoryMovieRepository implements MovieRepository {
  InMemoryMovieRepository() : _movies = [...seedMovies];

  final List<Movie> _movies;
  int _nextId = seedMovies.length + 1;

  @override
  Future<PageResult<Movie>> find(MovieQuery q) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (q.forceError) {
      throw StateError('Демонстрационная ошибка загрузки каталога');
    }
    var rows = _movies.where((m) => q.includeDeleted || !m.isDeleted).toList();
    final needle = q.search.trim().toLowerCase();
    if (needle.isNotEmpty) {
      rows = rows
          .where(
            (m) =>
                m.title.toLowerCase().contains(needle) ||
                m.studio.toLowerCase().contains(needle) ||
                m.description.toLowerCase().contains(needle),
          )
          .toList();
    }
    if (q.genre != null) {
      rows = rows.where((m) => m.genre == q.genre).toList();
    }
    if (q.studio != null) {
      rows = rows.where((m) => m.studio == q.studio).toList();
    }
    if (q.yearFrom != null) {
      rows = rows.where((m) => m.year >= q.yearFrom!).toList();
    }
    if (q.yearTo != null) {
      rows = rows.where((m) => m.year <= q.yearTo!).toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'year' => a.year.compareTo(b.year),
        'rating' => a.rating.compareTo(b.rating),
        'duration' => a.durationMinutes.compareTo(b.durationMinutes),
        'studio' => a.studio.compareTo(b.studio),
        _ => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });

    final total = rows.length;
    final from = (q.page - 1) * q.size;
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <Movie>[] : rows.sublist(from, to);
    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Movie?> findById(int id) async {
    for (final movie in _movies) {
      if (movie.id == id) return movie;
    }
    return null;
  }

  @override
  Future<Movie> create(Movie movie) async {
    final created = Movie(
      id: _nextId++,
      title: movie.title,
      year: movie.year,
      durationMinutes: movie.durationMinutes,
      genre: movie.genre,
      studio: movie.studio,
      directorIds: movie.directorIds,
      rating: movie.rating,
      description: movie.description,
    );
    _movies.add(created);
    return created;
  }

  @override
  Future<Movie> update(Movie movie) async {
    final index = _movies.indexWhere((item) => item.id == movie.id);
    if (index == -1) throw StateError('Фильм ${movie.id} не найден');
    _movies[index] = movie;
    return movie;
  }

  @override
  Future<void> softDelete(int id) async {
    final index = _movies.indexWhere((item) => item.id == id);
    if (index == -1) throw StateError('Фильм $id не найден');
    _movies[index] = _movies[index].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async =>
      _movies.removeWhere((m) => m.id == id);

  @override
  Future<void> restore(int id) async {
    final index = _movies.indexWhere((item) => item.id == id);
    if (index == -1) throw StateError('Фильм $id не найден');
    _movies[index] = _movies[index].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final index = _movies.indexWhere(
        (item) => item.id == id && !item.isDeleted,
      );
      if (index != -1) {
        _movies[index] = _movies[index].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }
}

const seedMovies = <Movie>[
  Movie(
    id: 1,
    title: 'Fight Club',
    year: 1999,
    durationMinutes: 139,
    genre: 'Драма',
    studio: '20th Century Fox',
    directorIds: [1],
    rating: 8.8,
    description:
        'Культовая история о кризисе личности, свободе и правилах общества.',
  ),
  Movie(
    id: 2,
    title: 'Se7en',
    year: 1995,
    durationMinutes: 127,
    genre: 'Триллер',
    studio: 'New Line Cinema',
    directorIds: [1],
    rating: 8.6,
    description:
        'Мрачное расследование преступлений, построенных вокруг семи смертных грехов.',
  ),
  Movie(
    id: 3,
    title: 'Once Upon a Time in Hollywood',
    year: 2019,
    durationMinutes: 161,
    genre: 'Драма',
    studio: 'Columbia Pictures',
    directorIds: [2],
    rating: 7.6,
    description: 'Голливудское лето 1969 года, дружба актёра и каскадёра.',
  ),
  Movie(
    id: 4,
    title: 'Inglourious Basterds',
    year: 2009,
    durationMinutes: 153,
    genre: 'Военный',
    studio: 'Universal Pictures',
    directorIds: [2],
    rating: 8.4,
    description:
        'Альтернативная история Второй мировой войны от Квентина Тарантино.',
  ),
  Movie(
    id: 5,
    title: "Ocean's Eleven",
    year: 2001,
    durationMinutes: 116,
    genre: 'Криминал',
    studio: 'Warner Bros.',
    directorIds: [3],
    rating: 7.7,
    description: 'Элегантное ограбление казино командой Дэнни Оушена.',
  ),
  Movie(
    id: 6,
    title: "Ocean's Twelve",
    year: 2004,
    durationMinutes: 125,
    genre: 'Криминал',
    studio: 'Warner Bros.',
    directorIds: [3],
    rating: 6.5,
    description: 'Команда возвращается в Европу ради нового сложного плана.',
  ),
  Movie(
    id: 7,
    title: "Ocean's Thirteen",
    year: 2007,
    durationMinutes: 122,
    genre: 'Криминал',
    studio: 'Warner Bros.',
    directorIds: [3],
    rating: 6.9,
    description:
        'Друзья объединяются, чтобы восстановить справедливость в Лас-Вегасе.',
  ),
  Movie(
    id: 8,
    title: 'Troy',
    year: 2004,
    durationMinutes: 163,
    genre: 'Исторический',
    studio: 'Warner Bros.',
    directorIds: [4],
    rating: 7.3,
    description: 'Эпическая экранизация легенды о Троянской войне.',
  ),
  Movie(
    id: 9,
    title: 'Snatch',
    year: 2000,
    durationMinutes: 104,
    genre: 'Комедия',
    studio: 'Columbia Pictures',
    directorIds: [5],
    rating: 8.2,
    description:
        'Азартная криминальная комедия Гая Ричи с легендарным цыганом Микки.',
  ),
  Movie(
    id: 10,
    title: 'The Curious Case of Benjamin Button',
    year: 2008,
    durationMinutes: 166,
    genre: 'Фэнтези',
    studio: 'Paramount Pictures',
    directorIds: [1],
    rating: 7.8,
    description:
        'Необычная жизнь человека, который родился стариком и молодел.',
  ),
  Movie(
    id: 11,
    title: 'Moneyball',
    year: 2011,
    durationMinutes: 133,
    genre: 'Спорт',
    studio: 'Sony Pictures',
    directorIds: [6],
    rating: 7.6,
    description: 'История менеджера бейсбольной команды и силы аналитики.',
  ),
  Movie(
    id: 12,
    title: 'Babel',
    year: 2006,
    durationMinutes: 143,
    genre: 'Драма',
    studio: 'Paramount Pictures',
    directorIds: [7],
    rating: 7.4,
    description: 'Переплетающиеся истории людей из разных стран и культур.',
  ),
  Movie(
    id: 13,
    title: 'Burn After Reading',
    year: 2008,
    durationMinutes: 96,
    genre: 'Комедия',
    studio: 'Focus Features',
    directorIds: [8],
    rating: 7.0,
    description: 'Чёрная комедия братьев Коэн о случайно найденном диске.',
  ),
  Movie(
    id: 14,
    title: 'The Assassination of Jesse James',
    year: 2007,
    durationMinutes: 160,
    genre: 'Вестерн',
    studio: 'Warner Bros.',
    directorIds: [9],
    rating: 7.5,
    description: 'Медитативный вестерн о славе, зависти и предательстве.',
  ),
  Movie(
    id: 15,
    title: 'Ad Astra',
    year: 2019,
    durationMinutes: 123,
    genre: 'Фантастика',
    studio: '20th Century Fox',
    directorIds: [10],
    rating: 6.5,
    description: 'Космическое путешествие к границам Солнечной системы.',
  ),
  Movie(
    id: 16,
    title: 'Bullet Train',
    year: 2022,
    durationMinutes: 126,
    genre: 'Боевик',
    studio: 'Sony Pictures',
    directorIds: [5],
    rating: 7.3,
    description: 'Несколько наёмников сталкиваются в скоростном поезде.',
  ),
  Movie(
    id: 17,
    title: 'World War Z',
    year: 2013,
    durationMinutes: 116,
    genre: 'Боевик',
    studio: 'Paramount Pictures',
    directorIds: [11],
    rating: 7.0,
    description:
        'Бывший сотрудник ООН пытается остановить глобальную пандемию.',
  ),
  Movie(
    id: 18,
    title: 'Fury',
    year: 2014,
    durationMinutes: 134,
    genre: 'Военный',
    studio: 'Sony Pictures',
    directorIds: [12],
    rating: 7.6,
    description: 'Экипаж танка ведёт последний бой в конце войны.',
  ),
  Movie(
    id: 19,
    title: 'Meet Joe Black',
    year: 1998,
    durationMinutes: 178,
    genre: 'Мелодрама',
    studio: 'Universal Pictures',
    directorIds: [13],
    rating: 7.2,
    description: 'Таинственный гость предлагает магнату необычную сделку.',
  ),
  Movie(
    id: 20,
    title: 'Legends of the Fall',
    year: 1994,
    durationMinutes: 133,
    genre: 'Драма',
    studio: 'TriStar Pictures',
    directorIds: [14],
    rating: 7.5,
    description: 'Семья Ладлоу и история любви на фоне больших перемен.',
  ),
  Movie(
    id: 21,
    title: 'The Big Short',
    year: 2015,
    durationMinutes: 130,
    genre: 'Драма',
    studio: 'Paramount Pictures',
    directorIds: [6],
    rating: 7.8,
    description:
        'Несколько инвесторов предсказывают финансовый кризис 2008 года.',
  ),
  Movie(
    id: 22,
    title: 'The Tree of Life',
    year: 2011,
    durationMinutes: 139,
    genre: 'Драма',
    studio: 'Fox Searchlight',
    directorIds: [15],
    rating: 6.8,
    description: 'Поэтическое размышление о семье, памяти и мироздании.',
  ),
  Movie(
    id: 23,
    title: 'Confessions of a Dangerous Mind',
    year: 2002,
    durationMinutes: 113,
    genre: 'Комедия',
    studio: 'Miramax',
    directorIds: [16],
    rating: 7.0,
    description: 'Телеведущий оказывается втянут в тайную жизнь.',
  ),
  Movie(
    id: 24,
    title: 'Thelma & Louise',
    year: 1991,
    durationMinutes: 130,
    genre: 'Драма',
    studio: 'Metro-Goldwyn-Mayer',
    directorIds: [17],
    rating: 7.5,
    description: 'Культовая дорожная история о свободе и дружбе.',
  ),
  Movie(
    id: 25,
    title: '12 Monkeys',
    year: 1995,
    durationMinutes: 129,
    genre: 'Фантастика',
    studio: 'Universal Pictures',
    directorIds: [18],
    rating: 8.0,
    description: 'Путешественник во времени пытается предотвратить катастрофу.',
  ),
  Movie(
    id: 26,
    title: 'The Mexican',
    year: 2001,
    durationMinutes: 123,
    genre: 'Комедия',
    studio: 'DreamWorks',
    directorIds: [19],
    rating: 6.1,
    description: 'Криминальная романтическая история о легендарном пистолете.',
  ),
  Movie(
    id: 27,
    title: 'Spy Game',
    year: 2001,
    durationMinutes: 126,
    genre: 'Триллер',
    studio: 'Universal Pictures',
    directorIds: [20],
    rating: 7.1,
    description: 'Опытный разведчик спасает ученика из тюрьмы.',
  ),
  Movie(
    id: 28,
    title: 'The Counselor',
    year: 2013,
    durationMinutes: 117,
    genre: 'Триллер',
    studio: '20th Century Fox',
    directorIds: [9],
    rating: 5.3,
    description: 'Юрист оказывается втянут в опасную сделку с наркотиками.',
  ),
  Movie(
    id: 29,
    title: 'Killing Them Softly',
    year: 2012,
    durationMinutes: 97,
    genre: 'Криминал',
    studio: 'The Weinstein Company',
    directorIds: [21],
    rating: 6.2,
    description: 'Криминальная история о последствиях неудачного ограбления.',
  ),
  Movie(
    id: 30,
    title: 'The Lost City',
    year: 2022,
    durationMinutes: 112,
    genre: 'Приключения',
    studio: 'Paramount Pictures',
    directorIds: [22],
    rating: 6.1,
    description: 'Писательница и модель оказываются в настоящих джунглях.',
  ),
];
