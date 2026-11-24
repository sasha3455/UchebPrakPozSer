import 'package:flutter/material.dart';

import '../services/app_settings.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    required this.settings,
    required this.title,
    required this.child,
    super.key,
  });

  final AppSettings settings;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title),
      actions: [
        IconButton(
          onPressed: settings.toggleTheme,
          tooltip: settings.themeMode == ThemeMode.dark
              ? 'Включить светлую тему'
              : 'Включить тёмную тему',
          icon: Icon(
            settings.themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode,
          ),
        ),
      ],
    ),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(constraints.maxWidth < 420 ? 16 : 24),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}
