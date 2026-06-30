import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import 'cubit/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();
  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  late final TextEditingController _storeNameCtrl;
  late final TextEditingController _ownerNameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _taxRateCtrl;
  late final TextEditingController _footerCtrl;

  @override
  void initState() {
    super.initState();
    final d = context.read<SettingsCubit>().state.data;
    _storeNameCtrl = TextEditingController(text: d.storeName);
    _ownerNameCtrl = TextEditingController(text: d.ownerName);
    _addressCtrl = TextEditingController(text: d.storeAddress);
    _phoneCtrl = TextEditingController(text: d.storePhone);
    _taxRateCtrl = TextEditingController(text: (d.taxRate * 100).toStringAsFixed(0));
    _footerCtrl = TextEditingController(text: d.receiptFooter);
  }

  @override
  void dispose() {
    _storeNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _taxRateCtrl.dispose();
    _footerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listenWhen: (prev, curr) =>
          curr is SettingsSaved && prev is SettingsSaving,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved (stub — drift wiring next)'),
            backgroundColor: AppColors.success,
          ),
        );
      },
      builder: (context, state) {
        final cubit = context.read<SettingsCubit>();
        final saving = state is SettingsSaving;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(dirty: state.dirty),
                  const SizedBox(height: 20),
                  _StoreProfileSection(
                    data: state.data,
                    storeNameCtrl: _storeNameCtrl,
                    ownerNameCtrl: _ownerNameCtrl,
                    addressCtrl: _addressCtrl,
                    phoneCtrl: _phoneCtrl,
                    onStoreName: cubit.setStoreName,
                    onOwnerName: cubit.setOwnerName,
                    onAddress: cubit.setStoreAddress,
                    onPhone: cubit.setStorePhone,
                  ),
                  const SizedBox(height: 16),
                  _ReceiptTaxSection(
                    data: state.data,
                    taxRateCtrl: _taxRateCtrl,
                    footerCtrl: _footerCtrl,
                    onTaxRate: (v) {
                      final pct = double.tryParse(v);
                      if (pct == null) return;
                      cubit.setTaxRate(pct / 100);
                    },
                    onTaxMode: cubit.setTaxMode,
                    onFooter: cubit.setReceiptFooter,
                    onAutoPrint: cubit.toggleAutoPrint,
                  ),
                  const SizedBox(height: 16),
                  _LicenseSection(data: state.data),
                  const SizedBox(height: 16),
                  _SyncSection(data: state.data),
                  const SizedBox(height: 16),
                  _AboutSection(data: state.data),
                  const SizedBox(height: 16),
                  const _DangerZoneSection(),
                  const SizedBox(height: 24),
                  _SaveBar(
                    dirty: state.dirty,
                    saving: saving,
                    onSave: cubit.save,
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

// ─── Header ────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.dirty});
  final bool dirty;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              const Text(
                'Store profile, receipt rules, license, and backups',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
              ),
            ],
          ),
        ),
        if (dirty)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: AppColors.warning),
                SizedBox(width: 6),
                Text(
                  'Unsaved changes',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Section shell ─────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});
  final String label;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

// ─── Store Profile ─────────────────────────────────────────────────────────

class _StoreProfileSection extends StatelessWidget {
  const _StoreProfileSection({
    required this.data,
    required this.storeNameCtrl,
    required this.ownerNameCtrl,
    required this.addressCtrl,
    required this.phoneCtrl,
    required this.onStoreName,
    required this.onOwnerName,
    required this.onAddress,
    required this.onPhone,
  });

