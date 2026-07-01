import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/supabase_data_service.dart';
import '../../core/hooks/managed_user_id.dart';

final historyProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userId = await ref.watch(managedUserIdProvider.future);
  if (userId == null) return [];
  return ref.read(supabaseDataServiceProvider).getHistory(userId);
});
