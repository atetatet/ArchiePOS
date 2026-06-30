part of 'products_list_cubit.dart';

enum StockFilter { all, inStock, lowStock, outOfStock }

enum ProductSort { nameAsc, nameDesc, priceAsc, priceDesc, stockAsc, stockDesc }

sealed class ProductsListState extends Equatable {
  const ProductsListState({
    required this.products,
    required this.searchQuery,
    required this.selectedCategory,
    required this.stockFilter,
    required this.sort,
  });

  final List<Product> products;
  final String searchQuery;
  final String selectedCategory;
  final StockFilter stockFilter;
  final ProductSort sort;

  int get totalProducts => products.length;
  int get lowStockCount =>
      products.where((p) => p.isLowStock && !p.isOutOfStock).length;
  int get outOfStockCount => products.where((p) => p.isOutOfStock).length;

  List<Product> get filteredProducts {
    final query = searchQuery.trim().toLowerCase();
    var list = products.where((p) {
      final inCategory =
          selectedCategory == 'All' || p.category == selectedCategory;
      if (!inCategory) return false;

      switch (stockFilter) {
        case StockFilter.all:
          break;
        case StockFilter.inStock:
          if (p.isLowStock || p.isOutOfStock) return false;
          break;
        case StockFilter.lowStock:
          if (!p.isLowStock || p.isOutOfStock) return false;
          break;
        case StockFilter.outOfStock:
          if (!p.isOutOfStock) return false;
          break;
      }

      if (query.isEmpty) return true;
      return p.name.toLowerCase().contains(query) ||
          p.sku.toLowerCase().contains(query);
    }).toList();

    list.sort((a, b) {
      switch (sort) {
        case ProductSort.nameAsc:
          return a.name.compareTo(b.name);
        case ProductSort.nameDesc:
          return b.name.compareTo(a.name);
        case ProductSort.priceAsc:
          return a.price.compareTo(b.price);
        case ProductSort.priceDesc:
          return b.price.compareTo(a.price);
        case ProductSort.stockAsc:
          return a.stock.compareTo(b.stock);
        case ProductSort.stockDesc:
          return b.stock.compareTo(a.stock);
      }
    });

    return list;
  }

  @override
  List<Object?> get props =>
      [products, searchQuery, selectedCategory, stockFilter, sort];
}

class ProductsListLoaded extends ProductsListState {
  const ProductsListLoaded({
    required super.products,
    required super.searchQuery,
    required super.selectedCategory,
    required super.stockFilter,
    required super.sort,
  });
}
