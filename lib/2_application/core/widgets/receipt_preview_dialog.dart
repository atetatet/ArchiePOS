import 'package:flutter/material.dart';

import '../../../1_domain/entities/order.dart';
import '../../theme/app_colors.dart';
import 'printable_receipt.dart';

/// Shows the thermal-style receipt in a centered modal with print / share actions.
class ReceiptPreviewDialog extends StatelessWidget {
  const ReceiptPreviewDialog({super.key, required this.order, this.tendered});
  final Order order;
  final double? tendered;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkBg,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 780),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(order: order),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                child: Center(
                  child: PrintableReceipt(order: order, tendered: tendered),
                ),
              ),
            ),
            _Actions(order: order),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.brandAmber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.receipt_long,
                color: AppColors.brandAmber, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Receipt — ${order.id}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'Preview before printing or sending',
                  style: TextStyle(
                      color: AppColors.textTertiary, fontSize: 11.5),
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

class _Actions extends StatelessWidget {
  const _Actions({required this.order});
  final Order order;

  void _stub(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — needs printer/cloud wiring'),
        backgroundColor: AppColors.darkSurfaceElevated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _stub(context, 'Print to thermal printer'),
              icon: const Icon(Icons.print_outlined, size: 18),
              label: const Text('Print'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _stub(context, 'Download as PDF'),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
              label: const Text('PDF'),
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
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _stub(context, 'Share via SMS / GCash'),
              icon: const Icon(Icons.share_outlined, size: 16),
              label: const Text('Share'),
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
        ],
      ),
    );
  }
}
