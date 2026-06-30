import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../services/app_routes.dart';
import '../services/auth/auth_cubit.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({
    super.key,
    required this.currentLocation,
    this.onItemTapped,
  });

  final String currentLocation;
  final VoidCallback? onItemTapped;

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late final Set<String> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = <String>{};
    if (widget.currentLocation.startsWith('/order')) _expanded.add('order');
    if (widget.currentLocation.startsWith('/master-data')) {
      _expanded.add('master-data');
    }
  }

  bool _isActive(String path) => widget.currentLocation == path;

  bool _isGroupActive(String prefix) =>
      widget.currentLocation.startsWith(prefix);

  void _navigate(String path) {
    context.go(path);
    widget.onItemTapped?.call();
  }

  void _toggleGroup(String key) {
    setState(() {
      if (_expanded.contains(key)) {
        _expanded.remove(key);
      } else {
        _expanded.add(key);
      }
    });
  }

  void _confirmLogout(BuildContext context) {
    final auth = context.read<AuthCubit>();
    widget.onItemTapped?.call(); // close phone drawer if open
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child:
                          const Icon(Icons.logout, color: AppColors.danger),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Sign out?',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'You\'ll be returned to the login screen. Any unsaved cart will be cleared.',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton(
                      onPressed: () {
                        auth.logout();
                        Navigator.of(ctx).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('Sign Out'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppColors.darkSurface,
      child: SafeArea(
        child: Column(
          children: [
            _Brand(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _NavItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    active: _isActive(AppRoutes.dashboard),
                    onTap: () => _navigate(AppRoutes.dashboard),
                  ),
                  _NavGroup(
                    icon: Icons.home_outlined,
                    label: 'Order',
                    active: _isGroupActive('/order'),
                    expanded: _expanded.contains('order'),
                    onToggle: () => _toggleGroup('order'),
                    children: [
                      _NavSubItem(
                        label: 'Add Order',
                        active: _isActive(AppRoutes.orderAdd),
                        onTap: () => _navigate(AppRoutes.orderAdd),
                      ),
                      _NavSubItem(
                        label: 'Order List',
                        active: _isActive(AppRoutes.orderList),
                        onTap: () => _navigate(AppRoutes.orderList),
                      ),
                    ],
                  ),
                  _NavGroup(
                    icon: Icons.inventory_2_outlined,
                    label: 'Master Data',
                    active: _isGroupActive('/master-data'),
                    expanded: _expanded.contains('master-data'),
                    onToggle: () => _toggleGroup('master-data'),
                    children: [
                      _NavSubItem(
                        label: 'Products',
                        active: _isActive(AppRoutes.masterDataProducts),
                        onTap: () => _navigate(AppRoutes.masterDataProducts),
                      ),
                      _NavSubItem(
                        label: 'Customers',
                        active: _isActive(AppRoutes.masterDataCustomers),
                        onTap: () => _navigate(AppRoutes.masterDataCustomers),
                      ),
                      _NavSubItem(
                        label: 'Categories',
                        active: _isActive(AppRoutes.masterDataCategories),
                        onTap: () => _navigate(AppRoutes.masterDataCategories),
                      ),
                    ],
                  ),
                  _NavItem(
                    icon: Icons.bar_chart_outlined,
                    label: 'Report',
                    active: _isActive(AppRoutes.report),
                    onTap: () => _navigate(AppRoutes.report),
                  ),
                  _NavItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Lista / Utang',
                    active: _isActive(AppRoutes.transaction),
                    onTap: () => _navigate(AppRoutes.transaction),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  _NavItem(
                    icon: Icons.help_outline,
                    label: 'Help Desk',
                    active: _isActive(AppRoutes.help),
                    onTap: () => _navigate(AppRoutes.help),
                  ),
                  _NavItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    active: _isActive(AppRoutes.settings),
                    onTap: () => _navigate(AppRoutes.settings),
                  ),
                  _NavItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    danger: true,
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brandAmber, AppColors.brandAmberDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text(
              'A',
              style: TextStyle(
                color: AppColors.textOnPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'ArchiePOS',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.danger = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg = danger
        ? AppColors.danger
        : active
            ? AppColors.textOnPrimary
            : AppColors.textSecondary;
    final Color bg = active ? AppColors.brandAmber : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: fg,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                    ),
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

class _NavGroup extends StatelessWidget {
  const _NavGroup({
    required this.icon,
    required this.label,
    required this.active,
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final Color fg = active ? AppColors.textOnPrimary : AppColors.textSecondary;
    final Color bg = active ? AppColors.brandAmber : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        children: [
          Material(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onToggle,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(icon, size: 20, color: fg),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: fg,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: fg,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 0, 4),
              child: Column(children: children),
            ),
        ],
      ),
    );
  }
}

class _NavSubItem extends StatelessWidget {
  const _NavSubItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: active ? AppColors.brandAmber.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: active ? AppColors.brandAmber : AppColors.darkBorder,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: active ? AppColors.brandAmber : AppColors.textSecondary,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13.5,
                    ),
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
