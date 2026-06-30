import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum CategoryColor { amber, blue, green, purple, pink, red, teal, gray }

extension CategoryColorPalette on CategoryColor {
  Color get color {
    switch (this) {
      case CategoryColor.amber:
        return const Color(0xFFF59E0B);
      case CategoryColor.blue:
        return const Color(0xFF3B82F6);
      case CategoryColor.green:
        return const Color(0xFF10B981);
      case CategoryColor.purple:
        return const Color(0xFF8B5CF6);
      case CategoryColor.pink:
        return const Color(0xFFEC4899);
      case CategoryColor.red:
        return const Color(0xFFEF4444);
      case CategoryColor.teal:
        return const Color(0xFF14B8A6);
      case CategoryColor.gray:
        return const Color(0xFF6B7280);
    }
  }

  String get label {
    switch (this) {
      case CategoryColor.amber:
        return 'Amber';
      case CategoryColor.blue:
        return 'Blue';
      case CategoryColor.green:
        return 'Green';
      case CategoryColor.purple:
        return 'Purple';
      case CategoryColor.pink:
        return 'Pink';
      case CategoryColor.red:
        return 'Red';
      case CategoryColor.teal:
        return 'Teal';
      case CategoryColor.gray:
        return 'Gray';
    }
  }
}

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.sortOrder,
    this.isArchived = false,
  });

  final String id;
  final String name;
  final String emoji;
  final CategoryColor color;
  final int sortOrder;
  final bool isArchived;

  Category copyWith({
    String? name,
    String? emoji,
    CategoryColor? color,
    int? sortOrder,
    bool? isArchived,
  }) =>
      Category(
        id: id,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        color: color ?? this.color,
        sortOrder: sortOrder ?? this.sortOrder,
        isArchived: isArchived ?? this.isArchived,
      );

  @override
  List<Object?> get props => [id];
}

const List<Category> kSeedCategories = [
  Category(id: 'cat-bev', name: 'Beverages', emoji: '🥤', color: CategoryColor.amber, sortOrder: 0),
  Category(id: 'cat-food', name: 'Food', emoji: '🍚', color: CategoryColor.green, sortOrder: 1),
  Category(id: 'cat-hlth', name: 'Health', emoji: '💊', color: CategoryColor.blue, sortOrder: 2),
  Category(id: 'cat-elec', name: 'Electronics', emoji: '🔌', color: CategoryColor.purple, sortOrder: 3),
  Category(id: 'cat-stat', name: 'Stationery', emoji: '📓', color: CategoryColor.pink, sortOrder: 4),
  Category(id: 'cat-cig', name: 'Cigarettes', emoji: '🚬', color: CategoryColor.gray, sortOrder: 5),
  Category(id: 'cat-pc', name: 'Personal Care', emoji: '🧼', color: CategoryColor.teal, sortOrder: 6),
];
