part of 'add_customer_cubit.dart';

class AddCustomerFormData extends Equatable {
  const AddCustomerFormData({required this.errors});

  final Map<String, String> errors;

  AddCustomerFormData copyWith({Map<String, String>? errors}) =>
      AddCustomerFormData(errors: errors ?? this.errors);

  @override
  List<Object?> get props => [errors];
}

sealed class AddCustomerState extends Equatable {
  const AddCustomerState({required this.form, required this.isEditMode});
  final AddCustomerFormData form;
  final bool isEditMode;
  @override
  List<Object?> get props => [form, isEditMode];
}

class AddCustomerIdle extends AddCustomerState {
  const AddCustomerIdle({required super.form, required super.isEditMode});
}

class AddCustomerSubmitting extends AddCustomerState {
  const AddCustomerSubmitting({required super.form, required super.isEditMode});
}

class AddCustomerSubmitted extends AddCustomerState {
  const AddCustomerSubmitted({
    required super.form,
    required super.isEditMode,
    required this.customerName,
  });
  final String customerName;
  @override
  List<Object?> get props => [...super.props, customerName];
}
