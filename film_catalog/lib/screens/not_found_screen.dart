import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({required this.location, super.key});

  final String location;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Страница не найдена')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.travel_explore, size: 56),
          const SizedBox(height: 12),
          Text('Маршрут $location не найден'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.go('/movies'),
            child: const Text('В каталог'),
          ),
        ],
      ),
    ),
  );
}
