import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../1_domain/entities/order.dart';
import '../../../core/services/app_routes.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/receipt_dialog.dart';
import '../../../theme/app_colors.dart';
import 'cubit/order_list_cubit.dart';

class OrderListPage extends StatelessWidget {
  const OrderListPage({super.key, this.defaultStatus, this.titleOverride});

  /// When set, the cubit starts with this status filter applied (used by
  /// /order/order-completed).
  final OrderStatus? defaultStatus;
  final String? titleOverride;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderListCubit(defaultStatus: defaultStatus),
      child: _OrderListView(titleOverride: titleOverride),
    );
  }
}

class _OrderListView extends StatelessWidget {
  const _OrderListView({this.titleOverride});
  final String? titleOverride;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderListCubit, OrderListState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(title: titleOverride ?? 'Order List'),
              const SizedBox(height: 20),
              _SummaryRow(state: state),
              const SizedBox(height: 20),
              _FilterBar(state: state),
              const SizedBox(height: 14),
              _DateChips(state: state),
              const SizedBox(height: 16),
              _OrdersList(state: state),
            ],
          ),
        );
      },
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              const Text(
                'Sales history, receipts, and refunds',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => context.go(AppRoutes.orderAdd),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('New Order'),
        ),
      ],
    );
  }
}

// ─── Summary ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.state});
  final OrderListState state;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryCard(
        icon: Icons.account_balance_wallet_outlined,
        iconColor: AppColors.brandAmber,
        label: "Today's Sales",
        value: Money.format(state.todaySales),
      ),
      _SummaryCard(
        icon: Icons.receipt_long_outlined,
        iconColor: const Color(0xFF3B82F6),
        label: "Today's Orders",
        value: state.todayOrderCount.toString(),
      ),
      _SummaryCard(
        icon: Icons.trending_up,
        iconColor: const Color(0xFF8B5CF6),
        label: 'Average Order',
        value: Money.format(state.averageOrder),
      ),
      _SummaryCard(
        icon: Icons.schedule,
        iconColor: AppColors.danger,
        label: 'Pending Lista',
        value: Money.format(state.pendingLista),
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
  final OrderListState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OrderListCubit>();
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 900;
        final search = TextField(
          onChanged: cubit.search,
          decoration: const InputDecoration(
            hintText: 'Search by order # or customer…',
            prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
          ),
        );
        final statusChips = _StatusChips(status: state.statusFilter);
        final payment = _PaymentDropdown(method: state.paymentFilter);
        final sort = _SortDropdown(sort: state.sort);

        if (wide) {
          return Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: 12),
              statusChips,
              const SizedBox(width: 12),
              SizedBox(width: 170, child: payment),
              const SizedBox(width: 12),
              sort,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            search,
            const SizedBox(height: 10),
            SingleChildScrollView(
                scrollDirection: Axis.horizontal, child: statusChips),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: payment),
                const SizedBox(width: 10),
                Expanded(child: sort),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StatusChips extends StatelessWidget {
  const _StatusChips({required this.status});
  final OrderStatus? status;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OrderListCubit>();
    Widget chip(OrderStatus? value, String label) {
      final selected = status == value;
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => cubit.setStatusFilter(value),
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
        chip(null, 'All'),
        chip(OrderStatus.completed, 'Completed'),
        chip(OrderStatus.lista, 'Lista'),
        chip(OrderStatus.refunded, 'Refunded'),
      ],
    );
  }
}

class _PaymentDropdown extends StatelessWidget {
  const _PaymentDropdown({required this.method});
  final OrderPaymentMethod? method;

  static const Map<OrderPaymentMethod, String> _labels = {
    OrderPaymentMethod.cash: 'Cash',
    OrderPaymentMethod.card: 'Card',
    OrderPaymentMethod.mobile: 'Mobile',
    OrderPaymentMethod.lista: 'Lista',
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OrderListCubit>();
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
            const Icon(Icons.payments_outlined,
                size: 18, color: AppColors.textTertiary),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<OrderPaymentMethod?>(
                value: method,
                isExpanded: true,
                isDense: true,
                dropdownColor: AppColors.darkSurfaceElevated,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13.5),
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.textTertiary, size: 18),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All methods')),
                  for (final e in _labels.entries)
                    DropdownMenuItem(value: e.key, child: Text(e.value)),
                ],
                onChanged: cubit.setPaymentFilter,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.sort});
  final OrderSort sort;

  static const Map<OrderSort, String> _labels = {
    OrderSort.newest: 'Newest first',
    OrderSort.oldest: 'Oldest first',
    OrderSort.highest: 'Highest total',
    OrderSort.lowest: 'Lowest total',
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OrderListCubit>();
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
            DropdownButton<OrderSort>(
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

class _DateChips extends StatelessWidget {
  const _DateChips({required this.state});
  final OrderListState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OrderListCubit>();
    Widget chip(DateRangeFilter f, String label) {
      final selected = state.dateRange == f;
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => cubit.setDateRange(f),
          backgroundColor: AppColors.darkBg,
          selectedColor: AppColors.brandAmber.withValues(alpha: 0.18),
          labelStyle: TextStyle(
            color: selected ? AppColors.brandAmber : AppColors.textTertiary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
          showCheckmark: false,
          side: BorderSide(
              color: selected ? AppColors.brandAmber : AppColors.darkBorder),
        ),
      );
    }

    return Row(
      children: [
        const Icon(Icons.calendar_today_outlined,
            size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 6),
        const Text(
          'Range:',
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        chip(DateRangeFilter.today, 'Today'),
        chip(DateRangeFilter.week, 'Last 7 days'),
        chip(DateRangeFilter.month, 'Last 30 days'),
        chip(DateRangeFilter.all, 'All time'),
      ],
    );
  }
}

// ─── Orders list ───────────────────────────────────────────────────────────

class _OrdersList extends StatelessWidget {
  const _OrdersList({required this.state});
  final OrderListState state;

  @override
  Widget build(BuildContext context) {
    final orders = state.filteredOrders;
    if (orders.isEmpty) {
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
                'No orders match your filters',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final o in orders)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OrderRow(order: o),
          ),
      ],
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});
  final Order order;

  static final _dateFmt = DateFormat('MMM d, h:mm a');

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.darkSurface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openReceipt(context, order),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReceiptPaymentBadge(method: order.paymentMethod),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          order.id,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ReceiptStatusPill(status: order.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 12, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          order.customerName ?? 'Walk-in',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time,
                            size: 12, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          _dateFmt.format(order.createdAt),
                          style: const TextStyle(
                              color: AppColors.textTertiary, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _itemsSummary(order),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11.5,
                      ),
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
                    Money.format(order.total),
                    style: TextStyle(
                      color: order.isRefunded
                          ? AppColors.textSecondary
                          : AppColors.brandAmber,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      decoration: order.isRefunded
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.itemCount} item${order.itemCount == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right,
                  color: AppColors.textTertiary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  static String _itemsSummary(Order o) {
    final names = o.items.map((i) => i.productName).take(3).join(', ');
    if (o.items.length > 3) return '$names, +${o.items.length - 3} more';
    return names;
  }

  void _openReceipt(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (ctx) => ReceiptDialog(order: order),
    );
  }
}
