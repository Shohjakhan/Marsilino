import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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
    }

    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen(_tokenStorage.saveFcmToken);

    // Setup message handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
