import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../1_domain/entities/product.dart';

part 'add_product_state.dart';

class AddProductCubit extends Cubit<AddProductState> {
  AddProductCubit({Product? initialProduct})
      : _initialProduct = initialProduct,
        super(_buildInitialState(initialProduct));

  final Product? _initialProduct;

  bool get isEditMode => _initialProduct != null;

  static AddProductState _buildInitialState(Product? initial) {
    if (initial == null) {
      return AddProductIdle(
        isEditMode: false,
        form: AddProductFormData(
          category: 'Beverages',
          emoji: '📦',
          imageBytes: null,
          isTingi: false,
          baseUnit: '',
          sellOptions: [_blankOption()],
          errors: const {},
        ),
      );
    }
    return AddProductIdle(
      isEditMode: true,
      form: AddProductFormData(
        category: initial.category,
        emoji: initial.emoji,
        imageBytes: null,
        isTingi: initial.isTingi,
        baseUnit: initial.baseUnit ?? '',
        sellOptions: initial.sellOptions
            .map((o) => SellOptionDraft(
                  id: o.id,
                  label: o.label,
                  baseQty: o.baseQty.toString(),
                  price: o.price.toStringAsFixed(2),
                ))
            .toList(),
        errors: const {},
      ),
    );
  }

  static SellOptionDraft _blankOption() => SellOptionDraft(
        id: 'draft-${DateTime.now().microsecondsSinceEpoch}',
        label: '',
        baseQty: '',
        price: '',
      );

  void selectCategory(String category) =>
      _emit(state.form.copyWith(category: category));

  void selectEmoji(String emoji) =>
      _emit(state.form.copyWith(emoji: emoji));

  void setImage(Uint8List bytes) =>
      _emit(state.form.copyWith(imageBytes: bytes));

  void clearImage() => _emit(state.form.copyWith(clearImage: true));

  void toggleTingi(bool value) {
    final form = state.form;
    // When switching ON, ensure at least one sell-option row exists.
    final options = value && form.sellOptions.isEmpty
        ? [_blankOption()]
        : form.sellOptions;
    _emit(form.copyWith(isTingi: value, sellOptions: options));
  }

  void setBaseUnit(String unit) => _emit(state.form.copyWith(baseUnit: unit));

  void addSellOption() {
    final next = [...state.form.sellOptions, _blankOption()];
    _emit(state.form.copyWith(sellOptions: next));
  }

  void updateSellOption(
    String id, {
    String? label,
    String? baseQty,
    String? price,
  }) {
    final next = state.form.sellOptions
        .map((o) => o.id == id
            ? o.copyWith(label: label, baseQty: baseQty, price: price)
            : o)
        .toList();
    _emit(state.form.copyWith(sellOptions: next));
  }

  void removeSellOption(String id) {
    final next = state.form.sellOptions.where((o) => o.id != id).toList();
    _emit(state.form.copyWith(
      sellOptions: next.isEmpty ? [_blankOption()] : next,
    ));
  }

  String autoGenerateSku() {
    final prefix = _categoryPrefix(state.form.category);
    final used = kSeedProducts
        .where((p) => p.sku.startsWith('$prefix-'))
        .map((p) => int.tryParse(p.sku.split('-').last) ?? 0)
        .toList()
      ..sort();
    final next = (used.isEmpty ? 0 : used.last) + 1;
    return '$prefix-${next.toString().padLeft(3, '0')}';
  }

  void submit({
    required String name,
    required String sku,
    required String description,
    required String price,
    required String stock,
    required String lowStockThreshold,
  }) {
    final form = state.form;
    final errors = <String, String>{};

    if (name.trim().isEmpty) {
      errors['name'] = 'Product name is required';
    }
    if (sku.trim().isEmpty) {
      errors['sku'] = 'SKU is required';
    } else {
      final isOwnSku = _initialProduct?.sku == sku.trim();
      if (!isOwnSku && kSeedProducts.any((p) => p.sku == sku.trim())) {
        errors['sku'] = 'SKU already exists';
      }
    }

    final stockVal = double.tryParse(stock.trim());
    if (stockVal == null || stockVal < 0) {
      errors['stock'] = 'Enter a valid stock quantity';
    }
    final thresholdVal = double.tryParse(lowStockThreshold.trim());
    if (thresholdVal == null || thresholdVal < 0) {
      errors['threshold'] = 'Enter a valid threshold';
    }

    if (form.isTingi) {
      if (form.baseUnit.trim().isEmpty) {
        errors['baseUnit'] = 'Base unit is required (e.g. kg, piece, ml)';
      }
      if (form.sellOptions.isEmpty) {
        errors['sellOptions'] = 'Add at least one sell option';
      }
      for (var i = 0; i < form.sellOptions.length; i++) {
        final o = form.sellOptions[i];
        if (o.label.trim().isEmpty) {
          errors['option-${o.id}-label'] = 'Required';
        }
        final qty = double.tryParse(o.baseQty.trim());
        if (qty == null || qty <= 0) {
          errors['option-${o.id}-baseQty'] = 'Invalid';
        }
        final p = double.tryParse(o.price.trim());
        if (p == null || p <= 0) {
          errors['option-${o.id}-price'] = 'Invalid';
        }
      }
    } else {
      final priceVal = double.tryParse(price.trim());
      if (priceVal == null || priceVal <= 0) {
        errors['price'] = 'Enter a valid price';
      }
    }

    if (errors.isNotEmpty) {
      emit(AddProductIdle(
        isEditMode: isEditMode,
        form: form.copyWith(errors: errors),
      ));
      return;
    }

    emit(AddProductSubmitting(
      isEditMode: isEditMode,
      form: form.copyWith(errors: const {}),
    ));

    // TODO: persist via drift. For now, simulate a quick save.
    Future<void>.delayed(const Duration(milliseconds: 350)).then((_) {
      if (isClosed) return;
      emit(AddProductSubmitted(
        isEditMode: isEditMode,
        form: form,
        productName: name.trim(),
      ));
    });
  }

  void _emit(AddProductFormData form) {
    emit(AddProductIdle(isEditMode: isEditMode, form: form));
  }

  static String _categoryPrefix(String category) {
    switch (category) {
      case 'Beverages':
        return 'BEV';
      case 'Food':
        return 'FOOD';
      case 'Health':
        return 'HLTH';
      case 'Electronics':
        return 'ELEC';
      case 'Stationery':
        return 'STAT';
      default:
        return 'GEN';
    }
  }
}
