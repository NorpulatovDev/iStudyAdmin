import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'teacher_salary_event.dart';
part 'teacher_salary_state.dart';

class TeacherSalaryBloc extends Bloc<TeacherSalaryEvent, TeacherSalaryState> {
  TeacherSalaryBloc() : super(TeacherSalaryInitial()) {
    on<TeacherSalaryEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
