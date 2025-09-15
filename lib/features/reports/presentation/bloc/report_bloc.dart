// lib/features/reports/presentation/bloc/report_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/report_model.dart';
import '../../data/repositories/report_repository.dart';

part 'report_event.dart';
part 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository _reportRepository;
  DashboardStatsModel? _dashboardStats;
  List<ReportModel> _recentReports = [];

  ReportBloc(this._reportRepository) : super(ReportInitial()) {
    on<DashboardStatsRequested>(_onDashboardStatsRequested);
    on<PaymentReportRequested>(_onPaymentReportRequested);
    on<ExpenseReportRequested>(_onExpenseReportRequested);
    on<SalaryReportRequested>(_onSalaryReportRequested);
    on<FinancialSummaryRequested>(_onFinancialSummaryRequested);
    on<ReportRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onDashboardStatsRequested(
    DashboardStatsRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());

    try {
      final stats = await _reportRepository.getDashboardStats();
      _dashboardStats = stats;
      emit(DashboardStatsLoaded(stats));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onPaymentReportRequested(
    PaymentReportRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());

    try {
      ReportModel report;
      
      switch (event.reportType) {
        case PaymentReportType.daily:
          report = await _reportRepository.getDailyPaymentReport(
            branchId: event.branchId,
            date: event.date!,
          );
          break;
        case PaymentReportType.monthly:
          report = await _reportRepository.getMonthlyPaymentReport(
            branchId: event.branchId,
            year: event.year!,
            month: event.month!,
          );
          break;
        case PaymentReportType.range:
          report = await _reportRepository.getPaymentRangeReport(
            branchId: event.branchId,
            startDate: event.startDate!,
            endDate: event.endDate!,
          );
          break;
      }

      _addToRecentReports(report);
      emit(ReportLoaded(report));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onExpenseReportRequested(
    ExpenseReportRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());

    try {
      ReportModel report;
      
      switch (event.reportType) {
        case ExpenseReportType.daily:
          report = await _reportRepository.getDailyExpenseReport(
            branchId: event.branchId,
            date: event.date!,
          );
          break;
        case ExpenseReportType.monthly:
          report = await _reportRepository.getMonthlyExpenseReport(
            branchId: event.branchId,
            year: event.year!,
            month: event.month!,
          );
          break;
        case ExpenseReportType.range:
          report = await _reportRepository.getExpenseRangeReport(
            branchId: event.branchId,
            startDate: event.startDate!,
            endDate: event.endDate!,
          );
          break;
        case ExpenseReportType.allTime:
          report = await _reportRepository.getAllTimeExpenseReport(
            branchId: event.branchId,
          );
          break;
      }

      _addToRecentReports(report);
      emit(ReportLoaded(report));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onSalaryReportRequested(
    SalaryReportRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());

    try {
      ReportModel report;
      
      switch (event.reportType) {
        case SalaryReportType.monthly:
          report = await _reportRepository.getMonthlySalaryReport(
            branchId: event.branchId,
            year: event.year!,
            month: event.month!,
          );
          break;
        case SalaryReportType.range:
          report = await _reportRepository.getSalaryRangeReport(
            branchId: event.branchId,
            startYear: event.startYear!,
            startMonth: event.startMonth!,
            endYear: event.endYear!,
            endMonth: event.endMonth!,
          );
          break;
      }

      _addToRecentReports(report);
      emit(ReportLoaded(report));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onFinancialSummaryRequested(
    FinancialSummaryRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());

    try {
      ReportModel report;
      
      if (event.startDate != null && event.endDate != null) {
        report = await _reportRepository.getFinancialSummaryRange(
          branchId: event.branchId,
          startDate: event.startDate!,
          endDate: event.endDate!,
        );
      } else {
        report = await _reportRepository.getFinancialSummary(
          branchId: event.branchId,
          year: event.year!,
          month: event.month!,
        );
      }

      _addToRecentReports(report);
      emit(ReportLoaded(report));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    ReportRefreshRequested event,
    Emitter<ReportState> emit,
  ) async {
    try {
      if (event.refreshDashboard) {
        final stats = await _reportRepository.getDashboardStats();
        _dashboardStats = stats;
        emit(DashboardStatsLoaded(stats));
      } else if (event.refreshFinancialSummary) {
        final report = await _reportRepository.getCurrentBranchFinancialSummary(
          year: event.year,
          month: event.month,
        );
        _addToRecentReports(report);
        emit(ReportLoaded(report));
      }
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  void _addToRecentReports(ReportModel report) {
    _recentReports.insert(0, report);
    // Keep only last 10 reports
    if (_recentReports.length > 10) {
      _recentReports = _recentReports.take(10).toList();
    }
  }

  // Getter for recent reports
  List<ReportModel> get recentReports => List.unmodifiable(_recentReports);
  
  // Getter for dashboard stats
  DashboardStatsModel? get dashboardStats => _dashboardStats;
}