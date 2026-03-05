import 'package:drift/drift.dart';
import 'package:mediflow/data/database/app_database.dart';

part 'medicines_dao.g.dart';

@DriftAccessor(tables: [Medicines])
class MedicinesDao extends DatabaseAccessor<AppDatabase>
    with _$MedicinesDaoMixin {
  MedicinesDao(super.db);

  // ── One-shot queries ─────────────────────────────────────────────────────

  Future<List<Medicine>> getAllMedicines(int userId) {
    return (select(medicines)
          ..where((m) => m.userId.equals(userId) & m.isActive.equals(true)))
        .get();
  }

  Future<Medicine?> getMedicineById(int id) {
    return (select(medicines)..where((m) => m.id.equals(id)))
        .getSingleOrNull();
  }

  // ── Reactive streams (Drift auto-notifies on any write to this table) ────

  /// Returns a live stream — emits a new list whenever medicines change.
  /// Use this in StreamProvider so home/profile update instantly after add/edit/delete.
  Stream<List<Medicine>> watchAllMedicines(int userId) {
    return (select(medicines)
          ..where((m) => m.userId.equals(userId) & m.isActive.equals(true))
          ..orderBy([(m) => OrderingTerm.asc(m.verifiedName)]))
        .watch();
  }

  /// Live stream for a single medicine — updates when that row changes.
  Stream<Medicine?> watchMedicineById(int id) {
    return (select(medicines)..where((m) => m.id.equals(id)))
        .watchSingleOrNull();
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  Future<int> insertMedicine(MedicinesCompanion medicine) {
    return into(medicines).insert(medicine);
  }

  Future<bool> updateMedicine(MedicinesCompanion medicine) {
    return update(medicines).replace(medicine);
  }

  /// Soft-delete: sets isActive = false so history references remain valid.
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

