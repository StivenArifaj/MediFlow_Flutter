import '../../core/supabase/supabase_client.dart';

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

Future<void> unlinkPatient(String caregiverUid) async {
  await supabase.from('profiles').update({
    'caregiver_id': null,
  }).eq('id', caregiverUid);
}
