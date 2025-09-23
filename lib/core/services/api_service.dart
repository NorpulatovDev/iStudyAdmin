import 'package:dio/dio.dart';
import 'package:istudyadmin/core/constants/api_constants.dart';
import 'storage_service.dart';

class ApiService {
  late final Dio _dio;
  final StorageService _storageService;
  bool _isRefreshing = false;
  final List<RequestOptions> _failedQueue = [];

  ApiService(this._storageService) {
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

    // Add token refresh interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to every request if available
          final token = await _storageService.getToken(ApiConstants.accessTokenKey);
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 unauthorized errors
          if (error.response?.statusCode == 401 && !_isRefreshing) {
            final originalRequest = error.requestOptions;
            
            // Don't retry if it's already a login or refresh request
            if (originalRequest.path.contains('/auth/login') || 
                originalRequest.path.contains('/auth/refresh')) {
              handler.next(error);
              return;
            }

            // Try to refresh token
            final refreshed = await _refreshTokenAndRetry();
            
            if (refreshed) {
              // Retry original request with new token
              try {
                final token = await _storageService.getToken(ApiConstants.accessTokenKey);
                originalRequest.headers["Authorization"] = "Bearer $token";
                
                final response = await _dio.fetch(originalRequest);
                handler.resolve(response);
                
                // Process queued requests
                _processFailedQueue(true);
              } catch (e) {
                _processFailedQueue(false);
                handler.next(error);
              }
            } else {
              // Refresh failed, clear tokens and redirect to login
              await _handleAuthFailure();
              _processFailedQueue(false);
              handler.next(DioException(
                requestOptions: originalRequest,
                error: 'Authentication failed. Please login again.',
                type: DioExceptionType.cancel,
              ));
            }
          } else if (error.response?.statusCode == 401 && _isRefreshing) {
            // If refresh is in progress, queue the request
            _failedQueue.add(error.requestOptions);
            return;
          } else {
            handler.next(error);
          }
        },
      ),
    );
  }

  Dio get dio => _dio;

  void setAuthToken(String token) {
    _dio.options.headers["Authorization"] = "Bearer $token";
  }

  void clearAuthToken() {
    _dio.options.headers.remove("Authorization");
  }

  Future<bool> _refreshTokenAndRetry() async {
    if (_isRefreshing) return false;
    
    _isRefreshing = true;
    
    try {
      final refreshToken = await _storageService.getToken(ApiConstants.refreshTokenKey);
      if (refreshToken == null) {
        return false;
      }

      // Create a new Dio instance without interceptors for refresh request
      final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      
      final response = await refreshDio.post(
        ApiConstants.refreshEndpoint,
        data: {"refreshToken": refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newAccessToken = data['accessToken'] as String;
        final newRefreshToken = data['refreshToken'] as String?;

        // Save new tokens
        await _storageService.saveToken(ApiConstants.accessTokenKey, newAccessToken);
        if (newRefreshToken != null) {
          await _storageService.saveToken(ApiConstants.refreshTokenKey, newRefreshToken);
        }

        // Update the main dio instance
        setAuthToken(newAccessToken);
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Token refresh failed: $e');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _handleAuthFailure() async {
    // Clear all stored tokens and user data
    await _storageService.clearAll();
    clearAuthToken();
    
    // You might want to emit an event here to notify the app about auth failure
    // This could trigger a navigation to login screen
  }

  void _processFailedQueue(bool success) {
    if (success) {
      // Retry all queued requests
      for (final request in _failedQueue) {
        _dio.fetch(request).catchError((error) {
          // Handle individual request failures
          print('Queued request failed: $error');
        });
      }
    }
    _failedQueue.clear();
  }

  // Method to manually refresh token (can be called from repository)
  Future<bool> refreshToken() async {
    return await _refreshTokenAndRetry();
  }
}