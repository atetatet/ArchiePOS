import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/money.dart';
import '../../theme/app_colors.dart';
import 'cubit/dashboard_cubit.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardCubit(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(dateRangeLabel: state.dateRangeLabel),
              const SizedBox(height: 20),
              _KpiRow(state: state),
              const SizedBox(height: 20),
              _ChartsRow(state: state),
              const SizedBox(height: 20),
              _PopularProductsTable(products: state.popularProducts),
            ],
          ),
        );
      },
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.dateRangeLabel});
  final String dateRangeLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              const Text(
                'Here is your analytics store details',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13.5),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                dateRangeLabel,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.keyboard_arrow_down,
                  size: 16, color: AppColors.textTertiary),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── KPI cards ─────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _KpiCard(
        icon: Icons.account_balance_wallet_outlined,
        iconBg: const Color(0xFFFEE2C7),
        iconColor: const Color(0xFFD97706),
        label: 'Total Revenue',
        value: Money.format(state.totalRevenue),
        delta: state.revenueDelta,
      ),
      _KpiCard(
        icon: Icons.receipt_long_outlined,
        iconBg: const Color(0xFFDCEBFE),
        iconColor: const Color(0xFF3B82F6),
        label: 'Total Orders',
        value: state.totalOrders.toString(),
        delta: state.ordersDelta,
      ),
      _KpiCard(
        icon: Icons.attach_money,
        iconBg: const Color(0xFFE0F2FE),
        iconColor: const Color(0xFF0EA5E9),
        label: 'Average Sale',
        value: Money.format(state.averageSale),
        delta: state.averageDelta,
      ),
      _KpiCard(
        icon: Icons.handshake_outlined,
        iconBg: const Color(0xFFDCFCE7),
        iconColor: const Color(0xFF10B981),
        label: 'Lista Outstanding',
        value: Money.format(state.listaOutstanding),
        delta: state.listaDelta,
      ),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 1200
            ? 4
            : c.maxWidth >= 720
                ? 2
                : 1;
        const gap = 16.0;
        final available = c.maxWidth - gap * (cols - 1);
        final cardW = (available <= 0 ? c.maxWidth : available) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: cards
              .map((w) => SizedBox(width: cardW, child: w))
              .toList(),
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.delta,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final KpiDelta delta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.more_horiz,
                  size: 18, color: AppColors.textTertiary),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          _DeltaRow(delta: delta),
        ],
      ),
    );
  }
}

class _DeltaRow extends StatelessWidget {
  const _DeltaRow({required this.delta});
  final KpiDelta delta;

