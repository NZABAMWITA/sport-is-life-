import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;
  static Function(String? payload)? _onNotificationTapCallback;

  // ✅ Initialize with callback for navigation
  static Future<void> initialize(
      {Function(String? payload)? onNotificationTap}) async {
    if (_isInitialized) return;

    _onNotificationTapCallback = onNotificationTap;

    // Initialize timezone
    tz.initializeTimeZones();

    // Request permissions
    await _requestPermissions();

    // Initialize local notifications
    await _initLocalNotifications();

    // ✅ Initialize push notifications (FCM)
    await _initPushNotifications();

    _isInitialized = true;
    print('✅ Notification Service initialized with push support');
  }

  // ✅ Request notification permissions
  static Future<void> _requestPermissions() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Push notifications authorized');
    } else {
      print('⚠️ Push notifications not authorized');
    }
  }

  // ✅ Initialize local notifications
  static Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTap,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      const channels = [
        AndroidNotificationChannel(
          'sport_is_life_channel',
          'Sport Is Life Notifications',
          description: 'Notifications for workouts, quotes, and reminders',
          importance: Importance.high,
        ),
        AndroidNotificationChannel(
          'daily_quote_channel',
          'Daily Motivation',
          description: 'Daily motivational quotes',
          importance: Importance.high,
        ),
        AndroidNotificationChannel(
          'streak_channel',
          'Streak Reminder',
          description: 'Reminders to maintain your workout streak',
          importance: Importance.high,
        ),
        AndroidNotificationChannel(
          'push_notifications_channel',
          'Push Notifications',
          description: 'Notifications from coaches and admins',
          importance: Importance.high,
        ),
      ];

      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      for (var channel in channels) {
        await androidPlugin?.createNotificationChannel(channel);
      }
    }

    print('✅ Local notifications initialized');
  }

  // ✅ Initialize push notifications (FCM)
  static Future<void> _initPushNotifications() async {
    // Get and log FCM token
    String? token = await _fcm.getToken();
    print('📱 FCM Token: $token');

    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Handle messages when app is opened from terminated state
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // ✅ Handle foreground messages (app is open)
  static void _onForegroundMessage(RemoteMessage message) async {
    print('📨 Foreground message received: ${message.notification?.title}');

    await _showLocalNotification(
      title: message.notification?.title ?? 'Sport Is Life',
      body: message.notification?.body ?? '',
      payload: message.data['type'] ?? 'general',
    );
  }

  // ✅ Handle message when app is opened from notification
  static void _onMessageOpenedApp(RemoteMessage message) {
    print('📱 App opened from notification: ${message.notification?.title}');
    _handleNavigation(message.data['type']);
  }

  // ✅ Handle background messages
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('📨 Background message received: ${message.notification?.title}');

    // Initialize plugin for background
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );

    final FlutterLocalNotificationsPlugin localNotifications =
        FlutterLocalNotificationsPlugin();
    await localNotifications.initialize(initSettings);

    await localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      message.notification?.title ?? 'Sport Is Life',
      message.notification?.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'push_notifications_channel',
          'Push Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // ✅ Handle notification tap
  static void _onNotificationTap(NotificationResponse response) {
    print('🔔 Notification tapped: ${response.payload}');
    _handleNavigation(response.payload);

    if (_onNotificationTapCallback != null) {
      _onNotificationTapCallback!(response.payload);
    }
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTap(NotificationResponse response) {
    print('🔔 Background notification tapped: ${response.payload}');
    _handleNavigation(response.payload);
  }

  // ✅ Navigate based on notification type
  static void _handleNavigation(String? type) {
    print('📍 Navigate to: $type');
    // You can add navigation logic here
  }

  // ✅ Show local notification
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'push_notifications_channel',
      'Push Notifications',
      channelDescription: 'Notifications from coaches and admins',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // ✅ Schedule daily quote notification
  static Future<void> scheduleDailyQuoteNotification() async {
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, 8, 0);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final quotes = [
      '"The only bad workout is the one that didn\'t happen."',
      '"Your body can stand almost anything. It\'s your mind you have to convince."',
      '"Small daily improvements = big results over time."',
      '"Don\'t count the days, make the days count."',
      '"The pain you feel today will be the strength you feel tomorrow."',
      '"Success starts with self-discipline."',
      '"You are stronger than you think."',
    ];

    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final quote = quotes[dayOfYear % quotes.length];

    await _localNotifications.zonedSchedule(
      9999,
      '💪 Daily Motivation',
      quote,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_quote_channel',
          'Daily Motivation',
          channelDescription: 'Daily motivational quotes',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    print(
        '✅ Daily quote notification scheduled for ${scheduledTime.toLocal()}');
  }

  // ✅ Schedule streak reminder notification
  static Future<void> scheduleStreakReminder() async {
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, 18, 0);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _localNotifications.zonedSchedule(
      8888,
      '🔥 Don\'t Break Your Streak!',
      'Complete your workout today to keep your streak alive! 💪',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_channel',
          'Streak Reminder',
          channelDescription: 'Reminders to maintain your workout streak',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    print('✅ Streak reminder scheduled for ${scheduledTime.toLocal()}');
  }

  // ✅ Send welcome notification
  static Future<void> sendWelcomeNotification() async {
    await _showLocalNotification(
      title: '👋 Welcome to Sport Is Life!',
      body:
          'Get ready to transform your fitness journey. Daily motivation at 8 AM!',
      payload: 'welcome',
    );
    print('✅ Welcome notification sent');
  }

  // ✅ Send welcome back notification
  static Future<void> sendWelcomeBackNotification() async {
    await _showLocalNotification(
      title: '👋 Welcome Back!',
      body:
          'Ready to crush your fitness goals today? Daily motivation at 8 AM! 💪',
      payload: 'welcome_back',
    );
    print('✅ Welcome back notification sent');
  }

  // ✅ Send workout completed notification
  static Future<void> sendWorkoutCompletedNotification(
      int minutes, int xpGained) async {
    await _showLocalNotification(
      title: '🏆 Great Workout!',
      body:
          'You completed $minutes minutes and earned $xpGained XP! Keep it up! 💪',
      payload: 'workout_complete',
    );
    print('✅ Workout completed notification sent');
  }

  // ✅ Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    print('✅ All notifications cancelled');
  }

  // ✅ Get all pending notifications
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  // ✅ Schedule weekly summary
  static Future<void> scheduleWeeklySummary() async {
    final now = DateTime.now();
    int daysUntilSunday = DateTime.sunday - now.weekday;
    if (daysUntilSunday <= 0) daysUntilSunday += 7;

    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day + daysUntilSunday,
      19,
      0,
    );

    await _localNotifications.zonedSchedule(
      7777,
      '📊 Your Weekly Summary',
      'Check your progress and achievements this week!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_summary_channel',
          'Weekly Summary',
          channelDescription: 'Weekly workout summary',
          importance: Importance.low,
          priority: Priority.low,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    print('✅ Weekly summary scheduled for Sunday at 7:00 PM');
  }

  // ✅ Cancel streak reminder
  static Future<void> cancelStreakReminder() async {
    await _localNotifications.cancel(8888);
  }

  // ✅ Cancel daily quote
  static Future<void> cancelDailyQuote() async {
    await _localNotifications.cancel(9999);
  }

  // ✅ Send test notification
  static Future<void> sendTestNotification() async {
    await _showLocalNotification(
      title: '🧪 Test Notification',
      body: 'Your local notifications are working!',
      payload: 'test',
    );
    print('✅ Test notification sent');
  }

  // ✅ Get FCM token
  static Future<String?> getFCMToken() async {
    return await _fcm.getToken();
  }

  // ✅ Save FCM token to Firestore
  static Future<void> saveFCMTokenToFirestore(String userId) async {
    try {
      String? token = await getFCMToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('✅ FCM token saved for user: $userId');
      }
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }
}
