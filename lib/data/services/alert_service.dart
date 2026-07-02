import '../../core/supabase/supabase_client.dart';

/// Emergency alerts from a linked patient to their caregiver.
/// Backed by the `emergency_alerts` table — see
/// supabase/emergency_alerts.sql for the migration + RLS policies.
class AlertService {
  AlertService._();

  static Future<void> sendEmergencyAlert({
    required String patientId,
    required String caregiverId,
    String? message,
  }) async {
    await supabase.from('emergency_alerts').insert({
      'patient_id': patientId,
      'caregiver_id': caregiverId,
      if (message != null && message.isNotEmpty) 'message': message,
    });
  }

  static Future<List<Map<String, dynamic>>> pendingAlertsFor(
      String caregiverId) async {
    final rows = await supabase
        .from('emergency_alerts')
        .select()
        .eq('caregiver_id', caregiverId)
        .eq('acknowledged', false)
        .order('created_at', ascending: false);
    return rows.cast<Map<String, dynamic>>();
  }

  static Future<void> acknowledge(String alertId) async {
    await supabase
        .from('emergency_alerts')
        .update({'acknowledged': true}).eq('id', alertId);
  }
}
