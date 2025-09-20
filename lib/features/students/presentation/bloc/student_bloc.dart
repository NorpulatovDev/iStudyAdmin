// lib/features/students/presentation/bloc/student_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/student_model.dart';
import '../../data/repositories/student_repository.dart';

part 'student_event.dart';
part 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentRepository _studentRepository;
  List<StudentModel> _allStudents = [];

  StudentBloc(this._studentRepository) : super(StudentInitial()) {
    on<StudentLoadByBranchRequested>(_onLoadByBranch);
    on<StudentLoadByGroupRequested>(_onLoadByGroup);
    on<StudentSearchRequested>(_onSearchRequested);
    on<StudentCreateRequested>(_onCreateRequested);
    on<StudentUpdateRequested>(_onUpdateRequested);
    on<StudentDeleteRequested>(_onDeleteRequested);
    on<StudentRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadByBranch(
    StudentLoadByBranchRequested event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());

    try {
      final students =
          await _studentRepository.getStudentsByBranch(event.branchId);
      _allStudents = students;
      emit(StudentLoaded(students, loadedBy: 'branch'));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onLoadByGroup(
    StudentLoadByGroupRequested event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());

    try {
      final students =
          await _studentRepository.getStudentsByGroup(event.groupId);
      _allStudents = students;
      emit(StudentLoaded(students, loadedBy: 'group'));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onSearchRequested(
    StudentSearchRequested event,
    Emitter<StudentState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      // If search is empty, show all students
      emit(StudentLoaded(_allStudents));
      return;
    }

    emit(StudentLoading());

    try {
      final students = await _studentRepository.searchStudents(
        branchId: event.branchId,
        firstName: event.query,
        lastName: event.query,
        phoneNumber: event.query,
      );
      emit(StudentLoaded(students, isSearchResult: true));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    StudentCreateRequested event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentOperationLoading());

    try {
      final newStudent =
          await _studentRepository.createStudent(request: event.request);

      _allStudents.add(newStudent);
      emit(const StudentOperationSuccess('Student created successfully'));
      emit(StudentLoaded(_allStudents, loadedBy: 'branch'));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    StudentUpdateRequested event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentOperationLoading());

    try {
      final updatedStudent = await _studentRepository.updateStudent(
        id: event.id,
        request: event.request,
      );

      final index =
          _allStudents.indexWhere((student) => student.id == event.id);
      if (index != -1) {
        _allStudents[index] = updatedStudent;
      }

      emit(const StudentOperationSuccess('Student updated successfully'));
      emit(StudentLoaded(_allStudents, loadedBy: 'branch'));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    StudentDeleteRequested event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentOperationLoading());

    try {
      await _studentRepository.deleteStudent(event.id);
      _allStudents.removeWhere((student) => student.id == event.id);

      emit(StudentOperationSuccess('Student deleted successfully'));
      emit(StudentLoaded(_allStudents, loadedBy: 'branch'));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    StudentRefreshRequested event,
    Emitter<StudentState> emit,
  ) async {
    try {
      List<StudentModel> students;
      String loadedBy;

      if (event.groupId != null) {
        students = await _studentRepository.getStudentsByGroup(event.groupId!);
        loadedBy = 'group';
      } else {
        students = await _studentRepository.getStudentsByBranch(event.branchId);
        loadedBy = 'branch';
      }

      _allStudents = students;
      emit(StudentLoaded(students, loadedBy: loadedBy));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }
}
