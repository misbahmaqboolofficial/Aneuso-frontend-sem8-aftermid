import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class LocalNotificationService {
  static Future<void> initialize() async {
    debugPrint('LocalNotificationService: Initializing Web Notifications...');
    if (html.Notification.permission != 'granted') {
      await html.Notification.requestPermission();
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    debugPrint('LocalNotificationService (Web): $title - $body');
    if (html.Notification.permission == 'granted') {
      html.Notification(title, body: body);
    } else {
      debugPrint('Web Notification permission not granted.');
    }
  }
}
