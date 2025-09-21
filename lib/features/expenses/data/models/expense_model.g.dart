// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseModel _$ExpenseModelFromJson(Map<String, dynamic> json) => ExpenseModel(
      id: (json['id'] as num).toInt(),
      description: json['description'] as String?,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      branchId: (json['branchId'] as num).toInt(),
      branchName: json['branchName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ExpenseModelToJson(ExpenseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'amount': instance.amount,
      'category': instance.category,
      'branchId': instance.branchId,
      'branchName': instance.branchName,
      'createdAt': instance.createdAt.toIso8601String(),
    };
