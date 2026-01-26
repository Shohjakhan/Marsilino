import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for authentication tokens.
class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _userPhoneKey = 'user_phone';
  static const _userNameKey = 'user_name';
  static const _fcmTokenKey = 'fcm_token';

  static TokenStorage? _instance;
  late final FlutterSecureStorage _storage;

  TokenStorage._() {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
  }

  /// Get singleton instance.
  static TokenStorage get instance {
    _instance ??= TokenStorage._();
    return _instance!;
  }

  /// Save access token.
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Get access token.
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Save refresh token.
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Get refresh token.
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Save both tokens.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  /// Save user info.
  Future<void> saveUserInfo({
    String? userId,
    String? phone,
    String? fullName,
  }) async {
    final saves = <Future>[];
    if (userId != null) {
      saves.add(_storage.write(key: _userIdKey, value: userId));
    }
    if (phone != null) {
      saves.add(_storage.write(key: _userPhoneKey, value: phone));
    }
    if (fullName != null) {
      saves.add(_storage.write(key: _userNameKey, value: fullName));
    }
    await Future.wait(saves);
  }

  /// Get user phone.
  Future<String?> getUserPhone() async {
    return await _storage.read(key: _userPhoneKey);
  }

  /// Get user name.
  Future<String?> getUserName() async {
    return await _storage.read(key: _userNameKey);
  }

  /// Check if user is logged in.
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Save FCM token.
  Future<void> saveFcmToken(String token) async {
    await _storage.write(key: _fcmTokenKey, value: token);
  }

  /// Get FCM token.
  Future<String?> getFcmToken() async {
    return await _storage.read(key: _fcmTokenKey);
  }

  /// Clear all stored data (logout).
  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
