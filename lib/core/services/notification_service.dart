import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      // استخدام var لتجنب تضارب الأنواع في الإصدار الجديد
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
        // Handle notification tap
      },
    );

    // طلب إذن الإشعارات للأندرويد 13+
    if (Platform.isAndroid) {
      await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      
      await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleDeadlineNotification({
    required int id,
    required String title,
    required String body,
    required DateTime deadline,
  }) async {
    // تخطي الجدولة على الويندوز والمنصات غير المدعومة لمنع الانهيار
    if (kIsWeb || (!kIsWeb && (Platform.isWindows || Platform.isLinux))) {
      return;
    }

    try {
      tz.local;
    } catch (_) {
      await init();
    }

    // Schedule for 1 hour before deadline
    final scheduledTime = deadline.subtract(const Duration(hours: 1));
    
    if (scheduledTime.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'deadline_reminders',
          'Deadline Reminders',
          channelDescription: 'Notifications for upcoming project/task deadlines',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    // لا داعي للإلغاء في المنصات غير المدعومة
    if (kIsWeb || (!kIsWeb && (Platform.isWindows || Platform.isLinux))) {
      return;
    }
    await _notifications.cancel(id);
  }
}
