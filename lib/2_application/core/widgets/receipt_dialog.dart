import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../1_domain/entities/order.dart';
import '../services/app_routes.dart';
import '../utils/money.dart';
import '../../theme/app_colors.dart';
import 'receipt_preview_dialog.dart';

class ReceiptDialog extends StatelessWidget {
  const ReceiptDialog({super.key, required this.order, this.showCompletedBanner = false});
  final Order order;

  /// When true (post-charge flow), shows a green "Sale completed!" banner at the top.
  final bool showCompletedBanner;

  static final _dateFmt = DateFormat('MMM d, yyyy — h:mm a');

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 760),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCompletedBanner) const _CompletedBanner(),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              order.id,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 10),
                            ReceiptStatusPill(status: order.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _dateFmt.format(order.createdAt),
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12.5),
                        ),
                        if (order.cashierName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Cashier: ${order.cashierName}',
                            style: const TextStyle(
                                color: AppColors.textTertiary, fontSize: 11.5),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Customer / payment row
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline,
                      color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.customerName ?? 'Walk-in',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ReceiptPaymentBadge(method: order.paymentMethod),
                  const SizedBox(width: 8),
                  Text(
                    paymentLabel(order.paymentMethod),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Items
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: order.items.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: AppColors.darkDivider,
                ),
                itemBuilder: (context, i) {
                  final item = order.items[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Text(item.productEmoji,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.displayLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${Money.format(item.price)} × ${item.qty}',
                                style: const TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          Money.format(item.lineTotal),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Totals + actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.darkDivider, width: 1),
                ),
              ),
              child: Column(
                children: [
                  _TotalRow(label: 'Subtotal', value: Money.format(order.subtotal)),
                  const SizedBox(height: 4),
                  _TotalRow(label: 'Tax', value: Money.format(order.tax)),
                  const SizedBox(height: 8),
                  Container(height: 1, color: AppColors.darkDivider),
                  const SizedBox(height: 8),
                  _TotalRow(
                    label: 'Total',
                    value: Money.format(order.total),
                    big: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openPrintPreview(context),
                          icon: const Icon(Icons.receipt_long_outlined, size: 16),
                          label: const Text('Print / Share'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.darkBorder),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            textStyle: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (order.isLista)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _viewLista(context),
                            icon: const Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 16),
                            label: const Text('View Lista'),
                          ),
                        )
                      else if (!order.isRefunded)
                        Expanded(
                          child: showCompletedBanner
                              ? ElevatedButton.icon(
                                  onPressed: () =>
                                      Navigator.of(context).pop(),
                                  icon: const Icon(Icons.check, size: 16),
                                  label: const Text('Done'),
                                )
                              : OutlinedButton.icon(
                                  onPressed: () =>
                                      _stubAction(context, 'Refund / void'),
                                  icon: const Icon(Icons.undo, size: 16),
                                  label: const Text('Refund'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.danger,
                                    side: const BorderSide(
                                        color: AppColors.danger),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    textStyle: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                        )
                      else
                        const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _stubAction(BuildContext context, String label) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — coming soon'),
        backgroundColor: AppColors.darkSurfaceElevated,
      ),
    );
  }

  void _openPrintPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => ReceiptPreviewDialog(order: order),
    );
  }

  void _viewLista(BuildContext context) {
    Navigator.of(context).pop();
    context.go(AppRoutes.transaction);
  }
}

class _CompletedBanner extends StatelessWidget {
  const _CompletedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.check_circle, color: AppColors.success, size: 18),
          SizedBox(width: 8),
          Text(
            'Sale completed!',
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class ReceiptPaymentBadge extends StatelessWidget {
  const ReceiptPaymentBadge({super.key, required this.method});
  final OrderPaymentMethod method;

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final Color color;
    switch (method) {
      case OrderPaymentMethod.cash:
        icon = Icons.payments_outlined;
        color = AppColors.success;
        break;
      case OrderPaymentMethod.card:
        icon = Icons.credit_card;
        color = AppColors.info;
        break;
      case OrderPaymentMethod.mobile:
        icon = Icons.smartphone;
        color = const Color(0xFF8B5CF6);
        break;
      case OrderPaymentMethod.lista:
        icon = Icons.account_balance_wallet_outlined;
        color = AppColors.brandAmber;
        break;
    }
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class ReceiptStatusPill extends StatelessWidget {
  const ReceiptStatusPill({super.key, required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;
    switch (status) {
      case OrderStatus.completed:
        label = 'Completed';
        color = AppColors.success;
        break;
      case OrderStatus.lista:
        label = 'Lista';
        color = AppColors.brandAmber;
        break;
      case OrderStatus.refunded:
        label = 'Refunded';
        color = AppColors.textTertiary;
        break;
      case OrderStatus.voided:
        label = 'Voided';
        color = AppColors.danger;
        break;
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

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value, this.big = false});
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
            fontSize: big ? 20 : 13.5,
            fontWeight: big ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

String paymentLabel(OrderPaymentMethod m) {
  switch (m) {
    case OrderPaymentMethod.cash:
      return 'Cash';
    case OrderPaymentMethod.card:
      return 'Card';
    case OrderPaymentMethod.mobile:
      return 'Mobile';
    case OrderPaymentMethod.lista:
      return 'Lista';
  }
}
