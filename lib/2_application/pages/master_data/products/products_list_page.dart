import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../1_domain/entities/product.dart';
import '../../../core/services/app_routes.dart';
import '../../../core/utils/money.dart';
import '../../../theme/app_colors.dart';
import 'cubit/products_list_cubit.dart';

class ProductsListPage extends StatelessWidget {
  const ProductsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductsListCubit(),
      child: const _ProductsListView(),
    );
  }
}

class _ProductsListView extends StatelessWidget {
  const _ProductsListView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsListCubit, ProductsListState>(
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
              LayoutBuilder(
                builder: (context, c) => c.maxWidth >= 720
                    ? _ProductsTable(state: state)
                    : _ProductsCards(state: state),
              ),
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
              Text('Products',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              const Text(
                'Manage your inventory — add, edit, and track stock',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13.5),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => context.go(AppRoutes.masterDataProductsAdd),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Product'),
        ),
      ],
    );
  }
}

// ─── Summary cards ─────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.state});
  final ProductsListState state;

  @override
  Widget build(BuildContext context) {
    final inStock =
        state.totalProducts - state.lowStockCount - state.outOfStockCount;
    final cards = [
      _SummaryCard(
        icon: Icons.inventory_2_outlined,
        iconColor: const Color(0xFF3B82F6),
        label: 'Total Products',
        value: state.totalProducts.toString(),
      ),
      _SummaryCard(
        icon: Icons.check_circle_outline,
        iconColor: AppColors.success,
        label: 'In Stock',
        value: inStock.toString(),
      ),
      _SummaryCard(
        icon: Icons.warning_amber_outlined,
        iconColor: AppColors.warning,
        label: 'Low Stock',
        value: state.lowStockCount.toString(),
      ),
      _SummaryCard(
        icon: Icons.block_outlined,
        iconColor: AppColors.danger,
        label: 'Out of Stock',
        value: state.outOfStockCount.toString(),
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
                    fontSize: 22,
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
  final ProductsListState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductsListCubit>();
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 900;
        final searchField = TextField(
          onChanged: cubit.search,
          decoration: const InputDecoration(
            hintText: 'Search by name or SKU…',
            prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
          ),
        );

        final categoryDropdown = _DropdownBox(
          icon: Icons.category_outlined,
          value: state.selectedCategory,
          items: kProductCategories,
          onChanged: (v) => cubit.selectCategory(v ?? 'All'),
        );

        final stockChips = _StockFilterChips(filter: state.stockFilter);
        final sortDropdown = _SortDropdown(sort: state.sort);

        if (wide) {
          return Row(
            children: [
              Expanded(child: searchField),
              const SizedBox(width: 12),
              SizedBox(width: 200, child: categoryDropdown),
              const SizedBox(width: 12),
              stockChips,
              const SizedBox(width: 12),
              sortDropdown,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            searchField,
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: categoryDropdown),
                const SizedBox(width: 12),
                Expanded(child: sortDropdown),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: stockChips,
            ),
          ],
        );
      },
    );
  }
}

class _DropdownBox extends StatelessWidget {
  const _DropdownBox({
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final IconData icon;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
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
            Icon(icon, size: 18, color: AppColors.textTertiary),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                isDense: true,
                dropdownColor: AppColors.darkSurfaceElevated,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13.5),
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.textTertiary, size: 18),
                items: [
                  for (final v in items)
                    DropdownMenuItem(value: v, child: Text(v)),
                ],
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockFilterChips extends StatelessWidget {
  const _StockFilterChips({required this.filter});
  final StockFilter filter;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductsListCubit>();
    Widget chip(StockFilter f, String label) {
      final selected = f == filter;
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => cubit.setStockFilter(f),
          backgroundColor: AppColors.darkSurface,
          selectedColor: AppColors.brandAmber,
          labelStyle: TextStyle(
            color:
                selected ? AppColors.textOnPrimary : AppColors.textSecondary,
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
        chip(StockFilter.all, 'All'),
        chip(StockFilter.inStock, 'In Stock'),
        chip(StockFilter.lowStock, 'Low'),
        chip(StockFilter.outOfStock, 'Out'),
      ],
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.sort});
  final ProductSort sort;

