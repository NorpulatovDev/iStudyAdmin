// lib/features/courses/presentation/bloc/course_state.dart
part of 'course_bloc.dart';

sealed class CourseState extends Equatable {
  const CourseState();

  @override
  List<Object> get props => [];
}

final class CourseInitial extends CourseState {}

final class CourseLoading extends CourseState {}

final class CourseLoaded extends CourseState {
  final List<CourseModel> courses;
  final bool isSearchResult;

  const CourseLoaded(this.courses, {this.isSearchResult = false});

  @override
  List<Object> get props => [courses, isSearchResult];
}

final class CourseError extends CourseState {
  final String message;

  const CourseError(this.message);

  @override
  List<Object> get props => [message];
}

final class CourseOperationLoading extends CourseState {}

final class CourseOperationSuccess extends CourseState {
  final String message;

  const CourseOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}