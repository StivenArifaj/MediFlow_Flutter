import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

import '../../data/database/app_database.dart';

/// Central notification service. Call [NotificationService.init()] once in main.dart.
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialised = false;

  // ── Android notification channel ──────────────────────────────────────────
  static const _channel = AndroidNotificationChannel(
    'mediflow_reminders',
    'MediFlow Reminders',
    description: 'Medicine reminder notifications',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  // ── Init ──────────────────────────────────────────────────────────────────
  static Future<void> init() async {
    if (_initialised) return;

    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Create Android channel
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    _initialised = true;
  }

  /// Request permission (Android 13+, iOS).
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

  // ── Schedule a daily recurring reminder ───────────────────────────────────
  /// [notificationId] — unique int per reminder (use reminder.id)
  /// [time] — "HH:mm" format e.g. "08:00"
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

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If today's time already passed, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(
          notes ?? 'Time to take your medicine',
          contentTitle: '💊 $medicineName',
        ),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      notificationId,
      '💊 $medicineName',
      notes ?? 'Time to take your medicine',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // daily repeat
    );
  }

  // ── Snooze: cancel + reschedule N minutes from now ────────────────────────
  static Future<void> snoozeReminder({
    required int notificationId,
    required String medicineName,
    required int snoozeMinutes,
    String? notes,
  }) async {
    if (!_initialised) await init();

    await _plugin.cancel(notificationId);

    final snoozeTime = tz.TZDateTime.now(tz.local)
        .add(Duration(minutes: snoozeMinutes));

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(),
    );

    // Use a different ID for the snooze so it doesn't collide
    final snoozeId = notificationId + 100000;

    await _plugin.zonedSchedule(
      snoozeId,
      '💊 $medicineName (snoozed)',
      notes ?? 'Snoozed reminder — time to take your medicine',
      snoozeTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Cancel a single notification ──────────────────────────────────────────
  static Future<void> cancelReminder(int notificationId) async {
    await _plugin.cancel(notificationId);
    await _plugin.cancel(notificationId + 100000); // also cancel any snooze
  }

  // ── Cancel all notifications ──────────────────────────────────────────────
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ── Reschedule all active reminders for a user ────────────────────────────
  /// Call this when the user re-enables notifications.
  static Future<void> rescheduleAll(List<Reminder> reminders, Map<int, String> medicineNames) async {
    for (final r in reminders) {
      if (!r.isActive) continue;
      final notifId = r.notificationId ?? r.id;
      final name = medicineNames[r.medicineId] ?? 'Medicine';
      await scheduleReminder(
        notificationId: notifId,
        medicineName: name,
        time: r.time,
      );
    }
  }

  // ── Show an immediate test notification ───────────────────────────────────
  static Future<void> showImmediate({
    required String title,
    required String body,
  }) async {
    if (!_initialised) await init();
    await _plugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mediflow_reminders',
          'MediFlow Reminders',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}