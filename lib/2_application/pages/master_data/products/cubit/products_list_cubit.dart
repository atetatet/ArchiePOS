import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../1_domain/entities/product.dart';

part 'products_list_state.dart';

class ProductsListCubit extends Cubit<ProductsListState> {
  ProductsListCubit() : super(const ProductsListLoaded(
        products: kSeedProducts,
        searchQuery: '',
        selectedCategory: 'All',
        stockFilter: StockFilter.all,
        sort: ProductSort.nameAsc,
      ));

  void search(String query) => _emit(searchQuery: query);
  void selectCategory(String category) => _emit(selectedCategory: category);
  void setStockFilter(StockFilter filter) => _emit(stockFilter: filter);
  void setSort(ProductSort sort) => _emit(sort: sort);

  void _emit({
    List<Product>? products,
    String? searchQuery,
    String? selectedCategory,
    StockFilter? stockFilter,
    ProductSort? sort,
  }) {
    emit(ProductsListLoaded(
      products: products ?? state.products,
      searchQuery: searchQuery ?? state.searchQuery,
      selectedCategory: selectedCategory ?? state.selectedCategory,
      stockFilter: stockFilter ?? state.stockFilter,
      sort: sort ?? state.sort,
    ));
  }
}
