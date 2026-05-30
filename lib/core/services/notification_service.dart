import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:rxdart/subjects.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // Stream to listen to notification taps
  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject<String?>();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName.toString()));
    } catch (_) {
      // Fallback for platforms that might fail
    }
    
    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings();
    const linuxInit = LinuxInitializationSettings(defaultActionName: 'Open Orbit');
    const initSettings = InitializationSettings(
      android: androidInit, 
      iOS: iosInit,
      linux: linuxInit,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (details.payload != null) {
          onNotificationClick.add(details.payload);
        }
      },
    );

    // Skip platform-specific calls on non-supported platforms to avoid errors
    if (kIsWeb || (!kIsWeb && (Platform.isWindows || Platform.isLinux))) {
      return;
    }

    // Check if app was launched via notification (Only for supported platforms)
    try {
      final NotificationAppLaunchDetails? launchDetails = await _notifications.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        if (launchDetails?.notificationResponse?.payload != null) {
          onNotificationClick.add(launchDetails!.notificationResponse!.payload);
        }
      }
    } catch (e) {
      debugPrint('Error getting notification launch details: $e');
    }

    // طلب إذن الإشعارات للأندرويد 13+
    if (Platform.isAndroid) {
      try {
        await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        
        await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestExactAlarmsPermission();
      } catch (e) {
        debugPrint('Error requesting Android permissions: $e');
      }
    }
  }

  /// Schedules notification for today (at 9 AM or current time + 1 hour if it's already past 9 AM)
  /// and for 1 day before the deadline (at 9 AM).
  Future<void> scheduleDeadlineReminders({
    required String id, // Using String ID (hash it for int requirements)
    required String title,
    required DateTime deadline,
    required String dayOfBody,
    required String dayBeforeBody,
  }) async {
    // Windows/Web placeholder
    if (kIsWeb || (!kIsWeb && (Platform.isWindows || Platform.isLinux))) {
      debugPrint('Notifications not fully supported on this platform yet.');
      return;
    }

    try {
      tz.local;
    } catch (_) {
      await init();
    }

    final int baseId = id.hashCode;
    final int dayOfId = baseId;
    final int dayBeforeId = baseId + 1;

    // 1. Day Of Deadline Notification (e.g., at 9:00 AM)
    final dayOfDate = DateTime(deadline.year, deadline.month, deadline.day, 9, 0);
    DateTime scheduledDayOf = dayOfDate;
    
    // If it's already past 9 AM on the deadline day, schedule for 1 hour from now if it's still before the actual deadline time
    if (scheduledDayOf.isBefore(DateTime.now())) {
      scheduledDayOf = DateTime.now().add(const Duration(hours: 1));
    }

    // Only schedule if it's before the actual deadline
    if (scheduledDayOf.isBefore(deadline)) {
      await _schedule(dayOfId, title, dayOfBody, scheduledDayOf, payload: id);
    }

    // 2. Day Before Deadline Notification (at 9:00 AM)
    final dayBeforeDate = deadline.subtract(const Duration(days: 1));
    final scheduledDayBefore = DateTime(dayBeforeDate.year, dayBeforeDate.month, dayBeforeDate.day, 9, 0);

    if (scheduledDayBefore.isAfter(DateTime.now())) {
      await _schedule(dayBeforeId, title, dayBeforeBody, scheduledDayBefore, payload: id);
    }
  }

  Future<void> _schedule(int id, String title, String body, DateTime scheduledTime, {String? payload}) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: const AndroidNotificationDetails(
          'deadline_reminders',
          'Deadline Reminders',
          channelDescription: 'Notifications for upcoming project/task deadlines',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminders(String id) async {
    if (kIsWeb || (!kIsWeb && (Platform.isWindows || Platform.isLinux))) return;
    final int baseId = id.hashCode;
    await _notifications.cancel(baseId);     // Day of
    await _notifications.cancel(baseId + 1); // Day before
  }
}
