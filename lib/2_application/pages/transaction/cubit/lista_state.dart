part of 'lista_cubit.dart';

enum ListaFilter { all, withBalance, overdue, paidUp }

enum ListaSort { largestBalance, mostRecent, oldest }

/// How long before an outstanding balance is considered overdue (days).
const int kOverdueDays = 30;

class CustomerSummary extends Equatable {
  const CustomerSummary({
    required this.customer,
    required this.balance,
    required this.lastActivity,
    required this.daysSinceLastActivity,
    required this.isOverdue,
    required this.entries,
  });

  final Customer customer;
  final double balance;
  final DateTime? lastActivity;
  final int daysSinceLastActivity;
  final bool isOverdue;
  final List<LedgerEntry> entries;

  bool get isPaidUp => balance <= 0.001;

  @override
  List<Object?> get props =>
      [customer.id, balance, lastActivity, isOverdue, entries.length];
}

sealed class ListaState extends Equatable {
  const ListaState({
    required this.customers,
    required this.entries,
    required this.searchQuery,
    required this.filter,
    required this.sort,
    required this.today,
  });

  final List<Customer> customers;
  final List<LedgerEntry> entries;
  final String searchQuery;
  final ListaFilter filter;
  final ListaSort sort;
  final DateTime today;

  List<CustomerSummary> get allSummaries {
    return customers.map((c) {
      final entries = this.entries.where((e) => e.customerId == c.id).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final balance =
          entries.fold<double>(0, (sum, e) => sum + e.signedAmount);
      final lastActivity = entries.isEmpty ? null : entries.first.createdAt;
      final days = lastActivity == null
          ? -1
          : today.difference(lastActivity).inDays;
      final isOverdue = balance > 0.001 && days >= kOverdueDays;
      return CustomerSummary(
        customer: c,
        balance: balance,
        lastActivity: lastActivity,
        daysSinceLastActivity: days,
        isOverdue: isOverdue,
        entries: entries,
      );
    }).toList();
  }

  List<CustomerSummary> get filteredSummaries {
    final query = searchQuery.trim().toLowerCase();
    var list = allSummaries.where((s) {
      switch (filter) {
        case ListaFilter.all:
          break;
        case ListaFilter.withBalance:
          if (s.isPaidUp) return false;
          break;
        case ListaFilter.overdue:
          if (!s.isOverdue) return false;
          break;
        case ListaFilter.paidUp:
          if (!s.isPaidUp) return false;
          break;
      }
      if (query.isEmpty) return true;
      return s.customer.name.toLowerCase().contains(query) ||
          s.customer.phone.contains(query);
    }).toList();

    list.sort((a, b) {
      switch (sort) {
        case ListaSort.largestBalance:
          final cmp = b.balance.compareTo(a.balance);
          if (cmp != 0) return cmp;
          return a.customer.name.compareTo(b.customer.name);
        case ListaSort.mostRecent:
          final aDate = a.lastActivity ?? DateTime(1970);
          final bDate = b.lastActivity ?? DateTime(1970);
          return bDate.compareTo(aDate);
        case ListaSort.oldest:
          final aDate = a.lastActivity ?? DateTime(2999);
          final bDate = b.lastActivity ?? DateTime(2999);
          return aDate.compareTo(bDate);
      }
    });
    return list;
  }

  double get totalOutstanding =>
      allSummaries.fold<double>(0, (sum, s) => sum + (s.balance > 0 ? s.balance : 0));

  int get customersWithBalance =>
      allSummaries.where((s) => !s.isPaidUp).length;

  double get largestBalance => allSummaries.isEmpty
      ? 0
      : allSummaries.map((s) => s.balance).reduce((a, b) => a > b ? a : b);

  int get overdueCount => allSummaries.where((s) => s.isOverdue).length;

  @override
  List<Object?> get props =>
      [customers, entries, searchQuery, filter, sort, today];
}

class ListaLoaded extends ListaState {
  const ListaLoaded({
    required super.customers,
    required super.entries,
    required super.searchQuery,
    required super.filter,
    required super.sort,
    required super.today,
  });
}
