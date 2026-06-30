part of 'customers_cubit.dart';

enum CustomerFilter { all, withBalance, settled, cashOnly, newThisMonth }

enum CustomerSort { lifetimeDesc, lifetimeAsc, recentActivity, oldestActivity, nameAsc }

class CustomerProfile extends Equatable {
  const CustomerProfile({
    required this.customer,
    required this.balance,
    required this.lifetimeSpend,
    required this.lifetimeOrders,
    required this.lastActivity,
    required this.daysSinceLastActivity,
    required this.entries,
    required this.orders,
  });

  final Customer customer;

  /// Current utang balance.
  final double balance;

  /// Sum of all orders ever made by this customer (excluding refunded).
  final double lifetimeSpend;
  final int lifetimeOrders;

  /// Latest of any activity — last order OR last ledger entry.
  final DateTime? lastActivity;
  final int daysSinceLastActivity;

  final List<LedgerEntry> entries;
  final List<Order> orders;

  bool get hasBalance => balance > 0.001;
  bool get isSettled => !hasBalance && lifetimeOrders > 0;
  bool get isCashOnly => entries.isEmpty && orders.isNotEmpty;
  bool get isNoActivity => entries.isEmpty && orders.isEmpty;
  bool get hasUtangHistory => entries.isNotEmpty;

  @override
  List<Object?> get props => [customer.id, balance, lifetimeSpend];
}

sealed class CustomersState extends Equatable {
  const CustomersState({
    required this.customers,
    required this.entries,
    required this.orders,
    required this.searchQuery,
    required this.filter,
    required this.sort,
    required this.today,
  });

  final List<Customer> customers;
  final List<LedgerEntry> entries;
  final List<Order> orders;
  final String searchQuery;
  final CustomerFilter filter;
  final CustomerSort sort;
  final DateTime today;

  List<CustomerProfile> get allProfiles {
    return customers.map((c) {
      final myEntries = entries.where((e) => e.customerId == c.id).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final balance =
          myEntries.fold<double>(0, (sum, e) => sum + e.signedAmount);
      final myOrders = orders.where((o) => o.customerId == c.id).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final lifetimeSpend = myOrders
          .where((o) => !o.isRefunded)
          .fold<double>(0, (sum, o) => sum + o.total);

      DateTime? lastActivity;
      if (myEntries.isNotEmpty) lastActivity = myEntries.first.createdAt;
      if (myOrders.isNotEmpty) {
        final od = myOrders.first.createdAt;
        if (lastActivity == null || od.isAfter(lastActivity)) lastActivity = od;
      }
      final days = lastActivity == null
          ? -1
          : today.difference(lastActivity).inDays;

      return CustomerProfile(
        customer: c,
        balance: balance,
        lifetimeSpend: lifetimeSpend,
        lifetimeOrders: myOrders.where((o) => !o.isRefunded).length,
        lastActivity: lastActivity,
        daysSinceLastActivity: days,
        entries: myEntries,
        orders: myOrders,
      );
    }).toList();
  }

  List<CustomerProfile> get filteredProfiles {
    final query = searchQuery.trim().toLowerCase();
    final startOfMonth = DateTime(today.year, today.month, 1);
    var list = allProfiles.where((p) {
      switch (filter) {
        case CustomerFilter.all:
          break;
        case CustomerFilter.withBalance:
          if (!p.hasBalance) return false;
          break;
        case CustomerFilter.settled:
          if (!p.isSettled && p.balance != 0) return false;
          if (p.hasBalance) return false;
          break;
        case CustomerFilter.cashOnly:
          if (!p.isCashOnly) return false;
          break;
        case CustomerFilter.newThisMonth:
          if (p.customer.createdAt.isBefore(startOfMonth)) return false;
          break;
      }
      if (query.isEmpty) return true;
      return p.customer.name.toLowerCase().contains(query) ||
          p.customer.phone.contains(query);
    }).toList();

    list.sort((a, b) {
      switch (sort) {
        case CustomerSort.lifetimeDesc:
          return b.lifetimeSpend.compareTo(a.lifetimeSpend);
        case CustomerSort.lifetimeAsc:
          return a.lifetimeSpend.compareTo(b.lifetimeSpend);
        case CustomerSort.recentActivity:
          final aDate = a.lastActivity ?? DateTime(1970);
          final bDate = b.lastActivity ?? DateTime(1970);
          return bDate.compareTo(aDate);
        case CustomerSort.oldestActivity:
          final aDate = a.lastActivity ?? DateTime(2999);
          final bDate = b.lastActivity ?? DateTime(2999);
          return aDate.compareTo(bDate);
        case CustomerSort.nameAsc:
          return a.customer.name.compareTo(b.customer.name);
      }
    });
    return list;
  }

  // ─ Summary metrics ─
  int get totalCustomers => customers.length;

  int get withBalanceCount =>
      allProfiles.where((p) => p.hasBalance).length;

  int get activeThisMonthCount {
    final cutoff = today.subtract(const Duration(days: 30));
    return allProfiles
        .where((p) =>
            p.lastActivity != null && p.lastActivity!.isAfter(cutoff))
        .length;
  }

  int get newThisMonthCount {
    final startOfMonth = DateTime(today.year, today.month, 1);
    return customers
        .where((c) => !c.createdAt.isBefore(startOfMonth))
        .length;
  }

  @override
  List<Object?> get props => [
        customers,
        entries,
        orders,
        searchQuery,
        filter,
        sort,
        today,
      ];
}

class CustomersLoaded extends CustomersState {
  const CustomersLoaded({
    required super.customers,
    required super.entries,
    required super.orders,
    required super.searchQuery,
    required super.filter,
    required super.sort,
    required super.today,
  });
}
