import 'package:drift/drift.dart';
import 'package:mediflow/data/database/app_database.dart';

part 'reminders_dao.g.dart';

@DriftAccessor(tables: [Reminders])
class RemindersDao extends DatabaseAccessor<AppDatabase> with _$RemindersDaoMixin {
  RemindersDao(super.db);

  Future<List<Reminder>> getRemindersForMedicine(int medicineId) {
    return (select(reminders)
          ..where((r) => r.medicineId.equals(medicineId) & r.isActive.equals(true)))
        .get();
  }

  Future<List<Reminder>> getRemindersForUser(int userId) {
    return (select(reminders)
          ..where((r) => r.userId.equals(userId) & r.isActive.equals(true)))
        .get();
  }

  Future<Reminder?> getReminderById(int id) {
    return (select(reminders)..where((r) => r.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertReminder(RemindersCompanion reminder) {
    return into(reminders).insert(reminder);
  }

  Future<bool> updateReminder(RemindersCompanion reminder) {
    return update(reminders).replace(reminder);
  }

  Future<int> deleteReminder(int id) {
    return (update(reminders)..where((r) => r.id.equals(id))).write(
      const RemindersCompanion(isActive: Value(false)),
    );
  }

  Future<List<Reminder>> getRemindersForToday(int userId) {
    // ignore: unused_local_variable
    final today = DateTime.now();
    
    return (select(reminders)
          ..where((r) =>
              r.userId.equals(userId) &
              r.isActive.equals(true) &
              (r.frequency.equals('daily') | r.days.isNotNull())))
        .get();
  }
}
