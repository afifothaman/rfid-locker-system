import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request notification permission
    await Permission.notification.request();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );
  }

  Future<void> showAccessNotification({
    required String title,
    required String body,
    required bool isSuccess,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'access_channel',
      'Access Notifications',
      channelDescription: 'Notifications for locker access events',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      isSuccess ? 1 : 2,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> showAccessSuccess({
    required String lockerName,
    required DateTime timestamp,
  }) async {
    await showAccessNotification(
      title: 'Access Granted',
      body: 'Successfully accessed $lockerName at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
      isSuccess: true,
    );
  }

  Future<void> showAccessDenied({
    required String reason,
    required DateTime timestamp,
  }) async {
    await showAccessNotification(
      title: 'Access Denied',
      body: 'Access denied: $reason at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
      isSuccess: false,
    );
  }
}