import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../1_domain/entities/customer.dart';
import '../../../1_domain/entities/product.dart';
import '../../pages/dashboard/dashboard_page.dart';
import '../../pages/login/login_page.dart';
import '../../pages/master_data/categories/categories_page.dart';
import '../../pages/master_data/customers/add_customer/add_customer_page.dart';
import '../../pages/master_data/customers/customers_page.dart';
import '../../pages/master_data/products/add_product/add_product_page.dart';
import '../../pages/master_data/products/products_list_page.dart';
import '../../pages/order/add_order/add_order_page.dart';
import '../../pages/order/order_list/order_list_page.dart';
import '../../pages/settings/settings_page.dart';
import '../../pages/transaction/lista_page.dart';
import '../widgets/base_page.dart';
import '../widgets/placeholder_page.dart';
import 'app_routes.dart';
import 'auth/auth_cubit.dart';

class GoRouterService {
  GoRouterService._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static late final GoRouter router;

  /// Call from main() before runApp(), passing the root AuthCubit.
  static void init(AuthCubit auth) {
    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation:
          auth.state.isAuthenticated ? AppRoutes.afterLogin : AppRoutes.login,
      refreshListenable: _AuthListenable(auth.stream),
      redirect: (context, state) {
        final loggedIn = auth.state.isAuthenticated;
        final onLogin = state.matchedLocation == AppRoutes.login;
        if (!loggedIn && !onLogin) return AppRoutes.login;
        if (loggedIn && onLogin) return AppRoutes.afterLogin;
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.login,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: LoginPage()),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => BasePage(
            location: state.matchedLocation,
            child: child,
          ),
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: DashboardPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.orderAdd,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: AddOrderPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.orderList,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: OrderListPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.masterData,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: PlaceholderPage(
                  title: 'Master Data',
                  icon: Icons.inventory_2_outlined,
                ),
              ),
            ),
            GoRoute(
              path: AppRoutes.masterDataProducts,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProductsListPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.masterDataProductsAdd,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: AddProductPage(),
              ),
            ),
            GoRoute(
              path: '${AppRoutes.masterDataProductsEdit}/:sku',
              pageBuilder: (context, state) {
                final sku = state.pathParameters['sku'];
                final product = kSeedProducts.firstWhere(
                  (p) => p.sku == sku,
                  orElse: () => kSeedProducts.first,
                );
                return NoTransitionPage(
                  child: AddProductPage(initialProduct: product),
                );
              },
            ),
            GoRoute(
              path: AppRoutes.masterDataCustomers,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: CustomersPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.masterDataCustomersAdd,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: AddCustomerPage(),
              ),
            ),
            GoRoute(
              path: '${AppRoutes.masterDataCustomersEdit}/:id',
              pageBuilder: (context, state) {
                final id = state.pathParameters['id'];
                final customer = kSeedCustomers.firstWhere(
                  (c) => c.id == id,
                  orElse: () => kSeedCustomers.first,
                );
                return NoTransitionPage(
                  child: AddCustomerPage(initialCustomer: customer),
                );
              },
            ),
            GoRoute(
              path: AppRoutes.masterDataCategories,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: CategoriesPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.report,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: PlaceholderPage(
                  title: 'Report',
                  icon: Icons.bar_chart_outlined,
                ),
              ),
            ),
            GoRoute(
              path: AppRoutes.transaction,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ListaPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.settings,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SettingsPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.help,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: PlaceholderPage(
                  title: 'Help Desk',
                  icon: Icons.help_outline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Bridges a Bloc stream to GoRouter's `refreshListenable`.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
