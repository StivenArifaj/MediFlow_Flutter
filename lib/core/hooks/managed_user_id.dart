import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/current_user_provider.dart';
import '../supabase/supabase_client.dart';

/// Returns the user_id that data should be written to and read from.
/// - patient / linked_patient → own ID
/// - caregiver → first linked patient's ID
final managedUserIdProvider = FutureProvider<String?>((ref) async {
  final userData = await ref.watch(currentUserProvider.future);
  if (userData == null) return null;

  if (userData.role == 'caregiver') {
    final row = await supabase
        .from('profiles')
        .select('id')
        .eq('caregiver_id', userData.id)
        .maybeSingle();
    return row?['id'] as String?;
  }

  return userData.id;
});
