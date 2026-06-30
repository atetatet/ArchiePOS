import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../1_domain/entities/order.dart';
import '../utils/money.dart';

/// Paper-style thermal receipt — 320px wide, white background, monospace.
/// Used inside [ReceiptPreviewDialog] and the eventual print pipeline.
class PrintableReceipt extends StatelessWidget {
  const PrintableReceipt({
    super.key,
    required this.order,
    this.storeName = "Aling Nena's Sari-Sari",
    this.storeAddress = 'Purok 2, Brgy. Santo Niño, Davao City',
    this.storePhone = '+63 917 123 4567',
    this.footerText = 'Salamat po! ❤️',
    this.tendered,
  });

  final Order order;
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final String footerText;
  final double? tendered;

  static const _paperWidth = 320.0;
  static const _paper = Color(0xFFFFFFFF);
  static const _ink = Color(0xFF111111);
  static const _muted = Color(0xFF555555);

  static final _dateFmt = DateFormat('MMM d, yyyy  hh:mm a');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _paperWidth,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: _ink,
          fontSize: 11.5,
          fontFamily: 'monospace',
          height: 1.45,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Store header
            Text(
              storeName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _ink,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 2),
            Text(storeAddress, textAlign: TextAlign.center),
            Text(storePhone, textAlign: TextAlign.center),

            const _Divider(),

            // Order metadata
            _Row(label: order.id, value: _dateFmt.format(order.createdAt)),
            _Row(
              label: 'Cashier',
              value: order.cashierName ?? '—',
            ),
            _Row(
              label: 'Customer',
              value: order.customerName ?? 'Walk-in',
            ),

            const _Divider(),

            // Item header
            const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'ITEM',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _ink,
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                    ),
                  ),
                ),
                SizedBox(
                  width: 30,
                  child: Text(
                    'QTY',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _ink,
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                    ),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    'TOTAL',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _ink,
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Item lines
            for (final item in order.items) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.displayLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _ink,
                        fontFamily: 'monospace',
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      '  @ ${Money.format(item.price)}',
                      style: const TextStyle(
                        color: _muted,
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${item.qty}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: _ink,
                        fontFamily: 'monospace',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text(
                      Money.format(item.lineTotal),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: _ink,
                        fontFamily: 'monospace',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
            ],

            const _Divider(),

            // Totals
            _Row(label: 'Subtotal', value: Money.format(order.subtotal)),
            if (order.tax > 0)
              _Row(label: 'Tax', value: Money.format(order.tax)),

            const _Divider(thick: true),

            _Row(
              label: 'TOTAL',
              value: Money.format(order.total),
              bold: true,
              big: true,
            ),

            const _Divider(),

            // Payment
            _Row(label: 'Payment', value: _paymentLabel(order.paymentMethod)),
            if (tendered != null) ...[
              _Row(label: 'Tendered', value: Money.format(tendered!)),
              _Row(
                label: 'Change',
                value: Money.format((tendered! - order.total).clamp(0, double.infinity)),
                bold: true,
              ),
            ],
            if (order.isLista)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  '** ON LISTA **',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _ink,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            if (order.isRefunded)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  '** REFUNDED **',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _ink,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

            const _Divider(),

            // Footer
            const SizedBox(height: 6),
            Text(
              footerText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _ink,
                fontFamily: 'monospace',
                fontSize: 13,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Powered by ArchiePOS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontFamily: 'monospace',
                fontSize: 9.5,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            // Faux barcode strip for character
            _BarcodeStrip(text: order.id),
          ],
        ),
      ),
    );
  }

  static String _paymentLabel(OrderPaymentMethod m) {
    switch (m) {
      case OrderPaymentMethod.cash:
        return 'Cash';
      case OrderPaymentMethod.card:
        return 'Card';
      case OrderPaymentMethod.mobile:
        return 'Mobile (GCash/Maya)';
      case OrderPaymentMethod.lista:
        return 'Lista (credit)';
    }
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.bold = false,
    this.big = false,
  });
  final String label;
  final String value;
  final bool bold;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: PrintableReceipt._ink,
      fontFamily: 'monospace',
      fontSize: big ? 13.5 : 11.5,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style, textAlign: TextAlign.right),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({this.thick = false});
  final bool thick;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        thick ? '═' * 30 : '─' * 30,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: PrintableReceipt._muted,
          fontFamily: 'monospace',
          height: 0.6,
          fontSize: thick ? 10 : 11,
          letterSpacing: -1.5,
        ),
      ),
    );
  }
}

class _BarcodeStrip extends StatelessWidget {
  const _BarcodeStrip({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 28,
          child: CustomPaint(
            painter: _BarcodePainter(seed: text),
            size: const Size(double.infinity, 28),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: PrintableReceipt._ink,
            fontFamily: 'monospace',
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BarcodePainter extends CustomPainter {
  _BarcodePainter({required this.seed});
  final String seed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = PrintableReceipt._ink;
    final codes = seed.codeUnits;
    int x = 0;
    int i = 0;
    while (x < size.width) {
      final w = ((codes[i % codes.length] % 4) + 1).toDouble();
      final gap = ((codes[(i + 1) % codes.length] % 3) + 1).toDouble();
      canvas.drawRect(Rect.fromLTWH(x.toDouble(), 0, w, size.height), paint);
      x += (w + gap).toInt();
      i++;
    }
  }

  @override
  bool shouldRepaint(_BarcodePainter old) => old.seed != seed;
}
