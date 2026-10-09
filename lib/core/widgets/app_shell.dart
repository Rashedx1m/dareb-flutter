import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                _NavItem(
                  outlined: PhosphorIconsRegular.house,
                  filled: PhosphorIconsFill.house,
                  selected: navigationShell.currentIndex == 0,
                  onTap: () => _go(0),
                ),
                _NavItem(
                  outlined: PhosphorIconsRegular.image,
                  filled: PhosphorIconsFill.image,
                  selected: navigationShell.currentIndex == 1,
                  onTap: () => _go(1),
                ),
                _NavItem(
                  outlined: PhosphorIconsRegular.books,
                  filled: PhosphorIconsFill.books,
                  selected: navigationShell.currentIndex == 2,
                  onTap: () => _go(2),
                ),
                _NavItem(
                  outlined: PhosphorIconsRegular.user,
                  filled: PhosphorIconsFill.user,
                  selected: navigationShell.currentIndex == 3,
                  onTap: () => _go(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _go(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.outlined,
    required this.filled,
    required this.selected,
    required this.onTap,
  });

  final IconData outlined;
  final IconData filled;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        child: Icon(
          selected ? filled : outlined,
          size: 28,
          color: selected ? AppColors.primary : AppColors.navMuted,
        ),
      ),
    );
  }
}
