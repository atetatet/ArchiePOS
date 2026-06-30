import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_colors.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(_seed());

  static DashboardLoaded _seed() => const DashboardLoaded(
        totalRevenue: 1280.50,
        revenueDelta: KpiDelta(pct: 10.5, isUp: true),
        totalOrders: 24,
        ordersDelta: KpiDelta(pct: 15.0, isUp: true),
        averageSale: 53.35,
        averageDelta: KpiDelta(pct: 3.5, isUp: true),
        listaOutstanding: 248.00,
        listaDelta: KpiDelta(pct: 2.5, isUp: false),
        dateRangeLabel: 'Nov 19, 2023 – Nov 26, 2023',
        salesSeries: [
          SalesPoint(label: 'Mon', value: 980),
          SalesPoint(label: 'Tue', value: 1150),
          SalesPoint(label: 'Wed', value: 1320),
          SalesPoint(label: 'Thu', value: 890),
          SalesPoint(label: 'Fri', value: 1450),
          SalesPoint(label: 'Sat', value: 1780),
          SalesPoint(label: 'Sun', value: 1280),
        ],
        paymentBreakdown: [
          PaymentSlice(label: 'Cash', value: 58, color: AppColors.brandAmber),
          PaymentSlice(label: 'Card', value: 22, color: AppColors.info),
          PaymentSlice(label: 'Mobile', value: 15, color: AppColors.success),
          PaymentSlice(label: 'Lista', value: 5, color: AppColors.danger),
        ],
        popularProducts: [
          PopularProduct(rank: 1, name: 'Coca-Cola 1.5L', emoji: '🥤', price: 1.20, soldQty: 32, discountPct: 5),
          PopularProduct(rank: 2, name: 'Lucky Me Pancit Canton', emoji: '🍜', price: 0.45, soldQty: 28, discountPct: 0),
          PopularProduct(rank: 3, name: 'Tide Sachet', emoji: '🧺', price: 0.20, soldQty: 24, discountPct: 0),
          PopularProduct(rank: 4, name: 'C2 Iced Tea', emoji: '🧋', price: 0.65, soldQty: 19, discountPct: 10),
          PopularProduct(rank: 5, name: 'Marlboro Stick', emoji: '🚬', price: 0.30, soldQty: 17, discountPct: 0),
        ],
      );
}
