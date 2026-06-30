part of 'settings_cubit.dart';

enum TaxMode { none, inclusive, exclusive }

enum LicensePlan { free, tindahan, negosyo, onlineSeller }

enum SyncStatus { connected, syncing, offline, failed }

class SettingsData extends Equatable {
  const SettingsData({
    // Store profile
    required this.storeName,
    required this.ownerName,
    required this.storeAddress,
    required this.storePhone,
    // Receipt & Tax
    required this.taxRate,
    required this.taxMode,
    required this.receiptFooter,
    required this.autoPrintReceipts,
    // License
    required this.plan,
    required this.licenseExpiresAtIso,
    required this.autoRenew,
    // Sync
    required this.lastSyncedAtIso,
    required this.syncStatus,
    required this.pendingChanges,
    required this.autoSync,
    // About
    required this.appVersion,
    required this.cashierName,
    required this.deviceId,
  });

  final String storeName;
  final String ownerName;
  final String storeAddress;
  final String storePhone;

  final double taxRate;
  final TaxMode taxMode;
  final String receiptFooter;
  final bool autoPrintReceipts;

  final LicensePlan plan;
  final String? licenseExpiresAtIso;
  final bool autoRenew;

  final String? lastSyncedAtIso;
  final SyncStatus syncStatus;
  final int pendingChanges;
  final bool autoSync;

  final String appVersion;
  final String cashierName;
  final String deviceId;

  DateTime? get licenseExpiresAt =>
      licenseExpiresAtIso == null ? null : DateTime.parse(licenseExpiresAtIso!);

  DateTime? get lastSyncedAt =>
      lastSyncedAtIso == null ? null : DateTime.parse(lastSyncedAtIso!);

  SettingsData copyWith({
    String? storeName,
    String? ownerName,
    String? storeAddress,
    String? storePhone,
    double? taxRate,
    TaxMode? taxMode,
    String? receiptFooter,
    bool? autoPrintReceipts,
    LicensePlan? plan,
    String? licenseExpiresAtIso,
    bool? autoRenew,
    String? lastSyncedAtIso,
    SyncStatus? syncStatus,
    int? pendingChanges,
    bool? autoSync,
    String? appVersion,
    String? cashierName,
    String? deviceId,
  }) =>
      SettingsData(
        storeName: storeName ?? this.storeName,
        ownerName: ownerName ?? this.ownerName,
        storeAddress: storeAddress ?? this.storeAddress,
        storePhone: storePhone ?? this.storePhone,
        taxRate: taxRate ?? this.taxRate,
        taxMode: taxMode ?? this.taxMode,
        receiptFooter: receiptFooter ?? this.receiptFooter,
        autoPrintReceipts: autoPrintReceipts ?? this.autoPrintReceipts,
        plan: plan ?? this.plan,
        licenseExpiresAtIso: licenseExpiresAtIso ?? this.licenseExpiresAtIso,
        autoRenew: autoRenew ?? this.autoRenew,
        lastSyncedAtIso: lastSyncedAtIso ?? this.lastSyncedAtIso,
        syncStatus: syncStatus ?? this.syncStatus,
        pendingChanges: pendingChanges ?? this.pendingChanges,
        autoSync: autoSync ?? this.autoSync,
        appVersion: appVersion ?? this.appVersion,
        cashierName: cashierName ?? this.cashierName,
        deviceId: deviceId ?? this.deviceId,
      );

  @override
  List<Object?> get props => [
        storeName,
        ownerName,
        storeAddress,
        storePhone,
        taxRate,
        taxMode,
        receiptFooter,
        autoPrintReceipts,
        plan,
        licenseExpiresAtIso,
        autoRenew,
        lastSyncedAtIso,
        syncStatus,
        pendingChanges,
        autoSync,
        appVersion,
        cashierName,
        deviceId,
      ];
}

sealed class SettingsState extends Equatable {
  const SettingsState({required this.data, required this.dirty});
  final SettingsData data;

  /// True if there are unsaved field edits.
  final bool dirty;
  @override
  List<Object?> get props => [data, dirty];
}

class SettingsIdle extends SettingsState {
  const SettingsIdle({required super.data, required super.dirty});
}

class SettingsSaving extends SettingsState {
  const SettingsSaving({required super.data, required super.dirty});
}

class SettingsSaved extends SettingsState {
  const SettingsSaved({required super.data})
      : super(dirty: false);
}