  final SettingsData data;
  final TextEditingController storeNameCtrl;
  final TextEditingController ownerNameCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController phoneCtrl;
  final ValueChanged<String> onStoreName;
  final ValueChanged<String> onOwnerName;
  final ValueChanged<String> onAddress;
  final ValueChanged<String> onPhone;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Store Profile',
      subtitle: 'Shown on receipts and reports',
      icon: Icons.storefront_outlined,
      iconColor: AppColors.brandAmber,
      child: LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 540;
        final storeName = _Field(
          label: 'Store Name',
          child: TextField(
            controller: storeNameCtrl,
            onChanged: onStoreName,
            decoration: const InputDecoration(hintText: "Aling Nena's Sari-Sari"),
          ),
        );
        final ownerName = _Field(
          label: 'Owner Name',
          child: TextField(
            controller: ownerNameCtrl,
            onChanged: onOwnerName,
            decoration: const InputDecoration(hintText: 'Aling Nena'),
          ),
        );
        final address = _Field(
          label: 'Address',
          child: TextField(
            controller: addressCtrl,
            onChanged: onAddress,
            decoration: const InputDecoration(
                hintText: 'Purok 2, Brgy. Santo Niño'),
          ),
        );
        final phone = _Field(
          label: 'Contact Number',
          child: TextField(
            controller: phoneCtrl,
            onChanged: onPhone,
            keyboardType: TextInputType.phone,
            decoration:
                const InputDecoration(hintText: '+63 9XX XXX XXXX'),
          ),
        );
        return Column(
          children: [
            if (wide)
              Row(children: [
                Expanded(child: storeName),
                const SizedBox(width: 12),
                Expanded(child: ownerName),
              ])
            else ...[
              storeName,
              const SizedBox(height: 12),
              ownerName,
            ],
            const SizedBox(height: 12),
            address,
            const SizedBox(height: 12),
            phone,
          ],
        );
      }),
    );
  }
}

// ─── Receipt & Tax ─────────────────────────────────────────────────────────

class _ReceiptTaxSection extends StatelessWidget {
  const _ReceiptTaxSection({
    required this.data,
    required this.taxRateCtrl,
    required this.footerCtrl,
    required this.onTaxRate,
    required this.onTaxMode,
    required this.onFooter,
    required this.onAutoPrint,
  });

  final SettingsData data;
  final TextEditingController taxRateCtrl;
  final TextEditingController footerCtrl;
  final ValueChanged<String> onTaxRate;
  final ValueChanged<TaxMode> onTaxMode;
  final ValueChanged<String> onFooter;
  final ValueChanged<bool> onAutoPrint;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Receipt & Tax',
      subtitle: 'How prices and taxes appear at checkout',
      icon: Icons.receipt_long_outlined,
      iconColor: AppColors.info,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(builder: (context, c) {
            final wide = c.maxWidth >= 540;
            final taxRate = _Field(
              label: 'Tax Rate',
              child: TextField(
                controller: taxRateCtrl,
                onChanged: onTaxRate,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  hintText: '12',
                  suffixText: ' % ',
                ),
              ),
            );
            final taxMode = _Field(
              label: 'Tax Mode',
              child: _TaxModeDropdown(mode: data.taxMode, onChanged: onTaxMode),
            );
            if (wide) {
              return Row(children: [
                Expanded(child: taxRate),
                const SizedBox(width: 12),
                Expanded(child: taxMode),
              ]);
            }
            return Column(children: [
              taxRate,
              const SizedBox(height: 12),
              taxMode,
            ]);
          }),
          const SizedBox(height: 12),
          _Field(
            label: 'Receipt Footer',
            child: TextField(
              controller: footerCtrl,
              onChanged: onFooter,
              decoration:
                  const InputDecoration(hintText: 'Salamat po! ❤️'),
            ),
          ),
          const SizedBox(height: 14),
          _SwitchRow(
            title: 'Auto-print receipts',
            subtitle:
                'Print a copy automatically when an order is charged (needs printer)',
            value: data.autoPrintReceipts,
            onChanged: onAutoPrint,
          ),
        ],
      ),
    );
  }
}

class _TaxModeDropdown extends StatelessWidget {
  const _TaxModeDropdown({required this.mode, required this.onChanged});
  final TaxMode mode;
  final ValueChanged<TaxMode> onChanged;

