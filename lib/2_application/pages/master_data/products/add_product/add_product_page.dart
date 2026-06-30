import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../1_domain/entities/product.dart';
import '../../../../core/services/app_routes.dart';
import '../../../../core/utils/money.dart';
import '../../../../theme/app_colors.dart';
import 'cubit/add_product_cubit.dart';

class AddProductPage extends StatelessWidget {
  const AddProductPage({super.key, this.initialProduct});

  /// When non-null, page is in edit mode and prefills from this product.
  final Product? initialProduct;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddProductCubit(initialProduct: initialProduct),
      child: _AddProductView(initialProduct: initialProduct),
    );
  }
}

class _AddProductView extends StatefulWidget {
  const _AddProductView({this.initialProduct});
  final Product? initialProduct;

  @override
  State<_AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<_AddProductView> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _skuCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _thresholdCtrl;

  bool get _isEdit => widget.initialProduct != null;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProduct;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _skuCtrl = TextEditingController(text: p?.sku ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(
      text: p != null && !p.isTingi ? p.price.toStringAsFixed(2) : '',
    );
    _stockCtrl = TextEditingController(
      text: p == null ? '' : Money.formatQty(p.stock),
    );
    _thresholdCtrl = TextEditingController(
      text: p == null ? '10' : Money.formatQty(p.lowStockThreshold),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _thresholdCtrl.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    context.read<AddProductCubit>().submit(
          name: _nameCtrl.text,
          sku: _skuCtrl.text,
          description: _descCtrl.text,
          price: _priceCtrl.text,
          stock: _stockCtrl.text,
          lowStockThreshold: _thresholdCtrl.text,
        );
  }

  void _onAutoGenerateSku(BuildContext context) {
    _skuCtrl.text = context.read<AddProductCubit>().autoGenerateSku();
  }

  void _onCancel(BuildContext context) {
    context.go(AppRoutes.masterDataProducts);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddProductCubit, AddProductState>(
      listenWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
      listener: (context, state) {
        if (state is AddProductSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.isEditMode
                    ? '"${state.productName}" updated (stub — drift wiring next)'
                    : '"${state.productName}" added (stub — drift wiring next)',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          context.go(AppRoutes.masterDataProducts);
        }
        if (state is AddProductError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      builder: (context, state) {
        final submitting = state is AddProductSubmitting;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Breadcrumb(onBack: () => _onCancel(context)),
                  const SizedBox(height: 16),
                  Text(
                    _isEdit ? 'Edit Product' : 'Add New Product',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isEdit
                        ? 'Update product details, stock, and selling units'
                        : 'Fill in the details to add a new item to your inventory',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13.5),
                  ),
                  const SizedBox(height: 20),
                  _FormCard(
                    form: state.form,
                    submitting: submitting,
                    nameCtrl: _nameCtrl,
                    skuCtrl: _skuCtrl,
                    descCtrl: _descCtrl,
                    priceCtrl: _priceCtrl,
                    stockCtrl: _stockCtrl,
                    thresholdCtrl: _thresholdCtrl,
                    onAutoGenerateSku: () => _onAutoGenerateSku(context),
                  ),
                  const SizedBox(height: 20),
                  _ActionBar(
                    isEdit: _isEdit,
                    submitting: submitting,
                    onCancel: () => _onCancel(context),
                    onSave: () => _onSubmit(context),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Breadcrumb ────────────────────────────────────────────────────────────

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: const [
                Icon(Icons.arrow_back, size: 18, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Text(
                  'Back to Products',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Form card ─────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.form,
    required this.submitting,
    required this.nameCtrl,
    required this.skuCtrl,
    required this.descCtrl,
    required this.priceCtrl,
    required this.stockCtrl,
    required this.thresholdCtrl,
    required this.onAutoGenerateSku,
  });

  final AddProductFormData form;
  final bool submitting;
  final TextEditingController nameCtrl;
  final TextEditingController skuCtrl;
  final TextEditingController descCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController stockCtrl;
  final TextEditingController thresholdCtrl;
  final VoidCallback onAutoGenerateSku;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionLabel(label: 'PRODUCT IMAGE'),
          const SizedBox(height: 10),
          _ProductImagePicker(form: form, disabled: submitting),
          const SizedBox(height: 24),
          const _SectionLabel(label: 'BASIC INFO'),
          const SizedBox(height: 12),
          _Field(
            label: 'Product Name',
            required: true,
            errorText: form.errors['name'],
            child: TextField(
              controller: nameCtrl,
              enabled: !submitting,
              decoration:
                  const InputDecoration(hintText: 'e.g. Lucky Me Pancit Canton'),
            ),
          ),
          const SizedBox(height: 14),
          _Field(
            label: 'SKU',
            required: true,
            errorText: form.errors['sku'],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: skuCtrl,
                    enabled: !submitting,
                    decoration: const InputDecoration(hintText: 'e.g. BEV-017'),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: submitting ? null : onAutoGenerateSku,
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Auto'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brandAmber,
                    side: const BorderSide(color: AppColors.brandAmber),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Field(
            label: 'Category',
            required: true,
            child: _CategoryDropdown(
                selected: form.category, disabled: submitting),
          ),
          const SizedBox(height: 14),
          _Field(
            label: 'Description',
            child: TextField(
              controller: descCtrl,
              enabled: !submitting,
              maxLines: 3,
              decoration: const InputDecoration(
                  hintText: 'Optional notes about this product'),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),
          _SellingUnitsSection(form: form, priceCtrl: priceCtrl, disabled: submitting),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),
          const _SectionLabel(label: 'INVENTORY'),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) {
              final wide = c.maxWidth >= 540;
              final unitSuffix =
                  form.isTingi && form.baseUnit.trim().isNotEmpty
                      ? ' (${form.baseUnit.trim()})'
                      : '';
              final stockField = _Field(
                label: 'Initial Stock$unitSuffix',
                required: true,
                helper: form.isTingi
                    ? 'Total stock you have in base units (e.g. total kg).'
                    : null,
                errorText: form.errors['stock'],
                child: TextField(
                  controller: stockCtrl,
                  enabled: !submitting,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(hintText: '0'),
                ),
              );
              final thresholdField = _Field(
                label: 'Low Stock Threshold$unitSuffix',
                helper: 'Show a warning when stock drops to this level',
                errorText: form.errors['threshold'],
                child: TextField(
                  controller: thresholdCtrl,
                  enabled: !submitting,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(hintText: '10'),
                ),
              );
              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: stockField),
                    const SizedBox(width: 14),
                    Expanded(child: thresholdField),
                  ],
                );
              }
              return Column(
                children: [
                  stockField,
                  const SizedBox(height: 14),
                  thresholdField,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Selling units (tingi toggle + sell-option rows) ──────────────────────

class _SellingUnitsSection extends StatelessWidget {
  const _SellingUnitsSection({
    required this.form,
    required this.priceCtrl,
    required this.disabled,
  });

  final AddProductFormData form;
  final TextEditingController priceCtrl;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddProductCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: _SectionLabel(label: 'SELLING & PRICING')),
            Row(
              children: [
                const Text(
                  'Tingi (multi-size)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: form.isTingi,
                  onChanged: disabled ? null : cubit.toggleTingi,
                  activeThumbColor: AppColors.brandAmber,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (!form.isTingi)
          _Field(
            label: 'Selling Price',
            required: true,
            errorText: form.errors['price'],
            child: TextField(
              controller: priceCtrl,
              enabled: !disabled,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: '${Money.currencySymbol}  ',
                prefixStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700),
              ),
            ),
          )
        else
          _TingiPanel(form: form, disabled: disabled),
      ],
    );
  }
}

class _TingiPanel extends StatelessWidget {
  const _TingiPanel({required this.form, required this.disabled});
  final AddProductFormData form;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddProductCubit>();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Field(
            label: 'Base Unit',
            required: true,
            helper:
                'The smallest unit you track (e.g. kg, piece, ml). Stock counts in this unit.',
            errorText: form.errors['baseUnit'],
            child: TextFormField(
              initialValue: form.baseUnit,
              enabled: !disabled,
              onChanged: cubit.setBaseUnit,
              decoration: const InputDecoration(hintText: 'e.g. kg'),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Sell options',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Define each size you sell. Each option deducts its "qty per unit" from stock.',
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 10),
          for (final o in form.sellOptions)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SellOptionRow(
                option: o,
                baseUnit: form.baseUnit,
                disabled: disabled,
                form: form,
                canRemove: form.sellOptions.length > 1,
              ),
            ),
          OutlinedButton.icon(
            onPressed: disabled ? null : cubit.addSellOption,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Sell Option'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brandAmber,
              side: const BorderSide(color: AppColors.brandAmber),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SellOptionRow extends StatelessWidget {
  const _SellOptionRow({
    required this.option,
    required this.baseUnit,
    required this.disabled,
    required this.form,
    required this.canRemove,
  });

  final SellOptionDraft option;
  final String baseUnit;
  final bool disabled;
  final AddProductFormData form;
  final bool canRemove;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddProductCubit>();
    final labelErr = form.errors['option-${option.id}-label'];
    final qtyErr = form.errors['option-${option.id}-baseQty'];
    final priceErr = form.errors['option-${option.id}-price'];
    final unitLabel = baseUnit.trim().isEmpty ? 'unit' : baseUnit.trim();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 480;
          final labelField = _MiniField(
            label: 'Label',
            errorText: labelErr,
            child: TextFormField(
              key: ValueKey('${option.id}-label'),
              initialValue: option.label,
              enabled: !disabled,
              onChanged: (v) =>
                  cubit.updateSellOption(option.id, label: v),
              decoration: const InputDecoration(hintText: 'e.g. 1 kg'),
            ),
          );
          final qtyField = _MiniField(
            label: 'Qty / unit',
            errorText: qtyErr,
            helper: 'In $unitLabel',
            child: TextFormField(
              key: ValueKey('${option.id}-qty'),
              initialValue: option.baseQty,
              enabled: !disabled,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
              ],
              onChanged: (v) =>
                  cubit.updateSellOption(option.id, baseQty: v),
              decoration: const InputDecoration(hintText: '1'),
            ),
          );
          final priceField = _MiniField(
            label: 'Price',
            errorText: priceErr,
            child: TextFormField(
              key: ValueKey('${option.id}-price'),
              initialValue: option.price,
              enabled: !disabled,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              onChanged: (v) =>
                  cubit.updateSellOption(option.id, price: v),
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: '${Money.currencySymbol}  ',
                prefixStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700),
              ),
            ),
          );
          final removeBtn = IconButton(
            onPressed: (disabled || !canRemove)
                ? null
                : () => cubit.removeSellOption(option.id),
            icon: const Icon(Icons.close),
            color: AppColors.danger,
            tooltip: 'Remove',
            visualDensity: VisualDensity.compact,
          );
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: labelField),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: qtyField),
                const SizedBox(width: 8),
                Expanded(flex: 3, child: priceField),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(top: 22),
                  child: removeBtn,
                ),
              ],
            );
          }
          return Column(
            children: [
              labelField,
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: qtyField),
                  const SizedBox(width: 8),
                  Expanded(child: priceField),
                  Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: removeBtn,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MiniField extends StatelessWidget {
  const _MiniField({
    required this.label,
    required this.child,
    this.helper,
    this.errorText,
  });

  final String label;
  final Widget child;
  final String? helper;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        child,
        if (errorText != null) ...[
          const SizedBox(height: 2),
          Text(
            errorText!,
            style: const TextStyle(
              color: AppColors.danger,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ] else if (helper != null) ...[
          const SizedBox(height: 2),
          Text(
            helper!,
            style: const TextStyle(
                color: AppColors.textTertiary, fontSize: 11),
          ),
        ],
      ],
    );
  }
}

