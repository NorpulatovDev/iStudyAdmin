// lib/features/courses/presentation/bloc/course_event.dart
part of 'course_bloc.dart';

sealed class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object?> get props => [];
}

class CourseLoadRequested extends CourseEvent {
  final int? branchId;

  const CourseLoadRequested({this.branchId});

  @override
  List<Object?> get props => [branchId];
}

// class CourseSearchRequested extends CourseEvent {
//   final String query;
//   final int branchId;

//   const CourseSearchRequested({
//     required this.query,
//     required this.branchId,
//   });

//   @override
//   List<Object> get props => [query, branchId];
// }

class CourseCreateRequested extends CourseEvent {
  final String name;
  final double price;
  final int branchId;
  final String? description;
  final int? durationMonths;

  const CourseCreateRequested({
    required this.name,
    required this.price,
    required this.branchId,
    this.description,
    this.durationMonths,
  });

  @override
  List<Object?> get props => [name, price, branchId, description, durationMonths];
}

class CourseUpdateRequested extends CourseEvent {
  final int id;
  final String name;
  final double price;
  final int branchId;
  final String? description;
  final int? durationMonths;

  const CourseUpdateRequested({
    required this.id,
    required this.name,
    required this.price,
    required this.branchId,
    this.description,
    this.durationMonths,
  });

  @override
  List<Object?> get props => [id, name, price, branchId, description, durationMonths];
}

class CourseDeleteRequested extends CourseEvent {
  final int id;

  const CourseDeleteRequested(this.id);

  @override
  List<Object> get props => [id];
}

class CourseRefreshRequested extends CourseEvent {
  final int? branchId;

  const CourseRefreshRequested({this.branchId});

  @override
  List<Object?> get props => [branchId];
}