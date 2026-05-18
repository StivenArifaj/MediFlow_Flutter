import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../database/app_database.dart';
import '../services/firebase_service.dart';

const _keyUserId = 'mediflow_user_id';
const _keyHasSeenOnboarding = 'mediflow_has_seen_onboarding';
const _keySelectedRole = 'mediflow_selected_role';

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

  int? get currentUserId => _prefs.getInt(_keyUserId);
  bool get hasSeenOnboarding => _prefs.getBool(_keyHasSeenOnboarding) ?? false;
  String? get selectedRole => _prefs.getString(_keySelectedRole);

  Future<void> setHasSeenOnboarding(bool value) async {
    await _prefs.setBool(_keyHasSeenOnboarding, value);
  }

  Future<void> setSelectedRole(String role) async {
    await _prefs.setString(_keySelectedRole, role);
  }

  Future<bool> hasValidSession() async {
    final userId = currentUserId;
    if (userId == null) return false;
    final user = await _db.usersDao.getUserById(userId);
    return user != null;
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
    // First create local user
    final existing = await _db.usersDao.emailExists(email);
    if (existing) {
      throw AuthException('Email already registered');
    }

    final hash = _hashPassword(password);
    final now = DateTime.now();
    final id = await _db.usersDao.insertUser(
      UsersCompanion.insert(
        name: name,
        email: email,
        passwordHash: hash,
        role: Value(role),
        isDarkMode: Value(isDarkMode),
        notificationsEnabled: const Value(true),
        createdAt: now,
      ),
    );

    // Try to also create Firebase Auth account if Firebase is ready
    final auth = firebaseAuth;
    if (auth != null) {
      try {
        final credential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        if (credential.user != null) {
          // Update local user with Firebase UID
          final user = await _db.usersDao.getUserById(id);
          if (user != null) {
            await _db.usersDao.updateUser(
              user.copyWithCompanion(UsersCompanion(firebaseUid: Value(credential.user!.uid))),
            );
          }
          
          // Create Firestore profile
          await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
            'name': name,
            'email': email,
            'role': role,
            'createdAt': FieldValue.serverTimestamp(),
          });
          
          // Create caregiver profile if needed
          if (role == 'caregiver') {
            await _createCaregiverProfile(credential.user!.uid, name, email);
          }
        }
      } catch (e) {
        // Continue with local auth even if Firebase fails
      }
    }

    await _prefs.setInt(_keyUserId, id);
    await _prefs.setString(_keySelectedRole, role);
    return id;
  }

  Future<void> _createCaregiverProfile(String uid, String name, String email) async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = DateTime.now().millisecondsSinceEpoch;
    final code = List.generate(6, (i) => chars[(rng + i) % chars.length]).join();

    try {
      await FirebaseFirestore.instance.collection('caregivers').doc(uid).set({
        'profile': {'name': name, 'email': email, 'role': 'caregiver'},
        'inviteCode': code,
        'patientName': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Ignore Firestore errors
    }
  }

  Future<int> login({
    required String email,
    required String password,
  }) async {
    final user = await _db.usersDao.getUserByEmail(email);
    if (user == null) {
      throw AuthException('Invalid email or password');
    }

    final hash = _hashPassword(password);
    if (hash != user.passwordHash) {
      throw AuthException('Invalid email or password');
    }

    // Try Firebase login if available
    final auth = firebaseAuth;
    if (auth != null) {
      try {
        await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        // Continue with local login
      }
    }

    await _prefs.setInt(_keyUserId, user.id);
    await _prefs.setString(_keySelectedRole, user.role);
    return user.id;
  }

  Future<void> logout() async {
    try {
      final auth = firebaseAuth;
      if (auth != null && auth.currentUser != null) {
        await auth.signOut();
      }
    } catch (e) {
      // Ignore Firebase logout errors
    }
    try {
      await _prefs.remove(_keyUserId);
      await _prefs.remove(_keySelectedRole);
    } catch (e) {
      // Ignore prefs errors
    }
  }

  Future<User?> getCurrentUser() async {
    final userId = currentUserId;
    if (userId == null) return null;
    return _db.usersDao.getUserById(userId);
  }

  /// Get Firebase UID if user logged in with Firebase
  String? getFirebaseUid() {
    final auth = firebaseAuth;
    return auth?.currentUser?.uid;
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
}