import 'package:dio/dio.dart';
import '../api_client.dart';
import '../models/user_model.dart';
import 'token_storage.dart';

class UserRepository {
  final ApiClient _client;
  final TokenStorage _tokenStorage;

  UserRepository({ApiClient? client, TokenStorage? tokenStorage})
    : _client = client ?? ApiClient.instance,
      _tokenStorage = tokenStorage ?? TokenStorage.instance;

  Future<UserModel> getMe() async {
    try {
      final response = await _client.get('/me/');
      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data);
        // Update local storage if needed, but primarily return the fresh user
        if (user.fullName != null) {
          await _tokenStorage.saveUserInfo(fullName: user.fullName);
        }
        await _tokenStorage.saveUserInfo(phone: user.phoneNumber);
        return user;
      }
      throw Exception('Failed to load user profile');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token might be expired
        throw Exception('Session expired');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Updates the user's profile with the given [fullName].
  /// Returns the updated [UserModel] on success.
  /// Throws an [Exception] on failure.
  Future<UserModel> updateProfile({required String fullName}) async {
    try {
      final response = await _client.patch(
        '/me/',
        data: {'full_name': fullName},
      );
      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data);
        // Update local storage
        await _tokenStorage.saveUserInfo(fullName: user.fullName);
        return user;
      }
      throw Exception('Failed to update profile');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired');
      }
      final message = e.response?.data?['detail'] ?? e.message;
      throw Exception('Failed to update: $message');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
