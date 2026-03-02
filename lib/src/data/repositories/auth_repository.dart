import 'package:dio/dio.dart';
import '../api_client.dart';
import 'token_storage.dart';

/// Result of OTP verification.
class OtpVerifyResult {
  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final bool isNewUser;
  final String? fullName;
  final String? error;

  const OtpVerifyResult({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.isNewUser = false,
    this.fullName,
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
  /// Hits POST /api/otp/send.
  /// Throws exception on failure.
  Future<void> requestOtp(String phoneNumber) async {
    try {
      final cleanPhone = phoneNumber.replaceAll(' ', '');

      final response = await _client.post(
        'otp/send/',
        data: {'phone_number': cleanPhone},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // In dev mode the server returns the OTP code for easy testing
        final otpCode = response.data?['otp_code'];
        if (otpCode != null) {
          // ignore: avoid_print
          print('[DEV] OTP code: $otpCode');
        }
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
  /// Hits POST /api/otp/verify.
  /// [fullName] is optional — sent for new users registering via Sign Up.
  /// Returns tokens and user info on success.
  /// Throws exception on failure.
  Future<OtpVerifyResult> verifyOtp(
    String phoneNumber,
    String code, {
    String? fullName,
  }) async {
    try {
      final cleanPhone = phoneNumber.replaceAll(' ', '');

      final body = <String, dynamic>{'phone_number': cleanPhone, 'code': code};
      if (fullName != null && fullName.trim().isNotEmpty) {
        body['full_name'] = fullName.trim();
      }

      final response = await _client.post('otp/verify/', data: body);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>?;
        final tokens = data?['tokens'] as Map<String, dynamic>?;
        final accessToken = tokens?['access'] as String?;
        final refreshToken = tokens?['refresh'] as String?;
        final isNewUser = data?['is_new_user'] as bool? ?? false;
        final userMap = data?['user'] as Map<String, dynamic>?;
        final returnedName =
            userMap?['full_name'] as String? ??
            userMap?['name'] as String? ??
            fullName;

        // Save tokens if present
        if (accessToken != null && refreshToken != null) {
          await _tokenStorage.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
          _client.setAuthToken(accessToken);
          await _tokenStorage.saveUserInfo(
            phone: cleanPhone,
            fullName: returnedName,
          );
        }

        return OtpVerifyResult(
          success: true,
          accessToken: accessToken,
          refreshToken: refreshToken,
          isNewUser: isNewUser,
          fullName: returnedName,
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
        'v1/me/',
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

  /// Refresh the access token using the stored refresh token.
  /// Returns true if successful, false otherwise.
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _client.post(
        'token/refresh/',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data?['access'] as String?;
        if (newAccessToken != null) {
          await _tokenStorage.saveAccessToken(newAccessToken);
          _client.setAuthToken(newAccessToken);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
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

        if (data is Map<String, dynamic>) {
          if (statusCode == 429) {
            // Rate limited
            errorMessage =
                data['error']?.toString() ??
                data['detail']?.toString() ??
                data['message']?.toString() ??
                'Too many requests. Please wait.';
          } else if (statusCode == 400) {
            final phoneErr = data['phone_number'];
            errorMessage =
                data['error']?.toString() ??
                data['detail']?.toString() ??
                data['message']?.toString() ??
                (phoneErr is List ? phoneErr.first.toString() : null) ??
                'Invalid request';
          } else {
            errorMessage =
                data['error']?.toString() ??
                data['detail']?.toString() ??
                data['message']?.toString() ??
                'Server error ($statusCode)';
          }
        } else if (data is String && data.trim().isNotEmpty) {
          errorMessage = data;
        } else {
          errorMessage = 'Server error ($statusCode)';
        }
        break;
      default:
        errorMessage = 'Network error. Please try again.';
    }

    if (errorMessage.trim().isEmpty) {
      errorMessage = 'An unknown error occurred.';
    }

    return errorMessage;
  }
}
