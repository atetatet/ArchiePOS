part of 'order_list_cubit.dart';

enum DateRangeFilter { today, week, month, all }

enum OrderSort { newest, oldest, highest, lowest }

sealed class OrderListState extends Equatable {
  const OrderListState({
    required this.orders,
    required this.searchQuery,
    required this.statusFilter,
    required this.paymentFilter,
    required this.dateRange,
    required this.sort,
    required this.today,
  });

  final List<Order> orders;
  final String searchQuery;

  /// null = "All"
  final OrderStatus? statusFilter;

  /// null = "All"
  final OrderPaymentMethod? paymentFilter;

  final DateRangeFilter dateRange;
  final OrderSort sort;
  final DateTime today;

  List<Order> get filteredOrders {
    final query = searchQuery.trim().toLowerCase();
    final startOfToday =
        DateTime(today.year, today.month, today.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));

    bool inRange(DateTime d) {
      switch (dateRange) {
        case DateRangeFilter.all:
          return true;
        case DateRangeFilter.today:
          return !d.isBefore(startOfToday) && d.isBefore(endOfToday);
        case DateRangeFilter.week:
          return !d.isBefore(startOfToday.subtract(const Duration(days: 7)));
        case DateRangeFilter.month:
          return !d.isBefore(startOfToday.subtract(const Duration(days: 30)));
      }
    }

    var list = orders.where((o) {
      if (statusFilter != null && o.status != statusFilter) return false;
      if (paymentFilter != null && o.paymentMethod != paymentFilter) return false;
      if (!inRange(o.createdAt)) return false;
      if (query.isEmpty) return true;
      return o.id.toLowerCase().contains(query) ||
          (o.customerName?.toLowerCase().contains(query) ?? false);
    }).toList();

    list.sort((a, b) {
      switch (sort) {
        case OrderSort.newest:
          return b.createdAt.compareTo(a.createdAt);
        case OrderSort.oldest:
          return a.createdAt.compareTo(b.createdAt);
        case OrderSort.highest:
          return b.total.compareTo(a.total);
        case OrderSort.lowest:
          return a.total.compareTo(b.total);
      }
    });
    return list;
  }

  // ─ summary metrics (always over today, regardless of filter) ─
  List<Order> get _todayOrders {
    final startOfToday =
        DateTime(today.year, today.month, today.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));
    return orders
        .where((o) =>
            !o.createdAt.isBefore(startOfToday) &&
            o.createdAt.isBefore(endOfToday) &&
            !o.isRefunded)
        .toList();
  }

  double get todaySales =>
      _todayOrders.fold<double>(0, (sum, o) => sum + o.total);

  int get todayOrderCount => _todayOrders.length;

  double get averageOrder =>
      _todayOrders.isEmpty ? 0 : todaySales / _todayOrders.length;

  double get pendingLista => orders
      .where((o) => o.isLista)
      .fold<double>(0, (sum, o) => sum + o.total);

  @override
  List<Object?> get props => [
        orders,
        searchQuery,
        statusFilter,
        paymentFilter,
        dateRange,
        sort,
        today,
      ];
}

class OrderListLoaded extends OrderListState {
  const OrderListLoaded({
    required super.orders,
    required super.searchQuery,
    required super.statusFilter,
    required super.paymentFilter,
    required super.dateRange,
    required super.sort,
    required super.today,
  });
}
