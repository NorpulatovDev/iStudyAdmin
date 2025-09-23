import 'dart:convert';
import 'dart:async';

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiService _apiService;
  final StorageService _storageService;
  
  // Stream controller for auth state changes
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();
  
  AuthRepository(this._apiService, this._storageService);

  // Stream to listen for auth failures
  Stream<bool> get authStateStream => _authStateController.stream;

  Future<UserModel> login(String username, String password) async {
    try {
      final request = LoginRequest(username: username, password: password);

      final response = await _apiService.dio.post(
        ApiConstants.loginEndpoint,
        data: request.toJson(),
      );
      final loginResponse = LoginResponse.fromJson(response.data);
      
      // CHECK if user is ADMIN
      if (loginResponse.role != 'ADMIN') {
        throw Exception("Only Admin can access this application");
      }

      // Save tokens
      await _storageService.saveToken(
        ApiConstants.accessTokenKey,
        loginResponse.accessToken,
      );
      await _storageService.saveToken(
        ApiConstants.refreshTokenKey,
        loginResponse.refreshToken,
      );
      await _storageService.saveUserData(
        jsonEncode(loginResponse.toUserModel().toJson()),
      );

      // Set auth token for future requests
      _apiService.setAuthToken(loginResponse.accessToken);

      // Notify successful auth
      _authStateController.add(true);

      return loginResponse.toUserModel();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid username or password');
      }
      throw Exception("Login failed: ${e.message}");
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final userData = await _storageService.getUserData();
      if (userData == null) return null;

      final userJson = jsonDecode(userData);
      final user = UserModel.fromJson(userJson);

      // Verify token exists
      final accessToken = await _storageService.getToken(
        ApiConstants.accessTokenKey,
      );
      if (accessToken != null) {
        _apiService.setAuthToken(accessToken);
        return user;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final userData = await getCurrentUser();
      if (userData != null) {
        // Try to call logout endpoint
        await _apiService.dio.post(
          ApiConstants.logoutEndpoint,
          queryParameters: {"userId": userData.userId},
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            // If logout API times out, continue with local cleanup
            return Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 200,
            );
          },
        );
      }
    } catch (e) {
      // Ignore errors during logout API call
      print('Logout API error (ignored): $e');
    } finally {
      // Always clear local data
      await _clearAuthData();
    }
  }

  Future<void> _clearAuthData() async {
    await _storageService.clearAll();
    _apiService.clearAuthToken();
    
    // Notify auth state change
    _authStateController.add(false);
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storageService.getToken(
        ApiConstants.refreshTokenKey,
      );
      if (refreshToken == null) return false;

      final response = await _apiService.dio.post(
        ApiConstants.refreshEndpoint,
        data: {"refreshToken": refreshToken},
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      // Save new tokens
      await _storageService.saveToken(
        ApiConstants.accessTokenKey,
        loginResponse.accessToken,
      );
      
      // Update refresh token if provided
      if (loginResponse.refreshToken.isNotEmpty) {
        await _storageService.saveToken(
          ApiConstants.refreshTokenKey,
          loginResponse.refreshToken,
        );
      }

      // Update user data if needed
      await _storageService.saveUserData(
        jsonEncode(loginResponse.toUserModel().toJson()),
      );

      _apiService.setAuthToken(loginResponse.accessToken);

      return true;
    } catch (e) {
      print('Token refresh failed: $e');
      // If refresh fails, clear auth data and notify
      await _clearAuthData();
      return false;
    }
  }

  // Check if tokens are valid
  Future<bool> isTokenValid() async {
    final accessToken = await _storageService.getToken(ApiConstants.accessTokenKey);
    final refreshToken = await _storageService.getToken(ApiConstants.refreshTokenKey);
    
    return accessToken != null && refreshToken != null;
  }

  // Manual token validation (optional - can be used for health checks)
  Future<bool> validateCurrentSession() async {
    try {
      // Make a simple API call to validate token
      await _apiService.dio.get('/auth/validate');
      return true;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _authStateController.close();
  }
}