import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    final localTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings: initSettings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Request notification permission on Android 13+
    await androidPlugin?.requestNotificationsPermission();

    // Request exact alarm permission on Android 14+
    await androidPlugin?.requestExactAlarmsPermission();
  }

  Future<void> scheduleNotification({
    required int instanceId,
    required String plantName,
    required String taskType,
    required String? customNote,
    required DateTime dueDate,
    required int reminderTimeMinutes,
  }) async {
    final hour = reminderTimeMinutes ~/ 60;
    final minute = reminderTimeMinutes % 60;

    final scheduledDate = tz.TZDateTime(
      tz.local,
      dueDate.year,
      dueDate.month,
      dueDate.day,
      hour,
      minute,
    );

    // Skip if the scheduled time is in the past
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    final title = switch (taskType) {
      'watering' => 'Time to water $plantName!',
      'light' => "Check $plantName's light!",
      'fertilizing' => 'Time to fertilize $plantName!',
      'custom' => 'Reminder: ${customNote ?? 'Task'} for $plantName',
      _ => 'Plant care reminder for $plantName',
    };

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'plant_care_reminders',
        'Plant Care Reminders',
        channelDescription: 'Reminders for plant care tasks',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    try {
      await _plugin.zonedSchedule(
        id: instanceId,
        title: title,
        body: 'Open PlantMe to mark it done.',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } on PlatformException {
      await _plugin.zonedSchedule(
        id: instanceId,
        title: title,
        body: 'Open PlantMe to mark it done.',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelNotification(int instanceId) async {
    await _plugin.cancel(id: instanceId);
  }

  Future<void> cancelNotifications(List<int> instanceIds) async {
    for (final id in instanceIds) {
      await _plugin.cancel(id: id);
    }
  }
}
