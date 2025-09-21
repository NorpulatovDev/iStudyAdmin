// lib/features/payments/presentation/bloc/payment_event.dart
part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPayments extends PaymentEvent {}

class LoadUnpaidStudents extends PaymentEvent {
  final int? year;
  final int? month;
  
  LoadUnpaidStudents({this.year, this.month});
  
  @override
  List<Object?> get props => [year, month];
}

class LoadPaymentsByDateRange extends PaymentEvent {
  final DateTime startDate;
  final DateTime endDate;
  
  LoadPaymentsByDateRange({required this.startDate, required this.endDate});
  
  @override
  List<Object?> get props => [startDate, endDate];
}

class LoadPaymentsByMonth extends PaymentEvent {
  final int year;
  final int month;
  
  LoadPaymentsByMonth({required this.year, required this.month});
  
  @override
  List<Object?> get props => [year, month];
}

class LoadRecentPayments extends PaymentEvent {
  final int limit;
  
  LoadRecentPayments({this.limit = 20});
  
  @override
  List<Object?> get props => [limit];
}

class LoadPaymentsByStudent extends PaymentEvent {
  final int studentId;
  
  LoadPaymentsByStudent({required this.studentId});
  
  @override
  List<Object?> get props => [studentId];
}

class LoadPaymentById extends PaymentEvent {
  final int id;
  
  LoadPaymentById({required this.id});
  
  @override
  List<Object?> get props => [id];
}

class CreatePayment extends PaymentEvent {
  final int studentId;
  final int groupId;
  final double amount;
  final String? description;
  final int paymentYear;
  final int paymentMonth;
  
  CreatePayment({
    required this.studentId,
    required this.groupId,
    required this.amount,
    this.description,
    required this.paymentYear,
    required this.paymentMonth,
  });
  
  @override
  List<Object?> get props => [
        studentId,
        groupId,
        amount,
        description,
        paymentYear,
        paymentMonth,
      ];
}

class UpdatePaymentAmount extends PaymentEvent {
  final int id;
  final double amount;
  
  UpdatePaymentAmount({required this.id, required this.amount});
  
  @override
  List<Object?> get props => [id, amount];
}

class SearchPaymentsByStudentName extends PaymentEvent {
  final String studentName;
  
  SearchPaymentsByStudentName({required this.studentName});
  
  @override
  List<Object?> get props => [studentName];
}

class DeletePayment extends PaymentEvent {
  final int id;
  
  DeletePayment({required this.id});
  
  @override
  List<Object?> get props => [id];
}