  static const Map<TaxMode, String> _labels = {
    TaxMode.none: 'Non-VAT',
    TaxMode.inclusive: 'VAT-inclusive',
    TaxMode.exclusive: 'VAT-exclusive',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TaxMode>(
          value: mode,
          isExpanded: true,
          isDense: true,
          dropdownColor: AppColors.darkSurfaceElevated,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textTertiary),
          items: [
            for (final e in _labels.entries)
              DropdownMenuItem(value: e.key, child: Text(e.value)),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

// ─── License & Activation ──────────────────────────────────────────────────

class _LicenseSection extends StatelessWidget {
  const _LicenseSection({required this.data});
  final SettingsData data;

  static final _dateFmt = DateFormat('MMM d, yyyy');

  @override
  Widget build(BuildContext context) {
    final daysLeft = data.licenseExpiresAt == null
        ? 0
        : data.licenseExpiresAt!
            .difference(DateTime.parse('2026-06-15'))
            .inDays;
    final isPaid = data.plan != LicensePlan.free;
    final isExpiring = isPaid && daysLeft <= 7;

    return _Section(
      title: 'License & Activation',
      subtitle: 'Prepaid plans unlock the app for a set time',
      icon: Icons.workspace_premium_outlined,
      iconColor: const Color(0xFF8B5CF6),
      trailing: _PlanBadge(plan: data.plan),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isPaid) ...[
            Row(
              children: [
                Text(
                  daysLeft > 0 ? '$daysLeft days remaining' : 'Expired',
                  style: TextStyle(
                    color: isExpiring ? AppColors.danger : AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  data.licenseExpiresAt == null
                      ? '—'
                      : 'Expires ${_dateFmt.format(data.licenseExpiresAt!)}',
                  style: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (daysLeft.clamp(0, 30)) / 30.0,
                minHeight: 6,
                backgroundColor: AppColors.darkBg,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isExpiring ? AppColors.danger : AppColors.brandAmber,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.brandAmber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.brandAmber, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "You're on the Free plan. Enter an activation code below to unlock Tindahan, Negosyo, or Online Seller features.",
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openActivation(context),
                  icon: const Icon(Icons.vpn_key_outlined, size: 18),
                  label: const Text('Enter Activation Code'),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Compare plans — coming soon'),
                      backgroundColor: AppColors.darkSurfaceElevated,
                    ),
                  );
                },
                icon: const Icon(Icons.compare_arrows, size: 16),
                label: const Text('Compare Plans'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.darkBorder),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (isPaid) ...[
            const SizedBox(height: 12),
            _SwitchRow(
              title: 'Auto-renew when online',
              subtitle:
                  'Automatically apply queued codes before expiry (if available)',
              value: data.autoRenew,
              onChanged: (v) =>
                  context.read<SettingsCubit>().toggleAutoRenew(v),
            ),
          ],
        ],
      ),
    );
  }

  void _openActivation(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: const _ActivationDialog(),
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.plan});
  final LicensePlan plan;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;
    switch (plan) {
      case LicensePlan.free:
        label = 'Free';
        color = AppColors.textSecondary;
        break;
      case LicensePlan.tindahan:
        label = 'Tindahan';
        color = AppColors.brandAmber;
        break;
      case LicensePlan.negosyo:
        label = 'Negosyo';
        color = const Color(0xFF8B5CF6);
        break;
      case LicensePlan.onlineSeller:
        label = 'Online Seller';
        color = const Color(0xFF3B82F6);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _ActivationDialog extends StatefulWidget {
  const _ActivationDialog();
  @override
  State<_ActivationDialog> createState() => _ActivationDialogState();
}

class _ActivationDialogState extends State<_ActivationDialog> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final err =
        context.read<SettingsCubit>().applyActivationCode(_ctrl.text);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Activation successful! Plan updated.'),
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
                      color: AppColors.brandAmber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.vpn_key_outlined,
                        color: AppColors.brandAmber),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Enter Activation Code',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
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
              const SizedBox(height: 6),
              const Text(
                'Buy a load-style code from your distributor, bayad center, or pawnshop. Example codes for testing: TINDAHAN-30, NEGOSYO-7, ONLINE-90.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ctrl,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: 'TINDAHAN-30',
                  prefixIcon:
                      Icon(Icons.confirmation_number_outlined, size: 20),
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 6),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 20),
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
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('Activate'),
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

// ─── Sync & Backup ─────────────────────────────────────────────────────────

class _SyncSection extends StatelessWidget {
  const _SyncSection({required this.data});
  final SettingsData data;

