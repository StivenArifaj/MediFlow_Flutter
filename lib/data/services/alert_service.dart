import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_client.dart';

class AlertService {
  static const _table = 'emergency_alerts';

  /// Send an emergency alert from a linked patient
  /// to their caregiver. Handles rate limit error
  /// gracefully and returns a typed result.
  static Future<AlertResult> sendAlert({String? message}) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      return AlertResult.error('Not logged in');
    }

    // Get caregiver_id from profile
    final profile = await supabase
        .from('profiles')
        .select('caregiver_id, name')
        .eq('id', userId)
        .maybeSingle();

    final caregiverId = profile?['caregiver_id'] as String?;
    if (caregiverId == null) {
      return AlertResult.error('No caregiver linked to your account');
    }

    try {
      await supabase.from(_table).insert({
        'patient_id': userId,
        'caregiver_id': caregiverId,
        'message':
            message?.trim().isEmpty ?? true ? null : message!.trim(),
        'is_acknowledged': false,
      });
      return AlertResult.success();
    } on PostgrestException catch (e) {
      if (e.message.contains('rate_limit')) {
        return AlertResult.error(
            'Too many alerts sent recently.\n'
            'Please wait a few minutes before trying again.');
      }
      return AlertResult.error(
          'Could not send alert. Check your connection and try again.');
    } catch (e) {
      return AlertResult.error('Unexpected error. Please try again.');
    }
  }

  /// Get all unacknowledged alerts for the
  /// currently logged-in caregiver.
  static Future<List<Map<String, dynamic>>> getPendingAlerts() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await supabase
        .from(_table)
        .select('*, profiles!patient_id(name, email)')
        .eq('caregiver_id', userId)
        .eq('is_acknowledged', false)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  /// Get recent alert history (last 30 days) for either role.
  static Future<List<Map<String, dynamic>>> getAlertHistory() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final since = DateTime.now()
        .subtract(const Duration(days: 30))
        .toUtc()
        .toIso8601String();

    final data = await supabase
        .from(_table)
        .select('*, profiles!patient_id(name)')
        .or('patient_id.eq.$userId,caregiver_id.eq.$userId')
        .gte('created_at', since)
        .order('created_at', ascending: false)
        .limit(50);

    return List<Map<String, dynamic>>.from(data);
  }

  /// Acknowledge an alert (caregiver only).
  static Future<void> acknowledgeAlert(String alertId) async {
    await supabase.from(_table).update({
      'is_acknowledged': true,
      'acknowledged_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', alertId);
  }

  /// Subscribe to new alerts for a caregiver.
  /// Returns a RealtimeChannel to cancel later.
  static RealtimeChannel subscribeToAlerts({
    required String caregiverId,
    required void Function(Map<String, dynamic>) onAlert,
  }) {
    return supabase
        .channel('emergency_alerts_$caregiverId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: _table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'caregiver_id',
            value: caregiverId,
          ),
          callback: (payload) {
            if (payload.newRecord.isNotEmpty) {
              onAlert(payload.newRecord);
            }
          },
        )
        .subscribe();
  }
}

/// Typed result for sendAlert.
class AlertResult {
  final bool sent;
  final String? errorMessage;

  const AlertResult._({required this.sent, this.errorMessage});

  factory AlertResult.success() => const AlertResult._(sent: true);

  factory AlertResult.error(String message) =>
      AlertResult._(sent: false, errorMessage: message);
}
