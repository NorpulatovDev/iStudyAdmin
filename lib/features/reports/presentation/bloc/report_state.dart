// lib/features/reports/presentation/bloc/report_state.dart
part of 'report_bloc.dart';

sealed class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object> get props => [];
}

final class ReportInitial extends ReportState {}

final class ReportLoading extends ReportState {}

final class DashboardStatsLoaded extends ReportState {
  final DashboardStatsModel stats;

  const DashboardStatsLoaded(this.stats);

  @override
  List<Object> get props => [stats];
}

final class ReportLoaded extends ReportState {
  final ReportModel report;

  const ReportLoaded(this.report);

  @override
  List<Object> get props => [report];
}

final class ReportError extends ReportState {
  final String message;

  const ReportError(this.message);

  @override
  List<Object> get props => [message];
}

final class ReportsHistoryLoaded extends ReportState {
  final List<ReportModel> reports;

  const ReportsHistoryLoaded(this.reports);

  @override
  List<Object> get props => [reports];
}