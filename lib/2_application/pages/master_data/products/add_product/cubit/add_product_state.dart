part of 'add_product_cubit.dart';

/// Editable sell-option row in the form. Has its own id so the UI can key
/// off it without depending on list index (which changes when rows are removed).
class SellOptionDraft extends Equatable {
  const SellOptionDraft({
    required this.id,
    required this.label,
    required this.baseQty,
    required this.price,
  });

  final String id;
  final String label;
  final String baseQty;
  final String price;

  SellOptionDraft copyWith({String? label, String? baseQty, String? price}) =>
      SellOptionDraft(
        id: id,
        label: label ?? this.label,
        baseQty: baseQty ?? this.baseQty,
        price: price ?? this.price,
      );

  @override
  List<Object?> get props => [id, label, baseQty, price];
}

class AddProductFormData extends Equatable {
  const AddProductFormData({
    required this.category,
    required this.emoji,
    required this.imageBytes,
    required this.isTingi,
    required this.baseUnit,
    required this.sellOptions,
    required this.errors,
  });

  final String category;
  final String emoji;
  final Uint8List? imageBytes;

  /// When true, the form shows the base-unit field + sell-options list.
  final bool isTingi;

  /// Only meaningful when isTingi is true.
  final String baseUnit;

  /// Sell-option drafts. Only meaningful when isTingi is true.
  /// For non-tingi the cubit synthesizes a single 'each' option on submit.
  final List<SellOptionDraft> sellOptions;

  final Map<String, String> errors;

  bool get hasImage => imageBytes != null;

  AddProductFormData copyWith({
    String? category,
    String? emoji,
    Uint8List? imageBytes,
    bool clearImage = false,
    bool? isTingi,
    String? baseUnit,
    List<SellOptionDraft>? sellOptions,
    Map<String, String>? errors,
  }) =>
      AddProductFormData(
        category: category ?? this.category,
        emoji: emoji ?? this.emoji,
        imageBytes: clearImage ? null : (imageBytes ?? this.imageBytes),
        isTingi: isTingi ?? this.isTingi,
        baseUnit: baseUnit ?? this.baseUnit,
        sellOptions: sellOptions ?? this.sellOptions,
        errors: errors ?? this.errors,
      );

  @override
  List<Object?> get props => [
        category,
        emoji,
        imageBytes,
        isTingi,
        baseUnit,
        sellOptions,
        errors,
      ];
}

sealed class AddProductState extends Equatable {
  const AddProductState({required this.form, required this.isEditMode});
  final AddProductFormData form;
  final bool isEditMode;
  @override
  List<Object?> get props => [form, isEditMode];
}

class AddProductIdle extends AddProductState {
  const AddProductIdle({required super.form, required super.isEditMode});
}

class AddProductSubmitting extends AddProductState {
  const AddProductSubmitting({required super.form, required super.isEditMode});
}

class AddProductSubmitted extends AddProductState {
  const AddProductSubmitted({
    required super.form,
    required super.isEditMode,
    required this.productName,
  });
  final String productName;
  @override
  List<Object?> get props => [...super.props, productName];
}

class AddProductError extends AddProductState {
  const AddProductError({
    required super.form,
    required super.isEditMode,
    required this.message,
  });
  final String message;
  @override
  List<Object?> get props => [...super.props, message];
}
