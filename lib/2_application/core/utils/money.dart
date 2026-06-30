import 'package:intl/intl.dart';

class Money {
  Money._();

  static const String currencySymbol = '₱'; // ₱

  static String format(num amount) =>
      NumberFormat.currency(symbol: currencySymbol, decimalDigits: 2)
          .format(amount);

  /// Format a quantity that may be fractional (e.g. tingi stock in kg).
  /// 24.0 → "24", 47.5 → "47.5", 0.25 → "0.25"
  static String formatQty(double qty) {
    if (qty == qty.truncateToDouble()) return qty.toStringAsFixed(0);
    if ((qty * 10) == (qty * 10).truncateToDouble()) {
      return qty.toStringAsFixed(1);
    }
    return qty.toStringAsFixed(2);
  }
}
