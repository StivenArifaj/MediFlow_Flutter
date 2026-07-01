import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/supabase_data_service.dart';
import '../../core/hooks/managed_user_id.dart';
import '../../core/supabase/supabase_client.dart';
import '../auth/providers/current_user_provider.dart';

final profileStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final userId = await ref.watch(managedUserIdProvider.future);
  if (userId == null) {
    return {'medicines': 0, 'reminders': 0, 'taken': 0, 'adherence': 0, 'streak': 0};
  }
  final svc = ref.read(supabaseDataServiceProvider);
  return svc.getProfileStats(userId);
});

/// Patient profile linked to the current caregiver (null if none linked).
final linkedPatientProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null || user.role != 'caregiver') return null;
  return supabase
      .from('profiles')
      .select('id, name, email')
      .eq('caregiver_id', user.id)
      .maybeSingle();
});

/// Patient's medicines + history + adherence — for caregiver dashboard.
final caregiverPatientDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final patientId = await ref.watch(managedUserIdProvider.future);
  if (patientId == null) {
    return {'medicines': <Map<String, dynamic>>[], 'recentHistory': <Map<String, dynamic>>[], 'adherence': 0};
  }
  final svc = ref.read(supabaseDataServiceProvider);
  final medicines = await svc.getMedicines(patientId);
  final history = await svc.getHistory(patientId, limit: 30);
  final taken = history.where((h) => h['status'] == 'taken' || h['status'] == 'taken_late').length;
  final adherence = history.isEmpty ? 0 : (taken / history.length * 100).round();
  return {'medicines': medicines, 'recentHistory': history, 'adherence': adherence};
});
