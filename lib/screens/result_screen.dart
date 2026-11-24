import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logic/calculator.dart';
import '../logic/currency.dart';
import '../services/app_settings.dart';
import '../widgets/app_page.dart';

class CalculationResultScreen extends StatelessWidget {
  const CalculationResultScreen({
    required this.settings,
    required this.query,
    super.key,
  });
  final AppSettings settings;
  final Map<String, String> query;

  @override
  Widget build(BuildContext context) {
    final result = calculate(query['a'], query['op'], query['b']);
    final expression =
        '${query['a'] ?? '?'} ${query['op'] ?? '?'} ${query['b'] ?? '?'}';
    return _ResultPage(
      settings: settings,
      title: 'Результат вычисления',
      expression: expression,
      value: result is CalcSuccess ? formatNumber(result.value) : null,
      error: result is CalcFailure ? result.message : null,
      backPath: '/calculator',
    );
  }
}

class ConversionResultScreen extends StatelessWidget {
  const ConversionResultScreen({
    required this.settings,
    required this.query,
    super.key,
  });
  final AppSettings settings;
  final Map<String, String> query;

  @override
  Widget build(BuildContext context) {
    final result = convert(query['amount'], query['from'], query['to']);
    final expression =
        '${query['amount'] ?? '?'} ${query['from'] ?? '?'} = ? ${query['to'] ?? '?'}';
    final output = result.isSuccess
        ? '${formatNumber(result.value!)} ${query['to']}'
        : null;
    return _ResultPage(
      settings: settings,
      title: 'Результат конвертации',
      expression: expression,
      value: output,
      error: result.message,
      backPath: '/converter',
    );
  }
}

class _ResultPage extends StatelessWidget {
  const _ResultPage({
    required this.settings,
    required this.title,
    required this.expression,
    required this.value,
    required this.error,
    required this.backPath,
  });

  final AppSettings settings;
  final String title;
  final String expression;
  final String? value;
  final String? error;
  final String backPath;

  @override
  Widget build(BuildContext context) => AppPage(
    settings: settings,
    title: title,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Параметры из адресной строки',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Text(
          expression,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (value != null)
          Column(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 48,
                color: Colors.green,
              ),
              const SizedBox(height: 8),
              Text(
                value!,
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
            ],
          )
        else
          Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 8),
              Text(
                error ?? 'Не удалось обработать адрес',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        const SizedBox(height: 32),
        OutlinedButton.icon(
          onPressed: () => context.go(backPath),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Вернуться к форме'),
        ),
      ],
    ),
  );
}
