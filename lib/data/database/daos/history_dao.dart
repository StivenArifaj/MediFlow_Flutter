import 'package:drift/drift.dart';
import 'package:mediflow/data/database/app_database.dart';

part 'history_dao.g.dart';

@DriftAccessor(tables: [HistoryEntries])
class HistoryDao extends DatabaseAccessor<AppDatabase> with _$HistoryDaoMixin {
  HistoryDao(super.db);

  Future<List<HistoryEntry>> getHistoryForUser(int userId, {DateTime? startDate, DateTime? endDate}) {
    var query = select(historyEntries)..where((h) => h.userId.equals(userId));
    
    if (startDate != null) {
      query = query..where((h) => h.scheduledTime.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query = query..where((h) => h.scheduledTime.isSmallerOrEqualValue(endDate));
    }
    
    return (query..orderBy([(h) => OrderingTerm.desc(h.scheduledTime)])).get();
  }

  Future<List<HistoryEntry>> getHistoryForMedicine(int medicineId) {
    return (select(historyEntries)
          ..where((h) => h.medicineId.equals(medicineId))
          ..orderBy([(h) => OrderingTerm.desc(h.scheduledTime)]))
        .get();
  }

  Future<HistoryEntry?> getHistoryById(int id) {
    return (select(historyEntries)..where((h) => h.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertHistoryEntry(HistoryEntriesCompanion entry) {
    return into(historyEntries).insert(entry);
  }

  Future<int> deleteHistoryEntry(int id) {
    return (delete(historyEntries)..where((h) => h.id.equals(id))).go();
  }

  Future<List<HistoryEntry>> getHistoryByStatus(int userId, String status) {
    return (select(historyEntries)
          ..where((h) => h.userId.equals(userId) & h.status.equals(status))
          ..orderBy([(h) => OrderingTerm.desc(h.scheduledTime)]))
        .get();
  }
}