// ─── Sub-components ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textTertiary,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.child,
    this.required = false,
    this.helper,
    this.errorText,
  });

  final String label;
  final Widget child;
  final bool required;
  final String? helper;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            children: required
                ? const [
                    TextSpan(
                        text: ' *', style: TextStyle(color: AppColors.danger)),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 6),
        child,
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(
              color: AppColors.danger,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ] else if (helper != null) ...[
          const SizedBox(height: 4),
          Text(
            helper!,
            style: const TextStyle(
                color: AppColors.textTertiary, fontSize: 11.5),
          ),
        ],
      ],
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({required this.selected, required this.disabled});
  final String selected;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddProductCubit>();
    final categories = kProductCategories.where((c) => c != 'All').toList();
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isExpanded: true,
          isDense: true,
          dropdownColor: AppColors.darkSurfaceElevated,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textTertiary),
          items: [
            for (final c in categories)
              DropdownMenuItem(value: c, child: Text(c)),
          ],
          onChanged:
              disabled ? null : (v) => v == null ? null : cubit.selectCategory(v),
        ),
      ),
    );
  }
}

class _ProductImagePicker extends StatelessWidget {
  const _ProductImagePicker({required this.form, required this.disabled});
  final AddProductFormData form;
  final bool disabled;

  static const List<String> _emojis = [
    '📦', '☕', '🥤', '💧', '🍊', '🍌', '🍞', '🥑', '🍜', '🥛',
    '🍫', '🍬', '🍭', '🥡', '🍳', '🌾', '🍚', '🧴', '💊', '💋',
    '🧺', '🧻', '🧼', '🪥', '🚬', '🔋', '🔌', '📓', '🖊', '🗒',
    '🛍', '🎁', '🍻', '🧃', '🌮',
  ];

