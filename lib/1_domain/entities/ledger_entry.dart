import 'package:equatable/equatable.dart';

enum LedgerKind {
  /// Customer bought on credit — owes the store.
  sale,

  /// Customer paid back (full or partial).
  repayment,
}

class LedgerEntry extends Equatable {
  const LedgerEntry({
    required this.id,
    required this.customerId,
    required this.kind,
    required this.amount,
    required this.createdAtIso,
    this.notes,
    this.saleId,
  });

  final String id;
  final String customerId;
  final LedgerKind kind;
  final double amount;
  final String createdAtIso;
  final String? notes;
  final String? saleId;

  DateTime get createdAt => DateTime.parse(createdAtIso);

  /// Signed amount: positive for debt added (sale), negative for debt reduced (repayment).
  double get signedAmount => kind == LedgerKind.sale ? amount : -amount;

  @override
  List<Object?> get props => [id];
}

/// Seed data — today is 2026-06-15.
const List<LedgerEntry> kSeedLedger = [
  // Aling Maria — owes ₱185.50, last activity 3 days ago
  LedgerEntry(id: 'led-001', customerId: 'cust-001', kind: LedgerKind.sale, amount: 245.50, createdAtIso: '2026-06-08T10:15:00', notes: 'Grocery — rice + canned goods'),
  LedgerEntry(id: 'led-002', customerId: 'cust-001', kind: LedgerKind.repayment, amount: 100.00, createdAtIso: '2026-06-10T17:22:00', notes: 'Partial payment'),
  LedgerEntry(id: 'led-003', customerId: 'cust-001', kind: LedgerKind.sale, amount: 40.00, createdAtIso: '2026-06-12T08:40:00', notes: 'Pancit canton + sachet'),

  // Mang Tonyo — owes ₱650.00, last activity 5 days ago (OVERDUE — first sale 38 days ago)
  LedgerEntry(id: 'led-010', customerId: 'cust-002', kind: LedgerKind.sale, amount: 500.00, createdAtIso: '2026-05-08T11:00:00', notes: 'Bigasan — 5 kilo rice'),
  LedgerEntry(id: 'led-011', customerId: 'cust-002', kind: LedgerKind.sale, amount: 150.00, createdAtIso: '2026-06-10T14:00:00', notes: 'Softdrinks + chips'),

  // Kuya Ben — owes ₱45.00, last activity 1 day ago
  LedgerEntry(id: 'led-020', customerId: 'cust-003', kind: LedgerKind.sale, amount: 45.00, createdAtIso: '2026-06-14T19:30:00'),

  // Ate Susan — owes ₱320.75, last activity 12 days ago
  LedgerEntry(id: 'led-030', customerId: 'cust-004', kind: LedgerKind.sale, amount: 420.75, createdAtIso: '2026-05-28T09:10:00', notes: 'Birthday party supplies'),
  LedgerEntry(id: 'led-031', customerId: 'cust-004', kind: LedgerKind.repayment, amount: 100.00, createdAtIso: '2026-06-03T16:00:00'),

  // Lolo Pedro — owes ₱1,250.00, last activity 35 days ago (OVERDUE)
  LedgerEntry(id: 'led-040', customerId: 'cust-005', kind: LedgerKind.sale, amount: 800.00, createdAtIso: '2026-04-20T08:00:00', notes: 'Sack of rice (50kg)'),
  LedgerEntry(id: 'led-041', customerId: 'cust-005', kind: LedgerKind.sale, amount: 450.00, createdAtIso: '2026-05-11T11:30:00', notes: 'Cooking oil + condiments'),

  // Nene — owes ₱28.50, last activity today
  LedgerEntry(id: 'led-050', customerId: 'cust-006', kind: LedgerKind.sale, amount: 28.50, createdAtIso: '2026-06-15T07:45:00', notes: 'Pandesal + coffee'),

  // Aling Liza — fully paid (₱0 balance), last activity 7 days ago
  LedgerEntry(id: 'led-060', customerId: 'cust-007', kind: LedgerKind.sale, amount: 220.00, createdAtIso: '2026-06-01T10:00:00'),
  LedgerEntry(id: 'led-061', customerId: 'cust-007', kind: LedgerKind.repayment, amount: 220.00, createdAtIso: '2026-06-08T15:20:00', notes: 'Full payment'),
];
