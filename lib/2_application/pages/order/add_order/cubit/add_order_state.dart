part of 'add_order_cubit.dart';

class CartLine extends Equatable {
  const CartLine({
    required this.product,
    required this.sellOption,
    required this.qty,
  });

  final Product product;
  final SellOption sellOption;
  final int qty;

  double get lineTotal => sellOption.price * qty;

  String get displayLabel => product.isTingi
      ? '${product.name} — ${sellOption.label}'
      : product.name;

  CartLine copyWith({int? qty}) => CartLine(
        product: product,
        sellOption: sellOption,
        qty: qty ?? this.qty,
      );

  @override
  List<Object?> get props => [product.sku, sellOption.id, qty];
}

sealed class AddOrderState extends Equatable {
  const AddOrderState({
    required this.products,
    required this.selectedCategory,
    required this.searchQuery,
    required this.cart,
    required this.paymentMethod,
    required this.taxRate,
    required this.todayTotal,
    required this.todayOrders,
    required this.nextOrderSeq,
  });

  final List<Product> products;
  final String selectedCategory;
  final String searchQuery;
  final List<CartLine> cart;
  final OrderPaymentMethod paymentMethod;
  final double taxRate;
  final double todayTotal;
  final int todayOrders;

  /// Next order ID number to assign (e.g. 13 → ORD-0013).
  final int nextOrderSeq;

  List<Product> get filteredProducts {
    final query = searchQuery.trim().toLowerCase();
    return products.where((p) {
      final inCategory =
          selectedCategory == 'All' || p.category == selectedCategory;
      if (!inCategory) return false;
      if (query.isEmpty) return true;
      return p.name.toLowerCase().contains(query) ||
          p.sku.toLowerCase().contains(query);
    }).toList();
  }

  double get subtotal => cart.fold(0.0, (sum, line) => sum + line.lineTotal);
  double get tax => subtotal * taxRate;
  double get total => subtotal + tax;
  int get cartItemCount => cart.fold(0, (sum, l) => sum + l.qty);

  @override
  List<Object?> get props => [
        products,
        selectedCategory,
        searchQuery,
        cart,
        paymentMethod,
        taxRate,
        todayTotal,
        todayOrders,
        nextOrderSeq,
      ];
}

class AddOrderInitial extends AddOrderState {
  const AddOrderInitial({
    required super.products,
    required super.selectedCategory,
    required super.searchQuery,
    required super.cart,
    required super.paymentMethod,
    required super.taxRate,
    required super.todayTotal,
    required super.todayOrders,
    required super.nextOrderSeq,
  });
}

class AddOrderUpdated extends AddOrderState {
  const AddOrderUpdated({
    required super.products,
    required super.selectedCategory,
    required super.searchQuery,
    required super.cart,
    required super.paymentMethod,
    required super.taxRate,
    required super.todayTotal,
    required super.todayOrders,
    required super.nextOrderSeq,
  });
}

/// Emitted once when a charge completes — page listens to open the receipt.
class AddOrderCharged extends AddOrderState {
  const AddOrderCharged({
    required super.products,
    required super.selectedCategory,
    required super.searchQuery,
    required super.cart,
    required super.paymentMethod,
    required super.taxRate,
    required super.todayTotal,
    required super.todayOrders,
    required super.nextOrderSeq,
    required this.order,
  });

  final Order order;

  @override
  List<Object?> get props => [...super.props, order.id];
}
