import 'package:equatable/equatable.dart';

class SellOption extends Equatable {
  const SellOption({
    required this.id,
    required this.label,
    required this.baseQty,
    required this.price,
  });

  /// Unique within a product.
  final String id;

  /// User-facing name shown on POS and cart line (e.g. "1 kg", "½ kg", "each").
  final String label;

  /// How many base units this option consumes. 1.0 for non-tingi, 0.5 for "½ kg", etc.
  final double baseQty;

  /// Selling price for this option, in ₱.
  final double price;

  @override
  List<Object?> get props => [id, label, baseQty, price];
}

class Product extends Equatable {
  const Product({
    required this.sku,
    required this.name,
    required this.category,
    required this.stock,
    required this.lowStockThreshold,
    required this.emoji,
    required this.sellOptions,
    this.baseUnit,
    this.description,
  });

  final String sku;
  final String name;
  final String category;

  /// Current stock, in base units. Always tracked as a double — even non-tingi
  /// products (where the base unit is "piece") use whole-number doubles so the
  /// math stays consistent for tingi products that can have fractional stock.
  final double stock;
  final double lowStockThreshold;
  final String emoji;
  final String? baseUnit;
  final String? description;

  /// Always at least one entry. Non-tingi products have exactly one with
  /// `label: 'each'` and `baseQty: 1.0`.
  final List<SellOption> sellOptions;

  bool get isTingi => sellOptions.length > 1;
  bool get isOutOfStock => stock <= 0;
  bool get isLowStock => stock <= lowStockThreshold;

  /// Convenience for screens that just need "the product's price" (POS card,
  /// list view, etc). Returns the first sell option's price.
  double get price =>
      sellOptions.isEmpty ? 0 : sellOptions.first.price;

  /// Lowest price across sell options — useful for "from ₱X" displays.
  double get lowestPrice => sellOptions.isEmpty
      ? 0
      : sellOptions.map((o) => o.price).reduce((a, b) => a < b ? a : b);

  /// Highest price across sell options.
  double get highestPrice => sellOptions.isEmpty
      ? 0
      : sellOptions.map((o) => o.price).reduce((a, b) => a > b ? a : b);

  SellOption get defaultSellOption => sellOptions.first;

  @override
  List<Object?> get props => [sku];
}

