part of 'teacher_salary_bloc.dart';

sealed class TeacherSalaryState extends Equatable {
  const TeacherSalaryState();
  
  @override
  List<Object> get props => [];
}

final class TeacherSalaryInitial extends TeacherSalaryState {}
