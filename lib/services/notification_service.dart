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
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permissions');
    }

    // Get the token and save it
    await uploadToken();

    // Listen to token refresh
    _fcm.onTokenRefresh.listen((token) => uploadToken());

    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.notification?.title}');
      // We can trigger a local notification or show a dialog here
    });

    // Handle message when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('App opened from notification: ${message.data}');
      _handleNotificationClick(message);
    });

    // Check if app was opened from a terminated state via notification
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage);
    }
  }

  void _handleNotificationClick(RemoteMessage message) {
    if (message.data['type'] == 'invite') {
      // Navigate to lobby to see the invite
      // We use the global appRouter for navigation
      appRouter.go('/lobby');
    }
  }

  Future<void> uploadToken() async {
    try {
      String? token = await _fcm.getToken();
      if (token == null) return;

      final userId = AuthService().currentUserId;
      if (userId == null) return;

      await _firestore.collection('users').doc(userId).set({
        'fcmToken': token,
        'lastUpdated': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.toString(),
      }, SetOptions(merge: true));
      
      debugPrint('FCM Token uploaded for user $userId');
    } catch (e) {
      debugPrint('Error uploading FCM token: $e');
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
