import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'router.dart';
import 'services/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Убирает # из адресов: /calculator вместо /#/calculator.
  usePathUrlStrategy();
  final settings = await AppSettings.load();
  runApp(CalcApp(settings: settings));
}

class CalcApp extends StatefulWidget {
  const CalcApp({required this.settings, super.key});

  final AppSettings settings;

  @override
  State<CalcApp> createState() => _CalcAppState();
}

class _CalcAppState extends State<CalcApp> {
  late final router = createRouter(widget.settings);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settings,
      builder: (context, _) => MaterialApp.router(
        title: 'Калькулятор и конвертер',
        debugShowCheckedModeBanner: false,
        themeMode: widget.settings.themeMode,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        routerConfig: router,
      ),
    );
  }

  ThemeData _theme(Brightness brightness) => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: brightness,
    ),
    useMaterial3: true,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}
