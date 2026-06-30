import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../1_domain/entities/customer.dart';
import '../../../../1_domain/entities/ledger_entry.dart';

part 'lista_state.dart';

class ListaCubit extends Cubit<ListaState> {
  ListaCubit()
      : super(ListaLoaded(
          customers: kSeedCustomers,
          entries: List.of(kSeedLedger),
          searchQuery: '',
          filter: ListaFilter.all,
          sort: ListaSort.largestBalance,
          today: DateTime.parse('2026-06-15T12:00:00'),
        ));

  void search(String query) => _emit(searchQuery: query);
  void setFilter(ListaFilter filter) => _emit(filter: filter);
  void setSort(ListaSort sort) => _emit(sort: sort);

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
    String? searchQuery,
    ListaFilter? filter,
    ListaSort? sort,
  }) {
    emit(ListaLoaded(
      customers: customers ?? state.customers,
      entries: entries ?? state.entries,
      searchQuery: searchQuery ?? state.searchQuery,
      filter: filter ?? state.filter,
      sort: sort ?? state.sort,
      today: state.today,
    ));
  }
}
