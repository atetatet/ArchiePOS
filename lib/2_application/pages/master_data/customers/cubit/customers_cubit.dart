import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../1_domain/entities/customer.dart';
import '../../../../../1_domain/entities/ledger_entry.dart';
import '../../../../../1_domain/entities/order.dart';

part 'customers_state.dart';

class CustomersCubit extends Cubit<CustomersState> {
  CustomersCubit()
      : super(CustomersLoaded(
          customers: kSeedCustomers,
          entries: List.of(kSeedLedger),
          orders: kSeedOrders,
          searchQuery: '',
          filter: CustomerFilter.all,
          sort: CustomerSort.lifetimeDesc,
          today: DateTime.parse('2026-06-15T23:59:59'),
        ));

  void search(String q) => _emit(searchQuery: q);
  void setFilter(CustomerFilter f) => _emit(filter: f);
  void setSort(CustomerSort s) => _emit(sort: s);

  void addRepayment({
    required String customerId,
    required double amount,
    String? notes,
  }) {
    if (amount <= 0) return;
    final entry = LedgerEntry(
      id: 'led-${DateTime.now().microsecondsSinceEpoch}',
      customerId: customerId,
      kind: LedgerKind.repayment,
      amount: amount,
      createdAtIso: state.today.toIso8601String(),
      notes: notes,
    );
    _emit(entries: [...state.entries, entry]);
  }

  void _emit({
    List<Customer>? customers,
    List<LedgerEntry>? entries,
    List<Order>? orders,
    String? searchQuery,
    CustomerFilter? filter,
    CustomerSort? sort,
  }) {
    emit(CustomersLoaded(
      customers: customers ?? state.customers,
      entries: entries ?? state.entries,
      orders: orders ?? state.orders,
      searchQuery: searchQuery ?? state.searchQuery,
      filter: filter ?? state.filter,
      sort: sort ?? state.sort,
      today: state.today,
    ));
  }
}
