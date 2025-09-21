// lib/features/teacher_salaries/data/repositories/teacher_salary_repository.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/salary_calculation_model.dart';

class TeacherSalaryRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  const TeacherSalaryRepository(this._apiService, this._storageService);

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

  // Calculate salary for specific teacher
  Future<SalaryCalculationModel> calculateTeacherSalary({
    required int teacherId,
    required int year,
    required int month,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/teacher-salaries/calculate/teacher/$teacherId',
        queryParameters: {
          'year': year,
          'month': month,
        },
      );

      return SalaryCalculationModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Teacher not found.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied to this teacher\'s salary.');
      }
      throw Exception('Failed to calculate teacher salary: ${e.message}');
    } catch (e) {
      throw Exception('Failed to calculate teacher salary: $e');
    }
  }

  // Calculate salaries for all teachers in branch
  Future<List<SalaryCalculationModel>> calculateSalariesForBranch({
    required int year,
    required int month,
    int? branchId,
  }) async {
    try {
      final user = await _getCurrentUser();
      final targetBranchId = branchId ?? user?.branchId;

      if (targetBranchId == null) {
        throw Exception('Branch ID is required. Please login again.');
      }

      final response = await _apiService.dio.get(
        '/teacher-salaries/calculate/branch/$targetBranchId',
        queryParameters: {
          'year': year,
          'month': month,
        },
      );

      final List<dynamic> salariesJson = response.data as List;
      return salariesJson
          .map((json) => SalaryCalculationModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to branch salary data.');
      }
      throw Exception('Failed to calculate branch salaries: ${e.message}');
    } catch (e) {
      throw Exception('Failed to calculate branch salaries: $e');
    }
  }

  // Create salary payment
  Future<TeacherSalaryPaymentModel> createSalaryPayment({
    required int teacherId,
    required int year,
    required int month,
    required double amount,
    String? description,
    int? branchId,
  }) async {
    try {
      final user = await _getCurrentUser();
      final targetBranchId = branchId ?? user?.branchId;

      if (targetBranchId == null) {
        throw Exception('Branch ID is required. Please login again.');
      }

      final data = {
        'teacherId': teacherId,
        'year': year,
        'month': month,
        'amount': amount,
        'branchId': targetBranchId,
        if (description != null) 'description': description,
      };

      final response = await _apiService.dio.post(
        '/teacher-salaries/payments',
        data: data,
      );

      return TeacherSalaryPaymentModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null && errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
        throw Exception('Invalid payment data provided.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Cannot create salary payment.');
      }
      throw Exception('Failed to create salary payment: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create salary payment: $e');
    }
  }

  // Get salary payments by branch
  Future<List<TeacherSalaryPaymentModel>> getSalaryPaymentsByBranch([
    int? branchId,
  ]) async {
    try {
      final user = await _getCurrentUser();
      final targetBranchId = branchId ?? user?.branchId;

      if (targetBranchId == null) {
        throw Exception('Branch ID is required. Please login again.');
      }

      final response = await _apiService.dio.get(
        '/teacher-salaries/payments/branch/$targetBranchId',
      );

      final List<dynamic> paymentsJson = response.data as List;
      return paymentsJson
          .map((json) => TeacherSalaryPaymentModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to branch salary payments.');
      }
      throw Exception('Failed to fetch salary payments: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch salary payments: $e');
    }
  }

  // Get salary payments by teacher
  Future<List<TeacherSalaryPaymentModel>> getSalaryPaymentsByTeacher(
    int teacherId,
  ) async {
    try {
      final response = await _apiService.dio.get(
        '/teacher-salaries/payments/teacher/$teacherId',
      );

      final List<dynamic> paymentsJson = response.data as List;
      return paymentsJson
          .map((json) => TeacherSalaryPaymentModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to teacher salary payments.');
      }
      throw Exception('Failed to fetch teacher payments: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch teacher payments: $e');
    }
  }

  // Get salary payments for specific teacher and month
  Future<List<TeacherSalaryPaymentModel>> getPaymentsForTeacherAndMonth({
    required int teacherId,
    required int year,
    required int month,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/teacher-salaries/payments/teacher/$teacherId/month',
        queryParameters: {
          'year': year,
          'month': month,
        },
      );

      final List<dynamic> paymentsJson = response.data as List;
      return paymentsJson
          .map((json) => TeacherSalaryPaymentModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to teacher payments.');
      }
      throw Exception('Failed to fetch monthly payments: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch monthly payments: $e');
    }
  }

  // Get salary history for teacher
  Future<List<TeacherSalaryHistoryModel>> getTeacherSalaryHistory(
    int teacherId,
  ) async {
    try {
      final response = await _apiService.dio.get(
        '/teacher-salaries/history/teacher/$teacherId',
      );

      final List<dynamic> historyJson = response.data as List;
      return historyJson
          .map((json) => TeacherSalaryHistoryModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to teacher salary history.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Teacher not found.');
      }
      throw Exception('Failed to fetch salary history: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch salary history: $e');
    }
  }

  // Get remaining amount for teacher
  Future<double> getRemainingAmountForTeacher({
    required int teacherId,
    required int year,
    required int month,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/teacher-salaries/remaining/teacher/$teacherId',
        queryParameters: {
          'year': year,
          'month': month,
        },
      );

      return (response.data as num).toDouble();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to teacher salary data.');
      }
      throw Exception('Failed to get remaining amount: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get remaining amount: $e');
    }
  }

  // Delete salary payment
  Future<void> deleteSalaryPayment(int paymentId) async {
    try {
      await _apiService.dio.delete(
        '/teacher-salaries/payments/$paymentId',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Salary payment not found.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Cannot delete this payment.');
      }
      throw Exception('Failed to delete salary payment: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete salary payment: $e');
    }
  }
}