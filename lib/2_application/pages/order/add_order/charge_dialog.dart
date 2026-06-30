import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../1_domain/entities/customer.dart';
import '../../../../1_domain/entities/order.dart';
import '../../../core/utils/money.dart';
import '../../../theme/app_colors.dart';
import 'cubit/add_order_cubit.dart';

void openChargeDialog(BuildContext context) {
  final cubit = context.read<AddOrderCubit>();
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => BlocProvider.value(
      value: cubit,
      child: const ChargeDialog(),
    ),
  );
}

class ChargeDialog extends StatefulWidget {
  const ChargeDialog({super.key});
  @override
  State<ChargeDialog> createState() => _ChargeDialogState();
}

class _ChargeDialogState extends State<ChargeDialog> {
  final _tenderedCtrl = TextEditingController();
  String? _customerId;
  String? _error;

  @override
  void dispose() {
    _tenderedCtrl.dispose();
    super.dispose();
  }

  double? _tendered() => double.tryParse(_tenderedCtrl.text.trim());

  void _setQuick(double amount) {
    setState(() {
      _tenderedCtrl.text = amount.toStringAsFixed(2);
      _error = null;
    });
  }

  void _submit(BuildContext context, AddOrderState state) {
    final method = state.paymentMethod;
    final err = context.read<AddOrderCubit>().charge(
          customerId: _customerId,
          tendered: method == OrderPaymentMethod.cash ? _tendered() : null,
        );
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddOrderCubit, AddOrderState>(
      builder: (context, state) {
        final method = state.paymentMethod;
        final tendered = _tendered();
        final total = method == OrderPaymentMethod.lista
            ? state.subtotal
            : state.total;
        final change = tendered == null ? 0.0 : tendered - state.total;
        final taxPct = (state.taxRate * 100).round();
        return Dialog(
          backgroundColor: AppColors.darkSurface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480, maxHeight: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
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
                          color: AppColors.brandAmber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.payments_outlined,
                            color: AppColors.brandAmber),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Complete Sale',
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
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.darkBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _DialogRow(
                          label: 'Subtotal',
                          value: Money.format(state.subtotal),
                        ),
                        const SizedBox(height: 4),
                        _DialogRow(
                          label: method == OrderPaymentMethod.lista
                              ? 'Tax (waived for lista)'
                              : 'Tax ($taxPct%)',
                          value: Money.format(
                              method == OrderPaymentMethod.lista
                                  ? 0
                                  : state.tax),
                        ),
                        const SizedBox(height: 8),
                        Container(height: 1, color: AppColors.darkDivider),
                        const SizedBox(height: 8),
                        _DialogRow(
                          label: 'Total',
                          value: Money.format(total),
                          big: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'PAYMENT METHOD',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MethodChips(method: method),
                  const SizedBox(height: 16),
                  if (method == OrderPaymentMethod.cash)
                    _CashTendered(
                      ctrl: _tenderedCtrl,
                      total: state.total,
                      change: change,
                      onChanged: () => setState(() => _error = null),
                      onQuick: _setQuick,
                    )
                  else if (method == OrderPaymentMethod.lista)
                    _ListaCustomerPicker(
                      selectedId: _customerId,
                      onSelected: (id) => setState(() {
                        _customerId = id;
                        _error = null;
                      }),
                    )
                  else
                    _CardOrMobileNote(method: method),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
                      ElevatedButton.icon(
                        onPressed: () => _submit(context, state),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text('Complete Sale'),
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

class _MethodChips extends StatelessWidget {
  const _MethodChips({required this.method});
  final OrderPaymentMethod method;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddOrderCubit>();
    Widget chip(OrderPaymentMethod m, IconData icon, String label) {
      final selected = m == method;
      return Expanded(
        child: GestureDetector(
          onTap: () => cubit.selectPayment(m),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.brandAmber : AppColors.darkBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? AppColors.textOnPrimary
                      : AppColors.textSecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? AppColors.textOnPrimary
                        : AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip(OrderPaymentMethod.cash, Icons.payments_outlined, 'Cash'),
        const SizedBox(width: 6),
        chip(OrderPaymentMethod.card, Icons.credit_card, 'Card'),
        const SizedBox(width: 6),
        chip(OrderPaymentMethod.mobile, Icons.smartphone, 'Mobile'),
        const SizedBox(width: 6),
        chip(OrderPaymentMethod.lista, Icons.account_balance_wallet_outlined,
            'Lista'),
      ],
    );
  }
}

class _DialogRow extends StatelessWidget {
  const _DialogRow({required this.label, required this.value, this.big = false});
  final String label;
  final String value;
  final bool big;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: big ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: big ? 15 : 13,
            fontWeight: big ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: big ? AppColors.brandAmber : AppColors.textPrimary,
            fontSize: big ? 22 : 13.5,
            fontWeight: big ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CashTendered extends StatelessWidget {
  const _CashTendered({
    required this.ctrl,
    required this.total,
    required this.change,
    required this.onChanged,
    required this.onQuick,
  });
  final TextEditingController ctrl;
  final double total;
  final double change;
  final VoidCallback onChanged;
  final ValueChanged<double> onQuick;

  @override
  Widget build(BuildContext context) {
    final hasInput = ctrl.text.isNotEmpty;
    final enough = hasInput && change >= -0.001;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Amount Tendered',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          onChanged: (_) => onChanged(),
          style:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          decoration: InputDecoration(
            hintText: '0.00',
            prefixText: '${Money.currencySymbol}  ',
            prefixStyle: const TextStyle(
                color: AppColors.brandAmber, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final amt in const [50.0, 100.0, 200.0, 500.0, 1000.0])
              OutlinedButton(
                onPressed: () => onQuick(amt),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandAmber,
                  side: const BorderSide(color: AppColors.darkBorder),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                ),
                child: Text(Money.format(amt)),
              ),
            OutlinedButton(
              onPressed: () => onQuick(total),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandAmber,
                side: const BorderSide(color: AppColors.brandAmber),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700),
              ),
              child: const Text('Exact'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (enough ? AppColors.success : AppColors.danger)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                enough ? Icons.check_circle : Icons.error_outline,
                color: enough ? AppColors.success : AppColors.danger,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasInput
                      ? (enough ? 'Change Due' : 'Short by')
                      : 'Enter amount received',
                  style: TextStyle(
                    color: enough ? AppColors.success : AppColors.danger,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                hasInput ? Money.format(change.abs()) : '—',
                style: TextStyle(
                  color: enough ? AppColors.success : AppColors.danger,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ListaCustomerPicker extends StatelessWidget {
  const _ListaCustomerPicker({
    required this.selectedId,
    required this.onSelected,
  });
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Customer',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.darkBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedId,
              isExpanded: true,
              isDense: true,
              hint: const Text(
                'Pick a customer (required for lista)',
                style:
                    TextStyle(color: AppColors.textTertiary, fontSize: 13.5),
              ),
              dropdownColor: AppColors.darkSurfaceElevated,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 14),
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.textTertiary),
              items: [
                for (final c in kSeedCustomers)
                  DropdownMenuItem(
                    value: c.id,
                    child: Text('${c.name}  •  ${c.phone}'),
                  ),
              ],
              onChanged: onSelected,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.brandAmber.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: const [
              Icon(Icons.info_outline,
                  color: AppColors.brandAmber, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "This sale is added to the customer's utang. No tax is applied — they pay when they repay.",
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 11.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardOrMobileNote extends StatelessWidget {
  const _CardOrMobileNote({required this.method});
  final OrderPaymentMethod method;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            method == OrderPaymentMethod.card
                ? Icons.credit_card
                : Icons.smartphone,
            color: AppColors.info,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              method == OrderPaymentMethod.card
                  ? 'Swipe / tap card on the terminal, then confirm below.'
                  : 'Customer scans GCash / Maya QR, then confirm below.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
