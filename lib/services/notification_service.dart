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
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permissions');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional notification permissions');
    } else {
      debugPrint('User declined or has not accepted notification permissions');
    }

    // Get the initial token and save it
    await uploadToken();

    // Listen to token refresh
    _fcm.onTokenRefresh.listen((token) {
      debugPrint('FCM Token refreshed: $token');
      uploadToken();
    });

    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.notification?.title}');
      debugPrint('Payload: ${message.data}');
      // In-app logic is handled via P2P in PeerService, 
      // but we could show a snackbar or dialog here if needed.
    });

    // Handle message when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('App opened from notification in background: ${message.data}');
      _handleNotificationClick(message);
    });

    // Check if app was opened from a terminated state via notification
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from notification in terminated state: ${initialMessage.data}');
      _handleNotificationClick(initialMessage);
    }
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
      String? token;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        token = await _fcm.getAPNSToken();
        debugPrint('APNS Token: $token');
      }
      
      // Fallback/Standard FCM token
      token = await _fcm.getToken();
      
      if (token == null) {
        debugPrint('FCM Token is null, retrying in 5 seconds...');
        Future.delayed(const Duration(seconds: 5), () => uploadToken());
        return;
      }

      final userId = AuthService().currentUserId;
      if (userId == null) {
        debugPrint('User ID is null, cannot upload token yet');
        return;
      }

      await _firestore.collection('users').doc(userId).set({
        'fcmToken': token,
        'lastUpdated': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.toString().split('.').last,
      }, SetOptions(merge: true));
      
      debugPrint('FCM Token uploaded for user $userId: $token');
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
