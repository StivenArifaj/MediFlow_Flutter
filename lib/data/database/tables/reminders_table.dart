import 'package:drift/drift.dart';
import 'medicines_table.dart';
import 'users_table.dart';

class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicineId => integer().references(Medicines, #id)();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get time => text()(); // "08:00"
  TextColumn get frequency => text()(); // 'daily', 'specific_days', 'interval', 'as_needed'
  TextColumn get days => text().nullable()(); // JSON: ["Mon","Wed","Fri"]
  IntColumn get intervalDays => integer().nullable()();
  TextColumn get durationType => text().withDefault(const Constant('ongoing'))();
  DateTimeColumn get endDate => dateTime().nullable()();
  IntColumn get durationDays => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get snoozeDuration => integer().withDefault(const Constant(15))();
  IntColumn get notificationId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
