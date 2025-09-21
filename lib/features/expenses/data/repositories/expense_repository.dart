// lib/features/expenses/data/repositories/expense_repository.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  const ExpenseRepository(this._apiService, this._storageService);

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

  // Get expenses by branch
  Future<List<ExpenseModel>> getExpensesByBranch([int? branchId]) async {
    try {
      final user = await _getCurrentUser();
      final targetBranchId = branchId ?? user?.branchId;

      if (targetBranchId == null) {
        throw Exception('Branch ID is required. Please login again.');
      }

      final response = await _apiService.dio.get(
        ApiConstants.expensesEndpoint,
        queryParameters: {'branchId': targetBranchId},
      );

      final List<dynamic> expensesJson = response.data as List;
      return expensesJson.map((json) => ExpenseModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Insufficient permissions.');
      }
      throw Exception('Failed to fetch expenses: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch expenses: $e');
    }
  }

  // Get expenses by month
  Future<List<ExpenseModel>> getExpensesByMonth({
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
        '${ApiConstants.expensesEndpoint}/monthly',
        queryParameters: {
          'branchId': targetBranchId,
          'year': year,
          'month': month,
        },
      );

      final List<dynamic> expensesJson = response.data as List;
      return expensesJson.map((json) => ExpenseModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to monthly expenses.');
      }
      throw Exception('Failed to fetch monthly expenses: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch monthly expenses: $e');
    }
  }

  // Get expenses by date
  Future<List<ExpenseModel>> getExpensesByDate({
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
        '${ApiConstants.expensesEndpoint}/daily',
        queryParameters: {
          'branchId': targetBranchId,
          'date': date.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
        },
      );

      final List<dynamic> expensesJson = response.data as List;
      return expensesJson.map((json) => ExpenseModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to daily expenses.');
      }
      throw Exception('Failed to fetch daily expenses: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch daily expenses: $e');
    }
  }

  // Create expense
  Future<ExpenseModel> createExpense({
    String? description,
    required double amount,
    required ExpenseCategory category,
    int? branchId,
  }) async {
    try {
      final user = await _getCurrentUser();
      final targetBranchId = branchId ?? user?.branchId;

      if (targetBranchId == null) {
        throw Exception('Branch ID is required. Please login again.');
      }

      final data = {
        'amount': amount,
        'category': category.apiValue,
        'branchId': targetBranchId,
        if (description != null) 'description': description,
      };

      final response = await _apiService.dio.post(
        ApiConstants.expensesEndpoint,
        data: data,
      );

      return ExpenseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null && errorData['fieldErrors'] != null) {
          final fieldErrors = errorData['fieldErrors'] as Map;
          final errorMessage = fieldErrors.values.join(', ');
          throw Exception('Validation error: $errorMessage');
        }
        throw Exception('Invalid expense data provided.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Cannot create expense in this branch.');
      }
      throw Exception('Failed to create expense: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create expense: $e');
    }
  }

  // Delete expense
  Future<void> deleteExpense(int id) async {
    try {
      await _apiService.dio.delete('${ApiConstants.expensesEndpoint}/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Expense not found.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Cannot delete this expense.');
      }
      throw Exception('Failed to delete expense: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }


// Update expense
Future<ExpenseModel> updateExpense({
  required int id,
  String? description,
  required double amount,
  required ExpenseCategory category,
  int? branchId,
}) async {
  try {
    final user = await _getCurrentUser();
    final targetBranchId = branchId ?? user?.branchId;

    if (targetBranchId == null) {
      throw Exception('Branch ID is required. Please login again.');
    }

    final data = {
      'amount': amount,
      'category': category.apiValue,
      'branchId': targetBranchId,
      if (description != null) 'description': description,
    };

    final response = await _apiService.dio.put(
      '${ApiConstants.expensesEndpoint}/$id',
      data: data,
    );

    return ExpenseModel.fromJson(response.data);
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) {
      throw Exception('Expense not found.');
    } else if (e.response?.statusCode == 403) {
      throw Exception('Access denied. Cannot update this expense.');
    } else if (e.response?.statusCode == 400) {
      final errorData = e.response?.data;
      if (errorData != null && errorData['fieldErrors'] != null) {
        final fieldErrors = errorData['fieldErrors'] as Map;
        final errorMessage = fieldErrors.values.join(', ');
        throw Exception('Validation error: $errorMessage');
      }
      throw Exception('Invalid expense data provided.');
    }
    throw Exception('Failed to update expense: ${e.message}');
  } catch (e) {
    throw Exception('Failed to update expense: $e');
  }
}

  // Get monthly expenses summary
  Future<Map<String, dynamic>> getMonthlyExpensesSummary({
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
        '${ApiConstants.expensesEndpoint}/monthly/summary',
        queryParameters: {
          'branchId': targetBranchId,
          'year': year,
          'month': month,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to monthly summary.');
      }
      throw Exception('Failed to get monthly expenses summary: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get monthly expenses summary: $e');
    }
  }

  // Get daily expenses summary
  Future<Map<String, dynamic>> getDailyExpensesSummary({
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
        '${ApiConstants.expensesEndpoint}/daily/summary',
        queryParameters: {
          'branchId': targetBranchId,
          'date': date.toIso8601String().split('T')[0],
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to daily summary.');
      }
      throw Exception('Failed to get daily expenses summary: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get daily expenses summary: $e');
    }
  }

  // Get monthly total only (lightweight)
  Future<double> getMonthlyExpensesTotal({
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
        '${ApiConstants.expensesEndpoint}/monthly/total',
        queryParameters: {
          'branchId': targetBranchId,
          'year': year,
          'month': month,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return (data['total'] as num).toDouble();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to monthly total.');
      }
      throw Exception('Failed to get monthly expenses total: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get monthly expenses total: $e');
    }
  }

  // Get daily total only (lightweight)
  Future<double> getDailyExpensesTotal({
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
        '${ApiConstants.expensesEndpoint}/daily/total',
        queryParameters: {
          'branchId': targetBranchId,
          'date': date.toIso8601String().split('T')[0],
        },
      );

      final data = response.data as Map<String, dynamic>;
      return (data['total'] as num).toDouble();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied to daily total.');
      }
      throw Exception('Failed to get daily expenses total: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get daily expenses total: $e');
    }
  }
}