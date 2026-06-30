class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String dashboard = '/dashboard';

  static const String orderAdd = '/order/add-order';
  static const String orderList = '/order/order-list';

  static const String masterData = '/master-data';
  static const String masterDataProducts = '/master-data/products';
  static const String masterDataProductsAdd = '/master-data/products/add';
  static const String masterDataProductsEdit = '/master-data/products/edit';

  static String editProduct(String sku) => '$masterDataProductsEdit/$sku';
  static const String masterDataCustomers = '/master-data/customers';
  static const String masterDataCustomersAdd = '/master-data/customers/add';
  static const String masterDataCustomersEdit = '/master-data/customers/edit';

  static String editCustomer(String id) => '$masterDataCustomersEdit/$id';
  static const String masterDataCategories = '/master-data/categories';

  static const String report = '/report';
  static const String transaction = '/transaction';

  static const String settings = '/settings';
  static const String help = '/help';

  static const String initial = login;
  static const String afterLogin = orderAdd;
}
