import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../database/app_database.dart';

const _keyUserId = 'mediflow_user_id';
const _keyHasSeenOnboarding = 'mediflow_has_seen_onboarding';
const _keySelectedRole = 'mediflow_selected_role';
const _keyFirebaseUid = 'mediflow_firebase_uid';

String _hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

class AuthRepository {
  AuthRepository({
    required AppDatabase database,
    required SharedPreferences prefs,
  })  : _db = database,
        _prefs = prefs;

  final AppDatabase _db;
  final SharedPreferences _prefs;

  final _faAuth = fa.FirebaseAuth.instance;
  final _fs = FirebaseFirestore.instance;

  int? get currentUserId => _prefs.getInt(_keyUserId);
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
    if (user != null) {
      return true;
    }
    
    // Check if we have a stored user ID from previous session
    final storedUid = firebaseUid;
    if (storedUid != null) {
      // Try to re-authenticate silently
      try {
        // We'll need to store the email to re-authenticate
        return false;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<void> updateUserRole(int userId, String role) async {
    await setSelectedRole(role);
    final user = await _db.usersDao.getUserById(userId);
    if (user != null) {
      await _db.usersDao.updateUser(
        user.copyWithCompanion(UsersCompanion(role: Value(role))),
      );
    }
  }

  Future<int> register({
    required String name,
    required String email,
    required String password,
    required String role,
    bool isDarkMode = true,
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

      // Create user profile in Firestore
      await _fs.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create caregiver profile if needed
      if (role == 'caregiver') {
        await _createCaregiverProfile(user.uid, name, email);
      }

      // Also store locally in SQLite for offline support
      final existingLocal = await _db.usersDao.emailExists(email);
      if (!existingLocal) {
        final hash = _hashPassword(password);
        final now = DateTime.now();
        final id = await _db.usersDao.insertUser(
          UsersCompanion.insert(
            name: name,
            email: email,
            passwordHash: hash,
            role: Value(role),
            firebaseUid: Value(user.uid),
            isDarkMode: Value(isDarkMode),
            notificationsEnabled: const Value(true),
            createdAt: now,
          ),
        );
        await _prefs.setInt(_keyUserId, id);
      }

      await _prefs.setString(_keySelectedRole, role);
      return user.uid.hashCode;
    } on fa.FirebaseAuthException catch (e) {
      throw AuthException(_getFirebaseErrorMessage(e));
    }
  }

  Future<void> _createCaregiverProfile(String uid, String name, String email) async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = DateTime.now().millisecondsSinceEpoch;
    final code = List.generate(6, (i) => chars[(rng + i) % chars.length]).join();

    await _fs.collection('caregivers').doc(uid).set({
      'profile': {'name': name, 'email': email, 'role': 'caregiver'},
      'inviteCode': code,
      'patientName': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
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

  Future<int> login({
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

      // Get or create local user
      var localUser = await _db.usersDao.getUserByEmail(email);
      if (localUser == null) {
        // Create local user from Firebase user
        final hash = _hashPassword(password);
        final now = DateTime.now();
        final id = await _db.usersDao.insertUser(
          UsersCompanion.insert(
            name: user.displayName ?? email.split('@').first,
            email: email,
            passwordHash: hash,
            role: Value('patient'),
            firebaseUid: Value(user.uid),
            isDarkMode: const Value(true),
            notificationsEnabled: const Value(true),
            createdAt: now,
          ),
        );
        localUser = await _db.usersDao.getUserById(id);
      }

      if (localUser != null) {
        await _prefs.setInt(_keyUserId, localUser.id);
        await _prefs.setString(_keySelectedRole, localUser.role);
      }

      return localUser?.id ?? user.uid.hashCode;
    } on fa.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw AuthException('Invalid email or password');
      }
      throw AuthException(e.message ?? 'Login failed');
    }
  }

  Future<void> logout() async {
    await _faAuth.signOut();
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keySelectedRole);
    // Keep firebaseUid for potential re-auth
  }

  Future<User?> getCurrentUser() async {
    final user = _faAuth.currentUser;
    if (user != null) {
      return await _db.usersDao.getUserById(currentUserId ?? 0);
    }
    
    final userId = currentUserId;
    if (userId == null) return null;
    return _db.usersDao.getUserById(userId);
  }

  String? getCurrentFirebaseUid() {
    return _faAuth.currentUser?.uid;
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
}