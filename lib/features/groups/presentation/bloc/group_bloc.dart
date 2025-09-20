// lib/features/groups/presentation/bloc/group_bloc.dart
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../data/models/group_model.dart';
import '../../data/repositories/group_repository.dart';

part 'group_event.dart';
part 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GroupRepository _groupRepository;
  List<GroupModel> _allGroups = [];

  GroupBloc(this._groupRepository) : super(GroupInitial()) {
    on<GroupLoadByBranchRequested>(_onLoadByBranch);
    on<GroupLoadByCourseRequested>(_onLoadByCourse);
    on<GroupLoadByTeacherRequested>(_onLoadByTeacher);
    on<GroupLoadByIdRequested>(_onLoadById);
    on<GroupCreateRequested>(_onCreateRequested);
    on<GroupUpdateRequested>(_onUpdateRequested);
    on<GroupDeleteRequested>(_onDeleteRequested);
    on<GroupRefreshRequested>(_onRefreshRequested);
    on<GroupRemoveStudentRequested>(_onRemoveStudentRequested);
  }

  Future<void> _onLoadByBranch(
    GroupLoadByBranchRequested event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());

    try {
      final groups = await _groupRepository.getGroupsByBranch(event.branchId);
      _allGroups = groups;
      emit(GroupLoaded(groups, loadedBy: 'branch'));
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }

  Future<void> _onLoadByCourse(
    GroupLoadByCourseRequested event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());

    try {
      final groups = await _groupRepository.getGroupsByCourse(event.courseId);
      _allGroups = groups;
      emit(GroupLoaded(groups, loadedBy: 'course'));
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }

  Future<void> _onLoadByTeacher(
    GroupLoadByTeacherRequested event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());

    try {
      final groups = await _groupRepository.getGroupsByTeacher(event.teacherId);
      _allGroups = groups;
      emit(GroupLoaded(groups, loadedBy: 'teacher'));
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }

  Future<void> _onLoadById(
    GroupLoadByIdRequested event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());

    try {
      final group = await _groupRepository.getGroupById(
        event.groupId, 
        event.year, 
        event.month
      );
      emit(GroupDetailLoaded(group));
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    GroupCreateRequested event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupOperationLoading());

    try {
      final newGroup = await _groupRepository.createGroup(
        name: event.name,
        courseId: event.courseId,
        branchId: event.branchId,
        teacherId: event.teacherId,
        studentIds: event.studentIds,
        startTime: event.startTime,
        endTime: event.endTime,
        daysOfWeek: event.daysOfWeek,
      );

      _allGroups.add(newGroup);
      emit(const GroupOperationSuccess('Group created successfully'));
      emit(GroupLoaded(_allGroups, loadedBy: 'branch'));
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    GroupUpdateRequested event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupOperationLoading());

    try {
      final updatedGroup = await _groupRepository.updateGroup(
        id: event.id,
        name: event.name,
        courseId: event.courseId,
        branchId: event.branchId,
        teacherId: event.teacherId,
        studentIds: event.studentIds,
        startTime: event.startTime,
        endTime: event.endTime,
        daysOfWeek: event.daysOfWeek,
      );

      final index = _allGroups.indexWhere((group) => group.id == event.id);
      if (index != -1) {
        _allGroups[index] = updatedGroup;
      }

      emit(const GroupOperationSuccess('Group updated successfully'));
      emit(GroupLoaded(_allGroups, loadedBy: 'branch'));
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    GroupDeleteRequested event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupOperationLoading());

    try {
      await _groupRepository.deleteGroup(event.id);
      _allGroups.removeWhere((group) => group.id == event.id);

      emit(const GroupOperationSuccess('Group deleted successfully'));
      emit(GroupLoaded(_allGroups, loadedBy: 'branch'));
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    GroupRefreshRequested event,
    Emitter<GroupState> emit,
  ) async {
    try {
      List<GroupModel> groups;
      String loadedBy;

      if (event.courseId != null) {
        groups = await _groupRepository.getGroupsByCourse(event.courseId!);
        loadedBy = 'course';
      } else if (event.teacherId != null) {
        groups = await _groupRepository.getGroupsByTeacher(event.teacherId!);
        loadedBy = 'teacher';
      } else {
        groups = await _groupRepository.getGroupsByBranch(event.branchId);
        loadedBy = 'branch';
      }

      _allGroups = groups;
      emit(GroupLoaded(groups, loadedBy: loadedBy));
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }

  Future<void> _onRemoveStudentRequested(
    GroupRemoveStudentRequested event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupOperationLoading());

    try {
      await _groupRepository.removeStudentFromGroup(
        event.groupId,
        event.studentId,
      );

      emit(const GroupOperationSuccess('Student removed from group successfully'));
      
      // Refresh the group details to show updated student list
      if (state is GroupDetailLoaded) {
        final currentGroup = (state as GroupDetailLoaded).group;
        final updatedGroup = await _groupRepository.getGroupById(
          currentGroup.id,
          DateTime.now().year,
          DateTime.now().month,
        );
        emit(GroupDetailLoaded(updatedGroup));
      }
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }
}