  Future<void> _pickImage(BuildContext context) async {
    final cubit = context.read<AddProductCubit>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      cubit.setImage(bytes);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not load image: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.darkBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              _PreviewBox(form: form),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              disabled ? null : () => _pickImage(context),
                          icon: const Icon(Icons.upload_outlined, size: 18),
                          label: Text(
                              form.hasImage ? 'Replace Image' : 'Upload Image'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            textStyle: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (form.hasImage) ...[
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: disabled
                                ? null
                                : () => context
                                    .read<AddProductCubit>()
                                    .clearImage(),
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Remove'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.danger,
                              textStyle: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      form.hasImage
                          ? 'Photo will be shown on the POS grid.'
                          : 'No photo? Pick an icon below as a fallback.',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Opacity(
          opacity: form.hasImage ? 0.55 : 1,
          child: _EmojiFallbackRow(
            selected: form.emoji,
            emojis: _emojis,
            disabled: disabled,
          ),
        ),
      ],
    );
  }
}

class _PreviewBox extends StatelessWidget {
  const _PreviewBox({required this.form});
  final AddProductFormData form;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.brandAmber, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: form.hasImage
          ? Image.memory(
              form.imageBytes!,
              fit: BoxFit.cover,
              width: 96,
              height: 96,
            )
          : Text(form.emoji, style: const TextStyle(fontSize: 44)),
    );
  }
}

class _EmojiFallbackRow extends StatelessWidget {
  const _EmojiFallbackRow({
    required this.selected,
    required this.emojis,
    required this.disabled,
  });

  final String selected;
  final List<String> emojis;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddProductCubit>();
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: emojis.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final e = emojis[i];
          final active = e == selected;
          return Material(
            color: active
                ? AppColors.brandAmber.withValues(alpha: 0.18)
                : AppColors.darkSurface,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: disabled ? null : () => cubit.selectEmoji(e),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: active ? AppColors.brandAmber : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(e, style: const TextStyle(fontSize: 22)),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Action bar ────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.isEdit,
    required this.submitting,
    required this.onCancel,
    required this.onSave,
  });

  final bool isEdit;
  final bool submitting;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: submitting ? null : onCancel,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: submitting ? null : onSave,
          child: submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textOnPrimary,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(isEdit ? 'Save Changes' : 'Save Product'),
                ),
        ),
      ],
    );
  }
}
