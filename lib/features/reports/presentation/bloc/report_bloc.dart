// lib/features/reports/presentation/bloc/report_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/report_model.dart';
import '../../data/repositories/report_repository.dart';

part 'report_event.dart';
part 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository _repository;

  ReportBloc(this._repository) : super(ReportInitial()) {
    on<LoadDailyPaymentReport>(_onLoadDailyPaymentReport);
    on<LoadMonthlyPaymentReport>(_onLoadMonthlyPaymentReport);
    on<LoadPaymentRangeReport>(_onLoadPaymentRangeReport);
    on<LoadDailyExpenseReport>(_onLoadDailyExpenseReport);
    on<LoadMonthlyExpenseReport>(_onLoadMonthlyExpenseReport);
    on<LoadExpenseRangeReport>(_onLoadExpenseRangeReport);
    on<LoadFinancialSummary>(_onLoadFinancialSummary);
    on<LoadFinancialSummaryRange>(_onLoadFinancialSummaryRange);
  }

  // Payment Report Handlers
  Future<void> _onLoadDailyPaymentReport(
      LoadDailyPaymentReport event, Emitter<ReportState> emit) async {
    try {
      emit(ReportLoading());
      final report = await _repository.getDailyPaymentReport(date: event.date);
      emit(PaymentReportLoaded(report: report));
    } catch (e) {
      emit(ReportError(message: e.toString()));
    }
  }

  Future<void> _onLoadMonthlyPaymentReport(
      LoadMonthlyPaymentReport event, Emitter<ReportState> emit) async {
    try {
      emit(ReportLoading());
      final report = await _repository.getMonthlyPaymentReport(
        year: event.year,
        month: event.month,
      );
      emit(PaymentReportLoaded(report: report));
    } catch (e) {
      emit(ReportError(message: e.toString()));
    }
  }

  Future<void> _onLoadPaymentRangeReport(
      LoadPaymentRangeReport event, Emitter<ReportState> emit) async {
    try {
      emit(ReportLoading());
      final report = await _repository.getPaymentRangeReport(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(PaymentReportLoaded(report: report));
    } catch (e) {
      emit(ReportError(message: e.toString()));
    }
  }

  // Expense Report Handlers
  Future<void> _onLoadDailyExpenseReport(
      LoadDailyExpenseReport event, Emitter<ReportState> emit) async {
    try {
      emit(ReportLoading());
      final report = await _repository.getDailyExpenseReport(date: event.date);
      emit(ExpenseReportLoaded(report: report));
    } catch (e) {
      emit(ReportError(message: e.toString()));
    }
  }

  Future<void> _onLoadMonthlyExpenseReport(
      LoadMonthlyExpenseReport event, Emitter<ReportState> emit) async {
    try {
      emit(ReportLoading());
      final report = await _repository.getMonthlyExpenseReport(
        year: event.year,
        month: event.month,
      );
      emit(ExpenseReportLoaded(report: report));
    } catch (e) {
      emit(ReportError(message: e.toString()));
    }
  }

  Future<void> _onLoadExpenseRangeReport(
      LoadExpenseRangeReport event, Emitter<ReportState> emit) async {
    try {
      emit(ReportLoading());
      final report = await _repository.getExpenseRangeReport(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(ExpenseReportLoaded(report: report));
    } catch (e) {
      emit(ReportError(message: e.toString()));
    }
  }

  // Financial Summary Handlers
  Future<void> _onLoadFinancialSummary(
      LoadFinancialSummary event, Emitter<ReportState> emit) async {
    try {
      emit(ReportLoading());
      final summary = await _repository.getFinancialSummary(
        year: event.year,
        month: event.month,
      );
      emit(FinancialSummaryLoaded(summary: summary));
    } catch (e) {
      emit(ReportError(message: e.toString()));
    }
  }

  Future<void> _onLoadFinancialSummaryRange(
      LoadFinancialSummaryRange event, Emitter<ReportState> emit) async {
    try {
      emit(ReportLoading());
      final summary = await _repository.getFinancialSummaryRange(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(FinancialSummaryLoaded(summary: summary));
    } catch (e) {
      emit(ReportError(message: e.toString()));
    }
  }
}
