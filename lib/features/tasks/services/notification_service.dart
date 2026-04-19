import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String _channelId = 'task_deadline_reminders';
  static const String _channelName = 'Task Deadline Reminders';
  static const String _channelDescription =
      'Reminder notifications before task due dates';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _plugin.initialize(settings);
    await _configureLocalTimeZone();
    await _createAndroidChannel();
    await requestPermissions();

    _initialized = true;
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return;

    final androidImplementation = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();

    final iosImplementation = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    final macImplementation = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    await macImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> scheduleTaskReminder({
    required int id,
    required DateTime dueDateTime,
    String title = 'Task Reminder',
    String body = 'Your task is due soon',
    Duration reminderOffset = const Duration(hours: 1),
  }) async {
    if (kIsWeb) return;

    await initialize();

    final scheduledTime = dueDateTime.subtract(reminderOffset);
    if (!scheduledTime.isAfter(DateTime.now())) {
      await cancelNotification(id);
      return;
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'task_deadline_reminder',
    );
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;

    await initialize();
    await _plugin.cancel(id);
  }

  Future<void> _createAndroidChannel() async {
    final androidImplementation = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
      ),
    );
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();

    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }
}
