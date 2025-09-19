// lib/features/courses/presentation/bloc/course_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/course_model.dart';
import '../../data/repositories/course_repository.dart';

part 'course_event.dart';
part 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseRepository _courseRepository;
  List<CourseModel> _allCourses = [];
  int? _currentBranchId;

  CourseBloc(this._courseRepository) : super(CourseInitial()) {
    on<CourseLoadRequested>(_onLoadRequested);
    // on<CourseSearchRequested>(_onSearchRequested);
    on<CourseCreateRequested>(_onCreateRequested);
    on<CourseUpdateRequested>(_onUpdateRequested);
    on<CourseDeleteRequested>(_onDeleteRequested);
    on<CourseRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    CourseLoadRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseLoading());

    try {
      final courses = await _courseRepository.getCoursesByBranch(event.branchId);
      _allCourses = courses;
      _currentBranchId = event.branchId ?? 
          (courses.isNotEmpty ? courses.first.branchId : null);
      
      emit(CourseLoaded(courses));
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }

  // Future<void> _onSearchRequested(
  //   CourseSearchRequested event,
  //   Emitter<CourseState> emit,
  // ) async {
  //   if (event.query.trim().isEmpty) {
  //     // If search is empty, show all courses
  //     emit(CourseLoaded(_allCourses));
  //     return;
  //   }

  //   emit(CourseLoading());

  //   try {
  //     final courses = await _courseRepository.searchCourses(
  //       branchId: event.branchId,
  //       name: event.query,
  //     );
  //     emit(CourseLoaded(courses, isSearchResult: true));
  //   } catch (e) {
  //     emit(CourseError(e.toString()));
  //   }
  // }

  Future<void> _onCreateRequested(
    CourseCreateRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseOperationLoading());

    try {
      final newCourse = await _courseRepository.createCourse(
        name: event.name,
        price: event.price,
        branchId: event.branchId,
        description: event.description,
        durationMonths: event.durationMonths,
      );

      // Add to local cache
      _allCourses.add(newCourse);
      
      emit(const CourseOperationSuccess('Course created successfully'));
      
      // Refresh the list
      add(CourseRefreshRequested(branchId: event.branchId));
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    CourseUpdateRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseOperationLoading());

    try {
      final updatedCourse = await _courseRepository.updateCourse(
        id: event.id,
        name: event.name,
        price: event.price,
        branchId: event.branchId,
        description: event.description,
        durationMonths: event.durationMonths,
      );

      // Update local cache
      final index = _allCourses.indexWhere((course) => course.id == event.id);
      if (index != -1) {
        _allCourses[index] = updatedCourse;
      }

      emit(CourseOperationSuccess('Course updated successfully'));
      
      // Refresh the list
      add(CourseRefreshRequested(branchId: event.branchId));
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    CourseDeleteRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseOperationLoading());

    try {
      await _courseRepository.deleteCourse(event.id);

      // Remove from local cache
      _allCourses.removeWhere((course) => course.id == event.id);

      emit( const CourseOperationSuccess('Course deleted successfully'));
      
      // Refresh the list
      add(CourseRefreshRequested(branchId: _currentBranchId));
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    CourseRefreshRequested event,
    Emitter<CourseState> emit,
  ) async {
    try {
      final courses = await _courseRepository.getCoursesByBranch(
        event.branchId ?? _currentBranchId
      );
      _allCourses = courses;
      emit(CourseLoaded(courses));
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }
}