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
  final String firstName;
  final String lastName;
  final int branchId;
  final String? phoneNumber;

  const StudentCreateRequested({
    required this.firstName,
    required this.lastName,
    required this.branchId,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [firstName, lastName, branchId, phoneNumber];
}

class StudentUpdateRequested extends StudentEvent {
  final int id;
  final String firstName;
  final String lastName;
  final int branchId;
  final String? phoneNumber;

  const StudentUpdateRequested({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.branchId,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [id, firstName, lastName, branchId, phoneNumber];
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
