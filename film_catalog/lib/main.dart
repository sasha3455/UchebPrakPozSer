import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'core/router.dart';
import 'repositories/in_memory_director_repository.dart';
import 'repositories/in_memory_movie_repository.dart';
import 'repositories/director_repository.dart';
import 'repositories/movie_repository.dart';
import 'state/director_list_notifier.dart';
import 'state/movie_list_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  runApp(
    MultiProvider(
      providers: [
        Provider<MovieRepository>(create: (_) => InMemoryMovieRepository()),
        Provider<DirectorRepository>(
          create: (_) => InMemoryDirectorRepository(),
        ),
        ChangeNotifierProvider<MovieListNotifier>(
          create: (context) =>
              MovieListNotifier(context.read<MovieRepository>())..load(),
        ),
        ChangeNotifierProvider<DirectorListNotifier>(
          create: (context) =>
              DirectorListNotifier(context.read<DirectorRepository>())..load(),
        ),
      ],
      child: const FilmCatalogApp(),
    ),
  );
}

class FilmCatalogApp extends StatefulWidget {
  const FilmCatalogApp({super.key});

  @override
  State<FilmCatalogApp> createState() => _FilmCatalogAppState();
}

class _FilmCatalogAppState extends State<FilmCatalogApp> {
  late final router = createRouter();

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Каталог культовых фильмов',
    debugShowCheckedModeBanner: false,
    routerConfig: router,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      dataTableTheme: const DataTableThemeData(dividerThickness: .5),
    ),
  );
}
