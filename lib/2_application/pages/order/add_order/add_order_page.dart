import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../1_domain/entities/order.dart';
import '../../../../1_domain/entities/product.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/receipt_dialog.dart';
import '../../../theme/app_colors.dart';
import 'charge_dialog.dart';
import 'cubit/add_order_cubit.dart';

class AddOrderPage extends StatelessWidget {
  const AddOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddOrderCubit(),
      child: const _AddOrderView(),
    );
  }
}

class _AddOrderView extends StatelessWidget {
  const _AddOrderView();

  static const double _cartPanelWidth = 320;
  static const double _cartCollapseBreakpoint = 1024;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddOrderCubit, AddOrderState>(
      listenWhen: (prev, curr) => curr is AddOrderCharged,
      listener: (context, state) async {
        if (state is! AddOrderCharged) return;
        final cubit = context.read<AddOrderCubit>();
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) =>
              ReceiptDialog(order: state.order, showCompletedBanner: true),
        );
        cubit.acknowledgeCharge();
      },
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final bool showSideCart =
                constraints.maxWidth >= _cartCollapseBreakpoint;

            return Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _TopBar(state: state),
                          _CategoryChips(state: state),
                          Expanded(child: _ProductGrid(state: state)),
                        ],
                      ),
                    ),
                    if (showSideCart) ...[
                      const VerticalDivider(
                          width: 1, color: AppColors.darkDivider),
                      SizedBox(
                        width: _cartPanelWidth,
                        child: _CartPanel(state: state),
                      ),
                    ],
                  ],
                ),
                if (!showSideCart && state.cartItemCount > 0)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: _CartFab(state: state),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

// ─── Top bar ────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.state});
  final AddOrderState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddOrderCubit>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: cubit.search,
              decoration: const InputDecoration(
                hintText: 'Search products or SKU…',
                prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _Kpi(label: 'TODAY', value: Money.format(state.todayTotal)),
          const SizedBox(width: 20),
          _Kpi(label: 'ORDERS', value: state.todayOrders.toString()),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─── Category chips ─────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.state});
  final AddOrderState state;

  static const List<String> _categories = [
    'All',
    'Beverages',
    'Food',
    'Health',
    'Electronics',
    'Stationery',
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddOrderCubit>();
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = _categories[i];
          final selected = c == state.selectedCategory;
          return ChoiceChip(
            label: Text(c),
            selected: selected,
            onSelected: (_) => cubit.selectCategory(c),
            backgroundColor: AppColors.darkSurface,
            selectedColor: AppColors.brandAmber,
            labelStyle: TextStyle(
              color: selected
                  ? AppColors.textOnPrimary
                  : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
            showCheckmark: false,
            side: BorderSide.none,
          );
        },
      ),
    );
  }
}

