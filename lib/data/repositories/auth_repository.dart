import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyUserId = 'mediflow_user_id';
const _keyHasSeenOnboarding = 'mediflow_has_seen_onboarding';
const _keySelectedRole = 'mediflow_selected_role';
const _keyFirebaseUid = 'mediflow_firebase_uid';

class AuthRepository {
  AuthRepository({
    required SharedPreferences prefs,
  }) : _prefs = prefs;

  final SharedPreferences _prefs;

  final _faAuth = fa.FirebaseAuth.instance;
  final _fs = FirebaseFirestore.instance;

  String? get currentUserId => _prefs.getString(_keyFirebaseUid);
  bool get hasSeenOnboarding => _prefs.getBool(_keyHasSeenOnboarding) ?? false;
  String? get selectedRole => _prefs.getString(_keySelectedRole);
  String? get firebaseUid => _prefs.getString(_keyFirebaseUid);

  Future<void> setHasSeenOnboarding(bool value) async {
    await _prefs.setBool(_keyHasSeenOnboarding, value);
  }

  Future<void> setSelectedRole(String role) async {
    await _prefs.setString(_keySelectedRole, role);
  }

  Future<bool> hasValidSession() async {
    final user = _faAuth.currentUser;
    return user != null;
  }

  Future<String> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Create user in Firebase Auth
      final credential = await _faAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthException('Failed to create user');
      }

      // Update display name
      await user.updateDisplayName(name);

      // Store Firebase UID
      await _prefs.setString(_keyFirebaseUid, user.uid);
      await _prefs.setString(_keySelectedRole, role);

      // Create user profile in appropriate Firestore collection
      await _createFirestoreProfile(user.uid, name, email, role);

      return user.uid;
    } on fa.FirebaseAuthException catch (e) {
      throw AuthException(_getFirebaseErrorMessage(e));
    }
  }

  Future<void> _createFirestoreProfile(String uid, String name, String email, String role) async {
    final now = FieldValue.serverTimestamp();

    if (role == 'caregiver') {
      // Create caregiver profile with invite code
      final code = _generateInviteCode();
      await _fs.collection('caregivers').doc(uid).set({
        'profile': {'name': name, 'email': email, 'role': 'caregiver'},
        'inviteCode': code,
        'linkedPatientName': '',
        'createdAt': now,
      });
    } else if (role == 'linked_patient') {
      // Create linked patient profile (minimal - will be linked to caregiver)
      await _fs.collection('linkedPatients').doc(uid).set({
        'name': name,
        'email': email,
        'role': 'linked_patient',
        'caregiverUid': '',
        'linkedAt': now,
      });
    } else {
      // Regular patient
      await _fs.collection('patients').doc(uid).set({
        'name': name,
        'email': email,
        'role': 'patient',
        'createdAt': now,
      });
    }

    // Also create in general users collection for lookup
    await _fs.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'role': role,
      'createdAt': now,
    });
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = DateTime.now().millisecondsSinceEpoch;
    return List.generate(6, (i) => chars[(rng + i) % chars.length]).join();
  }

  String _getFirebaseErrorMessage(fa.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return e.message ?? 'Registration failed';
    }
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _faAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthException('Invalid email or password');
      }

      // Store Firebase UID
      await _prefs.setString(_keyFirebaseUid, user.uid);

      // Get user role from Firestore
      final role = await _getUserRole(user.uid);
      await _prefs.setString(_keySelectedRole, role ?? 'patient');

      return user.uid;
    } on fa.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw AuthException('Invalid email or password');
      }
      throw AuthException(e.message ?? 'Login failed');
    }
  }

  Future<String?> _getUserRole(String uid) async {
    try {
      final doc = await _fs.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'] as String?;
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final uid = firebaseUid;
    if (uid == null) return null;

    try {
      // First check patients collection
      final patientDoc = await _fs.collection('patients').doc(uid).get();
      if (patientDoc.exists) {
        return patientDoc.data();
      }

      // Then check caregivers collection
      final caregiverDoc = await _fs.collection('caregivers').doc(uid).get();
      if (caregiverDoc.exists) {
        return caregiverDoc.data();
      }

      // Then check linkedPatients collection
      final linkedDoc = await _fs.collection('linkedPatients').doc(uid).get();
      if (linkedDoc.exists) {
        return linkedDoc.data();
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  Future<void> logout() async {
    await _faAuth.signOut();
    await _prefs.remove(_keyFirebaseUid);
    await _prefs.remove(_keySelectedRole);
  }

  String? getCurrentFirebaseUid() {
    return _faAuth.currentUser?.uid;
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
}