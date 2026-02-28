import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/app_database.dart';

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

    await _prefs.setInt(_keyUserId, id);
    await _prefs.setString(_keySelectedRole, role);
    return id;
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

    await _prefs.setInt(_keyUserId, user.id);
    await _prefs.setString(_keySelectedRole, user.role);
    return user.id;
  }

  Future<void> logout() async {
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keySelectedRole);
    // Keep hasSeenOnboarding (user has seen the slides, no need to show again)
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
