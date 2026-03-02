import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../data/api_client.dart';
import '../../data/repositories/token_storage.dart';

/// Service to handle Firebase Push Notifications.
class FirebasePushService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final TokenStorage _tokenStorage = TokenStorage.instance;

  /// Initialize Firebase and Push Service.
  Future<void> initialize() async {
    // Request permission for iOS/Web
    await _requestPermission();

    // Get and save token (with iOS APNS handling)
    final token = await _getTokenSafely();
    if (token != null) {
      if (kDebugMode) {
        print('FCM Token: $token');
      }
      await _tokenStorage.saveFcmToken(token);
      await _registerDeviceOnBackend(token);
    }

    // Listen to token refresh — save locally and send to backend
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      await _tokenStorage.saveFcmToken(newToken);
      await _registerDeviceOnBackend(newToken);
    });

    // Setup message handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Send FCM token to the backend so it can target this device.
  ///
  /// Endpoint: `POST /v1/me/device`
  /// Payload: `{ "fcm_token": "...", "device_type": "ios" | "android" }`
  Future<void> _registerDeviceOnBackend(String fcmToken) async {
    try {
      final deviceType =
          defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS
          ? 'ios'
          : 'android';

      await ApiClient.instance.post(
        '/v1/me/device',
        data: {'fcm_token': fcmToken, 'device_type': deviceType},
      );

      if (kDebugMode) {
        print('FCM token registered on backend ($deviceType)');
      }
    } catch (e) {
      // Non-critical — don't crash the app if registration fails.
      // The token will be retried on next app launch or refresh.
      if (kDebugMode) {
        print('Failed to register FCM token on backend: $e');
      }
    }
  }

  /// Get FCM token safely, handling iOS APNS token availability.
  Future<String?> _getTokenSafely() async {
    // On iOS, we need to wait for APNS token before getting FCM token
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      // Wait for APNS token with retries
      String? apnsToken;
      for (int i = 0; i < 5; i++) {
        apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken != null) break;
        // Wait before retrying
        await Future.delayed(const Duration(seconds: 1));
      }

      if (apnsToken == null) {
        if (kDebugMode) {
          print('Warning: APNS token not available after retries');
        }
        return null;
      }
    }

    return await _firebaseMessaging.getToken();
  }

  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      print('User granted permission: ${settings.authorizationStatus}');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
    }

    if (message.notification != null) {
      if (kDebugMode) {
        print('Message also contained a notification: ${message.notification}');
      }
    }
  }
}

/// Top-level background handler.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `Firebase.initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  if (kDebugMode) {
    print('Handling a background message: ${message.messageId}');
  }
}
