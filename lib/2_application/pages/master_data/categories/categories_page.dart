import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../1_domain/entities/category.dart';
import '../../../theme/app_colors.dart';
import 'cubit/categories_cubit.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoriesCubit(),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
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
              _CategoryList(state: state),
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
              Text('Categories',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              const Text(
                'Group your products into the sections that fit your store',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13.5),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _openCategoryDialog(context),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Category'),
        ),
      ],
    );
  }
}

// ─── Summary ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.state});
  final CategoriesState state;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryCard(
        icon: Icons.category_outlined,
        iconColor: const Color(0xFF3B82F6),
        label: 'Total Categories',
        value: state.totalCount.toString(),
      ),
      _SummaryCard(
        icon: Icons.check_circle_outline,
        iconColor: AppColors.success,
        label: 'Active',
        value: state.activeCount.toString(),
      ),
      _SummaryCard(
        icon: Icons.inventory_2_outlined,
        iconColor: AppColors.brandAmber,
        label: 'In Use',
        value: state.inUseCount.toString(),
      ),
      _SummaryCard(
        icon: Icons.archive_outlined,
        iconColor: AppColors.textSecondary,
        label: 'Archived',
        value: state.archivedCount.toString(),
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
                    fontSize: 20,
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
  final CategoriesState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoriesCubit>();
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: cubit.search,
            decoration: const InputDecoration(
              hintText: 'Search categories…',
              prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _StatusChips(filter: state.statusFilter),
      ],
    );
  }
}

class _StatusChips extends StatelessWidget {
  const _StatusChips({required this.filter});
  final CategoryStatusFilter filter;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoriesCubit>();
    Widget chip(CategoryStatusFilter f, String label) {
      final selected = f == filter;
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => cubit.setStatusFilter(f),
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
        chip(CategoryStatusFilter.all, 'All'),
        chip(CategoryStatusFilter.active, 'Active'),
        chip(CategoryStatusFilter.archived, 'Archived'),
      ],
    );
  }
}

// ─── Category list ─────────────────────────────────────────────────────────

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.state});
  final CategoriesState state;

  @override
  Widget build(BuildContext context) {
    final list = state.filteredUsage;
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.category_outlined,
                  color: AppColors.textTertiary, size: 32),
              SizedBox(height: 8),
              Text(
                'No categories match your filters',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final u in list)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CategoryCard(usage: u),
          ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.usage});
  final CategoryUsage usage;

  @override
  Widget build(BuildContext context) {
    final c = usage.category;
    final color = c.color.color;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(c.emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        c.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (c.isArchived)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.textTertiary
                              .withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Archived',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      '${usage.productCount} product${usage.productCount == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 10,
                      height: 10,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      c.color.label,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Edit',
            onPressed: () => _openCategoryDialog(context, existing: c),
            icon: const Icon(Icons.edit_outlined,
                size: 18, color: AppColors.textSecondary),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            tooltip: c.isArchived ? 'Restore' : 'Archive',
            onPressed: () =>
                context.read<CategoriesCubit>().toggleArchive(c.id),
            icon: Icon(
              c.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
              size: 18,
              color: c.isArchived ? AppColors.brandAmber : AppColors.textSecondary,
            ),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context, usage),
            icon: const Icon(Icons.delete_outline,
                size: 18, color: AppColors.danger),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, CategoryUsage usage) {
    final cubit = context.read<CategoriesCubit>();
    final inUse = cubit.isCategoryInUse(usage.category);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                        color: AppColors.danger.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.delete_outline,
                          color: AppColors.danger),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Delete "${usage.category.name}"?',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  inUse
                      ? '${usage.productCount} product${usage.productCount == 1 ? '' : 's'} still use this category. Archiving keeps them safe — deleting will leave them uncategorized.'
                      : 'No products use this category. This action cannot be undone.',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 6),
                    if (inUse)
                      OutlinedButton(
                        onPressed: () {
                          cubit.toggleArchive(usage.category.id);
                          Navigator.of(ctx).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side:
                              const BorderSide(color: AppColors.darkBorder),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Archive instead'),
                      ),
                    if (inUse) const SizedBox(width: 6),
                    ElevatedButton(
                      onPressed: () {
                        cubit.deleteCategory(usage.category.id);
                        Navigator.of(ctx).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Add / Edit dialog ─────────────────────────────────────────────────────

void _openCategoryDialog(BuildContext context, {Category? existing}) {
  final cubit = context.read<CategoriesCubit>();
  showDialog(
    context: context,
    builder: (ctx) => BlocProvider.value(
      value: cubit,
      child: _CategoryDialog(existing: existing),
    ),
  );
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({this.existing});
  final Category? existing;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late final TextEditingController _nameCtrl;
  late String _emoji;
  late CategoryColor _color;
  String? _nameError;

  bool get _isEdit => widget.existing != null;

  static const List<String> _emojis = [
    '📦', '🥤', '🍔', '🍚', '🍞', '🥑', '🍌', '☕', '🧋', '🍫',
    '💊', '🧴', '🧼', '🪥', '🚬', '🔌', '🔋', '📓', '🖊', '🗒',
    '🛍', '🎁', '🌶', '🐟', '🥩', '🥚', '🧂', '🍻', '🧃', '🍳',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _emoji = e?.emoji ?? '📦';
    _color = e?.color ?? CategoryColor.amber;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final name = _nameCtrl.text.trim();
    final cubit = context.read<CategoriesCubit>();

    if (name.isEmpty) {
      setState(() => _nameError = 'Name is required');
      return;
    }
    if (name.length < 2) {
      setState(() => _nameError = 'Name must be at least 2 characters');
      return;
    }
    if (cubit.isNameTaken(name, selfId: widget.existing?.id)) {
      setState(() => _nameError = 'A category with this name already exists');
      return;
    }

    if (_isEdit) {
      cubit.updateCategory(
        id: widget.existing!.id,
        name: name,
        emoji: _emoji,
        color: _color,
      );
    } else {
      cubit.addCategory(name: name, emoji: _emoji, color: _color);
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit
            ? '"$name" updated'
            : '"$name" added — assign it to products from the Add Product page'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _Preview(emoji: _emoji, color: _color),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _isEdit ? 'Edit Category' : 'New Category',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
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
              const SizedBox(height: 18),
              const Text(
                'Name',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'e.g. Snacks, Frozen, Toiletries',
                ),
              ),
              if (_nameError != null) ...[
                const SizedBox(height: 4),
                Text(
                  _nameError!,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Icon',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _emojis.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, i) {
                    final e = _emojis[i];
                    final active = e == _emoji;
                    return GestureDetector(
                      onTap: () => setState(() => _emoji = e),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.brandAmber.withValues(alpha: 0.18)
                              : AppColors.darkBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: active
                                ? AppColors.brandAmber
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(e, style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Color',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in CategoryColor.values)
                    _ColorSwatch(
                      color: c,
                      active: c == _color,
                      onTap: () => setState(() => _color = c),
                    ),
                ],
              ),
              const SizedBox(height: 22),
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
                  ElevatedButton(
                    onPressed: () => _submit(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(_isEdit ? 'Save Changes' : 'Add Category'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.emoji, required this.color});
  final String emoji;
  final CategoryColor color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.color, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 28)),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.active,
    required this.onTap,
  });
  final CategoryColor color;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? AppColors.textPrimary : Colors.transparent,
            width: 2,
          ),
        ),
        child: active
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}
