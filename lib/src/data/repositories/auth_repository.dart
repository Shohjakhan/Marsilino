import 'package:dio/dio.dart';
import '../api_client.dart';
import 'token_storage.dart';

/// Result of OTP verification.
class OtpVerifyResult {
  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final bool isNewUser;
  final String? error;

  const OtpVerifyResult({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.isNewUser = false,
    this.error,
  });
}

/// Result of profile update.
class UpdateProfileResult {
  final bool success;
  final String? error;

  const UpdateProfileResult({required this.success, this.error});
}

/// Repository for authentication operations.
class AuthRepository {
  final ApiClient _client;
  final TokenStorage _tokenStorage;

  AuthRepository({ApiClient? client, TokenStorage? tokenStorage})
    : _client = client ?? ApiClient.instance,
      _tokenStorage = tokenStorage ?? TokenStorage.instance;

  /// Request OTP for phone number.
  /// Returns success/error result.
  /// Request OTP for phone number.
  /// Throws exception on failure.
  Future<void> requestOtp(String phoneNumber) async {
    try {
      // Clean phone number - remove spaces and ensure format
      final cleanPhone = phoneNumber.replaceAll(' ', '');

      final response = await _client.post(
        '/auth/request-otp/',
        data: {'phone_number': cleanPhone},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      throw Exception(response.data?['error'] ?? 'Failed to send OTP');
    } on DioException catch (e) {
      throw Exception(_getDioErrorMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Verify OTP code.
  /// Returns tokens and user info on success.
  /// Throws exception on failure.
  Future<OtpVerifyResult> verifyOtp(String phoneNumber, String code) async {
    try {
      final cleanPhone = phoneNumber.replaceAll(' ', '');

      final response = await _client.post(
        '/auth/verify-otp/',
        data: {'phone_number': cleanPhone, 'code': code},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final accessToken = data?['access'] as String?;
        final refreshToken = data?['refresh'] as String?;
        final isNewUser = data?['is_new_user'] ?? false;

        // Save tokens if present
        if (accessToken != null && refreshToken != null) {
          await _tokenStorage.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
          // Set auth header for future requests
          _client.setAuthToken(accessToken);
          // Save phone
          await _tokenStorage.saveUserInfo(phone: cleanPhone);
        }

        return OtpVerifyResult(
          success: true,
          accessToken: accessToken,
          refreshToken: refreshToken,
          isNewUser: isNewUser,
        );
      }

      throw Exception(response.data?['error'] ?? 'Failed to verify OTP');
    } on DioException catch (e) {
      throw Exception(_getDioErrorMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Update user profile (full name).
  Future<UpdateProfileResult> updateProfile({required String fullName}) async {
    try {
      final response = await _client.patch(
        '/me/',
        data: {'full_name': fullName},
      );

      if (response.statusCode == 200) {
        // Save name locally
        await _tokenStorage.saveUserInfo(fullName: fullName);
        return const UpdateProfileResult(success: true);
      }

      throw Exception(response.data?['error'] ?? 'Failed to update profile');
    } on DioException catch (e) {
      throw Exception(_getDioErrorMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Logout - clear tokens.
  Future<void> logout() async {
    await _tokenStorage.clear();
    _client.clearAuthToken();
  }

  /// Check if user is logged in.
  Future<bool> isLoggedIn() async {
    final isLogged = await _tokenStorage.isLoggedIn();
    if (isLogged) {
      // Restore auth header
      final token = await _tokenStorage.getAccessToken();
      if (token != null) {
        _client.setAuthToken(token);
      }
    }
    return isLogged;
  }

  String _getDioErrorMessage(DioException e) {
    String errorMessage;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Connection timeout. Please check your internet.';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'Unable to connect to server. Please try again.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        if (statusCode == 429) {
          // Rate limited
          errorMessage = data?['error'] ?? 'Too many requests. Please wait.';
        } else if (statusCode == 400) {
          errorMessage =
              data?['error'] ?? data?['phone_number']?[0] ?? 'Invalid request';
        } else {
          errorMessage = data?['error'] ?? 'Server error ($statusCode)';
        }
        break;
      default:
        errorMessage = 'Network error. Please try again.';
    }

    return errorMessage;
  }
}