  static const Map<ProductSort, String> _labels = {
    ProductSort.nameAsc: 'Name (A–Z)',
    ProductSort.nameDesc: 'Name (Z–A)',
    ProductSort.priceAsc: 'Price ↑',
    ProductSort.priceDesc: 'Price ↓',
    ProductSort.stockAsc: 'Stock ↑',
    ProductSort.stockDesc: 'Stock ↓',
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductsListCubit>();
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
            const Icon(Icons.sort,
                size: 18, color: AppColors.textTertiary),
            const SizedBox(width: 8),
            DropdownButton<ProductSort>(
              value: sort,
              isDense: true,
              dropdownColor: AppColors.darkSurfaceElevated,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 13.5),
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.textTertiary, size: 18),
              items: [
                for (final entry in _labels.entries)
                  DropdownMenuItem(value: entry.key, child: Text(entry.value)),
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

// ─── Products table (wide) ─────────────────────────────────────────────────

class _ProductsTable extends StatelessWidget {
  const _ProductsTable({required this.state});
  final ProductsListState state;

  @override
  Widget build(BuildContext context) {
    final products = state.filteredProducts;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.darkDivider, width: 1),
              ),
            ),
            child: Row(
              children: const [
                SizedBox(width: 32, child: _ColHeader(label: '#')),
                Expanded(flex: 5, child: _ColHeader(label: 'PRODUCT')),
                Expanded(
                    flex: 2, child: _ColHeader(label: 'CATEGORY')),
                Expanded(
                    flex: 2,
                    child: _ColHeader(
                        label: 'PRICE', align: TextAlign.right)),
                Expanded(
                    flex: 2,
                    child: _ColHeader(
                        label: 'STOCK', align: TextAlign.right)),
                Expanded(
                    flex: 2,
                    child: _ColHeader(
                        label: 'STATUS', align: TextAlign.center)),
                SizedBox(width: 64, child: _ColHeader(label: '')),
              ],
            ),
          ),
          if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: _EmptyState(),
            )
          else
            for (var i = 0; i < products.length; i++)
              _ProductRow(index: i + 1, product: products[i]),
        ],
      ),
    );
  }
}

class _ColHeader extends StatelessWidget {
  const _ColHeader({required this.label, this.align = TextAlign.left});
  final String label;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: align,
      style: const TextStyle(
        color: AppColors.textTertiary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.index, required this.product});
  final int index;
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.darkDivider, width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              index.toString(),
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.darkBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child:
                      Text(product.emoji, style: const TextStyle(fontSize: 20)),
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
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.sku,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11.5,
                          letterSpacing: 0.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: _CategoryChip(category: product.category),
          ),
          Expanded(
            flex: 2,
            child: Text(
              Money.format(product.price),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Money.formatQty(product.stock) +
                      (product.baseUnit != null ? ' ${product.baseUnit}' : ''),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: product.isOutOfStock
                        ? AppColors.danger
                        : product.isLowStock
                            ? AppColors.warning
                            : AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (product.isTingi) ...[
                  const SizedBox(height: 3),
                  const _TingiPill(),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(child: _StatusPill(product: product)),
          ),
          SizedBox(
            width: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _IconAction(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit',
                  onTap: () => _onEdit(context, product),
                ),
                _IconAction(
                  icon: Icons.more_horiz,
                  tooltip: 'More',
                  onTap: () => _onMore(context, product),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onEdit(BuildContext context, Product p) {
    context.go(AppRoutes.editProduct(p.sku));
  }

  void _onMore(BuildContext context, Product p) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('More actions for ${p.name} — coming soon'),
        backgroundColor: AppColors.darkSurfaceElevated,
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: AppColors.textSecondary),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});
  final String category;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.darkBg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          category,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;
    if (product.isOutOfStock) {
      label = 'Out of Stock';
      color = AppColors.danger;
    } else if (product.isLowStock) {
      label = 'Low Stock';
      color = AppColors.warning;
    } else {
      label = 'In Stock';
      color = AppColors.success;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TingiPill extends StatelessWidget {
  const _TingiPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.brandAmber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'TINGI',
        style: TextStyle(
          color: AppColors.brandAmber,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.inbox_outlined, color: AppColors.textTertiary, size: 32),
          SizedBox(height: 8),
          Text(
            'No products match your filters',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── Products as cards (phone) ─────────────────────────────────────────────

class _ProductsCards extends StatelessWidget {
  const _ProductsCards({required this.state});
  final ProductsListState state;

  @override
  Widget build(BuildContext context) {
    final products = state.filteredProducts;
    if (products.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const _EmptyState(),
      );
    }
    return Column(
      children: [
        for (final p in products)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ProductCardMobile(product: p),
          ),
      ],
    );
  }
}

class _ProductCardMobile extends StatelessWidget {
  const _ProductCardMobile({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.darkBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(product.emoji, style: const TextStyle(fontSize: 24)),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.sku}  •  ${product.category}',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      Money.format(product.price),
                      style: const TextStyle(
                        color: AppColors.brandAmber,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Stock: ${Money.formatQty(product.stock)}${product.baseUnit != null ? ' ${product.baseUnit}' : ''}',
                      style: TextStyle(
                        color: product.isOutOfStock
                            ? AppColors.danger
                            : product.isLowStock
                                ? AppColors.warning
                                : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusPill(product: product),
        ],
      ),
    );
  }
}
