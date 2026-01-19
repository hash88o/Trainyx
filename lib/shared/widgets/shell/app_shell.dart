import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_theme.dart';

/// Main app shell with bottom navigation
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({required this.child, super.key});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/clients')) return 1;
    if (location.startsWith('/workouts')) return 2;
    if (location.startsWith('/templates')) return 3;
    if (location.startsWith('/progress')) return 5;
    if (location.startsWith('/settings')) return 6;
    return 0; // Dashboard
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
        break;
      case 1:
        context.go(AppRoutes.clients);
        break;
      case 2:
        context.go(AppRoutes.workouts);
        break;
      case 3:
        context.go(AppRoutes.templates);
        break;
      case 5:
        context.go(AppRoutes.progress);
        break;
      case 6:
        context.go(AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final tabIndex = selectedIndex >= 5 ? selectedIndex - 1 : selectedIndex;

    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.surfaceLighter, width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                Expanded(
                  child: CupertinoTabBar(
                    currentIndex: tabIndex,
                    backgroundColor: AppColors.surface,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.textTertiary,
                    iconSize: 24,
                    onTap: (i) {
                      // Map tab index back to route index:
                      // 0 Home, 1 Clients, 2 Workout, 3 Templates, 4 Progress, 5 Settings
                      final routeIndex = i >= 4 ? i + 1 : i;
                      _onItemTapped(context, routeIndex);
                    },
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.house),
                        activeIcon: Icon(CupertinoIcons.house_fill),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.person_2),
                        activeIcon: Icon(CupertinoIcons.person_2_fill),
                        label: 'Clients',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.bolt),
                        activeIcon: Icon(CupertinoIcons.bolt_fill),
                        label: 'Workout',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.square_grid_2x2),
                        activeIcon: Icon(CupertinoIcons.square_grid_2x2_fill),
                        label: 'Templates',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.chart_bar),
                        activeIcon: Icon(CupertinoIcons.chart_bar_fill),
                        label: 'Progress',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.gear),
                        activeIcon: Icon(CupertinoIcons.gear_alt_fill),
                        label: 'Settings',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

