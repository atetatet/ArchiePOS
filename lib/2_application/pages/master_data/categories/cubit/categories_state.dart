part of 'categories_cubit.dart';

enum CategoryStatusFilter { all, active, archived }

class CategoryUsage extends Equatable {
  const CategoryUsage({required this.category, required this.productCount});
  final Category category;
  final int productCount;
  @override
  List<Object?> get props => [category.id, productCount];
}

sealed class CategoriesState extends Equatable {
  const CategoriesState({
    required this.categories,
    required this.products,
    required this.searchQuery,
    required this.statusFilter,
  });

  final List<Category> categories;
  final List<Product> products;
  final String searchQuery;
  final CategoryStatusFilter statusFilter;

  List<CategoryUsage> get allUsage {
    return categories.map((c) {
      final count = products.where((p) => p.category == c.name).length;
      return CategoryUsage(category: c, productCount: count);
    }).toList();
  }

  List<CategoryUsage> get filteredUsage {
    final query = searchQuery.trim().toLowerCase();
    return allUsage
        .where((u) {
          switch (statusFilter) {
            case CategoryStatusFilter.all:
              break;
            case CategoryStatusFilter.active:
              if (u.category.isArchived) return false;
              break;
            case CategoryStatusFilter.archived:
              if (!u.category.isArchived) return false;
              break;
          }
          if (query.isEmpty) return true;
          return u.category.name.toLowerCase().contains(query);
        })
        .toList()
      ..sort((a, b) =>
          a.category.sortOrder.compareTo(b.category.sortOrder));
  }

  int get totalCount => categories.length;
  int get activeCount => categories.where((c) => !c.isArchived).length;
  int get archivedCount => categories.where((c) => c.isArchived).length;
  int get inUseCount => allUsage.where((u) => u.productCount > 0).length;

  @override
  List<Object?> get props =>
      [categories, products, searchQuery, statusFilter];
}

class CategoriesLoaded extends CategoriesState {
  const CategoriesLoaded({
    required super.categories,
    required super.products,
    required super.searchQuery,
    required super.statusFilter,
  });
}
