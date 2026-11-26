import 'package:go_router/go_router.dart';

import '../screens/director_detail_screen.dart';
import '../screens/director_list_screen.dart';
import '../screens/home_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/not_found_screen.dart';
import '../widgets/app_scaffold.dart';

GoRouter createRouter() => GoRouter(
  initialLocation: '/movies',
  routes: [
    ShellRoute(
      builder: (context, state, child) =>
          AppScaffold(location: state.uri.path, child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/movies',
          builder: (context, state) => MovieListScreen(uri: state.uri),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => MovieDetailScreen(
                id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/directors',
          builder: (context, state) => DirectorListScreen(uri: state.uri),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => DirectorDetailScreen(
                id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) =>
      NotFoundScreen(location: state.uri.toString()),
);
