import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/services/supabase_data_service.dart';
import '../providers/medicines_provider.dart';

class MedicineDetailScreen extends ConsumerWidget {
  final String? medicineId;
  const MedicineDetailScreen({super.key, this.medicineId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (medicineId == null) return const _ErrorScaffold(message: 'Medicine not found');
    final medAsync = ref.watch(medicineByIdProvider(medicineId!));
    return medAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
      ),
      error: (_, __) => const _ErrorScaffold(message: 'Error loading medicine'),
      data: (medicine) {
        if (medicine == null) return const _ErrorScaffold(message: 'Medicine not found');
        return _DetailView(medicine: medicine, medicineId: medicineId!);
      },
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  final String message;
  const _ErrorScaffold({required this.message});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: BackButton(color: AppColors.textPrimary),
    ),
    body: Center(
      child: Text(message,
          style: const TextStyle(color: AppColors.textPrimary)),
    ),
  );
}

class _DetailView extends ConsumerStatefulWidget {
  final Map<String, dynamic> medicine;
  final String medicineId;
  const _DetailView({required this.medicine, required this.medicineId});
  @override
  ConsumerState<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends ConsumerState<_DetailView> {
  Future<void> _deleteMedicine() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Medicine',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete ${widget.medicine['verified_name']}? This cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.danger,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final svc = ref.read(supabaseDataServiceProvider);
    await svc.deleteRemindersForMedicine(widget.medicineId);
    await svc.deleteMedicine(widget.medicineId);
    ref.invalidate(medicinesProvider);
    if (mounted) context.go('/home');
  }

  String _monthName(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.medicine;
    final remindersAsync = ref.watch(remindersForMedicineProvider(widget.medicineId));

    final expiryRaw = m['expiry_date'] as String?;
    final expiryDate = expiryRaw != null ? DateTime.tryParse(expiryRaw) : null;
    final createdRaw = m['created_at'] as String?;
    final createdAt = createdRaw != null ? DateTime.tryParse(createdRaw) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          m['verified_name'] as String,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: BackButton(color: AppColors.textPrimary),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            onPressed: _deleteMedicine,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [

          // ── Medicine header card ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('💊', style: TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m['verified_name'] as String,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    if (m['strength'] != null) ...[
                      const SizedBox(height: 3),
                      Text(m['strength'] as String,
                          style: const TextStyle(
                              fontSize: 15, color: AppColors.textSecondary)),
                    ],
                    if (m['form'] != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(m['form'] as String,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                    if (m['api_source'] == 'openfda') ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('OpenFDA ✓',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
              ),
            ]),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),

          const SizedBox(height: 20),

          // ── Details card ──────────────────────────────────────────────
          _SectionHeader(title: 'Medicine Details'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                if (m['generic_name'] != null)
                  _DetailRow('Generic Name', m['generic_name'] as String),
                if (m['manufacturer'] != null)
                  _DetailRow('Manufacturer', m['manufacturer'] as String),
                if (m['category'] != null)
                  _DetailRow('Category', m['category'] as String),
                if (m['quantity'] != null)
                  _DetailRow('Quantity', '${m['quantity']} units'),
                if (expiryDate != null)
                  _DetailRow(
                    'Expiry Date',
                    '${_monthName(expiryDate.month)} ${expiryDate.year}',
                    valueColor: expiryDate.isBefore(DateTime.now())
                        ? AppColors.danger : null,
                  ),
                if (createdAt != null)
                  _DetailRow('Added On',
                      '${_monthName(createdAt.month)} ${createdAt.day}, ${createdAt.year}'),
                _DetailRow('Source',
                    m['api_source'] == 'openfda' ? 'OpenFDA' : 'Manually Added'),
              ],
            ),
          ).animate().fadeIn(delay: 80.ms, duration: 300.ms),

          const SizedBox(height: 20),

          // ── Reminders card ────────────────────────────────────────────
          _SectionHeader(
            title: 'Reminders',
            trailing: TextButton.icon(
              onPressed: () => context.push(
                  '/home/reminder-setup?medicineId=${widget.medicineId}'),
              icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
              label: const Text('Add',
                  style: TextStyle(color: AppColors.primary, fontSize: 13)),
            ),
          ),
          const SizedBox(height: 10),
          remindersAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
            ),
            error: (_, __) => const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Error loading reminders',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            data: (reminders) => reminders.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(children: [
                      Icon(Icons.alarm_off_rounded,
                          color: AppColors.textTertiary, size: 36),
                      SizedBox(height: 10),
                      Text('No reminders set',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 14)),
                      SizedBox(height: 4),
                      Text('Tap + Add to create one',
                          style: TextStyle(
                              color: AppColors.textTertiary, fontSize: 12)),
                    ]),
                  )
                : Column(
                    children: reminders.map((r) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.alarm_outlined,
                              color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r['time'] as String,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)),
                              Text(r['frequency'] as String? ?? 'Every day',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.danger, size: 20),
                          onPressed: () =>
                              _deleteReminderRow(r['id'] as String),
                        ),
                      ]),
                    )).toList(),
                  ),
          ).animate().fadeIn(delay: 160.ms, duration: 300.ms),

          // ── Notes ─────────────────────────────────────────────────────
          if (m['notes'] != null && (m['notes'] as String).isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionHeader(title: 'Notes'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(m['notes'] as String,
                  style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.6)),
            ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
          ],

          const SizedBox(height: 20),

          // ── Set Reminder button ────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => context.push(
                  '/home/reminder-setup?medicineId=${widget.medicineId}'),
              icon: const Icon(Icons.alarm_rounded, size: 18),
              label: const Text('Set Reminder'),
            ),
          ).animate().fadeIn(delay: 240.ms, duration: 300.ms),

          const SizedBox(height: 12),

          // ── Disclaimer ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '⚠️ MediFlow is a medication organization tool only. Always follow your doctor\'s instructions.',
                    style: TextStyle(fontSize: 12, color: AppColors.warning, height: 1.5),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 280.ms, duration: 300.ms),
        ],
      ),
    );
  }

  Future<void> _deleteReminderRow(String reminderId) async {
    final svc = ref.read(supabaseDataServiceProvider);
    await svc.deleteReminder(reminderId);
    ref.invalidate(remindersForMedicineProvider(widget.medicineId));
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionHeader({required this.title, this.trailing});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 3, height: 18,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(title, style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary)),
      ),
      if (trailing != null) trailing!,
    ]);
  }
}

// ── Detail Row ────────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _DetailRow(this.label, this.value, {this.valueColor});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ]),
    );
  }
}
