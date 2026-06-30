import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../1_domain/entities/customer.dart';
import '../../../../core/services/app_routes.dart';
import '../../../../theme/app_colors.dart';
import 'cubit/add_customer_cubit.dart';

class AddCustomerPage extends StatelessWidget {
  const AddCustomerPage({super.key, this.initialCustomer});

  /// When non-null, page is in edit mode and prefills from this customer.
  final Customer? initialCustomer;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddCustomerCubit(initialCustomer: initialCustomer),
      child: _AddCustomerView(initialCustomer: initialCustomer),
    );
  }
}

class _AddCustomerView extends StatefulWidget {
  const _AddCustomerView({this.initialCustomer});
  final Customer? initialCustomer;

  @override
  State<_AddCustomerView> createState() => _AddCustomerViewState();
}

class _AddCustomerViewState extends State<_AddCustomerView> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _notesCtrl;

  bool get _isEdit => widget.initialCustomer != null;

  @override
  void initState() {
    super.initState();
    final c = widget.initialCustomer;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _phoneCtrl = TextEditingController(text: c?.phone ?? '');
    _addressCtrl = TextEditingController(text: c?.address ?? '');
    _notesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    context.read<AddCustomerCubit>().submit(
          name: _nameCtrl.text,
          phone: _phoneCtrl.text,
          address: _addressCtrl.text,
          notes: _notesCtrl.text,
        );
  }

  void _onCancel(BuildContext context) {
    context.go(AppRoutes.masterDataCustomers);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCustomerCubit, AddCustomerState>(
      listenWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
      listener: (context, state) {
        if (state is AddCustomerSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.isEditMode
                    ? '"${state.customerName}" updated (stub — drift wiring next)'
                    : '"${state.customerName}" added (stub — drift wiring next)',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          context.go(AppRoutes.masterDataCustomers);
        }
      },
      builder: (context, state) {
        final submitting = state is AddCustomerSubmitting;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Breadcrumb(onBack: () => _onCancel(context)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _AvatarPreview(name: _nameCtrl.text),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEdit ? 'Edit Customer' : 'Add New Customer',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isEdit
                                  ? 'Update this suki\'s contact information'
                                  : 'Register a regular customer so you can track lista and purchases',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _FormCard(
                    form: state.form,
                    submitting: submitting,
                    nameCtrl: _nameCtrl,
                    phoneCtrl: _phoneCtrl,
                    addressCtrl: _addressCtrl,
                    notesCtrl: _notesCtrl,
                    onNameChanged: () => setState(() {}),
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
                Icon(Icons.arrow_back,
                    size: 18, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Text(
                  'Back to Customers',
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

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final initial =
        name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.brandAmber, AppColors.brandAmberDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ─── Form ──────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.form,
    required this.submitting,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.addressCtrl,
    required this.notesCtrl,
    required this.onNameChanged,
  });

  final AddCustomerFormData form;
  final bool submitting;
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController notesCtrl;
  final VoidCallback onNameChanged;

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
          const _SectionLabel(label: 'CONTACT INFO'),
          const SizedBox(height: 12),
          _Field(
            label: 'Customer Name',
            required: true,
            errorText: form.errors['name'],
            child: TextField(
              controller: nameCtrl,
              enabled: !submitting,
              onChanged: (_) => onNameChanged(),
              decoration: const InputDecoration(
                hintText: 'e.g. Aling Maria',
                prefixIcon: Icon(Icons.person_outline,
                    color: AppColors.textTertiary, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _Field(
            label: 'Phone Number',
            required: true,
            errorText: form.errors['phone'],
            helper: 'Used for reminders and GCash references',
            child: TextField(
              controller: phoneCtrl,
              enabled: !submitting,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d\s+\-()]')),
              ],
              decoration: const InputDecoration(
                hintText: '+63 9XX XXX XXXX',
                prefixIcon: Icon(Icons.phone,
                    color: AppColors.textTertiary, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),
          const _SectionLabel(label: 'OPTIONAL DETAILS'),
          const SizedBox(height: 12),
          _Field(
            label: 'Address',
            child: TextField(
              controller: addressCtrl,
              enabled: !submitting,
              decoration: const InputDecoration(
                hintText: 'e.g. Purok 3, Brgy. Santo Niño',
                prefixIcon: Icon(Icons.location_on_outlined,
                    color: AppColors.textTertiary, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _Field(
            label: 'Notes',
            helper: 'Private notes about this customer (e.g. "pays every Friday")',
            child: TextField(
              controller: notesCtrl,
              enabled: !submitting,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Optional notes',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
                  child: Text(isEdit ? 'Save Changes' : 'Save Customer'),
                ),
        ),
      ],
    );
  }
}
