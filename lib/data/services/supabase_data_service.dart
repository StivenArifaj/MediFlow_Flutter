import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_client.dart';

class SupabaseDataService {
  final SupabaseClient _client;
  SupabaseDataService(this._client);

  // ─── MEDICINES ──────────────────────────────

  Future<List<Map<String, dynamic>>> getMedicines(String userId) async {
    final data = await _client
        .from('medicines')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>?> getMedicineById(String medicineId) async {
    return await _client
        .from('medicines')
        .select()
        .eq('id', medicineId)
        .maybeSingle();
  }

  Future<Map<String, dynamic>> createMedicine({
    required String userId,
    required String verifiedName,
    String? brandName,
    String? genericName,
    String? manufacturer,
    String? strength,
    String? form,
    String? category,
    int? quantity,
    String? notes,
    String? expiryDate,
    String apiSource = 'manual',
  }) async {
    final data = await _client
        .from('medicines')
        .insert({
          'user_id': userId,
          'verified_name': verifiedName,
          'brand_name': brandName,
          'generic_name': genericName,
          'manufacturer': manufacturer,
          'strength': strength,
          'form': form,
          'category': category,
          'quantity': quantity,
          'notes': notes,
          'expiry_date': expiryDate,
          'api_source': apiSource,
          'is_active': true,
        })
        .select()
        .single();
    return Map<String, dynamic>.from(data);
  }

  Future<void> updateMedicine(
      String medicineId, Map<String, dynamic> updates) async {
    await _client.from('medicines').update(updates).eq('id', medicineId);
  }

  Future<void> deleteMedicine(String medicineId) async {
    await _client
        .from('medicines')
        .update({'is_active': false})
        .eq('id', medicineId);
  }

  // ─── REMINDERS ──────────────────────────────

  Future<List<Map<String, dynamic>>> getReminders(
    String userId, {
    String? medicineId,
  }) async {
    var query = _client
        .from('reminders')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true);
    if (medicineId != null) {
      query = query.eq('medicine_id', medicineId);
    }
    final data = await query.order('created_at');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> createReminder({
    required String userId,
    required String medicineId,
    required String time,
    String frequency = 'daily',
    List<String>? days,
    int? intervalDays,
    String durationType = 'ongoing',
    String? endDate,
    int? durationDays,
    int snoozeDuration = 15,
  }) async {
    final data = await _client
        .from('reminders')
        .insert({
          'user_id': userId,
          'medicine_id': medicineId,
          'time': time,
          'frequency': frequency,
          'days': days,
          'interval_days': intervalDays,
          'duration_type': durationType,
          'end_date': endDate,
          'duration_days': durationDays,
          'snooze_duration': snoozeDuration,
          'is_active': true,
        })
        .select()
        .single();
    return Map<String, dynamic>.from(data);
  }

  Future<void> deleteReminder(String reminderId) async {
    await _client
        .from('reminders')
        .update({'is_active': false})
        .eq('id', reminderId);
  }

  Future<void> deleteRemindersForMedicine(String medicineId) async {
    await _client
        .from('reminders')
        .update({'is_active': false})
        .eq('medicine_id', medicineId);
  }

  // ─── TODAY'S SCHEDULE ───────────────────────

  Future<List<Map<String, dynamic>>> getTodayReminders(String userId) async {
    final data = await _client
        .from('reminders')
        .select('*, medicines(*)')
        .eq('user_id', userId)
        .eq('is_active', true);
    return List<Map<String, dynamic>>.from(data);
  }

  // ─── HISTORY ────────────────────────────────

  Future<List<Map<String, dynamic>>> getHistory(
    String userId, {
    int limit = 100,
  }) async {
    final data = await _client
        .from('history_entries')
        .select('*, medicines(verified_name, strength, form)')
        .eq('user_id', userId)
        .order('scheduled_time', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getTodayHistory(String userId) async {
    final now = DateTime.now();
    final startOfDay =
        DateTime(now.year, now.month, now.day).toUtc().toIso8601String();
    final endOfDay =
        DateTime(now.year, now.month, now.day + 1).toUtc().toIso8601String();

    final data = await _client
        .from('history_entries')
        .select()
        .eq('user_id', userId)
        .gte('scheduled_time', startOfDay)
        .lt('scheduled_time', endOfDay);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> logDose({
    required String userId,
    required String medicineId,
    required String reminderId,
    required String status,
    required DateTime scheduledTime,
    DateTime? actualTime,
    String? existingEntryId,
    String? notes,
  }) async {
    final now = actualTime ?? DateTime.now();
    if (existingEntryId != null) {
      await _client.from('history_entries').update({
        'status': status,
        'actual_time': now.toUtc().toIso8601String(),
      }).eq('id', existingEntryId);
      return;
    }
    await _client.from('history_entries').insert({
      'user_id': userId,
      'medicine_id': medicineId,
      'reminder_id': reminderId,
      'status': status,
      'scheduled_time': scheduledTime.toUtc().toIso8601String(),
      'actual_time': now.toUtc().toIso8601String(),
      'notes': notes,
    });
  }

  // ─── HEALTH MEASUREMENTS ────────────────────

  Future<List<Map<String, dynamic>>> getMeasurements(
    String userId, {
    String? type,
    int limit = 100,
  }) async {
    var query = _client
        .from('health_measurements')
        .select()
        .eq('user_id', userId);
    if (type != null) query = query.eq('type', type);
    final data = await query
        .order('recorded_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> createMeasurement({
    required String userId,
    required String type,
    required double value,
    double? valueSecondary,
    required String unit,
    String? notes,
  }) async {
    final data = await _client
        .from('health_measurements')
        .insert({
          'user_id': userId,
          'type': type,
          'value': value,
          'value_secondary': valueSecondary,
          'unit': unit,
          'notes': notes,
          'recorded_at': DateTime.now().toUtc().toIso8601String(),
        })
        .select()
        .single();
    return Map<String, dynamic>.from(data);
  }

  Future<void> deleteMeasurement(String id) async {
    await _client.from('health_measurements').delete().eq('id', id);
  }

  Future<Map<String, Map<String, dynamic>>> getLatestMeasurements(
      String userId) async {
    final data = await _client
        .from('health_measurements')
        .select()
        .eq('user_id', userId)
        .order('recorded_at', ascending: false)
        .limit(200);

    final latest = <String, Map<String, dynamic>>{};
    for (final row in List<Map<String, dynamic>>.from(data)) {
      final type = row['type'] as String;
      if (!latest.containsKey(type)) latest[type] = row;
    }
    return latest;
  }

  // ─── PROFILE STATS ──────────────────────────

  Future<Map<String, dynamic>> getProfileStats(String userId) async {
    final now = DateTime.now();
    final thirtyDaysAgo = now
        .subtract(const Duration(days: 30))
        .toUtc()
        .toIso8601String();

    final countResults = await Future.wait<PostgrestResponse>([
      _client
          .from('medicines')
          .select('id')
          .eq('user_id', userId)
          .eq('is_active', true)
          .count(CountOption.exact),
      _client
          .from('reminders')
          .select('id')
          .eq('user_id', userId)
          .eq('is_active', true)
          .count(CountOption.exact),
      _client
          .from('history_entries')
          .select('id')
          .eq('user_id', userId)
          .inFilter('status', ['taken', 'taken_late'])
          .count(CountOption.exact),
    ]);

    final recent = await _client
        .from('history_entries')
        .select('status,scheduled_time')
        .eq('user_id', userId)
        .gte('scheduled_time', thirtyDaysAgo);

    final taken30 = recent
        .where((r) => r['status'] == 'taken' || r['status'] == 'taken_late')
        .length;
    final total30 = recent.length;
    final adherence = total30 > 0 ? (taken30 / total30 * 100).round() : 0;

    final takenDays = <String>{};
    for (final r in recent) {
      if (r['status'] == 'taken' || r['status'] == 'taken_late') {
        final d = DateTime.parse(r['scheduled_time'] as String);
        takenDays.add('${d.year}-${d.month}-${d.day}');
      }
    }
    var streak = 0;
    var cursor = DateTime.now();
    while (takenDays.contains('${cursor.year}-${cursor.month}-${cursor.day}')) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return {
      'medicines': countResults[0].count,
      'reminders': countResults[1].count,
      'taken': countResults[2].count,
      'adherence': adherence,
      'streak': streak,
    };
  }
}

final supabaseDataServiceProvider = Provider<SupabaseDataService>((ref) {
  return SupabaseDataService(supabase);
});
