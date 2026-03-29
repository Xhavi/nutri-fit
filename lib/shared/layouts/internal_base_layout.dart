import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';

class InternalBaseLayout extends StatelessWidget {
  const InternalBaseLayout({
    required this.title,
    required this.currentIndex,
    required this.child,
    super.key,
  });

  final String title;
  final int currentIndex;
  final Widget child;

  static const List<_InternalNavItem> _items = <_InternalNavItem>[
    _InternalNavItem('Inicio', Icons.home_rounded, AppRoutePaths.home),
    _InternalNavItem(
      'Nutrición',
      Icons.restaurant_menu_rounded,
      AppRoutePaths.nutrition,
    ),
    _InternalNavItem('Ejercicio', Icons.fitness_center_rounded, AppRoutePaths.exercise),
    _InternalNavItem('Progreso', Icons.query_stats_rounded, AppRoutePaths.progress),
    _InternalNavItem('AI Coach', Icons.smart_toy_rounded, AppRoutePaths.aiCoach),
    _InternalNavItem('Perfil', Icons.person_rounded, AppRoutePaths.profile),
    _InternalNavItem('Ajustes', Icons.settings_rounded, AppRoutePaths.settings),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: currentIndex,
        onDestinationSelected: (int index) {
          context.go(_items[index].path);
        },
        destinations: _items
            .map(
              (_InternalNavItem item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _InternalNavItem {
  const _InternalNavItem(this.label, this.icon, this.path);

  final String label;
  final IconData icon;
  final String path;
}
