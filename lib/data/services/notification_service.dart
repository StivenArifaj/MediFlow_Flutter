import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

import '../../data/database/app_database.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialised = false;

  static const _channelId = 'mediflow_reminders';
  static const _channelName = 'MediFlow Reminders';

  static const _androidDetails = AndroidNotificationDetails(
    _channelId,
    _channelName,
    channelDescription: 'Medicine reminder notifications',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  static const _iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  static const _notificationDetails = NotificationDetails(
    android: _androidDetails,
    iOS: _iosDetails,
  );

  static Future<void> init() async {
    if (_initialised) return;

    // Init timezone data
    tz_data.initializeTimeZones();

    // Detect device timezone from UTC offset — no external package needed
    final offsetMs = DateTime.now().timeZoneOffset.inMilliseconds;
    for (final name in tz.timeZoneDatabase.locations.keys) {
      try {
        final loc = tz.getLocation(name);
        if (tz.TZDateTime.now(loc).timeZoneOffset.inMilliseconds == offsetMs) {
          tz.setLocalLocation(loc);
          break;
        }
      } catch (_) {}
    }
    debugPrint('NotificationService: tz.local = ${tz.local.name}');

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Medicine reminder notifications',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    _initialised = true;
  }

  static Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // Schedule a daily recurring reminder
  static Future<void> scheduleReminder({
    required int notificationId,
    required String medicineName,
    required String time,
    String? notes,
  }) async {
    if (!_initialised) await init();

    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 8;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    await _plugin.zonedSchedule(
      id: notificationId,
      title: '💊 $medicineName',
      body: notes ?? 'Time to take your medicine',
      scheduledDate: _nextInstanceOf(hour, minute),
      notificationDetails: _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Schedule a weekly recurring reminder
  static Future<void> scheduleWeeklyReminder({
    required int notificationId,
    required String medicineName,
    required String time,
    required int dayOfWeek,
    String? notes,
  }) async {
    if (!_initialised) await init();

    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 8;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    await _plugin.zonedSchedule(
      id: notificationId,
      title: '💊 $medicineName',
      body: notes ?? 'Time to take your medicine',
      scheduledDate: _nextInstanceOfWeekly(hour, minute, dayOfWeek),
      notificationDetails: _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // Schedule all reminders for a medicine at once
  Future<void> scheduleRemindersForMedicine({
    required int medicineId,
    required String medicineName,
    required List<String> times,
    String frequency = 'daily',
    List<int> days = const [],
  }) async {
    if (!_initialised) await init();
    await cancelRemindersForMedicine(medicineId);
    for (int i = 0; i < times.length; i++) {
      if (frequency == 'specific' && days.isNotEmpty) {
        for (int d = 0; d < days.length; d++) {
          await scheduleWeeklyReminder(
            notificationId: medicineId * 100 + i + (d * 1000),
            medicineName: medicineName,
            time: times[i],
            dayOfWeek: days[d],
          );
        }
      } else {
        await scheduleReminder(
          notificationId: medicineId * 100 + i,
          medicineName: medicineName,
          time: times[i],
        );
      }
    }
  }

  // Snooze
  static Future<void> snoozeReminder({
    required int notificationId,
    required String medicineName,
    required int snoozeMinutes,
    String? notes,
  }) async {
    if (!_initialised) await init();
    await _plugin.cancel(id: notificationId);
    final snoozeTime =
        tz.TZDateTime.now(tz.local).add(Duration(minutes: snoozeMinutes));
    await _plugin.zonedSchedule(
      id: notificationId + 100000,
      title: '💊 $medicineName (snoozed)',
      body: notes ?? 'Snoozed reminder — time to take your medicine',
      scheduledDate: snoozeTime,
      notificationDetails: _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  // Cancel all reminders for a medicine
  Future<void> cancelRemindersForMedicine(int medicineId) async {
    for (int i = 0; i < 10; i++) {
      await _plugin.cancel(id: medicineId * 100 + i);
      for (int d = 0; d < 7; d++) {
        await _plugin.cancel(id: medicineId * 100 + i + (d * 1000));
      }
    }
  }

  static Future<void> cancelReminder(int notificationId) async {
    await _plugin.cancel(id: notificationId);
    await _plugin.cancel(id: notificationId + 100000);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> rescheduleAll(
      List<Reminder> reminders, Map<int, String> medicineNames) async {
    for (final r in reminders) {
      if (!r.isActive) continue;
      final notifId = r.notificationId ?? r.id;
      final name = medicineNames[r.medicineId] ?? 'Medicine';
      await scheduleReminder(
          notificationId: notifId, medicineName: name, time: r.time);
    }
  }

  static Future<void> showImmediate({
    required String title,
    required String body,
  }) async {
    if (!_initialised) await init();
    await _plugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: _notificationDetails,
    );
  }

  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static tz.TZDateTime _nextInstanceOfWeekly(
      int hour, int minute, int dayOfWeek) {
    var scheduled = _nextInstanceOf(hour, minute);
    while (scheduled.weekday != dayOfWeek) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}