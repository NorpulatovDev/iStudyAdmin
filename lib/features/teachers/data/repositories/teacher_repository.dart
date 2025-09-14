// lib/features/teachers/data/repositories/teacher_repository.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/teacher_model.dart';

enum SalaryType { FIXED, PERCENTAGE, MIXED }

class TeacherRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  const TeacherRepository(this._apiService, this._storageService);

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

  // Get teachers by branch
  Future<List<TeacherModel>> getTeachersByBranch([int? branchId]) async {
    try {
      final user = await _getCurrentUser();
      final targetBranchId = branchId ?? user?.branchId;
      
      if (targetBranchId == null) {
        throw Exception('Branch ID is required. Please login again.');
      }

      final response = await _apiService.dio.get(
        ApiConstants.teachersEndpoint,
        queryParameters: {'branchId': targetBranchId},
      );

      final List<dynamic> teachersJson = response.data as List;
      return teachersJson.map((json) => TeacherModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Insufficient permissions.');
      }
      throw Exception('Failed to fetch teachers: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch teachers: $e');
    }
  }

  // Search teachers
  Future<List<TeacherModel>> searchTeachers({
    required int branchId,
    String? name,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'branchId': branchId,
      };
      
      if (name != null && name.trim().isNotEmpty) {
        queryParams['name'] = name.trim();
      }

      final response = await _apiService.dio.get(
        '${ApiConstants.teachersEndpoint}/search',
        queryParameters: queryParams,
      );

      final List<dynamic> teachersJson = response.data as List;
      return teachersJson.map((json) => TeacherModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to this branch.');
      }
      throw Exception('Failed to search teachers: ${e.message}');
    } catch (e) {
      throw Exception('Failed to search teachers: $e');
    }
  }

  // Get teachers by salary type
  Future<List<TeacherModel>> getTeachersBySalaryType({
    required int branchId,
    required String salaryType,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '${ApiConstants.teachersEndpoint}/by-salary-type',
        queryParameters: {
          'branchId': branchId,
          'salaryType': salaryType,
        },
      );

      final List<dynamic> teachersJson = response.data as List;
      return teachersJson.map((json) => TeacherModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to this branch.');
      }
      throw Exception('Failed to fetch teachers by salary type: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch teachers by salary type: $e');
    }
  }

  Future<TeacherModel> getTeacherById(int id) async {
    try {
      final response = await _apiService.dio.get(
        '${ApiConstants.teachersEndpoint}/$id',
      );

      return TeacherModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Teacher not found.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied to this teacher.');
      }
      throw Exception('Failed to fetch teacher: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch teacher: $e');
    }
  }

  Future<TeacherModel> createTeacher({
    required String firstName,
    required String lastName,
    required int branchId,
    String? phoneNumber,
    required double baseSalary,
    required double paymentPercentage,
    required SalaryType salaryType,
  }) async {
    try {
      final data = {
        'firstName': firstName,
        'lastName': lastName,
        'branchId': branchId,
        'baseSalary': baseSalary,
        'paymentPercentage': paymentPercentage,
        'salaryType': salaryType.name,
        if (phoneNumber != null && phoneNumber.isNotEmpty) 
          'phoneNumber': phoneNumber,
      };

      final response = await _apiService.dio.post(
        ApiConstants.teachersEndpoint,
        data: data,
      );

      return TeacherModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null && errorData['fieldErrors'] != null) {
          final fieldErrors = errorData['fieldErrors'] as Map;
          final errorMessage = fieldErrors.values.join(', ');
          throw Exception('Validation error: $errorMessage');
        }
        throw Exception('Invalid teacher data provided.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Cannot create teacher in this branch.');
      }
      throw Exception('Failed to create teacher: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create teacher: $e');
    }
  }

  Future<TeacherModel> updateTeacher({
    required int id,
    required String firstName,
    required String lastName,
    required int branchId,
    String? phoneNumber,
    required double baseSalary,
    required double paymentPercentage,
    required SalaryType salaryType,
  }) async {
    try {
      final data = {
        'firstName': firstName,
        'lastName': lastName,
        'branchId': branchId,
        'baseSalary': baseSalary,
        'paymentPercentage': paymentPercentage,
        'salaryType': salaryType.name,
        if (phoneNumber != null && phoneNumber.isNotEmpty) 
          'phoneNumber': phoneNumber,
      };

      final response = await _apiService.dio.put(
        '${ApiConstants.teachersEndpoint}/$id',
        data: data,
      );

      return TeacherModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Teacher not found.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Cannot update this teacher.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid teacher data provided.');
      }
      throw Exception('Failed to update teacher: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update teacher: $e');
    }
  }

  Future<void> deleteTeacher(int id) async {
    try {
      await _apiService.dio.delete('${ApiConstants.teachersEndpoint}/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Teacher not found.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Cannot delete this teacher.');
      }
      throw Exception('Failed to delete teacher: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete teacher: $e');
    }
  }
}