  static final _fmt = DateFormat('MMM d, yyyy — h:mm a');

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Sync & Backup',
      subtitle: 'Push local sales to the cloud when connected',
      icon: Icons.cloud_sync_outlined,
      iconColor: AppColors.info,
      trailing: _SyncBadge(status: data.syncStatus),
      child: Column(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Last synced',
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.lastSyncedAt == null
                            ? 'Never'
                            : _fmt.format(data.lastSyncedAt!),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (data.pendingChanges > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${data.pendingChanges} pending',
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: data.syncStatus == SyncStatus.syncing
                      ? null
                      : () => context.read<SettingsCubit>().triggerSync(),
                  icon: data.syncStatus == SyncStatus.syncing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textOnPrimary,
                          ),
                        )
                      : const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: Text(
                    data.syncStatus == SyncStatus.syncing
                        ? 'Syncing…'
                        : 'Sync Now',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Export DB to file — coming soon'),
                      backgroundColor: AppColors.darkSurfaceElevated,
                    ),
                  );
                },
                icon: const Icon(Icons.download_outlined, size: 16),
                label: const Text('Export'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.darkBorder),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SwitchRow(
            title: 'Auto-sync when connected',
            subtitle:
                'Upload pending changes in the background whenever signal returns',
            value: data.autoSync,
            onChanged: (v) => context.read<SettingsCubit>().toggleAutoSync(v),
          ),
        ],
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  const _SyncBadge({required this.status});
  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;
    late final IconData icon;
    switch (status) {
      case SyncStatus.connected:
        label = 'Connected';
        color = AppColors.success;
        icon = Icons.cloud_done_outlined;
        break;
      case SyncStatus.syncing:
        label = 'Syncing';
        color = AppColors.info;
        icon = Icons.cloud_sync;
        break;
      case SyncStatus.offline:
        label = 'Offline';
        color = AppColors.textTertiary;
        icon = Icons.cloud_off_outlined;
        break;
      case SyncStatus.failed:
        label = 'Failed';
        color = AppColors.danger;
        icon = Icons.error_outline;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── About ─────────────────────────────────────────────────────────────────

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.data});
  final SettingsData data;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'About',
      icon: Icons.info_outline,
      iconColor: AppColors.textSecondary,
      child: Column(
        children: [
          _InfoRow(label: 'App Version', value: data.appVersion),
          _InfoRow(label: 'Cashier', value: data.cashierName),
          _InfoRow(label: 'Device ID', value: data.deviceId),
          const SizedBox(height: 6),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Check for updates — coming soon'),
                      backgroundColor: AppColors.darkSurfaceElevated,
                    ),
                  );
                },
                icon: const Icon(Icons.system_update_alt, size: 16),
                label: const Text('Check for updates'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.brandAmber,
                  textStyle: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Privacy policy — coming soon'),
                      backgroundColor: AppColors.darkSurfaceElevated,
                    ),
                  );
                },
                icon: const Icon(Icons.policy_outlined, size: 16),
                label: const Text('Privacy policy'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  textStyle: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Danger zone ──────────────────────────────────────────────────────────

class _DangerZoneSection extends StatelessWidget {
  const _DangerZoneSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.warning_amber_rounded,
                    color: AppColors.danger, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Danger Zone',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Irreversible actions — proceed with care',
                      style: TextStyle(
                          color: AppColors.textTertiary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmReset(context),
                  icon: const Icon(Icons.delete_forever, size: 18),
                  label: const Text('Reset All Data'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
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
                      child: const Icon(Icons.warning_amber_rounded,
                          color: AppColors.danger),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Reset all data?',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'This permanently deletes products, sales, customers, lista entries, and resets settings to defaults. Make sure you have a recent backup before continuing.',
                  style: TextStyle(
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
                    ElevatedButton(
                      onPressed: () {
                        cubit.resetData();
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'All data reset — settings restored to defaults'),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('Reset Everything'),
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

// ─── Shared widgets ────────────────────────────────────────────────────────

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.brandAmber,
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.dirty,
    required this.saving,
    required this.onSave,
  });

  final bool dirty;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (dirty)
          const Padding(
            padding: EdgeInsets.only(right: 14),
            child: Text(
              'You have unsaved changes',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ElevatedButton(
          onPressed: (!dirty || saving) ? null : onSave,
          child: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textOnPrimary,
                  ),
                )
              : const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Save Changes'),
                ),
        ),
      ],
    );
  }
}
