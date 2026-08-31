import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // ------------------------------------------------------------
  // INITIALIZE NOTIFICATION
  // ------------------------------------------------------------

  static Future<void> initNotification() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Android
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
      requestSoundPermission: true,
    );

    // Combine Android + iOS
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    final bool? initialized =
    await notificationsPlugin.initialize(
      initializationSettings,
    );

    // Android permissions
    final androidPlugin =
    notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    await androidPlugin?.requestExactAlarmsPermission();

    log('Notifications initialized: $initialized');
  }

  // ------------------------------------------------------------
  // SHOW IMMEDIATE NOTIFICATION
  // ------------------------------------------------------------

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'tasklist_notification',
      'TodoList Notification',
      priority: Priority.max,
      importance: Importance.max,
    );

    const DarwinNotificationDetails iosDetails =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await notificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  // ------------------------------------------------------------
  // SCHEDULE NOTIFICATION
  // ------------------------------------------------------------

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduleTime,
  }) async {
    // Don't schedule past notification
    if (scheduleTime.isBefore(DateTime.now())) {
      log(
        'Notification not scheduled because time has passed: '
            '$scheduleTime',
      );
      return;
    }

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'tasklist_notification',
      'TodoList Notification',
      priority: Priority.max,
      importance: Importance.high,
    );

    const DarwinNotificationDetails iosDetails =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(
        scheduleTime,
        tz.local,
      ),
      notificationDetails,
      androidScheduleMode:
      AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    log(
      'Notification scheduled: '
          'id=$id, time=$scheduleTime',
    );
  }

  // ------------------------------------------------------------
  // CANCEL NOTIFICATION
  // ------------------------------------------------------------

  static Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);

    log('Notification cancelled: $id');
  }

  // ------------------------------------------------------------
  // CANCEL ALL NOTIFICATIONS
  // ------------------------------------------------------------

  static Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();

    log('All notifications cancelled');
  }
}




