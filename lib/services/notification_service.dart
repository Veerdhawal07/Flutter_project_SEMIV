import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import '../providers/auth_provider.dart';

final notificationServiceProvider = Provider((ref) => NotificationService(ref));

class NotificationService {
  final Ref _ref;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  NotificationService(this._ref);

  // IMPORTANT: For production, use Firebase Admin SDK on a backend server.
  // This legacy FCM API will be deprecated. Consider migrating to HTTP v1 API.
  static const String _fcmEndpoint = 'https://fcm.googleapis.com/fcm/send';

  // TODO: Replace with your actual Server Key from Firebase Console
  // (Project Settings -> Cloud Messaging -> Cloud Messaging API (Legacy))
  static const String _serverKey = 'YOUR_FIREBASE_SERVER_KEY';

  String _getCollection(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admins';
      case UserRole.officer:
        return 'officers';
      case UserRole.user:
        return 'users';
    }
  }

  Future<void> initialize() async {
    try {
      // Request permission for iOS/Android 13+
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get the token and save it to Firestore
        String? token = await _fcm.getToken();
        if (token != null) {
          _saveTokenToDatabase(token);
        }
      }
    } catch (e) {
      debugPrint('FCM Initialization Error: $e');
    }

    // Listen for token refreshes
    _fcm.onTokenRefresh.listen(_saveTokenToDatabase);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Logic for foreground notification if needed
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    });
  }

  Future<void> _saveTokenToDatabase(String token) async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final role = _ref.read(userRoleProvider);
        await _db.collection(_getCollection(role)).doc(uid).set({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Sends a notification to a specific user via their UID and Role
  Future<void> sendNotificationToUser(
    String uid,
    UserRole role,
    String title,
    String body,
  ) async {
    try {
      final userDoc = await _db.collection(_getCollection(role)).doc(uid).get();
      final token = userDoc.data()?['fcmToken'];

      if (token != null) {
        await _sendFCM(token, title, body);
      }
    } catch (e) {
      debugPrint('Error sending user notification: $e');
    }
  }

  /// Sends a notification to a topic (e.g., 'notices' or 'emergency')
  Future<void> sendNotificationToTopic(
    String topic,
    String title,
    String body,
  ) async {
    await _sendFCM('/topics/$topic', title, body);
  }

  Future<void> _sendFCM(String to, String title, String body) async {
    if (_serverKey == 'YOUR_FIREBASE_SERVER_KEY') {
      debugPrint('FCM Send skipped: Server Key not configured.');
      return;
    }

    // Note: Legacy FCM API. For production, use HTTP v1 API with OAuth2.
    try {
      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode({
          'to': to,
          'notification': {
            'title': title,
            'body': body,
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'sound': 'default',
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'type': 'complaint_update',
          },
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('FCM Error Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('FCM Send Error: $e');
    }
  }
}
