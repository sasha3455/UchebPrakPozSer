import 'package:go_router/go_router.dart';

import 'screens/calculator_screen.dart';
import 'screens/converter_screen.dart';
import 'screens/home_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/result_screen.dart';
import 'services/app_settings.dart';

GoRouter createRouter(AppSettings settings) => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(settings: settings),
    ),
    GoRoute(
      path: '/calculator',
      builder: (context, state) => CalculatorScreen(settings: settings),
      routes: [
        GoRoute(
          path: 'result',
          builder: (context, state) => CalculationResultScreen(
            settings: settings,
            query: state.uri.queryParameters,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/converter',
      builder: (context, state) => ConverterScreen(settings: settings),
      routes: [
        GoRoute(
          path: 'result',
          builder: (context, state) => ConversionResultScreen(
            settings: settings,
            query: state.uri.queryParameters,
          ),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) =>
      NotFoundScreen(settings: settings, location: state.uri.toString()),
);
