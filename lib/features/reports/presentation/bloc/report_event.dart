// lib/features/reports/presentation/bloc/report_event.dart
part of 'report_bloc.dart';

sealed class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class DashboardStatsRequested extends ReportEvent {
  const DashboardStatsRequested();
}

class PaymentReportRequested extends ReportEvent {
  final int branchId;
  final PaymentReportType reportType;
  final DateTime? date;
  final int? year;
  final int? month;
  final DateTime? startDate;
  final DateTime? endDate;

  const PaymentReportRequested({
    required this.branchId,
    required this.reportType,
    this.date,
    this.year,
    this.month,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
        branchId,
        reportType,
        date,
        year,
        month,
        startDate,
        endDate,
      ];
}

class ExpenseReportRequested extends ReportEvent {
  final int branchId;
  final ExpenseReportType reportType;
  final DateTime? date;
  final int? year;
  final int? month;
  final DateTime? startDate;
  final DateTime? endDate;

  const ExpenseReportRequested({
    required this.branchId,
    required this.reportType,
    this.date,
    this.year,
    this.month,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
        branchId,
        reportType,
        date,
        year,
        month,
        startDate,
        endDate,
      ];
}

class SalaryReportRequested extends ReportEvent {
  final int branchId;
  final SalaryReportType reportType;
  final int? year;
  final int? month;
  final int? startYear;
  final int? startMonth;
  final int? endYear;
  final int? endMonth;

  const SalaryReportRequested({
    required this.branchId,
    required this.reportType,
    this.year,
    this.month,
    this.startYear,
    this.startMonth,
    this.endYear,
    this.endMonth,
  });

  @override
  List<Object?> get props => [
        branchId,
        reportType,
        year,
        month,
        startYear,
        startMonth,
        endYear,
        endMonth,
      ];
}

class FinancialSummaryRequested extends ReportEvent {
  final int branchId;
  final int? year;
  final int? month;
  final DateTime? startDate;
  final DateTime? endDate;

  const FinancialSummaryRequested({
    required this.branchId,
    this.year,
    this.month,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
        branchId,
        year,
        month,
        startDate,
        endDate,
      ];
}

class ReportRefreshRequested extends ReportEvent {
  final bool refreshDashboard;
  final bool refreshFinancialSummary;
  final int? year;
  final int? month;

  const ReportRefreshRequested({
    this.refreshDashboard = false,
    this.refreshFinancialSummary = false,
    this.year,
    this.month,
  });

  @override
  List<Object?> get props => [
        refreshDashboard,
        refreshFinancialSummary,
        year,
        month,
      ];
}

// Enums for report types
enum PaymentReportType {
  daily,
  monthly,
  range,
}

enum ExpenseReportType {
  daily,
  monthly,
  range,
  allTime,
}

enum SalaryReportType {
  monthly,
  range,
}