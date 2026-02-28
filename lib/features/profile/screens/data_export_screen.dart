import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/starfield_background.dart';
import '../../../core/services/pdf_export_service.dart';
import '../../auth/providers/auth_provider.dart';

class DataExportScreen extends ConsumerStatefulWidget {
  const DataExportScreen({super.key});

  @override
  ConsumerState<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends ConsumerState<DataExportScreen> {
  bool _exportingJson = false;
  bool _exportingPdf = false;

  Future<void> _exportJson() async {
    setState(() => _exportingJson = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final repo = ref.read(authRepositoryProvider);
      final userId = repo.currentUserId;
      if (userId == null) return;

      final medicines = await db.medicinesDao.getAllMedicines(userId);
      final reminders = await db.remindersDao.getRemindersForUser(userId);
      final history = await db.historyDao.getHistoryForUser(userId);
      final health = await db.healthDao.getMeasurementsForUser(userId);

      final data = {
        'exportDate': DateTime.now().toIso8601String(),
        'medicines': medicines.map((m) => {
              'name': m.verifiedName,
              'brand': m.brandName,
              'generic': m.genericName,
              'strength': m.strength,
              'form': m.form,
              'category': m.category,
              'notes': m.notes,
            }).toList(),
        'reminders': reminders.map((r) => {
              'medicineId': r.medicineId,
              'time': r.time,
              'frequency': r.frequency,
            }).toList(),
        'history': history.map((h) => {
              'status': h.status,
              'scheduledTime': h.scheduledTime.toIso8601String(),
              'actualTime': h.actualTime?.toIso8601String(),
            }).toList(),
        'healthMeasurements': health.map((h) => {
              'type': h.type,
              'value': h.value,
              'unit': h.unit,
              'recordedAt': h.recordedAt.toIso8601String(),
            }).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final fileName = 'mediflow_export_$date.json';

      await SharePlus.instance.share(
        ShareParams(text: jsonString, subject: fileName),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _exportingJson = false);
    }
  }

  Future<void> _exportPdf() async {
    setState(() => _exportingPdf = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final repo = ref.read(authRepositoryProvider);
      final userId = repo.currentUserId;
      if (userId == null) return;

      final user = await repo.getCurrentUser();
      final medicines = await db.medicinesDao.getAllMedicines(userId);
      final history = await db.historyDao.getHistoryForUser(userId);
      final health = await db.healthDao.getMeasurementsForUser(userId);

      await PdfExportService.generateAndShareReport(
        userName: user?.name ?? 'Patient',
        medicines: medicines,
        history: history,
        healthData: health,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF export failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _exportingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: StarfieldBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 4),
                    Text('Export & Share', style: AppTypography.headlineMedium()),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Export cards
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // PDF Export card
                      _ExportCard(
                        icon: Icons.picture_as_pdf_rounded,
                        iconColor: AppColors.error,
                        title: 'PDF Report',
                        desc: 'Generate a formatted health report for your doctor with medicines, adherence stats, and health measurements.',
                        buttonLabel: 'Generate PDF',
                        loading: _exportingPdf,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF3B5C), Color(0xFFFF7043)],
                        ),
                        onTap: _exportPdf,
                      ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),

                      const SizedBox(height: 16),

                      // JSON Export card
                      _ExportCard(
                        icon: Icons.code_rounded,
                        iconColor: AppColors.neonCyan,
                        title: 'JSON Data Export',
                        desc: 'Export all your data as machine-readable JSON. Perfect for backups and data portability.',
                        buttonLabel: 'Export JSON',
                        loading: _exportingJson,
                        gradient: AppColors.primaryGradient,
                        onTap: _exportJson,
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),

                      const SizedBox(height: 24),

                      // Disclaimer
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.warning.withOpacity(0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your data stays on your device. Exports are shared via your device\'s share sheet — MediFlow never uploads your data to external servers.',
                                style: AppTypography.bodySmall(color: AppColors.warning),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String desc;
  final String buttonLabel;
  final bool loading;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ExportCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.desc,
    required this.buttonLabel,
    required this.loading,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1A00E5FF)),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.titleMedium()),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: AppTypography.bodySmall(color: AppColors.textSecondary),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: loading ? null : onTap,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        buttonLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
