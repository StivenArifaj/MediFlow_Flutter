import 'dart:math';

import '../../core/supabase/supabase_client.dart';

bool get isFirebaseReady => true;

Future<void> initFirebase() async {}

String generateInviteCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final rng = Random.secure();
  return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
}

Future<String> createCaregiverProfile({
  required String caregiverUid,
  required String name,
  required String email,
  required String patientName,
}) async => generateInviteCode();

Future<Map<String, dynamic>?> lookupInviteCode(String code) async {
  final result = await supabase.rpc('lookup_invite_code', params: {'code': code});
  final List<dynamic> rows;
  if (result is List) {
    rows = result;
  } else {
    return null;
  }
  if (rows.isEmpty) return null;
  final row = rows.first as Map<String, dynamic>;
  return {
    'caregiverUid': row['id'],
    'caregiverName': row['name'],
    'patientName': null,
  };
}

Future<void> registerLinkedPatient({
  required String patientUid,
  required String caregiverUid,
  required String inviteCode,
  required String name,
}) async {
  await supabase.rpc('link_patient', params: {
    'p_patient_id': patientUid,
    'p_caregiver_id': caregiverUid,
  });
}

Future<String> regenerateInviteCode(String caregiverUid) async =>
    generateInviteCode();

Future<void> unlinkPatient(String caregiverUid) async {
  await supabase.from('profiles').update({
    'caregiver_id': null,
  }).eq('id', caregiverUid);
}

Future<void> syncMedicineToFirestore({
  required String caregiverUid,
  required String medicineId,
  required Map<String, dynamic> data,
}) async {}

Future<void> syncReminderToFirestore({
  required String caregiverUid,
  required String reminderId,
  required Map<String, dynamic> data,
}) async {}

Future<void> logDoseAction({
  required String caregiverUid,
  required String status,
  required String medicineId,
  required String medicineName,
}) async {}

Future<void> syncPatientMedicineToFirestore({
  required String patientUid,
  required String medicineId,
  required Map<String, dynamic> data,
}) async {}

Future<void> syncPatientReminderToFirestore({
  required String patientUid,
  required String reminderId,
  required Map<String, dynamic> data,
}) async {}

Future<void> logPatientDoseAction({
  required String patientUid,
  required String status,
  required String medicineId,
  required String medicineName,
}) async {}

Stream<List<Map<String, dynamic>>> streamCaregiverMedicines(
    String caregiverUid) =>
    const Stream.empty();

Stream<List<Map<String, dynamic>>> streamCaregiverReminders(
    String caregiverUid) =>
    const Stream.empty();

Future<List<Map<String, dynamic>>> getTodayHistory(String caregiverUid) async =>
    [];

Future<Map<String, dynamic>?> getLinkedPatientForCaregiver(
    String caregiverUid) async =>
    null;
