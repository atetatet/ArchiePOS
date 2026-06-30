import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
    : super(
        const SettingsIdle(
          dirty: false,
          data: SettingsData(
            storeName: "Aling Nena's Sari-Sari",
            ownerName: 'Aling Nena',
            storeAddress: 'Purok 2, Brgy. Santo Niño, Davao City',
            storePhone: '+63 917 123 4567',
            taxRate: 0.12,
            taxMode: TaxMode.inclusive,
            receiptFooter: 'Salamat po! ❤️',
            autoPrintReceipts: false,
            plan: LicensePlan.tindahan,
            licenseExpiresAtIso: '2026-07-03T00:00:00',
            autoRenew: false,
            lastSyncedAtIso: '2026-06-15T11:42:00',
            syncStatus: SyncStatus.connected,
            pendingChanges: 3,
            autoSync: true,
            appVersion: '1.0.0+1',
            cashierName: 'Archie Gonzales',
            deviceId: 'POS-A8F2-3C91',
          ),
        ),
      );

  void _update(SettingsData data) {
    emit(SettingsIdle(data: data, dirty: true));
  }

  // ─ Store profile ─
  void setStoreName(String v) => _update(state.data.copyWith(storeName: v));
  void setOwnerName(String v) => _update(state.data.copyWith(ownerName: v));
  void setStoreAddress(String v) =>
      _update(state.data.copyWith(storeAddress: v));
  void setStorePhone(String v) => _update(state.data.copyWith(storePhone: v));

  // ─ Tax / receipt ─
  void setTaxRate(double v) => _update(state.data.copyWith(taxRate: v));
  void setTaxMode(TaxMode v) => _update(state.data.copyWith(taxMode: v));
  void setReceiptFooter(String v) =>
      _update(state.data.copyWith(receiptFooter: v));
  void toggleAutoPrint(bool v) =>
      _update(state.data.copyWith(autoPrintReceipts: v));

  // ─ License ─
  void toggleAutoRenew(bool v) => _update(state.data.copyWith(autoRenew: v));

  /// Apply a prepaid activation code. Fake logic for now:
  /// "TINDAHAN-30" → 30 days Tindahan, "NEGOSYO-30" → 30 days Negosyo, etc.
  /// Returns null on success, error message on failure.
  String? applyActivationCode(String code) {
    final c = code.trim().toUpperCase();
    if (c.isEmpty) return 'Enter an activation code';
    if (!RegExp(r'^[A-Z]+-\d+$').hasMatch(c)) {
      return 'Code must look like TINDAHAN-30 or NEGOSYO-30';
    }
    final parts = c.split('-');
    final planKey = parts[0];
    final days = int.tryParse(parts[1]);
    if (days == null || days <= 0) return 'Days must be positive';

    LicensePlan? plan;
    switch (planKey) {
      case 'TINDAHAN':
        plan = LicensePlan.tindahan;
        break;
      case 'NEGOSYO':
        plan = LicensePlan.negosyo;
        break;
      case 'ONLINE':
      case 'ONLINESELLER':
        plan = LicensePlan.onlineSeller;
        break;
      default:
        return 'Unknown plan: $planKey';
    }

    // Stack on top of any remaining time.
    final base =
        (state.data.licenseExpiresAt != null &&
            state.data.licenseExpiresAt!.isAfter(DateTime.parse('2026-06-15')))
        ? state.data.licenseExpiresAt!
        : DateTime.parse('2026-06-15');
    final newExpiry = base.add(Duration(days: days));

    emit(
      SettingsIdle(
        dirty: false,
        data: state.data.copyWith(
          plan: plan,
          licenseExpiresAtIso: newExpiry.toIso8601String(),
        ),
      ),
    );
    return null;
  }

  // ─ Sync ─
  void toggleAutoSync(bool v) => _update(state.data.copyWith(autoSync: v));

  Future<void> triggerSync() async {
    if (state.data.syncStatus == SyncStatus.offline) return;
    emit(
      SettingsIdle(
        data: state.data.copyWith(syncStatus: SyncStatus.syncing),
        dirty: state.dirty,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (isClosed) return;
    emit(
      SettingsIdle(
        data: state.data.copyWith(
          syncStatus: SyncStatus.connected,
          lastSyncedAtIso: DateTime.parse(
            '2026-06-15T12:00:00',
          ).toIso8601String(),
          pendingChanges: 0,
        ),
        dirty: state.dirty,
      ),
    );
  }

  // ─ Save / reset ─
  Future<void> save() async {
    emit(SettingsSaving(data: state.data, dirty: state.dirty));
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (isClosed) return;
    emit(SettingsSaved(data: state.data));
  }

  void resetData() {
    // In a real app: clear drift DB + secure storage. For now, just resets the
    // displayed values to seed defaults.
    emit(
      const SettingsSaved(
        data: SettingsData(
          storeName: "Aling Nena's Sari-Sari",
          ownerName: 'Aling Nena',
          storeAddress: 'Purok 2, Brgy. Santo Niño, Davao City',
          storePhone: '+63 917 123 4567',
          taxRate: 0.12,
          taxMode: TaxMode.inclusive,
          receiptFooter: 'Salamat po! ❤️',
          autoPrintReceipts: false,
          plan: LicensePlan.free,
          licenseExpiresAtIso: null,
          autoRenew: false,
          lastSyncedAtIso: null,
          syncStatus: SyncStatus.offline,
          pendingChanges: 0,
          autoSync: true,
          appVersion: '1.0.0+1',
          cashierName: 'Archie Gonzales',
          deviceId: 'POS-A8F2-3C91',
        ),
      ),
    );
  }
}
