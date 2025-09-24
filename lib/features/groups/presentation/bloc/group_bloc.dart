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
  String _currentLoadedBy = 'branch';
  int? _currentBranchId;
  int? _currentCourseId;
  int? _currentTeacherId;

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
    on<GroupAddStudentRequested>(_onAddStudentRequested);
  }

  Future<void> _onLoadByBranch(
    GroupLoadByBranchRequested event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());

    try {
      final groups = await _groupRepository.getGroupsByBranch(event.branchId);
      _allGroups = groups;
      _currentLoadedBy = 'branch';
      _currentBranchId = event.branchId;
      _currentCourseId = null;
      _currentTeacherId = null;
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
      _currentLoadedBy = 'course';
      _currentCourseId = event.courseId;
      _currentBranchId = null;
      _currentTeacherId = null;
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
      _currentLoadedBy = 'teacher';
      _currentTeacherId = event.teacherId;
      _currentBranchId = null;
      _currentCourseId = null;
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
          event.groupId, event.year, event.month);
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

    emit(const GroupOperationSuccess('Group created successfully'));
    
    // Fetch fresh data from server based on current context
    List<GroupModel> refreshedGroups;
    if (_currentCourseId != null) {
      refreshedGroups = await _groupRepository.getGroupsByCourse(_currentCourseId!);
    } else if (_currentTeacherId != null) {
      refreshedGroups = await _groupRepository.getGroupsByTeacher(_currentTeacherId!);
    } else {
      refreshedGroups = await _groupRepository.getGroupsByBranch(_currentBranchId);
    }
    
    _allGroups = refreshedGroups;
    emit(GroupLoaded(refreshedGroups, loadedBy: _currentLoadedBy));
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

      // Update local cache
      final index = _allGroups.indexWhere((group) => group.id == event.id);
      if (index != -1) {
        _allGroups[index] = updatedGroup;
      }

      emit(const GroupOperationSuccess('Group updated successfully'));
      
      // If we're on group details page, emit the updated group
      if (state is GroupDetailLoaded) {
        emit(GroupDetailLoaded(updatedGroup));
      } else {
        // Otherwise emit updated groups list
        emit(GroupLoaded(_allGroups, loadedBy: _currentLoadedBy));
      }
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

    emit(const GroupOperationSuccess('Group deleted successfully'));
    
    // Fetch fresh data from server
    List<GroupModel> refreshedGroups;
    if (_currentCourseId != null) {
      refreshedGroups = await _groupRepository.getGroupsByCourse(_currentCourseId!);
    } else if (_currentTeacherId != null) {
      refreshedGroups = await _groupRepository.getGroupsByTeacher(_currentTeacherId!);
    } else {
      refreshedGroups = await _groupRepository.getGroupsByBranch(_currentBranchId);
    }
    
    _allGroups = refreshedGroups;
    emit(GroupLoaded(refreshedGroups, loadedBy: _currentLoadedBy));
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
        _currentCourseId = event.courseId;
        _currentBranchId = null;
        _currentTeacherId = null;
      } else if (event.teacherId != null) {
        groups = await _groupRepository.getGroupsByTeacher(event.teacherId!);
        loadedBy = 'teacher';
        _currentTeacherId = event.teacherId;
        _currentBranchId = null;
        _currentCourseId = null;
      } else {
        groups = await _groupRepository.getGroupsByBranch(event.branchId);
        loadedBy = 'branch';
        _currentBranchId = event.branchId;
        _currentCourseId = null;
        _currentTeacherId = null;
      }

      _allGroups = groups;
      _currentLoadedBy = loadedBy;
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

      emit(const GroupOperationSuccess(
          'Student removed from group successfully'));

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

  Future<void> _onAddStudentRequested(
    GroupAddStudentRequested event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupOperationLoading());

    try {
      await _groupRepository.addStudentsToGroup(
        event.groupId,
        event.studentId,
      );

      emit(const GroupOperationSuccess('Student added to group successfully'));
      
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