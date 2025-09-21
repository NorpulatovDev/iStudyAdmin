// lib/features/expenses/data/models/expense_model.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'expense_model.g.dart';

@JsonSerializable()
class ExpenseModel extends Equatable {
  final int id;
  final String? description;
  final double amount;
  final String category;
  final int branchId;
  final String branchName;
  final DateTime createdAt;

  const ExpenseModel({
    required this.id,
    this.description,
    required this.amount,
    required this.category,
    required this.branchId,
    required this.branchName,
    required this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        description,
        amount,
        category,
        branchId,
        branchName,
        createdAt,
      ];
}

enum ExpenseCategory {
  @JsonValue('RENT')
  rent,
  @JsonValue('UTILITIES')
  utilities,
  @JsonValue('SUPPLIES')
  supplies,
  @JsonValue('MAINTENANCE')
  maintenance,
  @JsonValue('OTHER')
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.rent:
        return 'Rent';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.supplies:
        return 'Supplies';
      case ExpenseCategory.maintenance:
        return 'Maintenance';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  String get apiValue {
    switch (this) {
      case ExpenseCategory.rent:
        return 'RENT';
      case ExpenseCategory.utilities:
        return 'UTILITIES';
      case ExpenseCategory.supplies:
        return 'SUPPLIES';
      case ExpenseCategory.maintenance:
        return 'MAINTENANCE';
      case ExpenseCategory.other:
        return 'OTHER';
    }
  }

  static ExpenseCategory fromString(String value) {
    switch (value.toUpperCase()) {
      case 'RENT':
        return ExpenseCategory.rent;
      case 'UTILITIES':
        return ExpenseCategory.utilities;
      case 'SUPPLIES':
        return ExpenseCategory.supplies;
      case 'MAINTENANCE':
        return ExpenseCategory.maintenance;
      case 'OTHER':
        return ExpenseCategory.other;
      default:
        return ExpenseCategory.other;
    }
  }
}