import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../1_domain/entities/customer.dart';

part 'add_customer_state.dart';

class AddCustomerCubit extends Cubit<AddCustomerState> {
  AddCustomerCubit({Customer? initialCustomer})
      : _initialCustomer = initialCustomer,
        super(AddCustomerIdle(
          isEditMode: initialCustomer != null,
          form: const AddCustomerFormData(errors: {}),
        ));

  final Customer? _initialCustomer;

  bool get isEditMode => _initialCustomer != null;

  void submit({
    required String name,
    required String phone,
    required String address,
    required String notes,
  }) {
    final errors = <String, String>{};

    if (name.trim().isEmpty) {
      errors['name'] = 'Customer name is required';
    } else if (name.trim().length < 2) {
      errors['name'] = 'Name must be at least 2 characters';
    }

    final phoneClean = phone.trim();
    if (phoneClean.isEmpty) {
      errors['phone'] = 'Phone number is required';
    } else {
      final digits = phoneClean.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 10) {
        errors['phone'] = 'Phone must be at least 10 digits';
      }
    }

    // Duplicate-name guard (against the seed list — in edit mode skip own row).
    final isOwn = _initialCustomer?.name.toLowerCase() ==
        name.trim().toLowerCase();
    if (!isOwn &&
        kSeedCustomers.any((c) =>
            c.name.toLowerCase() == name.trim().toLowerCase())) {
      errors['name'] = 'A customer with this name already exists';
    }

    if (errors.isNotEmpty) {
      emit(AddCustomerIdle(
        isEditMode: isEditMode,
        form: state.form.copyWith(errors: errors),
      ));
      return;
    }

    emit(AddCustomerSubmitting(
      isEditMode: isEditMode,
      form: state.form.copyWith(errors: const {}),
    ));

    // TODO: persist via drift. Simulate a quick save for now.
    Future<void>.delayed(const Duration(milliseconds: 350)).then((_) {
      if (isClosed) return;
      emit(AddCustomerSubmitted(
        isEditMode: isEditMode,
        form: state.form,
        customerName: name.trim(),
      ));
    });
  }
}
