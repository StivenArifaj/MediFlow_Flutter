import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../supabase/supabase_client.dart';
import '../../data/services/alert_service.dart';

/// Full emergency alert form shown to the caregiver when a linked
/// patient sends an SOS. Resolves the patient's name, then presents
/// a dialog that must be acknowledged.
Future<void> showEmergencyAlert(
  BuildContext context,
  Map<String, dynamic> alert, {
  VoidCallback? onAcknowledged,
}) async {
  String patientName = 'Your patient';
  try {
    final row = await supabase
        .from('profiles')
        .select('name')
        .eq('id', alert['patient_id'] as String)
        .maybeSingle();
    patientName = row?['name'] as String? ?? patientName;
  } catch (_) {}

  if (!context.mounted) return;

  final message = alert['message'] as String?;
  final createdAt = DateTime.tryParse(alert['created_at'] as String? ?? '');

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
                DateFormat('d MMM · HH:mm').format(createdAt.toLocal()),
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
                  await AlertService.acknowledge(alert['id'] as String);
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
