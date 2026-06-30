import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../1_domain/entities/order.dart';

part 'order_list_state.dart';

class OrderListCubit extends Cubit<OrderListState> {
  OrderListCubit({OrderStatus? defaultStatus})
      : super(OrderListLoaded(
          orders: kSeedOrders,
          searchQuery: '',
          statusFilter: defaultStatus,
          paymentFilter: null,
          dateRange: DateRangeFilter.all,
          sort: OrderSort.newest,
          today: DateTime.parse('2026-06-15T23:59:59'),
        ));

  void search(String q) => _emit(searchQuery: q);
  void setStatusFilter(OrderStatus? status) =>
      _emit(statusFilter: status, clearStatus: status == null);
  void setPaymentFilter(OrderPaymentMethod? method) =>
      _emit(paymentFilter: method, clearPayment: method == null);
  void setDateRange(DateRangeFilter range) => _emit(dateRange: range);
  void setSort(OrderSort sort) => _emit(sort: sort);

  void _emit({
    List<Order>? orders,
    String? searchQuery,
    OrderStatus? statusFilter,
    OrderPaymentMethod? paymentFilter,
    DateRangeFilter? dateRange,
    OrderSort? sort,
    bool clearStatus = false,
    bool clearPayment = false,
  }) {
    emit(OrderListLoaded(
      orders: orders ?? state.orders,
      searchQuery: searchQuery ?? state.searchQuery,
      statusFilter:
          clearStatus ? null : (statusFilter ?? state.statusFilter),
      paymentFilter:
          clearPayment ? null : (paymentFilter ?? state.paymentFilter),
      dateRange: dateRange ?? state.dateRange,
      sort: sort ?? state.sort,
      today: state.today,
    ));
  }
}
