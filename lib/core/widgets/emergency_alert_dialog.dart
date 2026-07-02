import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../supabase/supabase_client.dart';
import '../../data/services/alert_service.dart';
import '../../data/services/notification_service.dart';

String _formatAlertTime(DateTime dt) {
  final local = dt.toLocal();
  final now = DateTime.now();
  final isToday = local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
  return isToday
      ? 'Today at ${DateFormat('HH:mm').format(local)}'
      : DateFormat('d MMM yyyy · HH:mm').format(local);
}

/// Full emergency alert form shown to the caregiver when a linked
/// patient sends an SOS. Resolves the patient's name, then presents
/// a dialog that must be acknowledged.
Future<void> showEmergencyAlert(
  BuildContext context,
  Map<String, dynamic> alert, {
  VoidCallback? onAcknowledged,
}) async {
  // Name comes with the profiles join when loaded via AlertService;
  // realtime payloads don't include it, so fall back to a lookup.
  String patientName =
      (alert['profiles'] as Map?)?['name'] as String? ?? '';
  if (patientName.isEmpty) {
    try {
      final row = await supabase
          .from('profiles')
          .select('name')
          .eq('id', alert['patient_id'] as String)
          .maybeSingle();
      patientName = row?['name'] as String? ?? '';
    } catch (_) {}
  }
  if (patientName.isEmpty) patientName = 'Your patient';

  final message = alert['message'] as String?;
  final createdAt = DateTime.tryParse(alert['created_at'] as String? ?? '');
  final alertId = alert['id'] as String? ?? '';

  // Heads-up notification so the alert is heard even if the
  // caregiver isn't looking at the screen.
  try {
    await NotificationService.instance.showImmediateNotification(
      title: 'Emergency Alert',
      body: '$patientName needs help!'
          '${message != null && message.isNotEmpty ? ': $message' : ''}',
      id: alertId.hashCode.abs() % 2147483647,
    );
  } catch (_) {}

  if (!context.mounted) return;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: AppColors.dangerLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sos_rounded,
                  color: AppColors.danger, size: 38),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.12, 1.12),
                    duration: 600.ms,
                    curve: Curves.easeInOut),
            const SizedBox(height: 18),
            const Text(
              'EMERGENCY ALERT',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$patientName needs your attention',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            if (createdAt != null) ...[
              const SizedBox(height: 6),
              Text(
                _formatAlertTime(createdAt),
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
            if (message != null && message.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '“$message”',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.danger,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                try {
                  await AlertService.acknowledgeAlert(alertId);
                } catch (_) {}
                if (ctx.mounted) Navigator.pop(ctx);
                onAcknowledged?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              child: const Text('I\'m on it — Acknowledge'),
            ),
          ],
        ),
      ),
    ),
  );
}
