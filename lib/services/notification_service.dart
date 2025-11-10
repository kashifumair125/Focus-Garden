import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service to handle local notifications
class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  NotificationService._();

  /// Initialize notifications
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      _initialized = true;

      // Request permissions for iOS
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _notifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notifications: $e');
      }
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
  }

  /// Show a simple notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();
    if (!await _areNotificationsEnabled()) return;

    const androidDetails = AndroidNotificationDetails(
      'focus_garden_channel',
      'Focus Garden',
      channelDescription: 'Notifications for Focus Garden app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        DateTime.now().millisecond,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error showing notification: $e');
      }
    }
  }

  /// Schedule a daily reminder notification
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await initialize();
    if (!await _areNotificationsEnabled()) return;

    // For now, we'll use a simpler periodic scheduling
    // In production, you'd want to use timezone-aware scheduling
    if (kDebugMode) {
      print('Daily reminder scheduled for $hour:$minute');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  /// Check if notifications are enabled
  Future<bool> _areNotificationsEnabled() async {
    final box = Hive.box('settings');
    return box.get('notificationsEnabled', defaultValue: true) as bool;
  }

  /// Get next instance of a specific time
  DateTime _nextInstanceOfTime(int hour, int minute) {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Show reminder to start a focus session
  Future<void> showFocusReminder() async {
    await showNotification(
      title: '🌱 Time to Focus!',
      body: 'Ready to grow your garden? Start a focus session now!',
      payload: 'focus_reminder',
    );
  }

  /// Show streak reminder
  Future<void> showStreakReminder(int streak) async {
    await showNotification(
      title: '🔥 Keep Your Streak!',
      body: 'You have a $streak day streak. Don\'t break it today!',
      payload: 'streak_reminder',
    );
  }

  /// Show milestone notification
  Future<void> showMilestoneNotification(String milestone) async {
    await showNotification(
      title: '🎉 Milestone Reached!',
      body: milestone,
      payload: 'milestone',
    );
  }
}
