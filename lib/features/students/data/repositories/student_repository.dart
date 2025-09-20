// lib/features/students/data/repositories/student_repository.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/student_model.dart';

class StudentRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  const StudentRepository(this._apiService, this._storageService);

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

  // Get students by branch (for students page)
  Future<List<StudentModel>> getStudentsByBranch([int? branchId]) async {
    try {
      final user = await _getCurrentUser();
      final targetBranchId = branchId ?? user?.branchId;

      if (targetBranchId == null) {
        throw Exception('Branch ID is required. Please login again.');
      }

      final response = await _apiService.dio.get(
        ApiConstants.studentsEndpoint,
        queryParameters: {'branchId': targetBranchId},
      );

      final List<dynamic> studentsJson = response.data as List;
      return studentsJson.map((json) => StudentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Insufficient permissions.');
      }
      throw Exception('Failed to fetch students: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch students: $e');
    }
  }

  // Get students by group (for group navigation)
  Future<List<StudentModel>> getStudentsByGroup(int groupId) async {
    try {
      final response = await _apiService.dio.get(
        "${ApiConstants.studentsEndpoint}/by-group",
        queryParameters: {'groupId': groupId},
      );

      final List<dynamic> studentsJson = response.data as List;
      return studentsJson.map((json) => StudentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to this group.');
      }
      throw Exception('Failed to fetch group students: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch group students: $e');
    }
  }

  // Search students
  Future<List<StudentModel>> searchStudents({
    required int branchId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'branchId': branchId,
      };

      if (firstName != null && firstName.trim().isNotEmpty) {
        queryParams['firstName'] = firstName.trim();
      }
      if (lastName != null && lastName.trim().isNotEmpty) {
        queryParams['lastName'] = lastName.trim();
      }
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        queryParams['phoneNumber'] = phoneNumber.trim();
      }

      final response = await _apiService.dio.get(
        '${ApiConstants.studentsEndpoint}/search',
        queryParameters: queryParams,
      );

      final List<dynamic> studentsJson = response.data as List;
      return studentsJson.map((json) => StudentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to this branch.');
      }
      throw Exception('Failed to search students: ${e.message}');
    } catch (e) {
      throw Exception('Failed to search students: $e');
    }
  }

  Future<StudentModel> getStudentById(int id) async {
    try {
      final response = await _apiService.dio.get(
        '${ApiConstants.studentsEndpoint}/$id',
      );

      return StudentModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Student not found.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied to this student.');
      }
      throw Exception('Failed to fetch student: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch student: $e');
    }
  }

  Future<StudentModel> createStudent({
    required CreateStudentRequest request
  }) async {
    try {
      final data = request.toJson();

      final response = await _apiService.dio.post(
        ApiConstants.studentsEndpoint,
        data: data,
      );

      return StudentModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null && errorData['fieldErrors'] != null) {
          final fieldErrors = errorData['fieldErrors'] as Map;
          final errorMessage = fieldErrors.values.join(', ');
          throw Exception('Validation error: $errorMessage');
        }
        throw Exception('Invalid student data provided.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Cannot create student in this branch.');
      }
      throw Exception('Failed to create student: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create student: $e');
    }
  }

  Future<StudentModel> updateStudent({
    required int id,
    required CreateStudentRequest request
  }) async {
    try {
      final data = request.toJson();

      final response = await _apiService.dio.put(
        '${ApiConstants.studentsEndpoint}/$id',
        data: data,
      );

      return StudentModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Student not found.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Cannot update this student.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid student data provided.');
      }
      throw Exception('Failed to update student: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update student: $e');
    }
  }

  Future<void> deleteStudent(int id) async {
    try {
      await _apiService.dio.delete('${ApiConstants.studentsEndpoint}/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Student not found.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Cannot delete this student.');
      }
      throw Exception('Failed to delete student: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete student: $e');
    }
  }
}
