// lib/core/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  factory NotificationService() => _instance;

  NotificationService._internal();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );
    
    await _notifications.initialize(initializationSettings);
  }

  Future<void> showSuccessNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'drawing_channel',
      'Drawing Notifications',
      channelDescription: 'Notifications for drawing app',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      enableVibration: true,
      playSound: true,
    );
    
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    
    await _notifications.show(
      0,
      'Рисунок сохранён',
      'Ваш рисунок успешно сохранён в галерею!',
      platformDetails,
      payload: 'drawing_saved',
    );
  }

  Future<void> showErrorNotification(String message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'drawing_channel',
      'Drawing Notifications',
      channelDescription: 'Error notifications for drawing app',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );
    
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    
    await _notifications.show(
      1,
      'Ошибка сохранения',
      message,
      platformDetails,
      payload: 'drawing_error',
    );
  }
}