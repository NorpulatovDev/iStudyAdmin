part of 'teacher_salary_bloc.dart';

sealed class TeacherSalaryEvent extends Equatable {
  const TeacherSalaryEvent();

  @override
  List<Object?> get props => [];
}

class SalaryCalculateForTeacherRequested extends TeacherSalaryEvent {
  final int teacherId;
  final int year;
  final int month;

  const SalaryCalculateForTeacherRequested({
    required this.teacherId,
    required this.year,
    required this.month,
  });

  @override
  List<Object> get props => [teacherId, year, month];
}

class SalaryCalculateForBranchRequested extends TeacherSalaryEvent {
  final int year;
  final int month;
  final int? branchId;

  const SalaryCalculateForBranchRequested({
    required this.year,
    required this.month,
    this.branchId,
  });

  @override
  List<Object?> get props => [year, month, branchId];
}

class SalaryPaymentCreateRequested extends TeacherSalaryEvent {
  final int teacherId;
  final int year;
  final int month;
  final double amount;
  final String? description;
  final int? branchId;

  const SalaryPaymentCreateRequested({
    required this.teacherId,
    required this.year,
    required this.month,
    required this.amount,
    this.description,
    this.branchId,
  });

  @override
  List<Object?> get props => [teacherId, year, month, amount, description, branchId];
}

class SalaryPaymentsByBranchRequested extends TeacherSalaryEvent {
  final int? branchId;

  const SalaryPaymentsByBranchRequested({this.branchId});

  @override
  List<Object?> get props => [branchId];
}

class SalaryPaymentsByTeacherRequested extends TeacherSalaryEvent {
  final int teacherId;

  const SalaryPaymentsByTeacherRequested({required this.teacherId});

  @override
  List<Object> get props => [teacherId];
}

class SalaryHistoryRequested extends TeacherSalaryEvent {
  final int teacherId;

  const SalaryHistoryRequested({required this.teacherId});

  @override
  List<Object> get props => [teacherId];
}

class SalaryPaymentDeleteRequested extends TeacherSalaryEvent {
  final int paymentId;

  const SalaryPaymentDeleteRequested({required this.paymentId});

  @override
  List<Object> get props => [paymentId];
}