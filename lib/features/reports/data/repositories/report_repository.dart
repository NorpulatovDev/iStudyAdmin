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

  // Dashboard Stats
  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.dashboardStatsEndpoint,
      );

      return DashboardStatsModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Insufficient permissions.');
      }
      throw Exception('Failed to fetch dashboard stats: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  // Payment Reports
  Future<ReportModel> getDailyPaymentReport({
    required int branchId,
    required DateTime date,
  }) async {
    try {
      final response = await _apiService.dio.get(
        "${ApiConstants.reportsEndpoint}/payments/daily",
        queryParameters: {
          'branchId': branchId,
          'date': date.toIso8601String().split('T')[0],
        },
      );

      return ReportModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to this branch reports.');
      }
      throw Exception('Failed to fetch daily payment report: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch daily payment report: $e');
    }
  }

  Future<ReportModel> getMonthlyPaymentReport({
    required int branchId,
    required int year,
    required int month,
  }) async {
    try {
      final response = await _apiService.dio.get(
        "${ApiConstants.reportsEndpoint}/payments/monthly",
        queryParameters: {
          'branchId': branchId,
          'year': year,
          'month': month,
        },
      );

      return ReportModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch monthly payment report: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch monthly payment report: $e');
    }
  }

  Future<ReportModel> getPaymentRangeReport({
    required int branchId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiService.dio.get(
        "${ApiConstants.reportsEndpoint}/payments/range",
        queryParameters: {
          'branchId': branchId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      return ReportModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch payment range report: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch payment range report: $e');
    }
  }

  // Expense Reports
  Future<ReportModel> getDailyExpenseReport({
    required int branchId,
    required DateTime date,
  }) async {
    try {
      final response = await _apiService.dio.get(
        "${ApiConstants.reportsEndpoint}/expenses/daily",
        queryParameters: {
          'branchId': branchId,
          'date': date.toIso8601String().split('T')[0],
        },
      );

      return ReportModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch daily expense report: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch daily expense report: $e');
    }
  }

  Future<ReportModel> getMonthlyExpenseReport({
    required int branchId,
    required int year,
    required int month,
  }) async {
    try {
      final response = await _apiService.dio.get(
        "${ApiConstants.reportsEndpoint}/expenses/monthly",
        queryParameters: {
          'branchId': branchId,
          'year': year,
          'month': month,
        },
      );

      return ReportModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch monthly expense report: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch monthly expense report: $e');
    }
  }

  Future<ReportModel> getExpenseRangeReport({
    required int branchId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiService.dio.get(
        "${ApiConstants.reportsEndpoint}/expenses/range",
        queryParameters: {
          'branchId': branchId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      return ReportModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch expense range report: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch expense range report: $e');
    }
  }

  Future<ReportModel> getAllTimeExpenseReport({required int branchId}) async {
    try {
      final response = await _apiService.dio.get(
        "${ApiConstants.reportsEndpoint}/expenses/all-time",
        queryParameters: {'branchId': branchId},
      );

      return ReportModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch all-time expense report: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch all-time expense report: $e');
    }
  }

  // Salary Reports
  Future<ReportModel> getMonthlySalaryReport({
    required int branchId,
    required int year,
    required int month,
  }) async {
    try {
      final response = await _apiService.dio.get(
        "${ApiConstants.reportsEndpoint}/salaries/monthly",
        queryParameters: {
          'branchId': branchId,
          'year': year,
          'month': month,
        },
      );

      return ReportModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch monthly salary report: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch monthly salary report: $e');
    }
  }

  Future<ReportModel> getSalaryRangeReport({
    required int branchId,
    required int startYear,
    required int startMonth,
    required int endYear,
    required int endMonth,
  }) async {
    try {
      final response = await _apiService.dio.get(
        "${ApiConstants.reportsEndpoint}/salaries/range",
        queryParameters: {
          'branchId': branchId,
          'startYear': startYear,
          'startMonth': startMonth,
          'endYear': endYear,
          'endMonth': endMonth,
        },
      );

      return ReportModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch salary range report: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch salary range report: $e');
    }
  }

  // Financial Summary Reports
  Future<ReportModel> getFinancialSummary({
    required int branchId,
    required int year,
    required int month,
  }) async {
    try {
      final response = await _apiService.dio.get(
        "${ApiConstants.reportsEndpoint}/financial/summary",
        queryParameters: {
          'branchId': branchId,
          'year': year,
          'month': month,
        },
      );

      return ReportModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch financial summary: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch financial summary: $e');
    }
  }

  Future<ReportModel> getFinancialSummaryRange({
    required int branchId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiService.dio.get(
        "${ApiConstants.reportsEndpoint}/financial/summary-range",
        queryParameters: {
          'branchId': branchId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      return ReportModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch financial summary range: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch financial summary range: $e');
    }
  }

  // Helper method to get current user's branch reports
  Future<ReportModel> getCurrentBranchFinancialSummary({
    int? year,
    int? month,
  }) async {
    final user = await _getCurrentUser();
    final branchId = user?.branchId;
    
    if (branchId == null) {
      throw Exception('Branch ID is required. Please login again.');
    }

    final now = DateTime.now();
    final targetYear = year ?? now.year;
    final targetMonth = month ?? now.month;

    return getFinancialSummary(
      branchId: branchId,
      year: targetYear,
      month: targetMonth,
    );
  }
}