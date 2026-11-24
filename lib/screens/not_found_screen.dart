import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/app_settings.dart';
import '../widgets/app_page.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({
    required this.settings,
    required this.location,
    super.key,
  });
  final AppSettings settings;
  final String location;

  @override
  Widget build(BuildContext context) => AppPage(
    settings: settings,
    title: 'Страница не найдена',
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '404',
          style: Theme.of(context).textTheme.displayLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Такого адреса в приложении нет.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        SelectableText(location, textAlign: TextAlign.center),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.home),
          label: const Text('На главную'),
        ),
      ],
    ),
  );
}