  @override
  Widget build(BuildContext context) {
    final color = delta.isUp ? AppColors.success : AppColors.danger;
    return Row(
      children: [
        Icon(
          delta.isUp ? Icons.trending_up : Icons.trending_down,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '${delta.pct.toStringAsFixed(delta.pct.truncateToDouble() == delta.pct ? 0 : 1)}%',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'From last month',
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }
}

// ─── Charts row ────────────────────────────────────────────────────────────

class _ChartsRow extends StatelessWidget {
  const _ChartsRow({required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 1000;
        const cardHeight = 320.0;
        if (wide) {
          return SizedBox(
            height: cardHeight,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _SalesOverviewCard(series: state.salesSeries),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _PaymentDonutCard(slices: state.paymentBreakdown),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            _SalesOverviewCard(series: state.salesSeries),
            const SizedBox(height: 16),
            _PaymentDonutCard(slices: state.paymentBreakdown),
          ],
        );
      },
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
              const SizedBox(width: 8),
              const Icon(Icons.more_horiz,
                  size: 18, color: AppColors.textTertiary),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SalesOverviewCard extends StatelessWidget {
  const _SalesOverviewCard({required this.series});
  final List<SalesPoint> series;

  @override
  Widget build(BuildContext context) {
    final maxY = series.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final yTop = (maxY * 1.2).ceilToDouble();

    return _CardShell(
      title: 'Sales Overview',
      child: SizedBox(
        height: 240,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: yTop,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: yTop / 5,
              getDrawingHorizontalLine: (_) => const FlLine(
                color: AppColors.darkDivider,
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: yTop / 5,
                  getTitlesWidget: (value, _) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      _formatK(value),
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: 1,
                  getTitlesWidget: (value, _) {
                    final i = value.toInt();
                    if (i < 0 || i >= series.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        series[i].label,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => AppColors.darkBg,
                tooltipRoundedRadius: 8,
                tooltipPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                getTooltipItems: (spots) => spots
                    .map((s) => LineTooltipItem(
                          '${series[s.x.toInt()].label}\n${Money.format(s.y)}',
                          const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ))
                    .toList(),
              ),
              getTouchedSpotIndicator: (_, indexes) => indexes
                  .map((_) => TouchedSpotIndicatorData(
                        const FlLine(
                            color: AppColors.brandAmber, strokeWidth: 1),
                        FlDotData(
                          getDotPainter: (_, __, ___, ____) =>
                              FlDotCirclePainter(
                            radius: 5,
                            color: AppColors.brandAmber,
                            strokeColor: AppColors.darkBg,
                            strokeWidth: 2,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (var i = 0; i < series.length; i++)
                    FlSpot(i.toDouble(), series[i].value),
                ],
                isCurved: true,
                curveSmoothness: 0.32,
                color: AppColors.brandAmber,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.brandAmber.withValues(alpha: 0.35),
                      AppColors.brandAmber.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatK(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k';
    return v.toStringAsFixed(0);
  }
}

class _PaymentDonutCard extends StatelessWidget {
  const _PaymentDonutCard({required this.slices});
  final List<PaymentSlice> slices;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<double>(0, (s, x) => s + x.value);
    return _CardShell(
      title: 'Payment',
      child: SizedBox(
        height: 240,
        child: Row(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 48,
                  startDegreeOffset: -90,
                  sections: [
                    for (final s in slices)
                      PieChartSectionData(
                        value: s.value,
                        color: s.color,
                        radius: 28,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final s in slices)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: s.color,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          s.label,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12.5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${(s.value / total * 100).round()}%',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Popular products table ────────────────────────────────────────────────

class _PopularProductsTable extends StatelessWidget {
  const _PopularProductsTable({required this.products});
  final List<PopularProduct> products;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      title: 'Popular Products',
      trailing: SizedBox(
        width: 200,
        height: 38,
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search products…',
            prefixIcon:
                const Icon(Icons.search, size: 18, color: AppColors.textTertiary),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            isDense: true,
            filled: true,
            fillColor: AppColors.darkBg,
            hintStyle: const TextStyle(fontSize: 12.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.darkBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                SizedBox(
                  width: 32,
                  child: _Col(text: 'No'),
                ),
                Expanded(flex: 4, child: _Col(text: 'Product')),
                Expanded(flex: 2, child: _Col(text: 'Price', align: TextAlign.right)),
                Expanded(flex: 2, child: _Col(text: 'Sold Qty', align: TextAlign.right)),
                Expanded(flex: 2, child: _Col(text: 'Discount', align: TextAlign.right)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          for (final p in products) _PopularRow(product: p),
        ],
      ),
    );
  }
}

class _Col extends StatelessWidget {
  const _Col({required this.text, this.align = TextAlign.left});
  final String text;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: const TextStyle(
        color: AppColors.textTertiary,
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _PopularRow extends StatelessWidget {
  const _PopularRow({required this.product});
  final PopularProduct product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              product.rank.toString(),
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.darkBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(product.emoji,
                      style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              Money.format(product.price),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              product.soldQty.toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: product.discountPct == 0
                  ? const Text(
                      '—',
                      style: TextStyle(
                          color: AppColors.textTertiary, fontSize: 13),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.brandAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${product.discountPct}%',
                        style: const TextStyle(
                          color: AppColors.brandAmber,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
