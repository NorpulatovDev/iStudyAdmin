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

  // Get unpaid students
  Future<List<UnpaidStudentModel>> getUnpaidStudents({
    int? branchId,
    int? year,
    int? month,
  }) async {
    try {
      final user = await _getCurrentUser();
      final targetBranchId = branchId ?? user?.branchId;

      if (targetBranchId == null) {
        throw Exception('Branch ID is required. Please login again.');
      }

      final queryParams = {'branchId': targetBranchId};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;

      final response = await _apiService.dio.get(
        '${ApiConstants.paymentsEndpoint}/unpaid',
        queryParameters: queryParams,
      );

      final List<dynamic> studentsJson = response.data as List;
      return studentsJson.map((json) => UnpaidStudentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to unpaid students.');
      }
      throw Exception('Failed to fetch unpaid students: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch unpaid students: $e');
    }
  }

  // Get payments by date range
  Future<List<PaymentModel>> getPaymentsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int? branchId,
  }) async {
    try {
      final user = await _getCurrentUser();
      final targetBranchId = branchId ?? user?.branchId;

      if (targetBranchId == null) {
        throw Exception('Branch ID is required. Please login again.');
      }

      final response = await _apiService.dio.get(
        '${ApiConstants.paymentsEndpoint}/by-date-range',
        queryParameters: {
          'branchId': targetBranchId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      final List<dynamic> paymentsJson = response.data as List;
      return paymentsJson.map((json) => PaymentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to payment data.');
      }
      throw Exception('Failed to fetch payments by date range: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch payments by date range: $e');
    }
  }

  // Get payments by month
  Future<List<PaymentModel>> getPaymentsByMonth({
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
        '${ApiConstants.paymentsEndpoint}/by-month',
        queryParameters: {
          'branchId': targetBranchId,
          'year': year,
          'month': month,
        },
      );

      final List<dynamic> paymentsJson = response.data as List;
      return paymentsJson.map((json) => PaymentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to monthly payments.');
      }
      throw Exception('Failed to fetch monthly payments: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch monthly payments: $e');
    }
  }

  // Get recent payments
  Future<List<PaymentModel>> getRecentPayments({
    int limit = 20,
    int? branchId,
  }) async {
    try {
      final user = await _getCurrentUser();
      final targetBranchId = branchId ?? user?.branchId;

      if (targetBranchId == null) {
        throw Exception('Branch ID is required. Please login again.');
      }

      final response = await _apiService.dio.get(
        '${ApiConstants.paymentsEndpoint}/recent',
        queryParameters: {
          'branchId': targetBranchId,
          'limit': limit,
        },
      );

      final List<dynamic> paymentsJson = response.data as List;
      return paymentsJson.map((json) => PaymentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to recent payments.');
      }
      throw Exception('Failed to fetch recent payments: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch recent payments: $e');
    }
  }

  // Get payments by student
  Future<List<PaymentModel>> getPaymentsByStudent(int studentId) async {
    try {
      final response = await _apiService.dio.get(
        '${ApiConstants.paymentsEndpoint}/student/$studentId',
      );

      final List<dynamic> paymentsJson = response.data as List;
      return paymentsJson.map((json) => PaymentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to student payments.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Student not found.');
      }
      throw Exception('Failed to fetch student payments: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch student payments: $e');
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
  Future<PaymentModel> createPayment(CreatePaymentRequest request) async {
  try {
    final user = await _getCurrentUser();
    final targetBranchId = user?.branchId;

    if (targetBranchId == null) {
      throw Exception('Branch ID is required. Please login again.');
    }

    // Override the branchId with current user's branch
    final data = request.toJson();
    data['branchId'] = targetBranchId;

    final response = await _apiService.dio.post(
      ApiConstants.paymentsEndpoint,
      data: data,
    );

    return PaymentModel.fromJson(response.data);
  } on DioException catch (e) {
    if (e.response?.statusCode == 400) {
      final errorData = e.response?.data;
      if (errorData != null && errorData['fieldErrors'] != null) {
        final fieldErrors = errorData['fieldErrors'] as Map;
        final errorMessage = fieldErrors.values.join(', ');
        throw Exception('Validation error: $errorMessage');
      } else if (errorData != null && errorData['message'] != null) {
        throw Exception(errorData['message']);
      }
      throw Exception('Invalid payment data provided.');
    } else if (e.response?.statusCode == 403) {
      throw Exception('Access denied. Cannot create payment in this branch.');
    }
    throw Exception('Failed to create payment: ${e.message}');
  } catch (e) {
    throw Exception('Failed to create payment: $e');
  }
}

  // Update payment amount
  Future<PaymentModel> updatePaymentAmount({
    required int id,
    required double amount,
  }) async {
    try {
      final response = await _apiService.dio.put(
        '${ApiConstants.paymentsEndpoint}/$id',
        data: UpdatePaymentRequest(amount: amount).toJson(),
      );

      return PaymentModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Payment not found.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Cannot update this payment.');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null && errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
        throw Exception('Invalid payment amount provided.');
      }
      throw Exception('Failed to update payment: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update payment: $e');
    }
  }

  // Search payments by student name
  Future<List<PaymentModel>> searchPaymentsByStudentName({
    required String studentName,
    int? branchId,
  }) async {
    try {
      final user = await _getCurrentUser();
      final targetBranchId = branchId ?? user?.branchId;

      if (targetBranchId == null) {
        throw Exception('Branch ID is required. Please login again.');
      }

      final response = await _apiService.dio.get(
        '${ApiConstants.paymentsEndpoint}/search',
        queryParameters: {
          'branchId': targetBranchId,
          'studentName': studentName,
        },
      );

      final List<dynamic> paymentsJson = response.data as List;
      return paymentsJson.map((json) => PaymentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to payment search.');
      }
      throw Exception('Failed to search payments: ${e.message}');
    } catch (e) {
      throw Exception('Failed to search payments: $e');
    }
  }

  // Delete payment
  Future<void> deletePayment(int id) async {
    try {
      await _apiService.dio.delete('${ApiConstants.paymentsEndpoint}/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Payment not found.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Cannot delete this payment.');
      }
      throw Exception('Failed to delete payment: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete payment: $e');
    }
  }
}