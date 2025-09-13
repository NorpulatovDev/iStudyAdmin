import 'dart:convert';

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

  const AuthRepository(this._apiService, this._storageService);

  Future<UserModel> login(String username, String password) async {
    try {
      final request = LoginRequest(username: username, password: password);

      final response = await _apiService.dio.post(
        ApiConstants.loginEndpoint,
        data: request.toJson(),
      );
      final loginResponse = LoginResponse.fromJson(response.data);
      // CHECK if user is SUPER_ADMIN
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

      // Set auth Token
      final accessToken = await _storageService.getToken(
        ApiConstants.accessTokenKey,
      );
      if (accessToken != null) {
        _apiService.setAuthToken(accessToken);
      }

      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final userData = await getCurrentUser();
      if (userData != null) {
        await _apiService.dio.post(
          ApiConstants.logoutEndpoint,
          queryParameters: {"userId": userData.userId},
        );
      }
    } catch (e) {
      //Ignore errors during logout API call
    } finally {
      await _storageService.clearAll();
      _apiService.clearAuthToken();
    }
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

      // Save new access token
      await _storageService.saveToken(
        ApiConstants.accessTokenKey,
        loginResponse.accessToken,
      );
      _apiService.setAuthToken(loginResponse.accessToken);

      return true;
    } catch (e) {
      return false;
    }
  }
}
