part of 'group_bloc.dart';

sealed class GroupEvent extends Equatable {
  const GroupEvent();

  @override
  List<Object?> get props => [];
}

class GroupLoadByBranchRequested extends GroupEvent {
  final int? branchId;

  const GroupLoadByBranchRequested({this.branchId});

  @override
  List<Object?> get props => [branchId];
}

class GroupLoadByCourseRequested extends GroupEvent {
  final int courseId;

  const GroupLoadByCourseRequested(this.courseId);

  @override
  List<Object> get props => [courseId];
}

class GroupCreateRequested extends GroupEvent {
  final String name;
  final int courseId;
  final int branchId;
  final int? teacherId;
  final List<int>? studentIds;

  const GroupCreateRequested({
    required this.name,
    required this.courseId,
    required this.branchId,
    this.teacherId,
    this.studentIds,
  });

  @override
  List<Object?> get props => [name, courseId, branchId, teacherId, studentIds];
}

class GroupUpdateRequested extends GroupEvent {
  final int id;
  final String name;
  final int courseId;
  final int branchId;
  final int? teacherId;
  final List<int>? studentIds;

  const GroupUpdateRequested({
    required this.id,
    required this.name,
    required this.courseId,
    required this.branchId,
    this.teacherId,
    this.studentIds,
  });

  @override
  List<Object?> get props => [id, name, courseId, branchId, teacherId, studentIds];
}

class GroupDeleteRequested extends GroupEvent {
  final int id;

  const GroupDeleteRequested(this.id);

  @override
  List<Object> get props => [id];
}

class GroupRefreshRequested extends GroupEvent {
  final int? branchId;
  final int? courseId;

  const GroupRefreshRequested({this.branchId, this.courseId});

  @override
  List<Object?> get props => [branchId, courseId];
}