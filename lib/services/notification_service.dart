import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kinetic_tictactoe/services/auth_service.dart';
import 'package:kinetic_tictactoe/router/app_router.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const String _oneSignalAppId = "2fa14c8e-e15b-4e42-b29b-7db77ea0689d";

  Future<void> init() async {
    // Initialize Local Notifications (Fallback for iOS/Terminated apps)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle click on local notification
        appRouter.push('/lobby');
      },
    );

    // Initial ID Sync if already logged in (Don't await to avoid blocking)
    syncPlayerId();

    // OneSignal is only for Android in this setup (or iOS with dev account)
    if (Platform.isAndroid) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize(_oneSignalAppId);
      OneSignal.Notifications.requestPermission(true);

      OneSignal.Notifications.addClickListener((event) {
        _handleNotificationClick(event.notification);
      });
    } else if (Platform.isIOS) {
      // For iOS without Dev Account, we rely entirely on Local Notifications 
      // triggered via the PeerService (WebRTC) channel.
      debugPrint('iOS: Relying on Local Notifications fallback');
    }
  }

  Future<void> syncPlayerId() async {
    final userId = AuthService().currentUserId;
    if (userId == null) return;

    if (Platform.isAndroid) {
      try {
        await OneSignal.login(userId).timeout(const Duration(seconds: 5));
        debugPrint('Logged into OneSignal as $userId');
      } catch (e) {
        debugPrint('OneSignal login failed: $e');
      }
    }
  }

  void _handleNotificationClick(OSNotification notification) {
    debugPrint('OneSignal notification clicked');
    appRouter.push('/lobby');
  }

  /// Triggers a local popup notification.
  /// Used for iOS fallback when an invite is received via WebRTC.
  Future<void> showLocalNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'kinetic_invites',
      'Game Invites',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const DarwinNotificationDetails darwinPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
    );
    
    await _localNotifications.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> sendInviteNotification(String targetUserId, String fromUsername) async {
    // Write to Firestore so we have a record. 
    // This could also trigger a Cloud Function if you ever upgrade to Blaze.
    await _firestore.collection('notifications').add({
      'to': targetUserId,
      'from': fromUsername,
      'type': 'invite',
      'createdAt': FieldValue.serverTimestamp(),
      'provider': 'onesignal',
    });
    
    debugPrint('Invite notification record created for $targetUserId');
  }
}
