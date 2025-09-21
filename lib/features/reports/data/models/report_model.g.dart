// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentReportModel _$PaymentReportModelFromJson(Map<String, dynamic> json) =>
    PaymentReportModel(
      type: json['type'] as String,
      year: (json['year'] as num?)?.toInt(),
      month: (json['month'] as num?)?.toInt(),
      date: json['date'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      branchId: (json['branchId'] as num).toInt(),
      totalPayments: (json['totalPayments'] as num).toDouble(),
    );

Map<String, dynamic> _$PaymentReportModelToJson(PaymentReportModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'year': instance.year,
      'month': instance.month,
      'date': instance.date,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'branchId': instance.branchId,
      'totalPayments': instance.totalPayments,
    };

ExpenseReportModel _$ExpenseReportModelFromJson(Map<String, dynamic> json) =>
    ExpenseReportModel(
      type: json['type'] as String,
      year: (json['year'] as num?)?.toInt(),
      month: (json['month'] as num?)?.toInt(),
      date: json['date'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      branchId: (json['branchId'] as num).toInt(),
      regularExpenses: (json['regularExpenses'] as num).toDouble(),
      salaryExpenses: (json['salaryExpenses'] as num).toDouble(),
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
    );

Map<String, dynamic> _$ExpenseReportModelToJson(ExpenseReportModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'year': instance.year,
      'month': instance.month,
      'date': instance.date,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'branchId': instance.branchId,
      'regularExpenses': instance.regularExpenses,
      'salaryExpenses': instance.salaryExpenses,
      'totalExpenses': instance.totalExpenses,
    };

FinancialSummaryModel _$FinancialSummaryModelFromJson(
        Map<String, dynamic> json) =>
    FinancialSummaryModel(
      type: json['type'] as String,
      year: (json['year'] as num?)?.toInt(),
      month: (json['month'] as num?)?.toInt(),
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      branchId: (json['branchId'] as num).toInt(),
      totalIncome: (json['totalIncome'] as num).toDouble(),
      regularExpenses: (json['regularExpenses'] as num).toDouble(),
      salaryPayments: (json['salaryPayments'] as num).toDouble(),
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
      netProfit: (json['netProfit'] as num).toDouble(),
    );

Map<String, dynamic> _$FinancialSummaryModelToJson(
        FinancialSummaryModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'year': instance.year,
      'month': instance.month,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'branchId': instance.branchId,
      'totalIncome': instance.totalIncome,
      'regularExpenses': instance.regularExpenses,
      'salaryPayments': instance.salaryPayments,
      'totalExpenses': instance.totalExpenses,
      'netProfit': instance.netProfit,
    };
