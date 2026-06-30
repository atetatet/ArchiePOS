import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../1_domain/entities/customer.dart';
import '../../../../../1_domain/entities/order.dart';
import '../../../../../1_domain/entities/product.dart';

part 'add_order_state.dart';

class AddOrderCubit extends Cubit<AddOrderState> {
  AddOrderCubit() : super(_initial());

  static AddOrderInitial _initial() => AddOrderInitial(
    products: List.of(kSeedProducts),
    selectedCategory: 'All',
    searchQuery: '',
    cart: const [],
    paymentMethod: OrderPaymentMethod.cash,
    taxRate: 0.12,
    todayTotal: 173.60,
    todayOrders: 9,
    nextOrderSeq: 13, // seed orders end at ORD-0012
  );

  void selectCategory(String category) {
    emit(_copy(selectedCategory: category));
  }

  void search(String query) {
    emit(_copy(searchQuery: query));
  }

  void addToCart(Product product, {SellOption? sellOption}) {
    final option = sellOption ?? product.defaultSellOption;
    final cart = List<CartLine>.from(state.cart);
    final i = cart.indexWhere(
      (l) => l.product.sku == product.sku && l.sellOption.id == option.id,
    );
    if (i >= 0) {
      cart[i] = cart[i].copyWith(qty: cart[i].qty + 1);
    } else {
      cart.add(CartLine(product: product, sellOption: option, qty: 1));
    }
    emit(_copy(cart: cart));
  }

  void updateLineQty(String sku, String sellOptionId, int qty) {
    if (qty <= 0) {
      removeLine(sku, sellOptionId);
      return;
    }
    final cart = List<CartLine>.from(state.cart);
    final i = cart.indexWhere(
      (l) => l.product.sku == sku && l.sellOption.id == sellOptionId,
    );
    if (i < 0) return;
    cart[i] = cart[i].copyWith(qty: qty);
    emit(_copy(cart: cart));
  }

  void removeLine(String sku, String sellOptionId) {
    final cart = state.cart
        .where(
          (l) => !(l.product.sku == sku && l.sellOption.id == sellOptionId),
        )
        .toList();
    emit(_copy(cart: cart));
  }

  void clearCart() => emit(_copy(cart: const []));

  void selectPayment(OrderPaymentMethod method) {
    emit(_copy(paymentMethod: method));
  }

  /// Completes the sale. Returns null on success, or an error message.
  ///
  /// - For Lista, `customerId` must be supplied (the picked customer).
  /// - For Cash, `tendered` must be ≥ total (caller validates first).
  String? charge({String? customerId, double? tendered}) {
    if (state.cart.isEmpty) return 'Cart is empty';

    final method = state.paymentMethod;
    Customer? customer;
    if (method == OrderPaymentMethod.lista) {
      if (customerId == null || customerId.isEmpty) {
        return 'Pick a customer for lista sales';
      }
      customer = kSeedCustomers.firstWhere(
        (c) => c.id == customerId,
        orElse: () => kSeedCustomers.first,
      );
    }
    if (method == OrderPaymentMethod.cash) {
      if (tendered == null || tendered < state.total - 0.001) {
        return 'Tendered amount is less than total';
      }
    }

    // Build the order from the current cart
    final orderId = 'ORD-${state.nextOrderSeq.toString().padLeft(4, '0')}';
    final items = state.cart
        .map(
          (l) => OrderItem(
            productSku: l.product.sku,
            productName: l.product.name,
            productEmoji: l.product.emoji,
            sellOptionId: l.sellOption.id,
            sellOptionLabel: l.sellOption.label,
            baseQty: l.sellOption.baseQty,
            price: l.sellOption.price,
            qty: l.qty,
          ),
        )
        .toList();

    final order = Order(
      id: orderId,
      createdAtIso: DateTime.parse('2026-06-15T12:00:00').toIso8601String(),
      items: items,
      subtotal: state.subtotal,
      tax: method == OrderPaymentMethod.lista ? 0 : state.tax,
      paymentMethod: method,
      status: method == OrderPaymentMethod.lista
          ? OrderStatus.lista
          : OrderStatus.completed,
      customerId: customer?.id,
      customerName: customer?.name ?? 'Walk-in',
      cashierName: 'Archie Gonzales',
    );

    // Visually decrement stock per cart line (in base units).
    final newProducts = state.products.map((p) {
      final consumed = state.cart
          .where((l) => l.product.sku == p.sku)
          .fold<double>(0, (sum, l) => sum + l.sellOption.baseQty * l.qty);
      if (consumed == 0) return p;
      return Product(
        sku: p.sku,
        name: p.name,
        category: p.category,
        stock: (p.stock - consumed).clamp(0, double.infinity),
        lowStockThreshold: p.lowStockThreshold,
        emoji: p.emoji,
        sellOptions: p.sellOptions,
        baseUnit: p.baseUnit,
        description: p.description,
      );
    }).toList();

    emit(
      AddOrderCharged(
        products: newProducts,
        selectedCategory: state.selectedCategory,
        searchQuery: '',
        cart: const [],
        paymentMethod: OrderPaymentMethod.cash,
        taxRate: state.taxRate,
        // Lista sales don't count toward "today's cash sales" — they're credit.
        todayTotal:
            state.todayTotal +
            (method == OrderPaymentMethod.lista ? 0 : order.total),
        todayOrders: state.todayOrders + 1,
        nextOrderSeq: state.nextOrderSeq + 1,
        order: order,
      ),
    );
    return null;
  }

  /// Acknowledge the charge — move from the one-shot AddOrderCharged state
  /// back to AddOrderUpdated so the page stops listening.
  void acknowledgeCharge() {
    emit(_copy());
  }

  AddOrderUpdated _copy({
    List<Product>? products,
    String? selectedCategory,
    String? searchQuery,
    List<CartLine>? cart,
    OrderPaymentMethod? paymentMethod,
    double? taxRate,
    double? todayTotal,
    int? todayOrders,
    int? nextOrderSeq,
  }) => AddOrderUpdated(
    products: products ?? state.products,
    selectedCategory: selectedCategory ?? state.selectedCategory,
    searchQuery: searchQuery ?? state.searchQuery,
    cart: cart ?? state.cart,
    paymentMethod: paymentMethod ?? state.paymentMethod,
    taxRate: taxRate ?? state.taxRate,
    todayTotal: todayTotal ?? state.todayTotal,
    todayOrders: todayOrders ?? state.todayOrders,
    nextOrderSeq: nextOrderSeq ?? state.nextOrderSeq,
  );
}
