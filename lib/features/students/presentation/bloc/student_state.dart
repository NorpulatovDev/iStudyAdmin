part of 'student_bloc.dart';

sealed class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object> get props => [];
}

final class StudentInitial extends StudentState {}

final class StudentLoading extends StudentState {}

final class StudentLoaded extends StudentState {
  final List<StudentModel> students;
  final String loadedBy; // 'branch', 'group'
  final bool isSearchResult;

  const StudentLoaded(
    this.students, {
    this.loadedBy = 'branch',
    this.isSearchResult = false,
  });

  @override
  List<Object> get props => [students, loadedBy, isSearchResult];
}

final class StudentError extends StudentState {
  final String message;

  const StudentError(this.message);

  @override
  List<Object> get props => [message];
}

final class StudentOperationLoading extends StudentState {}

final class StudentOperationSuccess extends StudentState {
  final String message;

  const StudentOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}