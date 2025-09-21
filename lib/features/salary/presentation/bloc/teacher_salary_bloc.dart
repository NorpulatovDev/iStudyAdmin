// lib/features/salary/presentation/bloc/teacher_salary_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/salary_calculation_model.dart';
import '../../data/repositories/teacher_salary_repository.dart';

part 'teacher_salary_event.dart';
part 'teacher_salary_state.dart';

class TeacherSalaryBloc extends Bloc<TeacherSalaryEvent, TeacherSalaryState> {
  final TeacherSalaryRepository _salaryRepository;

  TeacherSalaryBloc(this._salaryRepository) : super(TeacherSalaryInitial()) {
    on<SalaryCalculateForTeacherRequested>(_onCalculateForTeacher);
    on<SalaryCalculateForBranchRequested>(_onCalculateForBranch);
    on<SalaryPaymentCreateRequested>(_onCreatePayment);
    on<SalaryPaymentsByBranchRequested>(_onGetPaymentsByBranch);
    on<SalaryPaymentsByTeacherRequested>(_onGetPaymentsByTeacher);
    on<SalaryHistoryRequested>(_onGetSalaryHistory);
    on<SalaryPaymentDeleteRequested>(_onDeletePayment);
  }

  Future<void> _onCalculateForTeacher(
    SalaryCalculateForTeacherRequested event,
    Emitter<TeacherSalaryState> emit,
  ) async {
    emit(TeacherSalaryLoading());

    try {
      final salaryCalculation = await _salaryRepository.calculateTeacherSalary(
        teacherId: event.teacherId,
        year: event.year,
        month: event.month,
      );

      emit(TeacherSalaryCalculationLoaded(salaryCalculation));
    } catch (e) {
      emit(TeacherSalaryError(e.toString()));
    }
  }

  Future<void> _onCalculateForBranch(
    SalaryCalculateForBranchRequested event,
    Emitter<TeacherSalaryState> emit,
  ) async {
    emit(TeacherSalaryLoading());

    try {
      final salaryCalculations =
          await _salaryRepository.calculateSalariesForBranch(
        year: event.year,
        month: event.month,
        branchId: event.branchId,
      );

      emit(TeacherSalaryCalculationsLoaded(salaryCalculations));
    } catch (e) {
      emit(TeacherSalaryError(e.toString()));
    }
  }

  Future<void> _onCreatePayment(
    SalaryPaymentCreateRequested event,
    Emitter<TeacherSalaryState> emit,
  ) async {
    emit(TeacherSalaryOperationLoading());

    try {
      await _salaryRepository.createSalaryPayment(
        teacherId: event.teacherId,
        year: event.year,
        month: event.month,
        amount: event.amount,
        description: event.description,
        branchId: event.branchId,
      );

      emit(const TeacherSalaryOperationSuccess('Payment created successfully'));
    } catch (e) {
      emit(TeacherSalaryError(e.toString()));
    }
  }

  Future<void> _onGetPaymentsByBranch(
    SalaryPaymentsByBranchRequested event,
    Emitter<TeacherSalaryState> emit,
  ) async {
    emit(TeacherSalaryLoading());

    try {
      final payments =
          await _salaryRepository.getSalaryPaymentsByBranch(event.branchId);
      emit(TeacherSalaryPaymentsLoaded(payments));
    } catch (e) {
      emit(TeacherSalaryError(e.toString()));
    }
  }

  Future<void> _onGetPaymentsByTeacher(
    SalaryPaymentsByTeacherRequested event,
    Emitter<TeacherSalaryState> emit,
  ) async {
    emit(TeacherSalaryLoading());

    try {
      final payments =
          await _salaryRepository.getSalaryPaymentsByTeacher(event.teacherId);
      emit(TeacherSalaryPaymentsLoaded(payments));
    } catch (e) {
      emit(TeacherSalaryError(e.toString()));
    }
  }

  Future<void> _onGetSalaryHistory(
    SalaryHistoryRequested event,
    Emitter<TeacherSalaryState> emit,
  ) async {
    emit(TeacherSalaryLoading());

    try {
      final history =
          await _salaryRepository.getTeacherSalaryHistory(event.teacherId);
      emit(TeacherSalaryHistoryLoaded(history));
    } catch (e) {
      emit(TeacherSalaryError(e.toString()));
    }
  }

  Future<void> _onDeletePayment(
    SalaryPaymentDeleteRequested event,
    Emitter<TeacherSalaryState> emit,
  ) async {
    emit(TeacherSalaryOperationLoading());

    try {
      await _salaryRepository.deleteSalaryPayment(event.paymentId);
      emit(const TeacherSalaryOperationSuccess('Payment deleted successfully'));
    } catch (e) {
      emit(TeacherSalaryError(e.toString()));
    }
  }
}
