// lib/features/courses/data/repositories/course_repository.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/course_model.dart';

class CourseRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  const CourseRepository(this._apiService, this._storageService);

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

  Future<List<CourseModel>> getCoursesByBranch([int? branchId]) async {
    try {
      // Get current user's branch if branchId not provided
      final user = await _getCurrentUser();
      final targetBranchId = branchId ?? user?.branchId;
      
      if (targetBranchId == null) {
        throw Exception('Branch ID is required. Please login again.');
      }

      final response = await _apiService.dio.get(
        ApiConstants.coursesEndpoint,
        queryParameters: {'branchId': targetBranchId},
      );

      final List<dynamic> coursesJson = response.data as List;
      return coursesJson.map((json) => CourseModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Insufficient permissions.');
      }
      throw Exception('Failed to fetch courses: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch courses: $e');
    }
  }

  // Future<List<CourseModel>> searchCourses({
  //   required int branchId,
  //   String? name,
  // }) async {
  //   try {
  //     final queryParams = <String, dynamic>{
  //       'branchId': branchId,
  //     };
      
  //     if (name != null && name.trim().isNotEmpty) {
  //       queryParams['name'] = name.trim();
  //     }

  //     final response = await _apiService.dio.get(
  //       '${ApiConstants.coursesEndpoint}/search',
  //       queryParameters: queryParams,
  //     );

  //     final List<dynamic> coursesJson = response.data as List;
  //     return coursesJson.map((json) => CourseModel.fromJson(json)).toList();
  //   } on DioException catch (e) {
  //     if (e.response?.statusCode == 403) {
  //       throw Exception('Access denied to this branch.');
  //     }
  //     throw Exception('Failed to search courses: ${e.message}');
  //   } catch (e) {
  //     throw Exception('Failed to search courses: $e');
  //   }
  // }

  // Future<CourseModel> getCourseById(int id) async {
  //   try {
  //     final response = await _apiService.dio.get(
  //       '${ApiConstants.coursesEndpoint}/$id',
  //     );

  //     return CourseModel.fromJson(response.data);
  //   } on DioException catch (e) {
  //     if (e.response?.statusCode == 404) {
  //       throw Exception('Course not found.');
  //     } else if (e.response?.statusCode == 403) {
  //       throw Exception('Access denied to this course.');
  //     }
  //     throw Exception('Failed to fetch course: ${e.message}');
  //   } catch (e) {
  //     throw Exception('Failed to fetch course: $e');
  //   }
  // }

  Future<CourseModel> createCourse({
    required String name,
    required double price,
    required int branchId,
    String? description,
    int? durationMonths,
  }) async {
    try {
      final data = {
        'name': name,
        'price': price,
        'branchId': branchId,
        if (description != null && description.isNotEmpty) 
          'description': description,
        if (durationMonths != null) 
          'durationMonths': durationMonths,
      };

      final response = await _apiService.dio.post(
        ApiConstants.coursesEndpoint,
        data: data,
      );

      return CourseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null && errorData['fieldErrors'] != null) {
          final fieldErrors = errorData['fieldErrors'] as Map;
          final errorMessage = fieldErrors.values.join(', ');
          throw Exception('Validation error: $errorMessage');
        }
        throw Exception('Invalid course data provided.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Cannot create course in this branch.');
      }
      throw Exception('Failed to create course: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create course: $e');
    }
  }

  Future<CourseModel> updateCourse({
    required int id,
    required String name,
    required double price,
    required int branchId,
    String? description,
    int? durationMonths,
  }) async {
    try {
      final data = {
        'name': name,
        'price': price,
        'branchId': branchId,
        if (description != null && description.isNotEmpty) 
          'description': description,
        if (durationMonths != null) 
          'durationMonths': durationMonths,
      };

      final response = await _apiService.dio.put(
        '${ApiConstants.coursesEndpoint}/$id',
        data: data,
      );

      return CourseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Course not found.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Cannot update this course.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid course data provided.');
      }
      throw Exception('Failed to update course: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update course: $e');
    }
  }

  Future<void> deleteCourse(int id) async {
    try {
      await _apiService.dio.delete('${ApiConstants.coursesEndpoint}/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Course not found.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Cannot delete this course.');
      }
      throw Exception('Failed to delete course: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete course: $e');
    }
  }
}