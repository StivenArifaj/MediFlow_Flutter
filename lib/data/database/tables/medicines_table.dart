import 'package:drift/drift.dart';
import 'users_table.dart';

class Medicines extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get verifiedName => text()();
  TextColumn get brandName => text().nullable()();
  TextColumn get genericName => text().nullable()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get strength => text().nullable()();
  TextColumn get form => text().nullable()(); // tablet, capsule, etc.
  TextColumn get category => text().nullable()();
  IntColumn get quantity => integer().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get apiSource => text().withDefault(const Constant('manual'))();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}