// ─── Product grid ──────────────────────────────────────────────────────────

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.state});
  final AddOrderState state;

  @override
  Widget build(BuildContext context) {
    final products = state.filteredProducts;
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _cols(constraints.maxWidth);
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.25,
          ),
          itemBuilder: (context, i) {
            final p = products[i];
            final inCart = state.cart.where((l) => l.product.sku == p.sku);
            final qty = inCart.isEmpty ? 0 : inCart.first.qty;
            return _ProductCard(product: p, qtyInCart: qty);
          },
        );
      },
    );
  }

  static int _cols(double w) {
    if (w >= 1400) return 5;
    if (w >= 1100) return 4;
    if (w >= 800) return 3;
    if (w >= 520) return 2;
    return 1;
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.qtyInCart});
  final Product product;
  final int qtyInCart;

  bool get inCart => qtyInCart > 0;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddOrderCubit>();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: inCart ? AppColors.brandAmber : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => product.isTingi
              ? _openSellOptionPicker(context, product)
              : cubit.addToCart(product),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.emoji, style: const TextStyle(fontSize: 24)),
                    const Spacer(),
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.sku,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              children: [
                                if (product.isTingi)
                                  const TextSpan(
                                    text: 'from ',
                                    style: TextStyle(
                                      color: AppColors.textTertiary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                TextSpan(
                                  text: Money.format(
                                      product.isTingi
                                          ? product.lowestPrice
                                          : product.price),
                                  style: const TextStyle(
                                    color: AppColors.brandAmber,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _StockBadge(
                          stock: product.stock,
                          isLow: product.isLowStock,
                        ),
                      ],
                    ),
                  ],
                ),
                if (inCart)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: _CartQtyBadge(qty: qtyInCart),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartQtyBadge extends StatelessWidget {
  const _CartQtyBadge({required this.qty});
  final int qty;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: AppColors.brandAmber,
        shape: qty < 10 ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: qty < 10 ? null : BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBg, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        qty.toString(),
        style: const TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.stock, required this.isLow});
  final double stock;
  final bool isLow;

  String get _displayStock {
    if (stock == stock.truncateToDouble()) return stock.toStringAsFixed(0);
    return stock.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    if (isLow) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.lowStockBg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '! $_displayStock',
          style: const TextStyle(
            color: AppColors.lowStockFg,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return Text(
      _displayStock,
      style: const TextStyle(
        color: AppColors.textTertiary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ─── Cart ──────────────────────────────────────────────────────────────────

class _CartPanel extends StatelessWidget {
  const _CartPanel({required this.state});
  final AddOrderState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkBg,
      child: Column(
        children: [
          const _CartHeader(),
          Expanded(
            child: state.cart.isEmpty
                ? const _CartEmpty()
                : _CartList(state: state),
          ),
          const Divider(height: 1),
          _CartFooter(state: state),
        ],
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Row(
        children: const [
          Icon(Icons.shopping_cart_outlined,
              color: AppColors.textPrimary, size: 20),
          SizedBox(width: 8),
          Text(
            'Cart',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartEmpty extends StatelessWidget {
  const _CartEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 28,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Cart is empty',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap a product to add it',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartList extends StatelessWidget {
  const _CartList({required this.state});
  final AddOrderState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddOrderCubit>();
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.cart.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final line = state.cart[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Text(line.product.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.displayLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Money.format(line.sellOption.price),
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              _QtyStepper(
                qty: line.qty,
                onMinus: () => cubit.updateLineQty(
                  line.product.sku,
                  line.sellOption.id,
                  line.qty - 1,
                ),
                onPlus: () => cubit.updateLineQty(
                  line.product.sku,
                  line.sellOption.id,
                  line.qty + 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: onMinus,
            icon: const Icon(Icons.remove, color: AppColors.textSecondary),
          ),
          SizedBox(
            width: 24,
            child: Text(
              qty.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: onPlus,
            icon: const Icon(Icons.add, color: AppColors.brandAmber),
          ),
        ],
      ),
    );
  }
}

class _CartFooter extends StatelessWidget {
  const _CartFooter({required this.state});
  final AddOrderState state;

  @override
  Widget build(BuildContext context) {
    final taxPct = (state.taxRate * 100).round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Row(label: 'Subtotal', value: Money.format(state.subtotal)),
          const SizedBox(height: 6),
          _Row(label: 'Tax ($taxPct%)', value: Money.format(state.tax)),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          _Row(
            label: 'Total',
            value: Money.format(state.total),
            big: true,
          ),
          const SizedBox(height: 14),
          _PaymentChips(method: state.paymentMethod),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: state.cart.isEmpty ? null : () => openChargeDialog(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                state.cart.isEmpty
                    ? 'Charge ${Money.format(0)}'
                    : 'Charge ${Money.format(state.total)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.big = false});
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
            color: AppColors.textPrimary,
            fontSize: big ? 18 : 13.5,
            fontWeight: big ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PaymentChips extends StatelessWidget {
  const _PaymentChips({required this.method});
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
              color: selected ? AppColors.brandAmber : AppColors.darkSurface,
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

// ─── Phone-mode cart FAB ───────────────────────────────────────────────────

class _CartFab extends StatelessWidget {
  const _CartFab({required this.state});
  final AddOrderState state;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _openCartSheet(context, state),
      backgroundColor: AppColors.brandAmber,
      foregroundColor: AppColors.textOnPrimary,
      icon: const Icon(Icons.shopping_cart),
      label: Text(
        '${state.cartItemCount} • ${Money.format(state.total)}',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  void _openCartSheet(BuildContext context, AddOrderState state) {
    final cubit = context.read<AddOrderCubit>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<AddOrderCubit, AddOrderState>(
            builder: (context, s) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: _CartPanel(state: s),
            ),
          ),
        );
      },
    );
  }
}

// ─── Sell-option picker (tingi products) ───────────────────────────────────

void _openSellOptionPicker(BuildContext context, Product product) {
  final cubit = context.read<AddOrderCubit>();
  showDialog(
    context: context,
    builder: (dialogContext) => BlocProvider.value(
      value: cubit,
      child: _SellOptionPicker(product: product),
    ),
  );
}

class _SellOptionPicker extends StatelessWidget {
  const _SellOptionPicker({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddOrderCubit, AddOrderState>(
      builder: (context, state) {
        return Dialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PickerHeader(product: product),
                const Divider(height: 1),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                    itemCount: product.sellOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final option = product.sellOptions[i];
                      final inCart = state.cart
                          .where((l) =>
                              l.product.sku == product.sku &&
                              l.sellOption.id == option.id)
                          .toList();
                      final qtyInCart =
                          inCart.isEmpty ? 0 : inCart.first.qty;
                      return _SellOptionTile(
                        product: product,
                        option: option,
                        qtyInCart: qtyInCart,
                        onTap: () {
                          context
                              .read<AddOrderCubit>()
                              .addToCart(product, sellOption: option);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PickerHeader extends StatelessWidget {
  const _PickerHeader({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.darkBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(product.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text(
                      'Choose a size',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.brandAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${Money.formatQty(product.stock)} ${product.baseUnit ?? ''} in stock',
                        style: const TextStyle(
                          color: AppColors.brandAmber,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
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

class _SellOptionTile extends StatelessWidget {
  const _SellOptionTile({
    required this.product,
    required this.option,
    required this.qtyInCart,
    required this.onTap,
  });

  final Product product;
  final SellOption option;
  final int qtyInCart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inCart = qtyInCart > 0;
    return Material(
      color: AppColors.darkBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: inCart ? AppColors.brandAmber : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.brandAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.straighten,
                    size: 18, color: AppColors.brandAmber),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.label,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${Money.formatQty(option.baseQty)} ${product.baseUnit ?? ''} per unit',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (inCart)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: AppColors.brandAmber,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$qtyInCart in cart',
                    style: const TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              Text(
                Money.format(option.price),
                style: const TextStyle(
                  color: AppColors.brandAmber,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
