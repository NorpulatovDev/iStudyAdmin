// lib/features/reports/data/models/report_model.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_model.g.dart';

@JsonSerializable()
class PaymentReportModel extends Equatable {
  final String type;
  final int? year;
  final int? month;
  final String? date;
  final String? startDate;
  final String? endDate;
  final int branchId;
  final double totalPayments;

  const PaymentReportModel({
    required this.type,
    this.year,
    this.month,
    this.date,
    this.startDate,
    this.endDate,
    required this.branchId,
    required this.totalPayments,
  });

  factory PaymentReportModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentReportModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentReportModelToJson(this);

  @override
  List<Object?> get props => [
        type,
        year,
        month,
        date,
        startDate,
        endDate,
        branchId,
        totalPayments,
      ];
}

@JsonSerializable()
class ExpenseReportModel extends Equatable {
  final String type;
  final int? year;
  final int? month;
  final String? date;
  final String? startDate;
  final String? endDate;
  final int branchId;
  final double regularExpenses;
  final double salaryExpenses;
  final double totalExpenses;

  const ExpenseReportModel({
    required this.type,
    this.year,
    this.month,
    this.date,
    this.startDate,
    this.endDate,
    required this.branchId,
    required this.regularExpenses,
    required this.salaryExpenses,
    required this.totalExpenses,
  });

  factory ExpenseReportModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseReportModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseReportModelToJson(this);

  @override
  List<Object?> get props => [
        type,
        year,
        month,
        date,
        startDate,
        endDate,
        branchId,
        regularExpenses,
        salaryExpenses,
        totalExpenses,
      ];
}

@JsonSerializable()
class FinancialSummaryModel extends Equatable {
  final String type;
  final int? year;
  final int? month;
  final String? startDate;
  final String? endDate;
  final int branchId;
  final double totalIncome;
  final double regularExpenses;
  final double salaryPayments;
  final double totalExpenses;
  final double netProfit;

  const FinancialSummaryModel({
    required this.type,
    this.year,
    this.month,
    this.startDate,
    this.endDate,
    required this.branchId,
    required this.totalIncome,
    required this.regularExpenses,
    required this.salaryPayments,
    required this.totalExpenses,
    required this.netProfit,
  });

  factory FinancialSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$FinancialSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$FinancialSummaryModelToJson(this);

  @override
  List<Object?> get props => [
        type,
        year,
        month,
        startDate,
        endDate,
        branchId,
        totalIncome,
        regularExpenses,
        salaryPayments,
        totalExpenses,
        netProfit,
      ];
}

enum ReportPeriod {
  daily,
  monthly,
  range,
}

enum ReportType {
  payment,
  expense,
  financial,
}