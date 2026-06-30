import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAtIso,
    this.address,
  });

  final String id;
  final String name;
  final String phone;
  final String createdAtIso;
  final String? address;

  DateTime get createdAt => DateTime.parse(createdAtIso);

  @override
  List<Object?> get props => [id];
}

const List<Customer> kSeedCustomers = [
  // Lista customers (have utang entries)
  Customer(id: 'cust-001', name: 'Aling Maria', phone: '+63 917 234 5678', address: 'Purok 2, Brgy. Santo Niño', createdAtIso: '2025-09-12T08:00:00'),
  Customer(id: 'cust-002', name: 'Mang Tonyo', phone: '+63 928 110 4421', address: 'Purok 3, Brgy. Santo Niño', createdAtIso: '2024-11-03T08:00:00'),
  Customer(id: 'cust-003', name: 'Kuya Ben', phone: '+63 906 887 1003', createdAtIso: '2026-02-18T08:00:00'),
  Customer(id: 'cust-004', name: 'Ate Susan', phone: '+63 915 442 8830', address: 'Purok 5, Brgy. Mabini', createdAtIso: '2025-06-04T08:00:00'),
  Customer(id: 'cust-005', name: 'Lolo Pedro', phone: '+63 939 776 2901', address: 'Purok 1, Brgy. Santo Niño', createdAtIso: '2024-03-22T08:00:00'),
  Customer(id: 'cust-006', name: 'Nene', phone: '+63 922 333 8810', createdAtIso: '2026-05-10T08:00:00'),
  Customer(id: 'cust-007', name: 'Aling Liza', phone: '+63 917 661 4422', address: 'Purok 4, Brgy. Mabini', createdAtIso: '2025-12-30T08:00:00'),
  // Cash regulars (no utang history)
  Customer(id: 'cust-008', name: 'Manong Jun', phone: '+63 945 220 8821', address: 'Purok 6, Brgy. Mabini', createdAtIso: '2026-01-15T08:00:00'),
  Customer(id: 'cust-009', name: 'Tita Beth', phone: '+63 918 552 0007', createdAtIso: '2026-04-02T08:00:00'),
  Customer(id: 'cust-010', name: 'Iya Carmen', phone: '+63 933 781 6620', address: 'Purok 2, Brgy. Santo Niño', createdAtIso: '2026-06-09T08:00:00'),
];
