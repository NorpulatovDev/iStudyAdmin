part of 'teacher_salary_bloc.dart';

sealed class TeacherSalaryState extends Equatable {
  const TeacherSalaryState();
  
  @override
  List<Object?> get props => [];
}

final class TeacherSalaryInitial extends TeacherSalaryState {}

final class TeacherSalaryLoading extends TeacherSalaryState {}

final class TeacherSalaryCalculationLoaded extends TeacherSalaryState {
  final SalaryCalculationModel salaryCalculation;

  const TeacherSalaryCalculationLoaded(this.salaryCalculation);

  @override
  List<Object> get props => [salaryCalculation];
}

final class TeacherSalaryCalculationsLoaded extends TeacherSalaryState {
  final List<SalaryCalculationModel> salaryCalculations;

  const TeacherSalaryCalculationsLoaded(this.salaryCalculations);

  @override
  List<Object> get props => [salaryCalculations];
}

final class TeacherSalaryPaymentsLoaded extends TeacherSalaryState {
  final List<TeacherSalaryPaymentModel> payments;

  const TeacherSalaryPaymentsLoaded(this.payments);

  @override
  List<Object> get props => [payments];
}

final class TeacherSalaryHistoryLoaded extends TeacherSalaryState {
  final List<TeacherSalaryHistoryModel> history;

  const TeacherSalaryHistoryLoaded(this.history);

  @override
  List<Object> get props => [history];
}

final class TeacherSalaryOperationLoading extends TeacherSalaryState {}

final class TeacherSalaryOperationSuccess extends TeacherSalaryState {
  final String message;

  const TeacherSalaryOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

final class TeacherSalaryError extends TeacherSalaryState {
  final String message;

  const TeacherSalaryError(this.message);

  @override
  List<Object> get props => [message];
}