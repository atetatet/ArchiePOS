part of 'dashboard_cubit.dart';

class KpiDelta extends Equatable {
  const KpiDelta({required this.pct, required this.isUp});
  final double pct;
  final bool isUp;
  @override
  List<Object?> get props => [pct, isUp];
}

class SalesPoint extends Equatable {
  const SalesPoint({required this.label, required this.value});
  final String label;
  final double value;
  @override
  List<Object?> get props => [label, value];
}

class PaymentSlice extends Equatable {
  const PaymentSlice({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final double value;
  final Color color;
  @override
  List<Object?> get props => [label, value, color];
}

class PopularProduct extends Equatable {
  const PopularProduct({
    required this.rank,
    required this.name,
    required this.emoji,
    required this.price,
    required this.soldQty,
    required this.discountPct,
  });
  final int rank;
  final String name;
  final String emoji;
  final double price;
  final int soldQty;
  final int discountPct;

  @override
  List<Object?> get props => [rank, name, price, soldQty, discountPct];
}

sealed class DashboardState extends Equatable {
  const DashboardState({
    required this.totalRevenue,
    required this.revenueDelta,
    required this.totalOrders,
    required this.ordersDelta,
    required this.averageSale,
    required this.averageDelta,
    required this.listaOutstanding,
    required this.listaDelta,
    required this.salesSeries,
    required this.paymentBreakdown,
    required this.popularProducts,
    required this.dateRangeLabel,
  });

  final double totalRevenue;
  final KpiDelta revenueDelta;
  final int totalOrders;
  final KpiDelta ordersDelta;
  final double averageSale;
  final KpiDelta averageDelta;
  final double listaOutstanding;
  final KpiDelta listaDelta;
  final List<SalesPoint> salesSeries;
  final List<PaymentSlice> paymentBreakdown;
  final List<PopularProduct> popularProducts;
  final String dateRangeLabel;

  @override
  List<Object?> get props => [
        totalRevenue,
        revenueDelta,
        totalOrders,
        ordersDelta,
        averageSale,
        averageDelta,
        listaOutstanding,
        listaDelta,
        salesSeries,
        paymentBreakdown,
        popularProducts,
        dateRangeLabel,
      ];
}

class DashboardLoaded extends DashboardState {
  const DashboardLoaded({
    required super.totalRevenue,
    required super.revenueDelta,
    required super.totalOrders,
    required super.ordersDelta,
    required super.averageSale,
    required super.averageDelta,
    required super.listaOutstanding,
    required super.listaDelta,
    required super.salesSeries,
    required super.paymentBreakdown,
    required super.popularProducts,
    required super.dateRangeLabel,
  });
}
