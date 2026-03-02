import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'repositories/token_storage.dart';

/// HTTP client wrapper using Dio.
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiUrl,
        connectTimeout: Duration(seconds: AppConfig.requestTimeout),
        receiveTimeout: Duration(seconds: AppConfig.requestTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor in debug mode
    if (AppConfig.debugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true, error: true),
      );
    }

    // Add token refresh interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Attempt to refresh token
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              // Retry the original request with the new token
              final token = await TokenStorage.instance.getAccessToken();
              if (token != null) {
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                try {
                  final response = await _dio.fetch(error.requestOptions);
                  return handler.resolve(response);
                } catch (e) {
                  return handler.next(error);
                }
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Attempt to refresh the access token using the stored refresh token.
  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await TokenStorage.instance.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio(
        BaseOptions(baseUrl: AppConfig.apiUrl),
      ).post('token/refresh/', data: {'refresh': refreshToken});

      if (response.statusCode == 200) {
        final newAccessToken = response.data?['access'] as String?;
        if (newAccessToken != null) {
          await TokenStorage.instance.saveAccessToken(newAccessToken);
          setAuthToken(newAccessToken);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get singleton instance.
  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  /// Get the Dio instance.
  Dio get dio => _dio;

  /// Set authorization token.
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear authorization token.
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// POST request.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PATCH request.
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
