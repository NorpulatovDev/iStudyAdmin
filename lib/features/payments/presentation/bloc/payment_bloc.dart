// lib/features/payments/presentation/bloc/payment_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/payment_model.dart';
import '../../data/repositories/payment_repository.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _paymentRepository;
  List<PaymentModel> _allPayments = [];

  PaymentBloc(this._paymentRepository) : super(PaymentInitial()) {
    on<PaymentLoadByBranchRequested>(_onLoadByBranch);
    on<PaymentLoadByStudentRequested>(_onLoadByStudent);
    on<PaymentLoadByDateRangeRequested>(_onLoadByDateRange);
    on<PaymentLoadByMonthRequested>(_onLoadByMonth);
    on<PaymentLoadRecentRequested>(_onLoadRecent);
    on<PaymentSearchRequested>(_onSearchRequested);
    on<PaymentCreateRequested>(_onCreateRequested);
    on<PaymentRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadByBranch(
    PaymentLoadByBranchRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());

    try {
      final payments =
          await _paymentRepository.getPaymentsByBranch(event.branchId);
      _allPayments = payments;
      emit(PaymentLoaded(payments, loadedBy: 'branch'));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onLoadByStudent(
    PaymentLoadByStudentRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());

    try {
      final payments =
          await _paymentRepository.getPaymentsByStudent(event.studentId);
      _allPayments = payments;
      emit(PaymentLoaded(payments, loadedBy: 'student'));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onLoadByDateRange(
    PaymentLoadByDateRangeRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());

    try {
      final payments = await _paymentRepository.getPaymentsByDateRange(
        branchId: event.branchId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      _allPayments = payments;
      emit(PaymentLoaded(payments, loadedBy: 'dateRange'));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onLoadByMonth(
    PaymentLoadByMonthRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());

    try {
      final payments = await _paymentRepository.getPaymentsByMonth(
        branchId: event.branchId,
        year: event.year,
        month: event.month,
      );
      _allPayments = payments;
      emit(PaymentLoaded(payments, loadedBy: 'month'));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onLoadRecent(
    PaymentLoadRecentRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());

    try {
      final payments = await _paymentRepository.getRecentPayments(
        branchId: event.branchId,
        limit: event.limit,
      );
      _allPayments = payments;
      emit(PaymentLoaded(payments, loadedBy: 'recent'));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onSearchRequested(
    PaymentSearchRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());

    try {
      final payments = await _paymentRepository.searchPaymentsByStudentName(
        branchId: event.branchId,
        studentName: event.studentName,
      );
      _allPayments = payments;
      emit(PaymentLoaded(payments, loadedBy: 'search'));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    PaymentCreateRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentOperationLoading());

    try {
      final newPayment =
          await _paymentRepository.createPayment(request: event.request);

      _allPayments.insert(0, newPayment); // Add to beginning (most recent)
      emit(const PaymentOperationSuccess('Payment created successfully'));
      emit(PaymentLoaded(_allPayments, loadedBy: 'branch'));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    PaymentRefreshRequested event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      List<PaymentModel> payments;
      String loadedBy;

      if (event.studentId != null) {
        payments =
            await _paymentRepository.getPaymentsByStudent(event.studentId!);
        loadedBy = 'student';
      } else if (event.startDate != null && event.endDate != null) {
        payments = await _paymentRepository.getPaymentsByDateRange(
          branchId: event.branchId!,
          startDate: event.startDate!,
          endDate: event.endDate!,
        );
        loadedBy = 'dateRange';
      } else if (event.year != null && event.month != null) {
        payments = await _paymentRepository.getPaymentsByMonth(
          branchId: event.branchId!,
          year: event.year!,
          month: event.month!,
        );
        loadedBy = 'month';
      } else {
        payments = await _paymentRepository.getPaymentsByBranch(event.branchId);
        loadedBy = 'branch';
      }

      _allPayments = payments;
      emit(PaymentLoaded(payments, loadedBy: loadedBy));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }
}
