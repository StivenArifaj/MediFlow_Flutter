import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/widgets/app_background.dart';
import '../../../core/supabase/supabase_client.dart';

class EmailConfirmationScreen extends ConsumerWidget {
  final String email;
  const EmailConfirmationScreen({required this.email, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00D4D4).withValues(alpha: 0.15),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D4D4).withValues(alpha: 0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mark_email_unread_outlined,
                      size: 48, color: Color(0xFF00D4D4)),
                ),
                const SizedBox(height: 32),
                const Text('Check your email',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 16),
                Text(
                  'We sent a confirmation link to\n$email\n\n'
                  'Open it to activate your account, then come back to log in.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, color: Color(0xFF8FA3B8), height: 1.5),
                ),
                const SizedBox(height: 40),
                OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await supabase.auth.resend(
                        type: OtpType.signup,
                        email: email,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Confirmation email resent!')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())));
                      }
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Resend confirmation email'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00D4D4),
                    side: const BorderSide(color: Color(0xFF00D4D4)),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Back to login',
                      style: TextStyle(color: Color(0xFF8FA3B8))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
