import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kinetic_tictactoe/services/auth_service.dart';
import 'package:kinetic_tictactoe/router/app_router.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> init() async {
    // Request permission for iOS/Android 13+
    try {
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      ).timeout(const Duration(seconds: 8));
      debugPrint('FCM permissions handled');
    } catch (e) {
      debugPrint('FCM permission request failed or timed out: $e');
    }

    // Don't await uploadToken here to avoid blocking app startup
    uploadToken();

    // Listen to token refresh
    _fcm.onTokenRefresh.listen((token) {
      debugPrint('FCM Token refreshed: $token');
      uploadToken();
    });

    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.notification?.title}');
    });

    // Handle message when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });

    // Check if app was opened from a terminated state via notification
    _fcm.getInitialMessage().then((initialMessage) {
      if (initialMessage != null) {
        _handleNotificationClick(initialMessage);
      }
    });
  }

  void _handleNotificationClick(RemoteMessage message) {
    final type = message.data['type'];
    debugPrint('Handling notification click of type: $type');
    
    if (type == 'invite') {
      // Navigate to lobby to see the invite
      // Ensure we are not already on the lobby or in a game
      appRouter.push('/lobby');
    }
  }

  Future<void> uploadToken() async {
    try {
      final userId = AuthService().currentUserId;
      if (userId == null) return;

      String? fcmToken;
      
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // Must fetch APNS token first on iOS
        final apnsToken = await _fcm.getAPNSToken().timeout(
          const Duration(seconds: 5),
          onTimeout: () => null,
        );
        debugPrint('iOS APNS Token: $apnsToken');
      }
      
      // Get main FCM token
      fcmToken = await _fcm.getToken().timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
      
      if (fcmToken == null) {
        debugPrint('FCM Token retrieval timed out or failed. Will retry later.');
        return;
      }

      await _firestore.collection('users').doc(userId).set({
        'fcmToken': fcmToken,
        'lastUpdated': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.toString().split('.').last,
      }, SetOptions(merge: true));
      
      debugPrint('FCM Token synced for user $userId');
    } catch (e) {
      debugPrint('Error in uploadToken: $e');
    }
  }

  /// Sends a push notification request by writing to a Firestore collection.
  /// This assumes a Cloud Function is listening to this collection to actually send the push.
  Future<void> sendInviteNotification(String targetUserId, String fromUsername) async {
    await _firestore.collection('notifications').add({
      'to': targetUserId,
      'from': fromUsername,
      'type': 'invite',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
