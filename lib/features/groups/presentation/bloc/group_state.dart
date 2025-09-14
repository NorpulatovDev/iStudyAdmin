part of 'group_bloc.dart';

sealed class GroupState extends Equatable {
  const GroupState();

  @override
  List<Object> get props => [];
}

final class GroupInitial extends GroupState {}

final class GroupLoading extends GroupState {}

final class GroupLoaded extends GroupState {
  final List<GroupModel> groups;
  final String loadedBy; // 'branch' or 'course'

  const GroupLoaded(this.groups, {required this.loadedBy});

  @override
  List<Object> get props => [groups, loadedBy];
}

final class GroupError extends GroupState {
  final String message;

  const GroupError(this.message);

  @override
  List<Object> get props => [message];
}

final class GroupOperationLoading extends GroupState {}

final class GroupOperationSuccess extends GroupState {
  final String message;

  const GroupOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}