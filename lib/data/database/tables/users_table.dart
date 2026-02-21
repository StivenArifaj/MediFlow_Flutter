import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 2, max: 100)();
  TextColumn get email => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get role => text()(); // 'patient' | 'caregiver'
  BoolColumn get isPremium => boolean().withDefault(const Constant(false))();
  TextColumn get language => text().withDefault(const Constant('sq'))(); // Albanian default
  BoolColumn get isDarkMode => boolean().withDefault(const Constant(true))();
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get firebaseUid => text().nullable()();
}
