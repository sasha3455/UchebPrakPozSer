import '../models/director.dart';
import '../models/director_query.dart';
import '../models/page_result.dart';
import 'director_repository.dart';

class InMemoryDirectorRepository implements DirectorRepository {
  InMemoryDirectorRepository() : _directors = [...seedDirectors];

  final List<Director> _directors;
  int _nextId = seedDirectors.length + 1;

  @override
  Future<PageResult<Director>> find(DirectorQuery q) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    var rows = _directors
        .where((d) => q.includeDeleted || !d.isDeleted)
        .toList();
    final needle = q.search.trim().toLowerCase();
    if (needle.isNotEmpty) {
      rows = rows
          .where(
            (d) =>
                d.name.toLowerCase().contains(needle) ||
                d.country.toLowerCase().contains(needle) ||
                d.bio.toLowerCase().contains(needle),
          )
          .toList();
    }
    if (q.country != null) {
      rows = rows.where((d) => d.country == q.country).toList();
    }
    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'birthYear' => a.birthYear.compareTo(b.birthYear),
        'country' => a.country.compareTo(b.country),
        _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });
    final total = rows.length;
    final from = (q.page - 1) * q.size;
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <Director>[] : rows.sublist(from, to);
    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Director?> findById(int id) async {
    for (final director in _directors) {
      if (director.id == id) return director;
    }
    return null;
  }

  @override
  Future<Director> create(Director director) async {
    final created = Director(
      id: _nextId++,
      name: director.name,
      country: director.country,
      birthYear: director.birthYear,
      bio: director.bio,
    );
    _directors.add(created);
    return created;
  }

  @override
  Future<Director> update(Director director) async {
    final index = _directors.indexWhere((item) => item.id == director.id);
    if (index == -1) throw StateError('Режиссёр ${director.id} не найден');
    _directors[index] = director;
    return director;
  }

  @override
  Future<void> softDelete(int id) async {
    final index = _directors.indexWhere((item) => item.id == id);
    if (index == -1) throw StateError('Режиссёр $id не найден');
    _directors[index] = _directors[index].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async =>
      _directors.removeWhere((d) => d.id == id);

  @override
  Future<void> restore(int id) async {
    final index = _directors.indexWhere((item) => item.id == id);
    if (index == -1) throw StateError('Режиссёр $id не найден');
    _directors[index] = _directors[index].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final index = _directors.indexWhere(
        (item) => item.id == id && !item.isDeleted,
      );
      if (index != -1) {
        _directors[index] = _directors[index].copyWith(
          deletedAt: DateTime.now(),
        );
        count++;
      }
    }
    return count;
  }
}

const seedDirectors = <Director>[
  Director(
    id: 1,
    name: 'Дэвид Финчер',
    country: 'США',
    birthYear: 1962,
    bio: 'Режиссёр визуально точных психологических триллеров.',
  ),
  Director(
    id: 2,
    name: 'Квентин Тарантино',
    country: 'США',
    birthYear: 1963,
    bio: 'Автор постмодернистского кино и виртуозных диалогов.',
  ),
  Director(
    id: 3,
    name: 'Стивен Содерберг',
    country: 'США',
    birthYear: 1963,
    bio: 'Режиссёр криминальных историй и экспериментального кино.',
  ),
  Director(
    id: 4,
    name: 'Вольфганг Петерсен',
    country: 'Германия',
    birthYear: 1941,
    bio: 'Мастер масштабных исторических и приключенческих фильмов.',
  ),
  Director(
    id: 5,
    name: 'Гай Ричи',
    country: 'Великобритания',
    birthYear: 1968,
    bio: 'Создатель энергичных криминальных комедий.',
  ),
  Director(
    id: 6,
    name: 'Беннетт Миллер',
    country: 'США',
    birthYear: 1966,
    bio: 'Режиссёр спортивных и биографических драм.',
  ),
  Director(
    id: 7,
    name: 'Алехандро Гонсалес Иньярриту',
    country: 'Мексика',
    birthYear: 1963,
    bio: 'Автор эмоциональных историй о случайностях и взаимосвязях.',
  ),
  Director(
    id: 8,
    name: 'Джоэл Коэн',
    country: 'США',
    birthYear: 1954,
    bio: 'Половина знаменитого дуэта братьев Коэн.',
  ),
  Director(
    id: 9,
    name: 'Эндрю Доминик',
    country: 'Новая Зеландия',
    birthYear: 1967,
    bio: 'Режиссёр медитативных криминальных драм.',
  ),
  Director(
    id: 10,
    name: 'Джеймс Грэй',
    country: 'США',
    birthYear: 1969,
    bio: 'Автор атмосферных семейных и космических драм.',
  ),
  Director(
    id: 11,
    name: 'Марк Форстер',
    country: 'Германия',
    birthYear: 1969,
    bio: 'Режиссёр драм и масштабных жанровых проектов.',
  ),
  Director(
    id: 12,
    name: 'Дэвид Эйр',
    country: 'США',
    birthYear: 1968,
    bio: 'Специалист по суровым историям о войне и полиции.',
  ),
  Director(
    id: 13,
    name: 'Мартин Брест',
    country: 'США',
    birthYear: 1951,
    bio: 'Режиссёр драматических историй о человеческих отношениях.',
  ),
  Director(
    id: 14,
    name: 'Эдвард Цвик',
    country: 'США',
    birthYear: 1952,
    bio: 'Постановщик эпических исторических драм.',
  ),
  Director(
    id: 15,
    name: 'Терренс Малик',
    country: 'США',
    birthYear: 1943,
    bio: 'Поэтичный режиссёр философского авторского кино.',
  ),
  Director(
    id: 16,
    name: 'Джордж Клуни',
    country: 'США',
    birthYear: 1961,
    bio: 'Актёр и режиссёр интеллектуальных драм и сатир.',
  ),
  Director(
    id: 17,
    name: 'Ридли Скотт',
    country: 'Великобритания',
    birthYear: 1937,
    bio: 'Легендарный режиссёр исторического и фантастического кино.',
  ),
  Director(
    id: 18,
    name: 'Терри Гиллиам',
    country: 'Великобритания',
    birthYear: 1940,
    bio: 'Создатель сюрреалистических фантастических миров.',
  ),
  Director(
    id: 19,
    name: 'Гор Вербински',
    country: 'США',
    birthYear: 1964,
    bio: 'Режиссёр приключенческих фильмов и чёрных комедий.',
  ),
  Director(
    id: 20,
    name: 'Тони Скотт',
    country: 'Великобритания',
    birthYear: 1944,
    bio: 'Мастер напряжённых шпионских триллеров.',
  ),
  Director(
    id: 21,
    name: 'Эндрю Доминик',
    country: 'Новая Зеландия',
    birthYear: 1967,
    bio: 'Режиссёр неонуарных криминальных историй.',
  ),
  Director(
    id: 22,
    name: 'Адам Нэй',
    country: 'США',
    birthYear: 1971,
    bio: 'Режиссёр лёгких приключенческих комедий.',
  ),
];
