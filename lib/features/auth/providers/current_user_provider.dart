import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client.dart';
import 'auth_provider.dart';

class UserData {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isPremium;
  final String language;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final String? caregiverId;
  final String? inviteCode;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isPremium,
    required this.language,
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.createdAt,
    this.caregiverId,
    this.inviteCode,
  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
      isPremium: map['is_premium'] as bool? ?? false,
      language: map['language'] as String? ?? 'en',
      isDarkMode: map['is_dark_mode'] as bool? ?? true,
      notificationsEnabled: map['notifications_enabled'] as bool? ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
      caregiverId: map['caregiver_id'] as String?,
      inviteCode: map['invite_code'] as String?,
    );
  }
}

final currentUserProvider = FutureProvider<UserData?>((ref) async {
  final authState = ref.watch(authStateChangesProvider).value;
  if (authState != AuthState.authenticated) return null;

  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return null;

  final row = await supabase
      .from('profiles')
      .select()
      .eq('id', userId)
      .maybeSingle();

  if (row == null) return null;
  return UserData.fromMap(row);
});
