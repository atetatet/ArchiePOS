import 'package:equatable/equatable.dart';

enum UserRole { owner, manager, cashier }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.manager:
        return 'Manager';
      case UserRole.cashier:
        return 'Cashier';
    }
  }
}

class User extends Equatable {
  const User({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
  });

  final String id;
  final String username;
  final String name;
  final UserRole role;

  @override
  List<Object?> get props => [id];
}

const List<User> kSeedUsers = [
  User(
    id: 'user-001',
    username: 'admin',
    name: 'Archie Gonzales',
    role: UserRole.manager,
  ),
  User(
    id: 'user-002',
    username: 'nena',
    name: 'Aling Nena',
    role: UserRole.owner,
  ),
  User(
    id: 'user-003',
    username: 'cashier',
    name: 'Aling Maria',
    role: UserRole.cashier,
  ),
];

/// Hardcoded credentials. Will be replaced when the real auth backend lands.
const Map<String, String> kSeedCredentials = {
  'admin': 'admin123',
  'nena': '1234',
  'cashier': '1234',
};
