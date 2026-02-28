import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

import '../../data/database/app_database.dart';

/// Central notification service. Call [NotificationService.init()] once in main.dart.
class NotificationService {
  NotificationService._();

  /// Singleton instance — for code that calls NotificationService.instance.method()
  static final NotificationService instance = NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialised = false;

  static const _channelId = 'mediflow_reminders';
  static const _channelName = 'MediFlow Reminders';

  // ── Init ──────────────────────────────────────────────────────────────────
  static Future<void> init() async {
    if (_initialised) return;

    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );

    // Create Android channel
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

  // ── Android notification details (reusable) ───────────────────────────────
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

  // ── Schedule a daily recurring reminder ───────────────────────────────────
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

    final scheduledDate = _nextInstanceOf(hour, minute);

    await _plugin.zonedSchedule(
      id: notificationId,
      title: '💊 $medicineName',
      body: notes ?? 'Time to take your medicine',
      scheduledDate: scheduledDate,
      notificationDetails: _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // daily repeat
    );
  }

  // ── Schedule a weekly recurring reminder ──────────────────────────────────
  static Future<void> scheduleWeeklyReminder({
    required int notificationId,
    required String medicineName,
    required String time,
    required int dayOfWeek, // 1=Mon … 7=Sun
    String? notes,
  }) async {
    if (!_initialised) await init();

    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 8;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    final scheduledDate = _nextInstanceOfWeekly(hour, minute, dayOfWeek);

    await _plugin.zonedSchedule(
      id: notificationId,
      title: '💊 $medicineName',
      body: notes ?? 'Time to take your medicine',
      scheduledDate: scheduledDate,
      notificationDetails: _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // ── Snooze ────────────────────────────────────────────────────────────────
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

    final snoozeId = notificationId + 100000;

    await _plugin.zonedSchedule(
      id: snoozeId,
      title: '💊 $medicineName (snoozed)',
      body: notes ?? 'Snoozed reminder — time to take your medicine',
      scheduledDate: snoozeTime,
      notificationDetails: _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // ── Cancel ────────────────────────────────────────────────────────────────
  static Future<void> cancelReminder(int notificationId) async {
    await _plugin.cancel(id: notificationId);
    await _plugin.cancel(id: notificationId + 100000);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ── Reschedule all ────────────────────────────────────────────────────────
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

  // ── Immediate test ────────────────────────────────────────────────────────
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

  // ── Helpers ───────────────────────────────────────────────────────────────
  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
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