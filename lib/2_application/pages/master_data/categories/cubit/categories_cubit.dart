import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../1_domain/entities/category.dart';
import '../../../../../1_domain/entities/product.dart';

part 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit()
      : super(const CategoriesLoaded(
          categories: kSeedCategories,
          products: kSeedProducts,
          searchQuery: '',
          statusFilter: CategoryStatusFilter.all,
        ));

  void search(String q) => _emit(searchQuery: q);
  void setStatusFilter(CategoryStatusFilter f) => _emit(statusFilter: f);

  void addCategory({
    required String name,
    required String emoji,
    required CategoryColor color,
  }) {
    final id = 'cat-${DateTime.now().microsecondsSinceEpoch}';
    final nextSort = state.categories.isEmpty
        ? 0
        : state.categories.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b) +
            1;
    final cat = Category(
      id: id,
      name: name.trim(),
      emoji: emoji,
      color: color,
      sortOrder: nextSort,
    );
    _emit(categories: [...state.categories, cat]);
  }

  void updateCategory({
    required String id,
    required String name,
    required String emoji,
    required CategoryColor color,
  }) {
    final next = state.categories
        .map((c) => c.id == id
            ? c.copyWith(name: name.trim(), emoji: emoji, color: color)
            : c)
        .toList();
    _emit(categories: next);
  }

  void toggleArchive(String id) {
    final next = state.categories
        .map((c) => c.id == id ? c.copyWith(isArchived: !c.isArchived) : c)
        .toList();
    _emit(categories: next);
  }

  void deleteCategory(String id) {
    final next = state.categories.where((c) => c.id != id).toList();
    _emit(categories: next);
  }

  /// Does any product still reference this category by name?
  bool isCategoryInUse(Category cat) =>
      state.products.any((p) => p.category == cat.name);

  /// Returns true if the name conflicts with an existing one (excluding `selfId`).
  bool isNameTaken(String name, {String? selfId}) {
    final n = name.trim().toLowerCase();
    return state.categories.any(
      (c) => c.id != selfId && c.name.toLowerCase() == n,
    );
  }

  void _emit({
    List<Category>? categories,
    List<Product>? products,
    String? searchQuery,
    CategoryStatusFilter? statusFilter,
  }) {
    emit(CategoriesLoaded(
      categories: categories ?? state.categories,
      products: products ?? state.products,
      searchQuery: searchQuery ?? state.searchQuery,
      statusFilter: statusFilter ?? state.statusFilter,
    ));
  }
}
