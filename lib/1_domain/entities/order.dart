import 'package:equatable/equatable.dart';

enum OrderPaymentMethod { cash, card, mobile, lista }

enum OrderStatus { completed, lista, refunded, voided }

/// Snapshot of a sold line. Stores label/price as a snapshot — if the underlying
/// product or sell-option is later edited, old receipts still print correctly.
class OrderItem extends Equatable {
  const OrderItem({
    required this.productSku,
    required this.productName,
    required this.productEmoji,
    required this.sellOptionId,
    required this.sellOptionLabel,
    required this.baseQty,
    required this.price,
    required this.qty,
  });

  final String productSku;
  final String productName;
  final String productEmoji;
  final String sellOptionId;
  final String sellOptionLabel;
  final double baseQty;
  final double price;
  final int qty;

  double get lineTotal => price * qty;
  String get displayLabel => sellOptionLabel == 'each'
      ? productName
      : '$productName — $sellOptionLabel';

  @override
  List<Object?> get props => [productSku, sellOptionId, qty, price];
}

class Order extends Equatable {
  const Order({
    required this.id,
    required this.createdAtIso,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.paymentMethod,
    required this.status,
    this.customerId,
    this.customerName,
    this.cashierName,
  });

  final String id;
  final String createdAtIso;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final OrderPaymentMethod paymentMethod;
  final OrderStatus status;
  final String? customerId;
  final String? customerName;
  final String? cashierName;

  double get total => subtotal + tax;
  int get itemCount => items.fold(0, (sum, i) => sum + i.qty);
  DateTime get createdAt => DateTime.parse(createdAtIso);
  bool get isLista => status == OrderStatus.lista;
  bool get isCompleted => status == OrderStatus.completed;
  bool get isRefunded =>
      status == OrderStatus.refunded || status == OrderStatus.voided;

  @override
  List<Object?> get props => [id];
}

