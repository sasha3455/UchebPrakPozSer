import 'package:flutter/material.dart';

import '../state/load_status.dart';

class LoadStateView extends StatelessWidget {
  const LoadStateView({
    required this.status,
    required this.error,
    required this.onRetry,
    required this.emptyLabel,
    required this.child,
    super.key,
  });

  final LoadStatus status;
  final String? error;
  final VoidCallback onRetry;
  final String emptyLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      LoadStatus.idle ||
      LoadStatus.loading => const Center(child: CircularProgressIndicator()),
      LoadStatus.error => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(error ?? 'Произошла ошибка', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
      LoadStatus.success => child,
    };
  }

  static Widget empty(
    BuildContext context,
    String label,
    VoidCallback onReset,
  ) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.search_off,
          size: 52,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 12),
        Text(label),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onReset,
          child: const Text('Сбросить фильтры'),
        ),
      ],
    ),
  );
}
