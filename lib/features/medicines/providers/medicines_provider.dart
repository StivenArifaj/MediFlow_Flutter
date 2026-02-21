import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';
import '../../../features/auth/providers/auth_provider.dart';

/// Watches all active medicines for the current user
final medicinesProvider = FutureProvider<List<Medicine>>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  final userId = repo.currentUserId;
  if (userId == null) return [];
  final db = ref.watch(appDatabaseProvider);
  return db.medicinesDao.getAllMedicines(userId);
});

/// Provider for a single medicine by ID
final medicineByIdProvider =
    FutureProvider.family<Medicine?, int>((ref, id) async {
  final db = ref.watch(appDatabaseProvider);
  return db.medicinesDao.getMedicineById(id);
});
