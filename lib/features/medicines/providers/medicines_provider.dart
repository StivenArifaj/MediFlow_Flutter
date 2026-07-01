import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/supabase_data_service.dart';
import '../../../core/hooks/managed_user_id.dart';

final medicinesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userId = await ref.watch(managedUserIdProvider.future);
  if (userId == null) return [];
  return ref.read(supabaseDataServiceProvider).getMedicines(userId);
});

final medicineByIdProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  return ref.read(supabaseDataServiceProvider).getMedicineById(id);
});

final remindersForMedicineProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, medicineId) async {
  final userId = await ref.watch(managedUserIdProvider.future);
  if (userId == null) return [];
  return ref.read(supabaseDataServiceProvider).getReminders(userId, medicineId: medicineId);
});
