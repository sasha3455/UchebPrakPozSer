import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/breakpoints.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  static const _destinations = [
    (
      icon: Icons.movie_outlined,
      selected: Icons.movie,
      label: 'Фильмы',
      path: '/movies',
    ),
    (
      icon: Icons.videocam_outlined,
      selected: Icons.videocam,
      label: 'Режиссёры',
      path: '/directors',
    ),
  ];

  int get selectedIndex => location.startsWith('/directors') ? 1 : 0;

  void _navigate(BuildContext context, int index) =>
      context.go(_destinations[index].path);

  @override
  Widget build(BuildContext context) {
    final size = screenSizeOf(context);
    if (size == ScreenSize.compact) {
      return Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) => _navigate(context, index),
          destinations: [
            for (final d in _destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selected),
                label: d.label,
              ),
          ],
        ),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) => _navigate(context, index),
            extended: size == ScreenSize.expanded,
            labelType: size == ScreenSize.expanded
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Icon(
                Icons.local_movies,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
            ),
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selected),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