const List<Product> kSeedProducts = [
  Product(
    sku: 'BEV-001', name: 'Cold Brew Coffee', category: 'Beverages',
    stock: 24, lowStockThreshold: 10, emoji: '☕',
    sellOptions: [SellOption(id: 'so-bev-001-1', label: 'each', baseQty: 1, price: 4.50)],
  ),
  Product(
    sku: 'BEV-002', name: 'Sparkling Water', category: 'Beverages',
    stock: 48, lowStockThreshold: 10, emoji: '💧',
    sellOptions: [SellOption(id: 'so-bev-002-1', label: 'each', baseQty: 1, price: 2.25)],
  ),
  Product(
    sku: 'BEV-003', name: 'Orange Juice', category: 'Beverages',
    stock: 16, lowStockThreshold: 10, emoji: '🍊',
    sellOptions: [SellOption(id: 'so-bev-003-1', label: 'each', baseQty: 1, price: 3.75)],
  ),
  Product(
    sku: 'BEV-004', name: 'Energy Drink', category: 'Beverages',
    stock: 6, lowStockThreshold: 10, emoji: '⚡',
    sellOptions: [SellOption(id: 'so-bev-004-1', label: 'each', baseQty: 1, price: 3.50)],
  ),
  Product(
    sku: 'FOOD-001', name: 'Avocado Toast', category: 'Food',
    stock: 12, lowStockThreshold: 10, emoji: '🥑',
    sellOptions: [SellOption(id: 'so-food-001-1', label: 'each', baseQty: 1, price: 8.50)],
  ),
  Product(
    sku: 'FOOD-002', name: 'Granola Bar', category: 'Food',
    stock: 60, lowStockThreshold: 10, emoji: '🌾',
    sellOptions: [SellOption(id: 'so-food-002-1', label: 'each', baseQty: 1, price: 2.75)],
  ),
  Product(
    sku: 'FOOD-003', name: 'Banana', category: 'Food',
    stock: 40, lowStockThreshold: 10, emoji: '🍌',
    sellOptions: [SellOption(id: 'so-food-003-1', label: 'each', baseQty: 1, price: 0.75)],
  ),
  Product(
    sku: 'FOOD-004', name: 'Greek Yogurt', category: 'Food',
    stock: 8, lowStockThreshold: 10, emoji: '🥛',
    sellOptions: [SellOption(id: 'so-food-004-1', label: 'each', baseQty: 1, price: 4.25)],
  ),
  // Tingi demo — sack of rice sold per kilo / half / quarter
  Product(
    sku: 'FOOD-005', name: 'Bigas (Sinandomeng)', category: 'Food',
    stock: 47, lowStockThreshold: 5, emoji: '🍚',
    baseUnit: 'kg',
    description: 'Sinandomeng rice. Sold per kilo, ½ kilo, or ¼ kilo.',
    sellOptions: [
      SellOption(id: 'so-food-005-1', label: '1 kg', baseQty: 1.0, price: 60),
      SellOption(id: 'so-food-005-2', label: '½ kg', baseQty: 0.5, price: 32),
      SellOption(id: 'so-food-005-3', label: '¼ kg', baseQty: 0.25, price: 17),
    ],
  ),
  Product(
    sku: 'HLTH-001', name: 'Hand Sanitizer', category: 'Health',
    stock: 35, lowStockThreshold: 10, emoji: '🧴',
    sellOptions: [SellOption(id: 'so-hlth-001-1', label: 'each', baseQty: 1, price: 3.99)],
  ),
  Product(
    sku: 'HLTH-002', name: 'Lip Balm', category: 'Health',
    stock: 22, lowStockThreshold: 10, emoji: '💋',
    sellOptions: [SellOption(id: 'so-hlth-002-1', label: 'each', baseQty: 1, price: 2.50)],
  ),
  Product(
    sku: 'HLTH-003', name: 'Aspirin 20ct', category: 'Health',
    stock: 4, lowStockThreshold: 10, emoji: '💊',
    sellOptions: [SellOption(id: 'so-hlth-003-1', label: 'each', baseQty: 1, price: 5.49)],
  ),
  Product(
    sku: 'ELEC-001', name: 'USB-C Cable', category: 'Electronics',
    stock: 8, lowStockThreshold: 10, emoji: '🔌',
    sellOptions: [SellOption(id: 'so-elec-001-1', label: 'each', baseQty: 1, price: 12.99)],
  ),
  Product(
    sku: 'ELEC-002', name: 'Phone Charger', category: 'Electronics',
    stock: 0, lowStockThreshold: 10, emoji: '🔋',
    sellOptions: [SellOption(id: 'so-elec-002-1', label: 'each', baseQty: 1, price: 18.99)],
  ),
  Product(
    sku: 'STAT-001', name: 'Notebook A5', category: 'Stationery',
    stock: 25, lowStockThreshold: 10, emoji: '📓',
    sellOptions: [SellOption(id: 'so-stat-001-1', label: 'each', baseQty: 1, price: 4.99)],
  ),
  Product(
    sku: 'STAT-002', name: 'Ballpoint Pen', category: 'Stationery',
    stock: 80, lowStockThreshold: 10, emoji: '🖊',
    sellOptions: [SellOption(id: 'so-stat-002-1', label: 'each', baseQty: 1, price: 1.25)],
  ),
  Product(
    sku: 'STAT-003', name: 'Sticky Notes', category: 'Stationery',
    stock: 30, lowStockThreshold: 10, emoji: '🗒',
    sellOptions: [SellOption(id: 'so-stat-003-1', label: 'each', baseQty: 1, price: 3.49)],
  ),
];

const List<String> kProductCategories = [
  'All',
  'Beverages',
  'Food',
  'Health',
  'Electronics',
  'Stationery',
];
