import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:loyalty_wallet/models/loyalty_card.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();
    
    // Request notification permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // Local notifications setup
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
        
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(initSettings);
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(
        title: message.notification?.title ?? 'New Notification',
        body: message.notification?.body ?? '',
      );
    });
  }

  Future<void> scheduleExpirationNotification(LoyaltyCard card) async {
    if (card.expiryDate == null) return;
    
    // Schedule notification 3 days before expiration
    final expiryDate = card.expiryDate!.subtract(const Duration(days: 3));
    
    // Don't schedule if date is in the past
    if (expiryDate.isBefore(DateTime.now())) return;
    
    // Convert DateTime to TZDateTime
    final scheduledDate = tz.TZDateTime.from(expiryDate, tz.local);
    
    final androidDetails = const AndroidNotificationDetails(
      'expiration_channel',
      'Card Expiration',
      channelDescription: 'Notifications about expiring loyalty cards',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    final iosDetails = const DarwinNotificationDetails();
    
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      card.id.hashCode,
      'Card Expiring Soon',
      '${card.name} loyalty card will expire in 3 days!',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
  
  Future<void> cancelNotification(LoyaltyCard card) async {
    await _flutterLocalNotificationsPlugin.cancel(card.id.hashCode);
  }
  
  Future<void> _showNotification({
    required String title,
    required String body,
  }) async {
    final androidDetails = const AndroidNotificationDetails(
      'default_channel',
      'Default',
      channelDescription: 'Default notification channel',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    final iosDetails = const DarwinNotificationDetails();
    
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
    );
  }
}

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Need to ensure Firebase is initialized here if using Firebase services
}
