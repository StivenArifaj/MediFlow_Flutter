import 'package:drift/drift.dart';
import 'package:mediflow/data/database/app_database.dart';

part 'medicines_dao.g.dart';

@DriftAccessor(tables: [Medicines])
class MedicinesDao extends DatabaseAccessor<AppDatabase> with _$MedicinesDaoMixin {
  MedicinesDao(super.db);

  Future<List<Medicine>> getAllMedicines(int userId) {
    return (select(medicines)..where((m) => m.userId.equals(userId) & m.isActive.equals(true))).get();
  }

  Future<Medicine?> getMedicineById(int id) {
    return (select(medicines)..where((m) => m.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertMedicine(MedicinesCompanion medicine) {
    return into(medicines).insert(medicine);
  }

  Future<bool> updateMedicine(MedicinesCompanion medicine) {
    return update(medicines).replace(medicine);
  }

  Future<int> deleteMedicine(int id) {
    return (update(medicines)..where((m) => m.id.equals(id))).write(
      const MedicinesCompanion(isActive: Value(false)),
    );
  }

  Future<List<Medicine>> searchMedicines(int userId, String query) {
    return (select(medicines)
          ..where((m) =>
              m.userId.equals(userId) &
              m.isActive.equals(true) &
              (m.verifiedName.like('%$query%') |
                  m.brandName.like('%$query%') |
                  m.genericName.like('%$query%'))))
        .get();
  }
}
