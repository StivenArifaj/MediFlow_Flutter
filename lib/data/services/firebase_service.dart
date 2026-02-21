import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Whether Firebase initialised successfully.
bool _firebaseReady = false;
bool get isFirebaseReady => _firebaseReady;

/// Safe Firebase init — app continues offline if it fails.
Future<void> initFirebase() async {
  try {
    await Firebase.initializeApp();
    _firebaseReady = true;
  } catch (e) {
    _firebaseReady = false;
    // ignore — app works fully offline with SQLite
  }
}

FirebaseFirestore get _fs => FirebaseFirestore.instance;

// ── Invite code helpers ──────────────────────────────────────────────────────

String generateInviteCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0/O/1/I confusion
  final rng = Random.secure();
  return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
}

/// Create caregiver profile + invite code in Firestore.
Future<String> createCaregiverProfile({
  required String caregiverUid,
  required String name,
  required String email,
  required String patientName,
}) async {
  if (!_firebaseReady) throw Exception('Firebase not available');

  final code = generateInviteCode();

  await _fs.collection('caregivers').doc(caregiverUid).set({
    'profile': {'name': name, 'email': email, 'role': 'caregiver'},
    'inviteCode': code,
    'patientName': patientName,
    'createdAt': FieldValue.serverTimestamp(),
  });

  return code;
}

/// Look up an invite code → returns caregiver data or null.
Future<Map<String, dynamic>?> lookupInviteCode(String code) async {
  if (!_firebaseReady) return null;

  final snap = await _fs
      .collection('caregivers')
      .where('inviteCode', isEqualTo: code.toUpperCase())
      .limit(1)
      .get();

  if (snap.docs.isEmpty) return null;
  final doc = snap.docs.first;
  return {
    'caregiverUid': doc.id,
    'patientName': doc.data()['patientName'] ?? '',
    'caregiverName': (doc.data()['profile'] as Map?)?['name'] ?? '',
    'inviteCode': code.toUpperCase(),
  };
}

/// Register a linked patient in Firestore.
Future<void> registerLinkedPatient({
  required String patientUid,
  required String caregiverUid,
  required String inviteCode,
  required String name,
}) async {
  if (!_firebaseReady) return;

  await _fs.collection('linkedPatients').doc(patientUid).set({
    'caregiverUid': caregiverUid,
    'inviteCode': inviteCode,
    'name': name,
    'role': 'linked_patient',
    'linkedAt': FieldValue.serverTimestamp(),
  });
}

/// Regenerate invite code for caregiver.
Future<String> regenerateInviteCode(String caregiverUid) async {
  if (!_firebaseReady) throw Exception('Firebase not available');
  final code = generateInviteCode();
  await _fs.collection('caregivers').doc(caregiverUid).update({
    'inviteCode': code,
  });
  return code;
}

/// Unlink a patient.
Future<void> unlinkPatient(String caregiverUid) async {
  if (!_firebaseReady) return;
  // Remove all linked patients pointing to this caregiver
  final snap = await _fs
      .collection('linkedPatients')
      .where('caregiverUid', isEqualTo: caregiverUid)
      .get();
  for (final doc in snap.docs) {
    await doc.reference.delete();
  }
}

// ── Sync helpers ─────────────────────────────────────────────────────────────

/// Push a medicine to caregiver's Firestore subcollection.
Future<void> syncMedicineToFirestore({
  required String caregiverUid,
  required String medicineId,
  required Map<String, dynamic> data,
}) async {
  if (!_firebaseReady) return;
  await _fs
      .collection('caregivers')
      .doc(caregiverUid)
      .collection('medicines')
      .doc(medicineId)
      .set(data, SetOptions(merge: true));
}

/// Push a reminder to caregiver's Firestore subcollection.
Future<void> syncReminderToFirestore({
  required String caregiverUid,
  required String reminderId,
  required Map<String, dynamic> data,
}) async {
  if (!_firebaseReady) return;
  await _fs
      .collection('caregivers')
      .doc(caregiverUid)
      .collection('reminders')
      .doc(reminderId)
      .set(data, SetOptions(merge: true));
}

/// Log a dose action (from linked patient).
Future<void> logDoseAction({
  required String caregiverUid,
  required String status,
  required String medicineId,
  required String medicineName,
}) async {
  if (!_firebaseReady) return;
  await _fs
      .collection('caregivers')
      .doc(caregiverUid)
      .collection('history')
      .add({
    'status': status,
    'medicineId': medicineId,
    'medicineName': medicineName,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

/// Stream today's medicines for a linked patient (from caregiver).
Stream<List<Map<String, dynamic>>> streamCaregiverMedicines(
    String caregiverUid) {
  if (!_firebaseReady) return const Stream.empty();
  return _fs
      .collection('caregivers')
      .doc(caregiverUid)
      .collection('medicines')
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList());
}

/// Stream today's reminders for a linked patient.
Stream<List<Map<String, dynamic>>> streamCaregiverReminders(
    String caregiverUid) {
  if (!_firebaseReady) return const Stream.empty();
  return _fs
      .collection('caregivers')
      .doc(caregiverUid)
      .collection('reminders')
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList());
}

/// Get today's dose history for the linked patient.
Future<List<Map<String, dynamic>>> getTodayHistory(
    String caregiverUid) async {
  if (!_firebaseReady) return [];
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final snap = await _fs
      .collection('caregivers')
      .doc(caregiverUid)
      .collection('history')
      .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .get();
  return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
}

/// Get linked patient info for a caregiver.
Future<Map<String, dynamic>?> getLinkedPatientForCaregiver(
    String caregiverUid) async {
  if (!_firebaseReady) return null;
  final snap = await _fs
      .collection('linkedPatients')
      .where('caregiverUid', isEqualTo: caregiverUid)
      .limit(1)
      .get();
  if (snap.docs.isEmpty) return null;
  return {'uid': snap.docs.first.id, ...snap.docs.first.data()};
}
