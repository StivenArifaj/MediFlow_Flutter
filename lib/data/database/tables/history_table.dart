import 'package:drift/drift.dart';
import 'reminders_table.dart';
import 'medicines_table.dart';
import 'users_table.dart';

class HistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get reminderId => integer().references(Reminders, #id)();
  IntColumn get medicineId => integer().references(Medicines, #id)();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get status => text()(); // 'taken', 'taken_late', 'skipped', 'missed'
  DateTimeColumn get scheduledTime => dateTime()();
  DateTimeColumn get actualTime => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
