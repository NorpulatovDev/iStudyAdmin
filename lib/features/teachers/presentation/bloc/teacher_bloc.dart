// lib/features/teachers/presentation/bloc/teacher_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/teacher_model.dart';
import '../../data/repositories/teacher_repository.dart';

part 'teacher_event.dart';
part 'teacher_state.dart';

class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final TeacherRepository _teacherRepository;
  List<TeacherModel> _allTeachers = [];

  TeacherBloc(this._teacherRepository) : super(TeacherInitial()) {
    on<TeacherLoadByBranchRequested>(_onLoadByBranch);
    on<TeacherSearchRequested>(_onSearchRequested);
    on<TeacherFilterBySalaryTypeRequested>(_onFilterBySalaryType);
    on<TeacherCreateRequested>(_onCreateRequested);
    on<TeacherUpdateRequested>(_onUpdateRequested);
    on<TeacherDeleteRequested>(_onDeleteRequested);
    on<TeacherRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadByBranch(
    TeacherLoadByBranchRequested event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());

    try {
      final teachers = await _teacherRepository.getTeachersByBranch(event.branchId);
      _allTeachers = teachers;
      emit(TeacherLoaded(teachers));
    } catch (e) {
      emit(TeacherError(e.toString()));
    }
  }

  Future<void> _onSearchRequested(
    TeacherSearchRequested event,
    Emitter<TeacherState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      // If search is empty, show all teachers
      emit(TeacherLoaded(_allTeachers));
      return;
    }

    emit(TeacherLoading());

    try {
      final teachers = await _teacherRepository.searchTeachers(
        branchId: event.branchId,
        name: event.query,
      );
      emit(TeacherLoaded(teachers, isSearchResult: true));
    } catch (e) {
      emit(TeacherError(e.toString()));
    }
  }

  Future<void> _onFilterBySalaryType(
    TeacherFilterBySalaryTypeRequested event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());

    try {
      final teachers = await _teacherRepository.getTeachersBySalaryType(
        branchId: event.branchId,
        salaryType: event.salaryType,
      );
      emit(TeacherLoaded(teachers, filterType: 'salary_type'));
    } catch (e) {
      emit(TeacherError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    TeacherCreateRequested event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherOperationLoading());

    try {
      final newTeacher = await _teacherRepository.createTeacher(
        firstName: event.firstName,
        lastName: event.lastName,
        branchId: event.branchId,
        phoneNumber: event.phoneNumber,
        baseSalary: event.baseSalary,
        paymentPercentage: event.paymentPercentage,
        salaryType: event.salaryType,
      );

      _allTeachers.add(newTeacher);
      emit(TeacherOperationSuccess('Teacher created successfully'));
      emit(TeacherLoaded(_allTeachers));
    } catch (e) {
      emit(TeacherError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    TeacherUpdateRequested event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherOperationLoading());

    try {
      final updatedTeacher = await _teacherRepository.updateTeacher(
        id: event.id,
        firstName: event.firstName,
        lastName: event.lastName,
        branchId: event.branchId,
        phoneNumber: event.phoneNumber,
        baseSalary: event.baseSalary,
        paymentPercentage: event.paymentPercentage,
        salaryType: event.salaryType,
      );

      final index = _allTeachers.indexWhere((teacher) => teacher.id == event.id);
      if (index != -1) {
        _allTeachers[index] = updatedTeacher;
      }

      emit(TeacherOperationSuccess('Teacher updated successfully'));
      emit(TeacherLoaded(_allTeachers));
    } catch (e) {
      emit(TeacherError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    TeacherDeleteRequested event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherOperationLoading());

    try {
      await _teacherRepository.deleteTeacher(event.id);
      _allTeachers.removeWhere((teacher) => teacher.id == event.id);
      
      emit(TeacherOperationSuccess('Teacher deleted successfully'));
      emit(TeacherLoaded(_allTeachers));
    } catch (e) {
      emit(TeacherError(e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    TeacherRefreshRequested event,
    Emitter<TeacherState> emit,
  ) async {
    try {
      final teachers = await _teacherRepository.getTeachersByBranch(event.branchId);
      _allTeachers = teachers;
      emit(TeacherLoaded(teachers));
    } catch (e) {
      emit(TeacherError(e.toString()));
    }
  }
}