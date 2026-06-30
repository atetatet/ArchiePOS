import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../1_domain/entities/ledger_entry.dart';
import '../../../../1_domain/entities/order.dart';
import '../../../core/services/app_routes.dart';
import '../../../core/utils/money.dart';
import '../../../theme/app_colors.dart';
import 'cubit/customers_cubit.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomersCubit(),
      child: const _CustomersView(),
    );
  }
}

class _CustomersView extends StatelessWidget {
  const _CustomersView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomersCubit, CustomersState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Header(),
              const SizedBox(height: 20),
              _SummaryRow(state: state),
              const SizedBox(height: 20),
              _FilterBar(state: state),
              const SizedBox(height: 16),
              _CustomerList(state: state),
            ],
          ),
        );
      },
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customers',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              const Text(
                'Manage your suki — contact info, lista balance, and purchase history',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13.5),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => context.go(AppRoutes.masterDataCustomersAdd),
          icon: const Icon(Icons.person_add_alt, size: 18),
          label: const Text('Add Customer'),
        ),
      ],
    );
  }
}

// ─── Summary ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.state});
  final CustomersState state;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryCard(
        icon: Icons.people_outline,
        iconColor: const Color(0xFF3B82F6),
        label: 'Total Customers',
        value: state.totalCustomers.toString(),
      ),
      _SummaryCard(
        icon: Icons.account_balance_wallet_outlined,
        iconColor: AppColors.brandAmber,
        label: 'With Balance',
        value: state.withBalanceCount.toString(),
      ),
      _SummaryCard(
        icon: Icons.bolt_outlined,
        iconColor: AppColors.success,
        label: 'Active (30 days)',
        value: state.activeThisMonthCount.toString(),
      ),
      _SummaryCard(
        icon: Icons.person_add_alt_1,
        iconColor: const Color(0xFF8B5CF6),
        label: 'New This Month',
        value: state.newThisMonthCount.toString(),
      ),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 1100
            ? 4
            : c.maxWidth >= 640
                ? 2
                : 1;
        const gap = 14.0;
        final available = c.maxWidth - gap * (cols - 1);
        final cardW = (available <= 0 ? c.maxWidth : available) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children:
              cards.map((w) => SizedBox(width: cardW, child: w)).toList(),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter bar ────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.state});
  final CustomersState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CustomersCubit>();
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 900;
        final search = TextField(
          onChanged: cubit.search,
          decoration: const InputDecoration(
            hintText: 'Search by name or phone…',
            prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
          ),
        );
        final chips = _FilterChips(filter: state.filter);
        final sort = _SortDropdown(sort: state.sort);
        if (wide) {
          return Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: 12),
              chips,
              const SizedBox(width: 12),
              sort,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            search,
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: chips,
            ),
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: sort),
          ],
        );
      },
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.filter});
  final CustomerFilter filter;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CustomersCubit>();
    Widget chip(CustomerFilter f, String label) {
      final selected = f == filter;
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => cubit.setFilter(f),
          backgroundColor: AppColors.darkSurface,
          selectedColor: AppColors.brandAmber,
          labelStyle: TextStyle(
            color: selected ? AppColors.textOnPrimary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12.5,
          ),
          showCheckmark: false,
          side: BorderSide.none,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        chip(CustomerFilter.all, 'All'),
        chip(CustomerFilter.withBalance, 'With Balance'),
        chip(CustomerFilter.settled, 'Settled'),
        chip(CustomerFilter.cashOnly, 'Cash Only'),
        chip(CustomerFilter.newThisMonth, 'New This Month'),
      ],
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.sort});
  final CustomerSort sort;

  static const Map<CustomerSort, String> _labels = {
    CustomerSort.lifetimeDesc: 'Lifetime spend ↓',
    CustomerSort.lifetimeAsc: 'Lifetime spend ↑',
    CustomerSort.recentActivity: 'Recent activity',
    CustomerSort.oldestActivity: 'Oldest activity',
    CustomerSort.nameAsc: 'Name (A–Z)',
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CustomersCubit>();
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: Row(
          children: [
            const Icon(Icons.sort, size: 18, color: AppColors.textTertiary),
            const SizedBox(width: 8),
            DropdownButton<CustomerSort>(
              value: sort,
              isDense: true,
              dropdownColor: AppColors.darkSurfaceElevated,
              style:
                  const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.textTertiary, size: 18),
              items: [
                for (final e in _labels.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) => v == null ? null : cubit.setSort(v),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Customer rows ─────────────────────────────────────────────────────────

class _CustomerList extends StatelessWidget {
  const _CustomerList({required this.state});
  final CustomersState state;

  @override
  Widget build(BuildContext context) {
    final list = state.filteredProfiles;
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined,
                  color: AppColors.textTertiary, size: 32),
              SizedBox(height: 8),
              Text(
                'No customers match your filters',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final p in list)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CustomerCard(profile: p),
          ),
      ],
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.profile});
  final CustomerProfile profile;

  static String _relativeDate(int days) {
    if (days < 0) return 'No activity';
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return '$days days ago';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.darkSurface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openProfile(context, profile),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _Avatar(name: profile.customer.name),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            profile.customer.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _ProfilePill(profile: profile),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone,
                            size: 12, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          profile.customer.phone,
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Icon(Icons.access_time,
                            size: 12, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          _relativeDate(profile.daysSinceLastActivity),
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Money.format(profile.lifetimeSpend),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${profile.lifetimeOrders} order${profile.lifetimeOrders == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              if (profile.hasBalance)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.brandAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined,
                          size: 14, color: AppColors.brandAmber),
                      const SizedBox(width: 4),
                      Text(
                        Money.format(profile.balance),
                        style: const TextStyle(
                          color: AppColors.brandAmber,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  color: AppColors.textTertiary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _openProfile(BuildContext context, CustomerProfile p) {
    final cubit = context.read<CustomersCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: CustomerProfileDialog(customerId: p.customer.id),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.brandAmber, AppColors.brandAmberDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({required this.profile});
  final CustomerProfile profile;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;
    if (profile.hasBalance) {
      label = 'Lista';
      color = AppColors.brandAmber;
    } else if (profile.isSettled) {
      label = 'Settled';
      color = AppColors.success;
    } else if (profile.isCashOnly) {
      label = 'Cash regular';
      color = const Color(0xFF3B82F6);
    } else {
      label = 'New';
      color = const Color(0xFF8B5CF6);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Customer profile dialog ───────────────────────────────────────────────

class CustomerProfileDialog extends StatelessWidget {
  const CustomerProfileDialog({super.key, required this.customerId});
  final String customerId;

  static final _fmtFull = DateFormat('MMM d, yyyy');
  static final _fmtShort = DateFormat('MMM d, h:mm a');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomersCubit, CustomersState>(
      builder: (context, state) {
        final p = state.allProfiles
            .firstWhere((x) => x.customer.id == customerId);
        return Dialog(
          backgroundColor: AppColors.darkSurface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640, maxHeight: 760),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ProfileHeader(profile: p),
                const Divider(height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _StatsRow(profile: p),
                        const SizedBox(height: 18),
                        _ActionsBar(profile: p),
                        const SizedBox(height: 18),
                        if (p.orders.isNotEmpty) ...[
                          _SectionLabel(
                            label: 'RECENT ORDERS',
                            trailing: '${p.orders.length} total',
                          ),
                          const SizedBox(height: 8),
                          _OrdersPreview(orders: p.orders.take(4).toList()),
                          const SizedBox(height: 18),
                        ],
                        if (p.entries.isNotEmpty) ...[
                          _SectionLabel(
                            label: 'LISTA / UTANG HISTORY',
                            trailing: '${p.entries.length} entries',
                          ),
                          const SizedBox(height: 8),
                          _LedgerPreview(entries: p.entries.take(6).toList()),
                        ],
                        if (p.orders.isEmpty && p.entries.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            alignment: Alignment.center,
                            child: const Column(
                              children: [
                                Icon(Icons.history,
                                    size: 28, color: AppColors.textTertiary),
                                SizedBox(height: 8),
                                Text(
                                  'No purchase history yet',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});
  final CustomerProfile profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(name: profile.customer.name),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        profile.customer.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _ProfilePill(profile: profile),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone,
                        size: 13, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      profile.customer.phone,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
                if (profile.customer.address != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          profile.customer.address!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  'Customer since ${CustomerProfileDialog._fmtFull.format(profile.customer.createdAt)}',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profile});
  final CustomerProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            label: 'Balance',
            value: Money.format(profile.balance),
            color: profile.hasBalance
                ? AppColors.brandAmber
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBox(
            label: 'Lifetime',
            value: Money.format(profile.lifetimeSpend),
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBox(
            label: 'Orders',
            value: profile.lifetimeOrders.toString(),
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionsBar extends StatelessWidget {
  const _ActionsBar({required this.profile});
  final CustomerProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: profile.hasBalance
              ? ElevatedButton.icon(
                  onPressed: () => _openPayment(context, profile),
                  icon: const Icon(Icons.payments_outlined, size: 18),
                  label: const Text('Record Payment'),
                )
              : OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go(AppRoutes.editCustomer(profile.customer.id));
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Customer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.darkBorder),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Add credit sale for ${profile.customer.name} — coming soon'),
                  backgroundColor: AppColors.darkSurfaceElevated,
                ),
              );
            },
            icon: const Icon(Icons.add_shopping_cart, size: 18),
            label: const Text('Add Lista'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brandAmber,
              side: const BorderSide(color: AppColors.brandAmber),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.transaction);
            },
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('View Lista'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.darkBorder),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              textStyle:
                  const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _openPayment(BuildContext context, CustomerProfile profile) {
    final cubit = context.read<CustomersCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: _PaymentDialog(customerId: profile.customer.id),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.trailing});
  final String label;
  final String? trailing;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11.5,
            ),
          ),
      ],
    );
  }
}

class _OrdersPreview extends StatelessWidget {
  const _OrdersPreview({required this.orders});
  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final o in orders)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _orderStatusColor(o).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _orderStatusIcon(o),
                      color: _orderStatusColor(o),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          o.id,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${CustomerProfileDialog._fmtShort.format(o.createdAt)} · ${o.itemCount} item${o.itemCount == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    Money.format(o.total),
                    style: TextStyle(
                      color: o.isRefunded
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      decoration: o.isRefunded
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  static Color _orderStatusColor(Order o) {
    if (o.isRefunded) return AppColors.textTertiary;
    if (o.isLista) return AppColors.brandAmber;
    return AppColors.success;
  }

  static IconData _orderStatusIcon(Order o) {
    if (o.isRefunded) return Icons.undo;
    if (o.isLista) return Icons.account_balance_wallet_outlined;
    return Icons.check;
  }
}

class _LedgerPreview extends StatelessWidget {
  const _LedgerPreview({required this.entries});
  final List<LedgerEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.darkBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: (e.kind == LedgerKind.sale
                              ? AppColors.danger
                              : AppColors.success)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      e.kind == LedgerKind.sale
                          ? Icons.shopping_basket
                          : Icons.payments_outlined,
                      color: e.kind == LedgerKind.sale
                          ? AppColors.danger
                          : AppColors.success,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          e.kind == LedgerKind.sale
                              ? 'Credit Sale'
                              : 'Repayment',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          e.notes ??
                              CustomerProfileDialog._fmtShort
                                  .format(e.createdAt),
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${e.kind == LedgerKind.sale ? '+' : '-'}${Money.format(e.amount)}',
                    style: TextStyle(
                      color: e.kind == LedgerKind.sale
                          ? AppColors.danger
                          : AppColors.success,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Payment dialog (mirror of lista_page's, scoped to CustomersCubit) ────

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({required this.customerId});
  final String customerId;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, CustomerProfile p) {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid amount');
      return;
    }
    if (amount > p.balance + 0.001) {
      setState(() =>
          _error = 'Amount exceeds balance (${Money.format(p.balance)})');
      return;
    }
    context.read<CustomersCubit>().addRepayment(
          customerId: widget.customerId,
          amount: amount,
          notes:
              _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${Money.format(amount)} payment recorded for ${p.customer.name}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomersCubit, CustomersState>(
      builder: (context, state) {
        final p = state.allProfiles
            .firstWhere((x) => x.customer.id == widget.customerId);
        return Dialog(
          backgroundColor: AppColors.darkSurface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.payments_outlined,
                            color: AppColors.success),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Record Payment',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: AppColors.textSecondary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${p.customer.name} owes',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          Money.format(p.balance),
                          style: const TextStyle(
                            color: AppColors.brandAmber,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Payment Amount',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _amountCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixText: '${Money.currencySymbol}  ',
                      prefixStyle: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  const Text(
                    'Notes (optional)',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _notesCtrl,
                    decoration:
                        const InputDecoration(hintText: 'e.g. paid via GCash'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        onPressed: () => _submit(context, p),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('Record Payment'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
