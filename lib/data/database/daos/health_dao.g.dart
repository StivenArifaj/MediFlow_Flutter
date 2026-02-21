// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_dao.dart';

// ignore_for_file: type=lint
mixin _$HealthDaoMixin on DatabaseAccessor<AppDatabase> {
  $HealthMeasurementsTable get healthMeasurements =>
      attachedDatabase.healthMeasurements;
  HealthDaoManager get managers => HealthDaoManager(this);
}

class HealthDaoManager {
  final _$HealthDaoMixin _db;
  HealthDaoManager(this._db);
  $$HealthMeasurementsTableTableManager get healthMeasurements =>
      $$HealthMeasurementsTableTableManager(
          _db.attachedDatabase, _db.healthMeasurements);
}
