// lib/features/payments/presentation/bloc/payment_event.dart
part of 'payment_bloc.dart';

sealed class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class PaymentLoadByBranchRequested extends PaymentEvent {
  final int? branchId;

  const PaymentLoadByBranchRequested({this.branchId});

  @override
  List<Object?> get props => [branchId];
}

class PaymentLoadByStudentRequested extends PaymentEvent {
  final int studentId;

  const PaymentLoadByStudentRequested(this.studentId);

  @override
  List<Object> get props => [studentId];
}

class PaymentLoadByDateRangeRequested extends PaymentEvent {
  final int branchId;
  final DateTime startDate;
  final DateTime endDate;

  const PaymentLoadByDateRangeRequested({
    required this.branchId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [branchId, startDate, endDate];
}

class PaymentLoadByMonthRequested extends PaymentEvent {
  final int branchId;
  final int year;
  final int month;

  const PaymentLoadByMonthRequested({
    required this.branchId,
    required this.year,
    required this.month,
  });

  @override
  List<Object> get props => [branchId, year, month];
}

class PaymentLoadRecentRequested extends PaymentEvent {
  final int branchId;
  final int limit;

  const PaymentLoadRecentRequested({
    required this.branchId,
    this.limit = 20,
  });

  @override
  List<Object> get props => [branchId, limit];
}

class PaymentSearchRequested extends PaymentEvent {
  final int branchId;
  final String studentName;

  const PaymentSearchRequested({
    required this.branchId,
    required this.studentName,
  });

  @override
  List<Object> get props => [branchId, studentName];
}

class PaymentCreateRequested extends PaymentEvent {
  final CreatePaymentRequest request;

  const PaymentCreateRequested({
    required this.request
  });

  @override
  List<Object?> get props => [request];
}

class PaymentRefreshRequested extends PaymentEvent {
  final int? branchId;
  final int? studentId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? year;
  final int? month;

  const PaymentRefreshRequested({
    this.branchId,
    this.studentId,
    this.startDate,
    this.endDate,
    this.year,
    this.month,
  });

  @override
  List<Object?> get props => [branchId, studentId, startDate, endDate, year, month];
}