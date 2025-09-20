// lib/features/payments/data/repositories/payment_repository.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/payment_model.dart';

class PaymentRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  const PaymentRepository(this._apiService, this._storageService);

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

  // Get payments by branch
  Future<List<PaymentModel>> getPaymentsByBranch([int? branchId]) async {
    try {
      final user = await _getCurrentUser();
      final targetBranchId = branchId ?? user?.branchId;
      
      if (targetBranchId == null) {
        throw Exception('Branch ID is required. Please login again.');
      }

      final response = await _apiService.dio.get(
        ApiConstants.paymentsEndpoint,
        queryParameters: {'branchId': targetBranchId},
      );

      final List<dynamic> paymentsJson = response.data as List;
      return paymentsJson.map((json) => PaymentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Insufficient permissions.');
      }
      throw Exception('Failed to fetch payments: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch payments: $e');
    }
  }

  // Get payments by student
  Future<List<PaymentModel>> getPaymentsByStudent(int studentId) async {
    try {
      final response = await _apiService.dio.get(
        "${ApiConstants.paymentsEndpoint}/student/$studentId",
      );

      final List<dynamic> paymentsJson = response.data as List;
      return paymentsJson.map((json) => PaymentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to this student\'s payments.');
      }
      throw Exception('Failed to fetch student payments: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch student payments: $e');
    }
  }

  // Get payments by date range
  Future<List<PaymentModel>> getPaymentsByDateRange({
    required int branchId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiService.dio.get(
        "${ApiConstants.paymentsEndpoint}/by-date-range",
        queryParameters: {
          'branchId': branchId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      final List<dynamic> paymentsJson = response.data as List;
      return paymentsJson.map((json) => PaymentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch payments by date range: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch payments by date range: $e');
    }
  }

  // Get payments by month
  Future<List<PaymentModel>> getPaymentsByMonth({
    required int branchId,
    required int year,
    required int month,
  }) async {
    try {
      final response = await _apiService.dio.get(
        "${ApiConstants.paymentsEndpoint}/by-month",
        queryParameters: {
          'branchId': branchId,
          'year': year,
          'month': month,
        },
      );

      final List<dynamic> paymentsJson = response.data as List;
      return paymentsJson.map((json) => PaymentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch monthly payments: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch monthly payments: $e');
    }
  }

  // Get recent payments
  Future<List<PaymentModel>> getRecentPayments({
    required int branchId,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.dio.get(
        "${ApiConstants.paymentsEndpoint}/recent",
        queryParameters: {
          'branchId': branchId,
          'limit': limit,
        },
      );

      final List<dynamic> paymentsJson = response.data as List;
      return paymentsJson.map((json) => PaymentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch recent payments: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch recent payments: $e');
    }
  }

  // Search payments by student name
  Future<List<PaymentModel>> searchPaymentsByStudentName({
    required int branchId,
    required String studentName,
  }) async {
    try {
      final response = await _apiService.dio.get(
        "${ApiConstants.paymentsEndpoint}/search",
        queryParameters: {
          'branchId': branchId,
          'studentName': studentName,
        },
      );

      final List<dynamic> paymentsJson = response.data as List;
      return paymentsJson.map((json) => PaymentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to search payments: ${e.message}');
    } catch (e) {
      throw Exception('Failed to search payments: $e');
    }
  }

  // Get payment by ID
  Future<PaymentModel> getPaymentById(int id) async {
    try {
      final response = await _apiService.dio.get(
        '${ApiConstants.paymentsEndpoint}/$id',
      );

      return PaymentModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Payment not found.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied to this payment.');
      }
      throw Exception('Failed to fetch payment: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch payment: $e');
    }
  }

  // Create payment
  Future<PaymentModel> createPayment({
    required CreatePaymentRequest request
  }) async {
    try {
      final data = request.toJson();

      final response = await _apiService.dio.post(
        ApiConstants.paymentsEndpoint,
        data: data,
      );

      return PaymentModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid payment data provided.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Cannot create payment in this branch.');
      }
      throw Exception('Failed to create payment: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }
  
  Future<void> deletePayment(int paymentId) async {
    try {
      final response = await _apiService.dio.delete(
        '${ApiConstants.paymentsEndpoint}/$paymentId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete payment');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Payment not found.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Cannot delete this payment.');
      } else if (e.response?.statusCode == 409) {
        throw Exception('Cannot delete payment. It may be referenced by other records.');
      }
      throw Exception('Failed to delete payment: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete payment: $e');
    }
  }
}