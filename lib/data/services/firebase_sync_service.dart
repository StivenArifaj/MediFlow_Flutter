import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to sync with Firebase when needed
/// Used for linking mobile app with web dashboard
class FirebaseSyncService {
  static final _faAuth = fa.FirebaseAuth.instance;
  static final _fs = FirebaseFirestore.instance;

  /// Try to link local account with Firebase
  static Future<bool> linkWithFirebase({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _faAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user != null;
    } catch (e) {
      return false;
    }
  }

  /// Get Firebase UID for current user
  static String? getCurrentUid() {
    return _faAuth.currentUser?.uid;
  }

  /// Create caregiver profile in Firestore
  static Future<void> createCaregiverProfile({
    required String uid,
    required String name,
    required String email,
    String? patientName,
  }) async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = DateTime.now().millisecondsSinceEpoch;
    final code = List.generate(6, (i) => chars[(rng + i) % chars.length]).join();

    await _fs.collection('caregivers').doc(uid).set({
      'profile': {'name': name, 'email': email, 'role': 'caregiver'},
      'inviteCode': code,
      'patientName': patientName ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}