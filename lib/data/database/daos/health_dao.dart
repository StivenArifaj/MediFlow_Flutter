import 'package:drift/drift.dart';
import 'package:mediflow/data/database/app_database.dart';

part 'health_dao.g.dart';

@DriftAccessor(tables: [HealthMeasurements])
class HealthDao extends DatabaseAccessor<AppDatabase> with _$HealthDaoMixin {
  HealthDao(super.db);

  Future<List<HealthMeasurement>> getMeasurementsForUser(int userId, {String? type}) {
    var query = select(healthMeasurements)..where((h) => h.userId.equals(userId));
    
    if (type != null) {
      query = query..where((h) => h.type.equals(type));
    }
    
    return (query..orderBy([(h) => OrderingTerm.desc(h.recordedAt)])).get();
  }

  Future<HealthMeasurement?> getLatestMeasurement(int userId, String type) {
    return (select(healthMeasurements)
          ..where((h) => h.userId.equals(userId) & h.type.equals(type))
          ..orderBy([(h) => OrderingTerm.desc(h.recordedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<HealthMeasurement?> getMeasurementById(int id) {
    return (select(healthMeasurements)..where((h) => h.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertMeasurement(HealthMeasurementsCompanion measurement) {
    return into(healthMeasurements).insert(measurement);
  }

  Future<int> deleteMeasurement(int id) {
    return (delete(healthMeasurements)..where((h) => h.id.equals(id))).go();
  }

  /// Alias used across screens
  Future<List<HealthMeasurement>> getAllMeasurements(int userId) =>
      getMeasurementsForUser(userId);

  Future<List<HealthMeasurement>> getMeasurementsByDateRange(
    int userId,
    DateTime startDate,
    DateTime endDate,
    {String? type}
  ) {
    var query = select(healthMeasurements)
      ..where((h) =>
          h.userId.equals(userId) &
          h.recordedAt.isBiggerOrEqualValue(startDate) &
          h.recordedAt.isSmallerOrEqualValue(endDate));
    
    if (type != null) {
      query = query..where((h) => h.type.equals(type));
    }
    
    return (query..orderBy([(h) => OrderingTerm.asc(h.recordedAt)])).get();
  }
}
