// lib/features/groups/data/repositories/group_repository.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/group_model.dart';

class GroupRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  const GroupRepository(this._apiService, this._storageService);

  Future<UserModel?> _getCurrentUser() async {
    try {
      final userData = await _storageService.getUserData();
      if (userData == null) return null;
      final userJson = jsonDecode(userData);
      return UserModel.fromJson(userJson);
    } catch (e) {
      return null;
    }
  }

  // Get groups by branch (for drawer navigation)
  Future<List<GroupModel>> getGroupsByBranch([int? branchId]) async {
    try {
      final user = await _getCurrentUser();
      final targetBranchId = branchId ?? user?.branchId;

      if (targetBranchId == null) {
        throw Exception('Branch ID is required. Please login again.');
      }

      final response = await _apiService.dio.get(
        ApiConstants.groupsEndpoint,
        queryParameters: {'branchId': targetBranchId},
      );

      final List<dynamic> groupsJson = response.data as List;
      return groupsJson.map((json) => GroupModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Insufficient permissions.');
      }
      throw Exception('Failed to fetch groups: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch groups: $e');
    }
  }

  // Get groups by course (for course navigation)
  Future<List<GroupModel>> getGroupsByCourse(int courseId) async {
    try {
      final response = await _apiService.dio.get(
        "${ApiConstants.groupsEndpoint}/by-course",
        queryParameters: {'courseId': courseId},
      );

      final List<dynamic> groupsJson = response.data as List;
      return groupsJson.map((json) => GroupModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to this course.');
      }
      throw Exception('Failed to fetch course groups: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch course groups: $e');
    }
  }

// Get groups by teacher ID
  Future<List<GroupModel>> getGroupsByTeacher(int teacherId) async {
    try {
      final response = await _apiService.dio.get(
        "${ApiConstants.groupsEndpoint}/by-teacher",
        queryParameters: {'teacherId': teacherId},
      );

      final List<dynamic> groupsJson = response.data as List;
      return groupsJson.map((json) => GroupModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to this teacher\'s groups.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Teacher not found.');
      }
      throw Exception('Failed to fetch teacher groups: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch teacher groups: $e');
    }
  }

  Future<GroupModel> getGroupById(int id, int year, int month) async {
    try {
      final response = await _apiService.dio
          .get('${ApiConstants.groupsEndpoint}/$id', queryParameters: {
        'year': year,
        'month': month,
      });

      return GroupModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Group not found.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied to this group.');
      }
      throw Exception('Failed to fetch group: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch group: $e');
    }
  }

  Future<GroupModel> createGroup({
    required String name,
    required int courseId,
    required int branchId,
    int? teacherId,
    List<int>? studentIds,
    String? startTime,
    String? endTime,
    List<String>? daysOfWeek,
  }) async {
    try {
      final data = {
        'name': name,
        'courseId': courseId,
        'branchId': branchId,
        if (teacherId != null) 'teacherId': teacherId,
        if (studentIds != null) 'studentIds': studentIds,
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
        if (daysOfWeek != null) 'daysOfWeek': daysOfWeek,
      };

      final response = await _apiService.dio.post(
        ApiConstants.groupsEndpoint,
        data: data,
      );

      return GroupModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null && errorData['fieldErrors'] != null) {
          final fieldErrors = errorData['fieldErrors'] as Map;
          final errorMessage = fieldErrors.values.join(', ');
          throw Exception('Validation error: $errorMessage');
        }
        throw Exception('Invalid group data provided.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Cannot create group in this branch.');
      }
      throw Exception('Failed to create group: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }

  Future<GroupModel> updateGroup({
    required int id,
    required String name,
    required int courseId,
    required int branchId,
    int? teacherId,
    List<int>? studentIds,
    String? startTime,
    String? endTime,
    List<String>? daysOfWeek,
  }) async {
    try {
      final data = {
        'name': name,
        if (teacherId != null) 'teacherId': teacherId,
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
        if (daysOfWeek != null) 'daysOfWeek': daysOfWeek,
      };

      final response = await _apiService.dio.put(
        '${ApiConstants.groupsEndpoint}/$id',
        data: data,
      );

      return GroupModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Group not found.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Cannot update this group.');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null && errorData['fieldErrors'] != null) {
          final fieldErrors = errorData['fieldErrors'] as Map;
          final errorMessage = fieldErrors.values.join(', ');
          throw Exception('Validation error: $errorMessage');
        }
        throw Exception('Invalid group data provided.');
      }
      throw Exception('Failed to update group: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update group: $e');
    }
  }

  Future<void> deleteGroup(int id) async {
    try {
      await _apiService.dio.delete('${ApiConstants.groupsEndpoint}/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Group not found.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Cannot delete this group.');
      }
      throw Exception('Failed to delete group: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete group: $e');
    }
  }

  Future<void> removeStudentFromGroup(int groupId, int studentId) async {
    try {
      await _apiService.dio.delete(
        '${ApiConstants.groupsEndpoint}/$groupId/students/$studentId',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Group or student not found.');
      } else if (e.response?.statusCode == 403) {
        throw Exception(
            'Access denied. Cannot remove student from this group.');
      }
      throw Exception('Failed to remove student from group: ${e.message}');
    } catch (e) {
      throw Exception('Failed to remove student from group: $e');
    }
  }

  Future<void> addStudentsToGroup(int groupId, int studentId) async {
  try {
    

    await _apiService.dio.post(
      '${ApiConstants.groupsEndpoint}/$groupId/students/$studentId',
    );
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) {
      throw Exception('Group not found.');
    } else if (e.response?.statusCode == 403) {
      throw Exception('Access denied. Cannot add students to this group.');
    } else if (e.response?.statusCode == 400) {
      final errorData = e.response?.data;
      if (errorData != null && errorData['message'] != null) {
        throw Exception(errorData['message']);
      }
      throw Exception('Invalid request. Some students may already be in the group.');
    }
    throw Exception('Failed to add students to group: ${e.message}');
  } catch (e) {
    throw Exception('Failed to add students to group: $e');
  }
}
}
