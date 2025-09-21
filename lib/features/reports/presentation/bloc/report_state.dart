// lib/features/reports/presentation/bloc/report_state.dart
part of 'report_bloc.dart';

abstract class ReportState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class PaymentReportLoaded extends ReportState {
  final PaymentReportModel report;
  
  PaymentReportLoaded({required this.report});
  
  @override
  List<Object?> get props => [report];
}

class ExpenseReportLoaded extends ReportState {
  final ExpenseReportModel report;
  
  ExpenseReportLoaded({required this.report});
  
  @override
  List<Object?> get props => [report];
}

class FinancialSummaryLoaded extends ReportState {
  final FinancialSummaryModel summary;
  
  FinancialSummaryLoaded({required this.summary});
  
  @override
  List<Object?> get props => [summary];
}

class ReportError extends ReportState {
  final String message;
  
  ReportError({required this.message});
  
  @override
  List<Object?> get props => [message];
}