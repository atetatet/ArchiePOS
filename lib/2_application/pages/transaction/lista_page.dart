import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../1_domain/entities/ledger_entry.dart';
import '../../core/utils/money.dart';
import '../../theme/app_colors.dart';
import 'cubit/lista_cubit.dart';

class ListaPage extends StatelessWidget {
  const ListaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ListaCubit(),
      child: const _ListaView(),
    );
  }
}

class _ListaView extends StatelessWidget {
  const _ListaView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListaCubit, ListaState>(
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
              Text('Lista / Utang Ledger',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              const Text(
                'Track customer credit, repayments, and outstanding balances',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Record Credit Sale — opens POS in lista mode (coming soon)'),
                backgroundColor: AppColors.darkSurfaceElevated,
              ),
            );
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Record Credit Sale'),
        ),
      ],
    );
  }
}

// ─── Summary cards ─────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.state});
  final ListaState state;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryCard(
        icon: Icons.account_balance_wallet_outlined,
        iconColor: AppColors.brandAmber,
        label: 'Total Outstanding',
        value: Money.format(state.totalOutstanding),
      ),
      _SummaryCard(
        icon: Icons.people_outline,
        iconColor: const Color(0xFF3B82F6),
        label: 'Customers w/ Balance',
        value: state.customersWithBalance.toString(),
      ),
      _SummaryCard(
        icon: Icons.trending_up,
        iconColor: const Color(0xFF8B5CF6),
        label: 'Largest Balance',
        value: Money.format(state.largestBalance),
      ),
      _SummaryCard(
        icon: Icons.schedule,
        iconColor: AppColors.danger,
        label: 'Overdue (>$kOverdueDays days)',
        value: state.overdueCount.toString(),
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
  final ListaState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ListaCubit>();
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
  final ListaFilter filter;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ListaCubit>();
    Widget chip(ListaFilter f, String label) {
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
        chip(ListaFilter.all, 'All'),
        chip(ListaFilter.withBalance, 'With Balance'),
        chip(ListaFilter.overdue, 'Overdue'),
        chip(ListaFilter.paidUp, 'Paid Up'),
      ],
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.sort});
  final ListaSort sort;

  static const Map<ListaSort, String> _labels = {
    ListaSort.largestBalance: 'Largest balance',
    ListaSort.mostRecent: 'Most recent',
    ListaSort.oldest: 'Oldest',
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ListaCubit>();
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
            DropdownButton<ListaSort>(
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
              onChanged: (v) {
                if (v != null) cubit.setSort(v);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Customer list ─────────────────────────────────────────────────────────

class _CustomerList extends StatelessWidget {
  const _CustomerList({required this.state});
  final ListaState state;

  @override
  Widget build(BuildContext context) {
    final summaries = state.filteredSummaries;
    if (summaries.isEmpty) {
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
        for (final s in summaries)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CustomerCard(summary: s),
          ),
      ],
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.summary});
  final CustomerSummary summary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.darkSurface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openDetail(context, summary),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _Avatar(name: summary.customer.name),
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
                            summary.customer.name,
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
                        _StatusPill(summary: summary),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone,
                            size: 12, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          summary.customer.phone,
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
                          summary.lastActivity == null
                              ? 'No activity'
                              : _relativeDate(summary.daysSinceLastActivity),
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
                    Money.format(summary.balance),
                    style: TextStyle(
                      color: summary.isPaidUp
                          ? AppColors.textSecondary
                          : summary.isOverdue
                              ? AppColors.danger
                              : AppColors.brandAmber,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary.isPaidUp ? 'Settled' : 'Outstanding',
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              if (!summary.isPaidUp)
                OutlinedButton(
                  onPressed: () => _openPayment(context, summary),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brandAmber,
                    side: const BorderSide(color: AppColors.brandAmber),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Pay'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, CustomerSummary s) {
    final cubit = context.read<ListaCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: CustomerDetailDialog(customerId: s.customer.id),
      ),
    );
  }

  void _openPayment(BuildContext context, CustomerSummary s) {
    final cubit = context.read<ListaCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: AddPaymentDialog(customerId: s.customer.id),
      ),
    );
  }

  static String _relativeDate(int days) {
    if (days <= 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return '$days days ago';
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.summary});
  final CustomerSummary summary;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;
    if (summary.isPaidUp) {
      label = 'Paid Up';
      color = AppColors.success;
    } else if (summary.isOverdue) {
      label = 'Overdue';
      color = AppColors.danger;
    } else {
      label = 'Current';
      color = AppColors.info;
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

// ─── Customer detail dialog ────────────────────────────────────────────────

class CustomerDetailDialog extends StatelessWidget {
  const CustomerDetailDialog({super.key, required this.customerId});
  final String customerId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListaCubit, ListaState>(
      builder: (context, state) {
        final summary = state.allSummaries.firstWhere(
          (s) => s.customer.id == customerId,
        );
        return Dialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogHeader(summary: summary),
                _DialogActions(summary: summary),
                const Divider(height: 1),
                Flexible(
                  child: _HistoryList(entries: summary.entries),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.summary});
  final CustomerSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _Avatar(name: summary.customer.name),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  summary.customer.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  summary.customer.phone,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12.5,
                  ),
                ),
                if (summary.customer.address != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    summary.customer.address!,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'BALANCE',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                Money.format(summary.balance),
                style: TextStyle(
                  color: summary.isPaidUp
                      ? AppColors.success
                      : summary.isOverdue
                          ? AppColors.danger
                          : AppColors.brandAmber,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              _StatusPill(summary: summary),
            ],
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _DialogActions extends StatelessWidget {
  const _DialogActions({required this.summary});
  final CustomerSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: summary.isPaidUp
                  ? null
                  : () {
                      final cubit = context.read<ListaCubit>();
                      showDialog(
                        context: context,
                        builder: (dialogContext) => BlocProvider.value(
                          value: cubit,
                          child: AddPaymentDialog(
                              customerId: summary.customer.id),
                        ),
                      );
                    },
              icon: const Icon(Icons.payments_outlined, size: 18),
              label: const Text('Add Payment'),
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
                        'Open POS for ${summary.customer.name} (lista mode) — coming soon'),
                    backgroundColor: AppColors.darkSurfaceElevated,
                  ),
                );
              },
              icon: const Icon(Icons.add_shopping_cart, size: 18),
              label: const Text('Add Credit Sale'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandAmber,
                side: const BorderSide(color: AppColors.brandAmber),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.entries});
  final List<LedgerEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No transactions yet',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    final fmt = DateFormat('MMM d, yyyy — h:mm a');
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final e = entries[i];
        final isSale = e.kind == LedgerKind.sale;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.darkBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (isSale ? AppColors.danger : AppColors.success)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isSale ? Icons.shopping_basket : Icons.payments_outlined,
                  color: isSale ? AppColors.danger : AppColors.success,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isSale ? 'Credit Sale' : 'Repayment',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      e.notes ?? fmt.format(e.createdAt),
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11.5,
                      ),
                    ),
                    if (e.notes != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        fmt.format(e.createdAt),
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '${isSale ? '+' : '-'}${Money.format(e.amount)}',
                style: TextStyle(
                  color: isSale ? AppColors.danger : AppColors.success,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Add payment dialog ────────────────────────────────────────────────────

class AddPaymentDialog extends StatefulWidget {
  const AddPaymentDialog({super.key, required this.customerId});
  final String customerId;

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, CustomerSummary summary) {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid amount');
      return;
    }
    if (amount > summary.balance + 0.001) {
      setState(() =>
          _error = 'Amount exceeds balance (${Money.format(summary.balance)})');
      return;
    }
    context.read<ListaCubit>().addRepayment(
          customerId: widget.customerId,
          amount: amount,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${Money.format(amount)} payment recorded for ${summary.customer.name}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListaCubit, ListaState>(
      builder: (context, state) {
        final summary = state.allSummaries.firstWhere(
          (s) => s.customer.id == widget.customerId,
        );
        return Dialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
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
                            '${summary.customer.name} owes',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          Money.format(summary.balance),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _QuickAmount(
                        label: 'Full',
                        onTap: () => setState(() {
                          _amountCtrl.text = summary.balance.toStringAsFixed(2);
                          _error = null;
                        }),
                      ),
                      const SizedBox(width: 6),
                      _QuickAmount(
                        label: 'Half',
                        onTap: () => setState(() {
                          _amountCtrl.text =
                              (summary.balance / 2).toStringAsFixed(2);
                          _error = null;
                        }),
                      ),
                    ],
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
                    decoration: const InputDecoration(
                      hintText: 'e.g. paid via GCash',
                    ),
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
                        onPressed: () => _submit(context, summary),
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

class _QuickAmount extends StatelessWidget {
  const _QuickAmount({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.darkBg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.brandAmber,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
