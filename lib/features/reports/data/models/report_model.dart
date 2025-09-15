// lib/features/reports/data/models/report_model.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_model.g.dart';

@JsonSerializable()
class ReportModel extends Equatable {
  final String type;
  final int? branchId;
  final DateTime? date;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? year;
  final int? month;
  final double? totalPayments;
  final double? totalExpenses;
  final double? totalSalaries;
  final double? totalIncome;
  final double? totalCosts;
  final double? netProfit;

  const ReportModel({
    required this.type,
    this.branchId,
    this.date,
    this.startDate,
    this.endDate,
    this.year,
    this.month,
    this.totalPayments,
    this.totalExpenses,
    this.totalSalaries,
    this.totalIncome,
    this.totalCosts,
    this.netProfit,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) =>
      _$ReportModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReportModelToJson(this);

  // Helper getters for specific report types
  bool get isPaymentReport => type.contains('PAYMENT');
  bool get isExpenseReport => type.contains('EXPENSE');
  bool get isSalaryReport => type.contains('SALARY');
  bool get isFinancialSummary => type.contains('FINANCIAL_SUMMARY');
  bool get isDailyReport => type.contains('DAILY');
  bool get isMonthlyReport => type.contains('MONTHLY');
  bool get isRangeReport => type.contains('RANGE');

  String get formattedPeriod {
    if (date != null) {
      return '${date!.day}/${date!.month}/${date!.year}';
    } else if (year != null && month != null) {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[month! - 1]} $year';
    } else if (startDate != null && endDate != null) {
      return '${startDate!.day}/${startDate!.month}/${startDate!.year} - ${endDate!.day}/${endDate!.month}/${endDate!.year}';
    }
    return 'N/A';
  }

  @override
  List<Object?> get props => [
        type,
        branchId,
        date,
        startDate,
        endDate,
        year,
        month,
        totalPayments,
        totalExpenses,
        totalSalaries,
        totalIncome,
        totalCosts,
        netProfit,
      ];
}

// Specific model for dashboard stats
@JsonSerializable()
class DashboardStatsModel extends Equatable {
  final int totalBranches;
  final int totalUsers;
  final int totalStudents;
  final int totalTeachers;
  final double monthlyRevenue;
  final double totalRevenue;

  const DashboardStatsModel({
    required this.totalBranches,
    required this.totalUsers,
    required this.totalStudents,
    required this.totalTeachers,
    required this.monthlyRevenue,
    required this.totalRevenue,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardStatsModelToJson(this);

  @override
  List<Object> get props => [
        totalBranches,
        totalUsers,
        totalStudents,
        totalTeachers,
        monthlyRevenue,
        totalRevenue,
      ];
}