// lib/features/payments/presentation/bloc/payment_state.dart
part of 'payment_bloc.dart';

sealed class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => [];
}

final class PaymentInitial extends PaymentState {}

final class PaymentLoading extends PaymentState {}

final class PaymentLoaded extends PaymentState {
  final List<PaymentModel> payments;
  final String loadedBy; // 'branch', 'student', 'dateRange', 'month', 'recent', 'search'

  const PaymentLoaded(this.payments, {required this.loadedBy});

  @override
  List<Object> get props => [payments, loadedBy];
}

final class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object> get props => [message];
}

final class PaymentOperationLoading extends PaymentState {}

final class PaymentOperationSuccess extends PaymentState {
  final String message;

  const PaymentOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}