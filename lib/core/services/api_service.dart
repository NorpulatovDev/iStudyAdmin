import 'package:dio/dio.dart';
import 'package:istudyadmin/core/constants/api_constants.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {"Content-Type": "application/json"},
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Dio get dio => _dio;

  void setAuthToken(String token) {
    _dio.options.headers["Authorization"] = "Bearer $token";
  }

  void clearAuthToken() {
    _dio.options.headers.remove("Authorization");
  }
}