/// Seed data — today is 2026-06-15.
const List<Order> kSeedOrders = [
  Order(
    id: 'ORD-0001',
    createdAtIso: '2026-06-15T09:15:00',
    paymentMethod: OrderPaymentMethod.cash,
    status: OrderStatus.completed,
    customerName: 'Walk-in',
    cashierName: 'Archie Gonzales',
    subtotal: 85.50,
    tax: 10.26,
    items: [
      OrderItem(
        productSku: 'BEV-001',
        productName: 'Cold Brew Coffee',
        productEmoji: '☕',
        sellOptionId: 'so-bev-001-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 4.50,
        qty: 3,
      ),
      OrderItem(
        productSku: 'FOOD-002',
        productName: 'Granola Bar',
        productEmoji: '🌾',
        sellOptionId: 'so-food-002-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 2.75,
        qty: 2,
      ),
      OrderItem(
        productSku: 'FOOD-003',
        productName: 'Banana',
        productEmoji: '🍌',
        sellOptionId: 'so-food-003-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 0.75,
        qty: 6,
      ),
    ],
  ),
  Order(
    id: 'ORD-0002',
    createdAtIso: '2026-06-15T10:30:00',
    paymentMethod: OrderPaymentMethod.lista,
    status: OrderStatus.lista,
    customerId: 'cust-001',
    customerName: 'Aling Maria',
    cashierName: 'Archie Gonzales',
    subtotal: 40.00,
    tax: 0,
    items: [
      OrderItem(
        productSku: 'FOOD-002',
        productName: 'Granola Bar',
        productEmoji: '🌾',
        sellOptionId: 'so-food-002-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 2.75,
        qty: 4,
      ),
      OrderItem(
        productSku: 'BEV-002',
        productName: 'Sparkling Water',
        productEmoji: '💧',
        sellOptionId: 'so-bev-002-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 2.25,
        qty: 13,
      ),
    ],
  ),
  Order(
    id: 'ORD-0003',
    createdAtIso: '2026-06-15T11:05:00',
    paymentMethod: OrderPaymentMethod.card,
    status: OrderStatus.completed,
    customerName: 'Walk-in',
    cashierName: 'Archie Gonzales',
    subtotal: 245.75,
    tax: 29.49,
    items: [
      OrderItem(
        productSku: 'FOOD-005',
        productName: 'Bigas (Sinandomeng)',
        productEmoji: '🍚',
        sellOptionId: 'so-food-005-1',
        sellOptionLabel: '1 kg',
        baseQty: 1,
        price: 60,
        qty: 3,
      ),
      OrderItem(
        productSku: 'FOOD-001',
        productName: 'Avocado Toast',
        productEmoji: '🥑',
        sellOptionId: 'so-food-001-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 8.50,
        qty: 4,
      ),
      OrderItem(
        productSku: 'BEV-003',
        productName: 'Orange Juice',
        productEmoji: '🍊',
        sellOptionId: 'so-bev-003-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 3.75,
        qty: 2,
      ),
    ],
  ),
  Order(
    id: 'ORD-0004',
    createdAtIso: '2026-06-15T13:20:00',
    paymentMethod: OrderPaymentMethod.cash,
    status: OrderStatus.completed,
    customerName: 'Walk-in',
    cashierName: 'Archie Gonzales',
    subtotal: 4.50,
    tax: 0.54,
    items: [
      OrderItem(
        productSku: 'BEV-001',
        productName: 'Cold Brew Coffee',
        productEmoji: '☕',
        sellOptionId: 'so-bev-001-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 4.50,
        qty: 1,
      ),
    ],
  ),
  Order(
    id: 'ORD-0005',
    createdAtIso: '2026-06-15T14:00:00',
    paymentMethod: OrderPaymentMethod.lista,
    status: OrderStatus.lista,
    customerId: 'cust-002',
    customerName: 'Mang Tonyo',
    cashierName: 'Archie Gonzales',
    subtotal: 150.00,
    tax: 0,
    items: [
      OrderItem(
        productSku: 'FOOD-005',
        productName: 'Bigas (Sinandomeng)',
        productEmoji: '🍚',
        sellOptionId: 'so-food-005-2',
        sellOptionLabel: '½ kg',
        baseQty: 0.5,
        price: 32,
        qty: 2,
      ),
      OrderItem(
        productSku: 'BEV-004',
        productName: 'Energy Drink',
        productEmoji: '⚡',
        sellOptionId: 'so-bev-004-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 3.50,
        qty: 6,
      ),
      OrderItem(
        productSku: 'HLTH-003',
        productName: 'Aspirin 20ct',
        productEmoji: '💊',
        sellOptionId: 'so-hlth-003-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 5.49,
        qty: 12,
      ),
    ],
  ),
  Order(
    id: 'ORD-0006',
    createdAtIso: '2026-06-15T16:30:00',
    paymentMethod: OrderPaymentMethod.mobile,
    status: OrderStatus.completed,
    customerName: 'Walk-in',
    cashierName: 'Archie Gonzales',
    subtotal: 128.00,
    tax: 15.36,
    items: [
      OrderItem(
        productSku: 'HLTH-001',
        productName: 'Hand Sanitizer',
        productEmoji: '🧴',
        sellOptionId: 'so-hlth-001-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 3.99,
        qty: 6,
      ),
      OrderItem(
        productSku: 'HLTH-002',
        productName: 'Lip Balm',
        productEmoji: '💋',
        sellOptionId: 'so-hlth-002-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 2.50,
        qty: 8,
      ),
      OrderItem(
        productSku: 'STAT-002',
        productName: 'Ballpoint Pen',
        productEmoji: '🖊',
        sellOptionId: 'so-stat-002-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 1.25,
        qty: 12,
      ),
      OrderItem(
        productSku: 'STAT-003',
        productName: 'Sticky Notes',
        productEmoji: '🗒',
        sellOptionId: 'so-stat-003-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 3.49,
        qty: 20,
      ),
    ],
  ),
  Order(
    id: 'ORD-0007',
    createdAtIso: '2026-06-14T08:45:00',
    paymentMethod: OrderPaymentMethod.cash,
    status: OrderStatus.completed,
    customerName: 'Walk-in',
    cashierName: 'Archie Gonzales',
    subtotal: 12.50,
    tax: 1.50,
    items: [
      OrderItem(
        productSku: 'FOOD-003',
        productName: 'Banana',
        productEmoji: '🍌',
        sellOptionId: 'so-food-003-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 0.75,
        qty: 10,
      ),
      OrderItem(
        productSku: 'BEV-002',
        productName: 'Sparkling Water',
        productEmoji: '💧',
        sellOptionId: 'so-bev-002-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 2.25,
        qty: 2,
      ),
    ],
  ),
  Order(
    id: 'ORD-0008',
    createdAtIso: '2026-06-14T19:30:00',
    paymentMethod: OrderPaymentMethod.lista,
    status: OrderStatus.lista,
    customerId: 'cust-003',
    customerName: 'Kuya Ben',
    cashierName: 'Archie Gonzales',
    subtotal: 45.00,
    tax: 0,
    items: [
      OrderItem(
        productSku: 'FOOD-005',
        productName: 'Bigas (Sinandomeng)',
        productEmoji: '🍚',
        sellOptionId: 'so-food-005-3',
        sellOptionLabel: '¼ kg',
        baseQty: 0.25,
        price: 17,
        qty: 1,
      ),
      OrderItem(
        productSku: 'BEV-004',
        productName: 'Energy Drink',
        productEmoji: '⚡',
        sellOptionId: 'so-bev-004-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 3.50,
        qty: 8,
      ),
    ],
  ),
  Order(
    id: 'ORD-0009',
    createdAtIso: '2026-06-13T17:15:00',
    paymentMethod: OrderPaymentMethod.cash,
    status: OrderStatus.completed,
    customerName: 'Walk-in',
    cashierName: 'Archie Gonzales',
    subtotal: 310.25,
    tax: 37.23,
    items: [
      OrderItem(
        productSku: 'FOOD-005',
        productName: 'Bigas (Sinandomeng)',
        productEmoji: '🍚',
        sellOptionId: 'so-food-005-1',
        sellOptionLabel: '1 kg',
        baseQty: 1,
        price: 60,
        qty: 4,
      ),
      OrderItem(
        productSku: 'FOOD-002',
        productName: 'Granola Bar',
        productEmoji: '🌾',
        sellOptionId: 'so-food-002-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 2.75,
        qty: 8,
      ),
      OrderItem(
        productSku: 'BEV-001',
        productName: 'Cold Brew Coffee',
        productEmoji: '☕',
        sellOptionId: 'so-bev-001-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 4.50,
        qty: 8,
      ),
      OrderItem(
        productSku: 'HLTH-002',
        productName: 'Lip Balm',
        productEmoji: '💋',
        sellOptionId: 'so-hlth-002-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 2.50,
        qty: 4,
      ),
    ],
  ),
  Order(
    id: 'ORD-0010',
    createdAtIso: '2026-06-08T11:00:00',
    paymentMethod: OrderPaymentMethod.lista,
    status: OrderStatus.lista,
    customerId: 'cust-004',
    customerName: 'Ate Susan',
    cashierName: 'Archie Gonzales',
    subtotal: 220.00,
    tax: 0,
    items: [
      OrderItem(
        productSku: 'STAT-001',
        productName: 'Notebook A5',
        productEmoji: '📓',
        sellOptionId: 'so-stat-001-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 4.99,
        qty: 10,
      ),
      OrderItem(
        productSku: 'STAT-002',
        productName: 'Ballpoint Pen',
        productEmoji: '🖊',
        sellOptionId: 'so-stat-002-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 1.25,
        qty: 24,
      ),
      OrderItem(
        productSku: 'STAT-003',
        productName: 'Sticky Notes',
        productEmoji: '🗒',
        sellOptionId: 'so-stat-003-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 3.49,
        qty: 40,
      ),
    ],
  ),
  Order(
    id: 'ORD-0011',
    createdAtIso: '2026-06-12T10:20:00',
    paymentMethod: OrderPaymentMethod.cash,
    status: OrderStatus.completed,
    customerName: 'Walk-in',
    cashierName: 'Archie Gonzales',
    subtotal: 495.50,
    tax: 59.46,
    items: [
      OrderItem(
        productSku: 'ELEC-001',
        productName: 'USB-C Cable',
        productEmoji: '🔌',
        sellOptionId: 'so-elec-001-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 12.99,
        qty: 12,
      ),
      OrderItem(
        productSku: 'STAT-001',
        productName: 'Notebook A5',
        productEmoji: '📓',
        sellOptionId: 'so-stat-001-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 4.99,
        qty: 20,
      ),
      OrderItem(
        productSku: 'FOOD-001',
        productName: 'Avocado Toast',
        productEmoji: '🥑',
        sellOptionId: 'so-food-001-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 8.50,
        qty: 24,
      ),
      OrderItem(
        productSku: 'BEV-003',
        productName: 'Orange Juice',
        productEmoji: '🍊',
        sellOptionId: 'so-bev-003-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 3.75,
        qty: 9,
      ),
    ],
  ),
  Order(
    id: 'ORD-0012',
    createdAtIso: '2026-06-10T15:00:00',
    paymentMethod: OrderPaymentMethod.card,
    status: OrderStatus.refunded,
    customerName: 'Walk-in',
    cashierName: 'Archie Gonzales',
    subtotal: 28.00,
    tax: 3.36,
    items: [
      OrderItem(
        productSku: 'ELEC-002',
        productName: 'Phone Charger',
        productEmoji: '🔋',
        sellOptionId: 'so-elec-002-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 18.99,
        qty: 1,
      ),
      OrderItem(
        productSku: 'BEV-002',
        productName: 'Sparkling Water',
        productEmoji: '💧',
        sellOptionId: 'so-bev-002-1',
        sellOptionLabel: 'each',
        baseQty: 1,
        price: 2.25,
        qty: 4,
      ),
    ],
  ),
];
