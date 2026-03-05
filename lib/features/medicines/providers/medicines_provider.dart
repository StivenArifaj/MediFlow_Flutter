import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';
import '../../../features/auth/providers/auth_provider.dart';

/// Watches all active medicines for the current user — auto-updates via Drift stream.
/// Switching from FutureProvider to StreamProvider means the home screen, profile,
/// and any other screen watching this provider will rebuild instantly when a medicine
/// is added, edited, or deleted — no manual invalidation needed.
final medicinesProvider = StreamProvider<List<Medicine>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final userId = repo.currentUserId;
  if (userId == null) return Stream.value([]);
  final db = ref.watch(appDatabaseProvider);
  return db.medicinesDao.watchAllMedicines(userId);
});

/// Provider for a single medicine by ID — also a stream so it reflects edits.
final medicineByIdProvider =
    StreamProvider.family<Medicine?, int>((ref, id) {
  final db = ref.watch(appDatabaseProvider);
  return db.medicinesDao.watchMedicineById(id);
});




