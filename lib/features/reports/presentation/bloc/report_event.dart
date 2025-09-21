// lib/features/reports/presentation/bloc/report_event.dart
part of 'report_bloc.dart';

abstract class ReportEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Payment Report Events
class LoadDailyPaymentReport extends ReportEvent {
  final DateTime date;
  
  LoadDailyPaymentReport({required this.date});
  
  @override
  List<Object?> get props => [date];
}

class LoadMonthlyPaymentReport extends ReportEvent {
  final int year;
  final int month;
  
  LoadMonthlyPaymentReport({required this.year, required this.month});
  
  @override
  List<Object?> get props => [year, month];
}

class LoadPaymentRangeReport extends ReportEvent {
  final DateTime startDate;
  final DateTime endDate;
  
  LoadPaymentRangeReport({required this.startDate, required this.endDate});
  
  @override
  List<Object?> get props => [startDate, endDate];
}

// Expense Report Events
class LoadDailyExpenseReport extends ReportEvent {
  final DateTime date;
  
  LoadDailyExpenseReport({required this.date});
  
  @override
  List<Object?> get props => [date];
}

class LoadMonthlyExpenseReport extends ReportEvent {
  final int year;
  final int month;
  
  LoadMonthlyExpenseReport({required this.year, required this.month});
  
  @override
  List<Object?> get props => [year, month];
}

class LoadExpenseRangeReport extends ReportEvent {
  final DateTime startDate;
  final DateTime endDate;
  
  LoadExpenseRangeReport({required this.startDate, required this.endDate});
  
  @override
  List<Object?> get props => [startDate, endDate];
}

// Financial Summary Events
class LoadFinancialSummary extends ReportEvent {
  final int year;
  final int month;
  
  LoadFinancialSummary({required this.year, required this.month});
  
  @override
  List<Object?> get props => [year, month];
}

class LoadFinancialSummaryRange extends ReportEvent {
  final DateTime startDate;
  final DateTime endDate;
  
  LoadFinancialSummaryRange({required this.startDate, required this.endDate});
  
  @override
  List<Object?> get props => [startDate, endDate];
}