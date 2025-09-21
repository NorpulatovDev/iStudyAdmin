// lib/features/reports/data/repositories/report_repository.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/report_model.dart';

class ReportRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  const ReportRepository(this._apiService, this._storageService);

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

  // Payment Reports
  Future<PaymentReportModel> getDailyPaymentReport({
    required DateTime date,
    int? branchId,
  }) async {
    try {
      final user = await _getCurrentUser();
      final targetBranchId = branchId ?? user?.branchId;

      if (targetBranchId == null) {
        throw Exception('Branch ID is required. Please login again.');
      }

      final response = await _apiService.dio.get(
        '${ApiConstants.reportsEndpoint}/payments/daily',
        queryParameters: {
          'branchId': targetBranchId,
          'date': date.toIso8601String().split('T')[0],
        },
      );

      return PaymentReportModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to payment reports.');
      }
      throw Exception('Failed to get daily payment report: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get daily payment report: $e');
    }
  }

  Future<PaymentReportModel> getMonthlyPaymentReport({
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
        '${ApiConstants.reportsEndpoint}/payments/monthly',
        queryParameters: {
          'branchId': targetBranchId,
          'year': year,
          'month': month,
        },
      );

      return PaymentReportModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to payment reports.');
      }
      throw Exception('Failed to get monthly payment report: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get monthly payment report: $e');
    }
  }

  Future<PaymentReportModel> getPaymentRangeReport({
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
        '${ApiConstants.reportsEndpoint}/payments/range',
        queryParameters: {
          'branchId': targetBranchId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      return PaymentReportModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to payment reports.');
      }
      throw Exception('Failed to get payment range report: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get payment range report: $e');
    }
  }

  // Expense Reports
  Future<ExpenseReportModel> getDailyExpenseReport({
    required DateTime date,
    int? branchId,
  }) async {
    try {
      final user = await _getCurrentUser();
      final targetBranchId = branchId ?? user?.branchId;

      if (targetBranchId == null) {
        throw Exception('Branch ID is required. Please login again.');
      }

      final response = await _apiService.dio.get(
        '${ApiConstants.reportsEndpoint}/expenses/daily',
        queryParameters: {
          'branchId': targetBranchId,
          'date': date.toIso8601String().split('T')[0],
        },
      );

      return ExpenseReportModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to expense reports.');
      }
      throw Exception('Failed to get daily expense report: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get daily expense report: $e');
    }
  }

  Future<ExpenseReportModel> getMonthlyExpenseReport({
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
        '${ApiConstants.reportsEndpoint}/expenses/monthly',
        queryParameters: {
          'branchId': targetBranchId,
          'year': year,
          'month': month,
        },
      );

      return ExpenseReportModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to expense reports.');
      }
      throw Exception('Failed to get monthly expense report: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get monthly expense report: $e');
    }
  }

  Future<ExpenseReportModel> getExpenseRangeReport({
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
        '${ApiConstants.reportsEndpoint}/expenses/range',
        queryParameters: {
          'branchId': targetBranchId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      return ExpenseReportModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to expense reports.');
      }
      throw Exception('Failed to get expense range report: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get expense range report: $e');
    }
  }

  // Financial Summary Reports
  Future<FinancialSummaryModel> getFinancialSummary({
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
        '${ApiConstants.reportsEndpoint}/financial/summary',
        queryParameters: {
          'branchId': targetBranchId,
          'year': year,
          'month': month,
        },
      );

      return FinancialSummaryModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to financial summary.');
      }
      throw Exception('Failed to get financial summary: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get financial summary: $e');
    }
  }

  Future<FinancialSummaryModel> getFinancialSummaryRange({
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
        '${ApiConstants.reportsEndpoint}/financial/summary-range',
        queryParameters: {
          'branchId': targetBranchId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      return FinancialSummaryModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to financial summary.');
      }
      throw Exception('Failed to get financial summary range: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get financial summary range: $e');
    }
  }
}