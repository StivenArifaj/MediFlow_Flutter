import 'package:drift/drift.dart';
import 'users_table.dart';

class HealthMeasurements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get type => text()(); // 'weight', 'blood_pressure', etc.
  RealColumn get value => real()();
  TextColumn get unit => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get recordedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
}
