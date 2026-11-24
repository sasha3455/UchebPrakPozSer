import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/app_settings.dart';
import '../widgets/app_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.settings, super.key});
  final AppSettings settings;

  @override
  Widget build(BuildContext context) => AppPage(
    settings: settings,
    title: 'Главная',
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.calculate_outlined,
          size: 72,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 20),
        Text(
          'Калькулятор и конвертер',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text('Выберите нужный инструмент.', textAlign: TextAlign.center),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () => context.go('/calculator'),
          icon: const Icon(Icons.calculate),
          label: const Text('Калькулятор'),
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: () => context.go('/converter'),
          icon: const Icon(Icons.currency_exchange),
          label: const Text('Конвертер валют'),
        ),
      ],
    ),
  );
}
