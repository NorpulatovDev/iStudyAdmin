part of 'teacher_bloc.dart';

sealed class TeacherState extends Equatable {
  const TeacherState();

  @override
  List<Object> get props => [];
}

final class TeacherInitial extends TeacherState {}

final class TeacherLoading extends TeacherState {}

final class TeacherLoaded extends TeacherState {
  final List<TeacherModel> teachers;
  final bool isSearchResult;
  final String? filterType;

  const TeacherLoaded(
    this.teachers, {
    this.isSearchResult = false,
    this.filterType,
  });

  @override
  List<Object> get props => [teachers, isSearchResult];
}

final class TeacherError extends TeacherState {
  final String message;

  const TeacherError(this.message);

  @override
  List<Object> get props => [message];
}

final class TeacherOperationLoading extends TeacherState {}

final class TeacherOperationSuccess extends TeacherState {
  final String message;

  const TeacherOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}