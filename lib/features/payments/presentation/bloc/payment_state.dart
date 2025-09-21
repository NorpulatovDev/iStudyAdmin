// lib/features/payments/presentation/bloc/payment_state.dart
part of 'payment_bloc.dart';

abstract class PaymentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentsLoaded extends PaymentState {
  final List<PaymentModel> payments;
  
  PaymentsLoaded({required this.payments});
  
  @override
  List<Object?> get props => [payments];
}

class UnpaidStudentsLoaded extends PaymentState {
  final List<UnpaidStudentModel> unpaidStudents;
  
  UnpaidStudentsLoaded({required this.unpaidStudents});
  
  @override
  List<Object?> get props => [unpaidStudents];
}

class PaymentDetailsLoaded extends PaymentState {
  final PaymentModel payment;
  
  PaymentDetailsLoaded({required this.payment});
  
  @override
  List<Object?> get props => [payment];
}

class PaymentOperationSuccess extends PaymentState {
  final String message;
  
  PaymentOperationSuccess({required this.message});
  
  @override
  List<Object?> get props => [message];
}

class PaymentError extends PaymentState {
  final String message;
  
  PaymentError({required this.message});
  
  @override
  List<Object?> get props => [message];
}