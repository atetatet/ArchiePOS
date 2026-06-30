import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'app_drawer.dart';

class BasePage extends StatelessWidget {
  const BasePage({
    super.key,
    required this.child,
    required this.location,
  });

  final Widget child;
  final String location;

  static const double _tabletBreakpoint = 840;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth >= _tabletBreakpoint;
        if (wide) {
          return Scaffold(
            backgroundColor: AppColors.darkBg,
            body: Row(
              children: [
                AppDrawer(currentLocation: location),
                const VerticalDivider(width: 1, color: AppColors.darkDivider),
                Expanded(child: child),
              ],
            ),
          );
        }
        return Scaffold(
          backgroundColor: AppColors.darkBg,
          appBar: AppBar(
            backgroundColor: AppColors.darkBg,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
          ),
          drawer: Drawer(
            backgroundColor: AppColors.darkSurface,
            width: 240,
            child: Builder(
              builder: (drawerContext) => AppDrawer(
                currentLocation: location,
                onItemTapped: () => Navigator.of(drawerContext).pop(),
              ),
            ),
          ),
          body: child,
        );
      },
    );
  }
}
