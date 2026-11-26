import 'package:flutter_test/flutter_test.dart';

import 'package:film_catalog/models/movie_query.dart';
import 'package:film_catalog/repositories/in_memory_movie_repository.dart';

void main() {
  test('copyWith can restore a soft-deleted movie', () {
    final movie = seedMovies.first.copyWith(deletedAt: DateTime(2020));
    expect(movie.isDeleted, isTrue);
    expect(movie.copyWith(clearDeletedAt: true).isDeleted, isFalse);
  });

  test('repository filters and paginates the movie catalog', () async {
    final repository = InMemoryMovieRepository();
    final result = await repository.find(
      const MovieQuery(search: 'Fight', size: 10),
    );
    expect(result.total, greaterThan(0));
    expect(result.items.length, lessThanOrEqualTo(10));
  });
}
