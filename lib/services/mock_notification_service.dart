import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MockNotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Initialize the notification service
  Future<void> init() async {
    if (_initialized) return;

    try {
      // Initialize local notifications
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iOSSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iOSSettings,
      );
      
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      _initialized = true;
      print('Mock notification service initialized');
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Handle notification tap here
  }

  // Show a local notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) {
      await init();
    }

    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'loyalty_wallet_channel',
        'Loyalty Wallet Notifications',
        channelDescription: 'Notifications from Loyalty Wallet app',
        importance: Importance.high,
        priority: Priority.high,
      );
      
      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );
      
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  // Schedule a notification for later
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_initialized) {
      await init();
    }

    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'loyalty_wallet_scheduled_channel',
        'Loyalty Wallet Scheduled Notifications',
        channelDescription: 'Scheduled notifications from Loyalty Wallet app',
        importance: Importance.high,
        priority: Priority.high,
      );
      
      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );
      
      await _localNotifications.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        scheduledDate as dynamic, // This is simplified, ideally use tz.TZDateTime
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_initialized) {
      await init();
    }
    
    try {
      await _localNotifications.cancelAll();
    } catch (e) {
      print('Error canceling notifications: $e');
    }
  }
} 