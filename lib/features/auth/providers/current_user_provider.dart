import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_provider.dart';

class UserData {
  final String name;
  final String email;
  final String role;

  UserData({
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserData.fromFirestore(Map<String, dynamic> data, String role) {
    return UserData(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: role,
    );
  }
}

final currentUserProvider = FutureProvider<UserData?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  final uid = repo.firebaseUid;
  final role = repo.selectedRole;

  if (uid == null) return null;

  try {
    final fs = FirebaseFirestore.instance;
    String collectionName;

    // Determine which collection to look in based on role
    if (role == 'caregiver') {
      collectionName = 'caregivers';
    } else if (role == 'linked_patient') {
      collectionName = 'linkedPatients';
    } else {
      collectionName = 'patients';
    }

    final doc = await fs.collection(collectionName).doc(uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      // For caregivers, profile is nested
      if (role == 'caregiver' && data['profile'] != null) {
        return UserData(
          name: data['profile']['name'] ?? '',
          email: data['profile']['email'] ?? '',
          role: role,
        );
      }
      return UserData.fromFirestore(data, role);
    }
  } catch (e) {
    // Return null on error
  }

  return null;
});