import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging messaging =
      FirebaseMessaging.instance;

  static late AndroidNotificationChannel channel;

  static bool isFlutterLocalNotificationsInitialized = false;

  static late FlutterLocalNotificationsPlugin
  flutterLocalNotificationsPlugin;

  // ------------------------------------------------------------
  // BACKGROUND MESSAGE HANDLER
  // ------------------------------------------------------------

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message,
      ) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await setupFlutterNotifications();

    log(
      'Handling background message: ${message.messageId}',
    );
  }

  // ------------------------------------------------------------
  // SETUP FLUTTER LOCAL NOTIFICATIONS
  // ------------------------------------------------------------

  static Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }

    channel = const AndroidNotificationChannel(
      'todo_high_importance_channel',
      'Todo Notifications',
      description:
      'This channel is used for Todo reminder notifications.',
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // Android notification channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // iOS foreground notification
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    isFlutterLocalNotificationsInitialized = true;
  }

  // ------------------------------------------------------------
  // INITIALIZE FIREBASE MESSAGING
  // ------------------------------------------------------------

  static Future<void> init() async {
    // Notification permission
    final NotificationSettings settings =
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    log(
      'Notification permission: ${settings.authorizationStatus}',
    );

    // Local notification setup
    if (!kIsWeb) {
      await setupFlutterNotifications();
    }

    // Get FCM Token
    // final String? token = await messaging.getToken();
    //
    // log('FCM TOKEN: $token');

    final String? token = await messaging.getToken();

    log('FCM TOKEN: $token');

    final user = FirebaseAuth.instance.currentUser;

    if (user != null && token != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('fcmTokens')
          .doc(token)
          .set({
        'token': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    // Token refresh
    // messaging.onTokenRefresh.listen(
    //       (String newToken) {
    //     log('FCM TOKEN UPDATED: $newToken');
    //   },
    // );
    messaging.onTokenRefresh.listen(
          (String newToken) async {
        log('FCM TOKEN UPDATED: $newToken');

        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('fcmTokens')
              .doc(newToken)
              .set({
            'token': newToken,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      },
    );

    // Foreground message
    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) {
        log(
          'Foreground message received: '
              '${message.messageId}',
        );

        showFlutterNotification(message);
      },
    );

    // When user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen(
          (RemoteMessage message) {
        log(
          'Notification opened: '
              '${message.messageId}',
        );
      },
    );

    // When app was terminated and opened from notification
    final RemoteMessage? initialMessage =
    await messaging.getInitialMessage();

    if (initialMessage != null) {
      log(
        'App opened from notification: '
            '${initialMessage.messageId}',
      );
    }
  }

  // ------------------------------------------------------------
  // SHOW FCM NOTIFICATION
  // ------------------------------------------------------------

  static Future<void> showFlutterNotification(
      RemoteMessage message,
      ) async {
    final RemoteNotification? notification =
        message.notification;

    final AndroidNotification? android =
        message.notification?.android;

    if (notification != null &&
        android != null &&
        !kIsWeb) {
      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    }
  }
}