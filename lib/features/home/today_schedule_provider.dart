import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/supabase_data_service.dart';
import '../../core/hooks/managed_user_id.dart';

enum DoseStatus { pending, taken, takenLate, skipped, missed }

class TodaySlot {
  final String reminderId;
  final String medicineId;
  final String medicineName;
  final String? strength;
  final String? form;
  final DateTime scheduledAt;
  final DoseStatus status;
  final String? historyEntryId;
  final int notificationId;
  final int snoozeDuration;

  const TodaySlot({
    required this.reminderId,
    required this.medicineId,
    required this.medicineName,
    this.strength,
    this.form,
    required this.scheduledAt,
    required this.status,
    this.historyEntryId,
    required this.notificationId,
    required this.snoozeDuration,
  });

  bool get isDone => status != DoseStatus.pending;
  bool get isTaken =>
      status == DoseStatus.taken || status == DoseStatus.takenLate;
}

final todayScheduleProvider = FutureProvider<List<TodaySlot>>((ref) async {
  final userId = await ref.watch(managedUserIdProvider.future);
  if (userId == null) return [];

  final svc = ref.read(supabaseDataServiceProvider);
  final now = DateTime.now();

  final reminders = await svc.getTodayReminders(userId);
  if (reminders.isEmpty) return [];

  final history = await svc.getTodayHistory(userId);
  final historyByReminder = <String, Map<String, dynamic>>{};
  for (final h in history) {
    final rid = h['reminder_id'] as String?;
    if (rid != null) historyByReminder[rid] = h;
  }

  const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final todayName = dayNames[now.weekday % 7];

  final slots = <TodaySlot>[];

  for (final r in reminders) {
    final freq = r['frequency'] as String? ?? 'daily';
    if (freq == 'as_needed') continue;
    if (freq == 'specific_days') {
      final days =
          (r['days'] as List?)?.map((d) => d.toString()).toList() ?? [];
      if (!days.contains(todayName)) continue;
    }
    if (freq == 'interval') {
      final intervalDays = r['interval_days'] as int? ?? 1;
      final created = DateTime.parse(r['created_at'] as String);
      final daysDiff = now.difference(created).inDays;
      if (daysDiff % intervalDays != 0) continue;
    }

    final timeStr = r['time'] as String? ?? '08:00';
    final parts = timeStr.split(':');
    final scheduledAt = DateTime(
      now.year, now.month, now.day,
      int.parse(parts[0]), int.parse(parts[1]),
    );

    final medicine = r['medicines'] as Map<String, dynamic>?;
    final medicineId = r['medicine_id'] as String;
    final medicineName =
        medicine?['verified_name'] as String? ?? 'Unknown';
    final strength = medicine?['strength'] as String?;
    final form = medicine?['form'] as String?;

    final entry = historyByReminder[r['id'] as String];
    DoseStatus status;
    String? historyEntryId;

    if (entry != null) {
      historyEntryId = entry['id'] as String;
      final s = entry['status'] as String;
      status = switch (s) {
        'taken' => DoseStatus.taken,
        'taken_late' => DoseStatus.takenLate,
        'skipped' => DoseStatus.skipped,
        'missed' => DoseStatus.missed,
        _ => DoseStatus.pending,
      };
    } else if (now.isAfter(
        scheduledAt.add(const Duration(minutes: 15)))) {
      status = DoseStatus.missed;
    } else {
      status = DoseStatus.pending;
    }

    slots.add(TodaySlot(
      reminderId: r['id'] as String,
      medicineId: medicineId,
      medicineName: medicineName,
      strength: strength,
      form: form,
      scheduledAt: scheduledAt,
      status: status,
      historyEntryId: historyEntryId,
      notificationId: medicineId.hashCode.abs() % 2147483647,
      snoozeDuration: r['snooze_duration'] as int? ?? 15,
    ));
  }

  slots.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  return slots;
});

class DoseLogger extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> logDose({
    required String reminderId,
    required String medicineId,
    required DateTime scheduledAt,
    required String action,
    String? existingEntryId,
  }) async {
    final userId = await ref.read(managedUserIdProvider.future);
    if (userId == null) throw Exception('Not logged in');

    final svc = ref.read(supabaseDataServiceProvider);
    final now = DateTime.now();

    final isLate =
        now.isAfter(scheduledAt.add(const Duration(minutes: 15)));
    final status = action == 'taken'
        ? (isLate ? 'taken_late' : 'taken')
        : 'skipped';

    await svc.logDose(
      userId: userId,
      medicineId: medicineId,
      reminderId: reminderId,
      status: status,
      scheduledTime: scheduledAt,
      actualTime: now,
      existingEntryId: existingEntryId,
    );

    ref.invalidate(todayScheduleProvider);
  }
}

final doseLoggerProvider =
    AsyncNotifierProvider<DoseLogger, void>(DoseLogger.new);
