import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
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

    // Try to create Firebase Auth account silently
    // If it fails, we still have local auth working
    try {
      final credential = await _faAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await _prefs.setString(_keyFirebaseUid, credential.user!.uid);
        
        // Update local user with Firebase UID
        final user = await _db.usersDao.getUserById(id);
        if (user != null) {
          await _db.usersDao.updateUser(
            user.copyWithCompanion(UsersCompanion(firebaseUid: Value(credential.user!.uid))),
          );
        }
        
        // Create Firestore profile
        await _fs.collection('users').doc(credential.user!.uid).set({
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

    await _prefs.setInt(_keyUserId, id);
    await _prefs.setString(_keySelectedRole, role);
    return id;
  }

  Future<void> _createCaregiverProfile(String uid, String name, String email) async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = DateTime.now().millisecondsSinceEpoch;
    final code = List.generate(6, (i) => chars[(rng + i) % chars.length]).join();

    try {
      await _fs.collection('caregivers').doc(uid).set({
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

    // Try Firebase Auth for session persistence
    try {
      await _faAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // Continue with local login even if Firebase fails
    }

    await _prefs.setInt(_keyUserId, user.id);
    await _prefs.setString(_keySelectedRole, user.role);
    return user.id;
  }

  Future<void> logout() async {
    try {
      await _faAuth.signOut();
    } catch (e) {
      // Ignore Firebase logout errors
    }
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keySelectedRole);
  }

  Future<User?> getCurrentUser() async {
    final userId = currentUserId;
    if (userId == null) return null;
    return _db.usersDao.getUserById(userId);
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
}