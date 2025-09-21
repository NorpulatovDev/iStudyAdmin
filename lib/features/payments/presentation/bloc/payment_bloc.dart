// lib/features/payments/presentation/bloc/payment_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/payment_model.dart';
import '../../data/repositories/payment_repository.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _repository;
  
  PaymentBloc(this._repository)
      : 
        super(PaymentInitial()) {
    on<LoadPayments>(_onLoadPayments);
    on<LoadUnpaidStudents>(_onLoadUnpaidStudents);
    on<LoadPaymentsByDateRange>(_onLoadPaymentsByDateRange);
    on<LoadPaymentsByMonth>(_onLoadPaymentsByMonth);
    on<LoadRecentPayments>(_onLoadRecentPayments);
    on<LoadPaymentsByStudent>(_onLoadPaymentsByStudent);
    on<LoadPaymentById>(_onLoadPaymentById);
    on<CreatePayment>(_onCreatePayment);
    on<UpdatePaymentAmount>(_onUpdatePaymentAmount);
    on<SearchPaymentsByStudentName>(_onSearchPaymentsByStudentName);
    on<DeletePayment>(_onDeletePayment);
  }
  
  Future<void> _onLoadPayments(LoadPayments event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentLoading());
      final payments = await _repository.getPaymentsByBranch();
      emit(PaymentsLoaded(payments: payments));
    } catch (e) {
      emit(PaymentError(message: e.toString()));
    }
  }
  
  Future<void> _onLoadUnpaidStudents(LoadUnpaidStudents event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentLoading());
      final unpaidStudents = await _repository.getUnpaidStudents(
        year: event.year,
        month: event.month,
      );
      emit(UnpaidStudentsLoaded(unpaidStudents: unpaidStudents));
    } catch (e) {
      emit(PaymentError(message: e.toString()));
    }
  }
  
  Future<void> _onLoadPaymentsByDateRange(LoadPaymentsByDateRange event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentLoading());
      final payments = await _repository.getPaymentsByDateRange(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(PaymentsLoaded(payments: payments));
    } catch (e) {
      emit(PaymentError(message: e.toString()));
    }
  }
  
  Future<void> _onLoadPaymentsByMonth(LoadPaymentsByMonth event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentLoading());
      final payments = await _repository.getPaymentsByMonth(
        year: event.year,
        month: event.month,
      );
      emit(PaymentsLoaded(payments: payments));
    } catch (e) {
      emit(PaymentError(message: e.toString()));
    }
  }
  
  Future<void> _onLoadRecentPayments(LoadRecentPayments event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentLoading());
      final payments = await _repository.getRecentPayments(limit: event.limit);
      emit(PaymentsLoaded(payments: payments));
    } catch (e) {
      emit(PaymentError(message: e.toString()));
    }
  }
  
  Future<void> _onLoadPaymentsByStudent(LoadPaymentsByStudent event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentLoading());
      final payments = await _repository.getPaymentsByStudent(event.studentId);
      emit(PaymentsLoaded(payments: payments));
    } catch (e) {
      emit(PaymentError(message: e.toString()));
    }
  }
  
  Future<void> _onLoadPaymentById(LoadPaymentById event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentLoading());
      final payment = await _repository.getPaymentById(event.id);
      emit(PaymentDetailsLoaded(payment: payment));
    } catch (e) {
      emit(PaymentError(message: e.toString()));
    }
  }
  
  Future<void> _onCreatePayment(CreatePayment event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentLoading());
      
      final request = CreatePaymentRequest(
        studentId: event.studentId,
        groupId: event.groupId,
        amount: event.amount,
        description: event.description,
        branchId: 0, // This will be handled in repository
        paymentYear: event.paymentYear,
        paymentMonth: event.paymentMonth,
      );
      
      await _repository.createPayment(request);
      emit(PaymentOperationSuccess(message: 'Payment created successfully'));
    } catch (e) {
      emit(PaymentError(message: e.toString()));
    }
  }
  
  Future<void> _onUpdatePaymentAmount(UpdatePaymentAmount event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentLoading());
      await _repository.updatePaymentAmount(
        id: event.id,
        amount: event.amount,
      );
      emit(PaymentOperationSuccess(message: 'Payment amount updated successfully'));
    } catch (e) {
      emit(PaymentError(message: e.toString()));
    }
  }
  
  Future<void> _onSearchPaymentsByStudentName(SearchPaymentsByStudentName event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentLoading());
      final payments = await _repository.searchPaymentsByStudentName(
        studentName: event.studentName,
      );
      emit(PaymentsLoaded(payments: payments));
    } catch (e) {
      emit(PaymentError(message: e.toString()));
    }
  }
  
  Future<void> _onDeletePayment(DeletePayment event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentLoading());
      await _repository.deletePayment(event.id);
      emit(PaymentOperationSuccess(message: 'Payment deleted successfully'));
    } catch (e) {
      emit(PaymentError(message: e.toString()));
    }
  }
}