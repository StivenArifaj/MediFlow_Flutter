import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'daos/users_dao.dart';
import 'daos/medicines_dao.dart';
import 'daos/reminders_dao.dart';
import 'daos/history_dao.dart';
import 'daos/health_dao.dart';

part 'app_database.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 2, max: 100)();
  TextColumn get email => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get role => text().withDefault(const Constant('patient'))();
  BoolColumn get isPremium => boolean().withDefault(const Constant(false))();
  TextColumn get language => text().withDefault(const Constant('en'))();
  BoolColumn get isDarkMode => boolean().withDefault(const Constant(true))();
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get firebaseUid => text().nullable()();
}

class Medicines extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer()();
  TextColumn get verifiedName => text()();
  TextColumn get brandName => text().nullable()();
  TextColumn get genericName => text().nullable()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get strength => text().nullable()();
  TextColumn get form => text().nullable()();
  TextColumn get category => text().nullable()();
  IntColumn get quantity => integer().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get apiSource => text().withDefault(const Constant('manual'))();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicineId => integer()();
  IntColumn get userId => integer()();
  TextColumn get time => text()();
  TextColumn get frequency => text().withDefault(const Constant('daily'))();
  TextColumn get days => text().nullable()();
  IntColumn get intervalDays => integer().nullable()();
  TextColumn get durationType => text().withDefault(const Constant('ongoing'))();
  DateTimeColumn get endDate => dateTime().nullable()();
  IntColumn get durationDays => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get snoozeDuration => integer().withDefault(const Constant(15))();
  IntColumn get notificationId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class HistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get reminderId => integer()();
  IntColumn get medicineId => integer()();
  IntColumn get userId => integer()();
  TextColumn get status => text()();
  DateTimeColumn get scheduledTime => dateTime()();
  DateTimeColumn get actualTime => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class HealthMeasurements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer()();
  TextColumn get type => text()();
  RealColumn get value => real()();
  TextColumn get unit => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get recordedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(
  tables: [Users, Medicines, Reminders, HistoryEntries, HealthMeasurements],
  daos: [UsersDao, MedicinesDao, RemindersDao, HistoryDao, HealthDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'mediflow.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
