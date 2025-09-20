part of 'student_bloc.dart';

sealed class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object?> get props => [];
}

class StudentLoadByBranchRequested extends StudentEvent {
  final int? branchId;

  const StudentLoadByBranchRequested({this.branchId});

  @override
  List<Object?> get props => [branchId];
}

class StudentLoadByGroupRequested extends StudentEvent {
  final int groupId;

  const StudentLoadByGroupRequested(this.groupId);

  @override
  List<Object> get props => [groupId];
}

class StudentSearchRequested extends StudentEvent {
  final String query;
  final int branchId;

  const StudentSearchRequested({
    required this.query,
    required this.branchId,
  });

  @override
  List<Object> get props => [query, branchId];
}

class StudentCreateRequested extends StudentEvent {
  final CreateStudentRequest request;

  const StudentCreateRequested({
    required this.request
  });

  @override
  List<Object?> get props => [request];
}

class StudentUpdateRequested extends StudentEvent {
  final int id;
  final CreateStudentRequest request;

  const StudentUpdateRequested({
    required this.id,
    required this.request
  });

  @override
  List<Object?> get props => [request,id];
}

class StudentDeleteRequested extends StudentEvent {
  final int id;

  const StudentDeleteRequested(this.id);

  @override
  List<Object> get props => [id];
}

class StudentRefreshRequested extends StudentEvent {
  final int? branchId;
  final int? groupId;

  const StudentRefreshRequested({this.branchId, this.groupId});

  @override
  List<Object?> get props => [branchId, groupId];
}
