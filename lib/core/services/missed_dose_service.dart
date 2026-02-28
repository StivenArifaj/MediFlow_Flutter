

import '../../data/database/app_database.dart';

/// Automatically marks missed doses when the app resumes or launches.
/// A dose is considered "missed" if the scheduled time was more than
/// 30 minutes ago and no history entry exists for that reminder today.
class MissedDoseService {
  static Future<void> checkAndMarkMissed(AppDatabase db, int userId) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    // Get all active reminders for user
    final reminders = await db.remindersDao.getRemindersForUser(userId);

    // Get today's history entries to avoid double-marking
    final todayHistory = await db.historyDao.getHistoryForUser(
      userId,
      startDate: todayStart,
      endDate: now,
    );
    final markedReminderIds = todayHistory.map((h) => h.reminderId).toSet();

    for (final r in reminders) {
      if (markedReminderIds.contains(r.id)) continue; // already acted on

      // Parse reminder time
      final parts = r.time.split(':');
      final reminderHour = int.tryParse(parts[0]) ?? 0;
      final reminderMinute =
          int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

      final scheduledToday = DateTime(
          now.year, now.month, now.day, reminderHour, reminderMinute);

      // Only mark as missed if the scheduled time was more than 30 minutes ago
      if (now.isAfter(scheduledToday.add(const Duration(minutes: 30)))) {
        // Check weekly frequency — skip if today isn't a scheduled day
        if (r.frequency == 'weekly' && r.days != null) {
          final dayNames = [
            '',
            'monday',
            'tuesday',
            'wednesday',
            'thursday',
            'friday',
            'saturday',
            'sunday'
          ];
          final todayName = dayNames[now.weekday];
          final scheduledDays = r.days!
              .split(',')
              .map((d) => d.trim().toLowerCase())
              .toList();
          if (!scheduledDays.contains(todayName)) continue;
        }

        await db.historyDao.insertHistoryEntry(
          HistoryEntriesCompanion.insert(
            reminderId: r.id,
            medicineId: r.medicineId,
            userId: userId,
            status: 'missed',
            scheduledTime: scheduledToday,
            createdAt: now,
          ),
        );
      }
    }
  }
}
