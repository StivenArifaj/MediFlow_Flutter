import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/starfield_background.dart';
import '../../../core/widgets/neon_button.dart';
import '../../../data/database/app_database.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/medicines_provider.dart';

class MedicineDetailScreen extends ConsumerWidget {
  final int? medicineId;
  const MedicineDetailScreen({super.key, this.medicineId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (medicineId == null) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        appBar: AppBar(backgroundColor: AppColors.bgPrimary),
        body: const Center(child: Text('Medicine not found')),
      );
    }

    final medAsync = ref.watch(medicineByIdProvider(medicineId!));

    return medAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(child: CircularProgressIndicator(color: AppColors.neonCyan)),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: AppColors.bgPrimary,
        appBar: AppBar(backgroundColor: AppColors.bgPrimary),
        body: const Center(child: Text('Error loading medicine')),
      ),
      data: (medicine) {
        if (medicine == null) {
          return Scaffold(
            backgroundColor: AppColors.bgPrimary,
            appBar: AppBar(backgroundColor: AppColors.bgPrimary),
            body: const Center(child: Text('Medicine not found')),
          );
        }
        return _MedicineDetailView(medicine: medicine);
      },
    );
  }
}

class _MedicineDetailView extends ConsumerStatefulWidget {
  final Medicine medicine;
  const _MedicineDetailView({required this.medicine});

  @override
  ConsumerState<_MedicineDetailView> createState() => _MedicineDetailViewState();
}

class _MedicineDetailViewState extends ConsumerState<_MedicineDetailView> {
  List<Reminder> _reminders = [];
  bool _loadingReminders = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final db = ref.read(appDatabaseProvider);
    final list = await db.remindersDao.getRemindersForMedicine(widget.medicine.id);
    if (mounted) setState(() { _reminders = list; _loadingReminders = false; });
  }

  Future<void> _deleteMedicine() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: const BorderSide(color: Color(0x1A00E5FF)),
        ),
        title: Text('Delete Medicine', style: AppTypography.titleLarge()),
        content: Text(
          'Are you sure you want to delete ${widget.medicine.verifiedName}? This cannot be undone.',
          style: AppTypography.bodyMedium(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: AppTypography.labelLarge(color: AppColors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: AppTypography.labelLarge(color: AppColors.error))),
        ],
      ),
    );
    if (confirm != true) return;
    final db = ref.read(appDatabaseProvider);
    await db.medicinesDao.deleteMedicine(widget.medicine.id);
    if (mounted) context.pop();
  }

  Future<void> _deleteReminder(int id) async {
    final db = ref.read(appDatabaseProvider);
    await db.remindersDao.deleteReminder(id);
    await _loadReminders();
  }

  IconData _formIcon(String? form) {
    switch (form?.toLowerCase()) {
      case 'tablet': return Icons.medication_rounded;
      case 'capsule': return Icons.medication_liquid_rounded;
      case 'liquid': case 'syrup': return Icons.local_drink_rounded;
      case 'injection': return Icons.vaccines_rounded;
      case 'drops': return Icons.water_drop_rounded;
      case 'inhaler': return Icons.air_rounded;
      default: return Icons.medication_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.medicine;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: StarfieldBackground(
        child: Column(
          children: [
            // ── Gradient header ────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                boxShadow: [AppColors.cyanGlow],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Row(
                    children: [
                      IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded), color: AppColors.bgPrimary),
                      Expanded(child: Text(m.verifiedName, style: AppTypography.headlineMedium(color: AppColors.bgPrimary), overflow: TextOverflow.ellipsis)),
                      IconButton(
                        onPressed: () => context.push('/home/add-medicine', extra: {
                          'verifiedName': m.verifiedName, 'brandName': m.brandName,
                          'genericName': m.genericName, 'manufacturer': m.manufacturer,
                          'strength': m.strength, 'form': m.form,
                        }),
                        icon: const Icon(Icons.edit_rounded),
                        color: AppColors.bgPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Scrollable body ───────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Medicine card
                    _InfoCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.neonCyan.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                            ),
                            child: Icon(_formIcon(m.form), color: AppColors.neonCyan, size: 32),
                          ),
                          const SizedBox(width: AppDimensions.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.verifiedName, style: AppTypography.titleLarge()),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (m.form != null) _Badge(label: m.form!, color: AppColors.neonCyan),
                                    const SizedBox(width: 4),
                                    _Badge(
                                      label: m.apiSource == 'manual' ? 'Manual' : 'OpenFDA ✓',
                                      color: m.apiSource == 'manual' ? AppColors.textMuted : AppColors.success,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms),

                    const SizedBox(height: AppDimensions.md),

                    _InfoCard(
                      child: Column(
                        children: [
                          _DetailRow('Form', m.form),
                          _DetailRow('Strength', m.strength),
                          _DetailRow('Generic Name', m.genericName),
                          _DetailRow('Brand Name', m.brandName),
                          _DetailRow('Manufacturer', m.manufacturer),
                          _DetailRow('Category', m.category),
                          if (m.quantity != null) _DetailRow('Quantity', '${m.quantity} units'),
                          if (m.expiryDate != null) _DetailRow('Expiry Date', '${m.expiryDate!.month}/${m.expiryDate!.year}'),
                          _DetailRow('Added On', '${m.createdAt.day} ${_monthName(m.createdAt.month)} ${m.createdAt.year}'),
                          _DetailRow('Source', m.apiSource == 'manual' ? 'Manually Added' : 'OpenFDA'),
                        ],
                      ),
                    ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

                    const SizedBox(height: AppDimensions.md),

                    _InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Reminders', style: AppTypography.titleMedium()),
                              IconButton(
                                onPressed: () => context.push('/home/reminder-setup?medicineId=${m.id}'),
                                icon: const Icon(Icons.add_rounded, color: AppColors.neonCyan),
                              ),
                            ],
                          ),
                          if (_loadingReminders)
                            const Center(child: CircularProgressIndicator(color: AppColors.neonCyan))
                          else if (_reminders.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
                              child: Text('No reminders set', style: AppTypography.bodySmall()),
                            )
                          else
                            ..._reminders.map((r) => _ReminderTile(reminder: r, onDelete: () => _deleteReminder(r.id))),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

                    if (m.notes != null && m.notes!.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.md),
                      _InfoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notes', style: AppTypography.titleMedium()),
                            const SizedBox(height: AppDimensions.xs),
                            Text(m.notes!, style: AppTypography.bodyMedium()),
                          ],
                        ),
                      ).animate().fadeIn(delay: 250.ms, duration: 300.ms),
                    ],

                    const SizedBox(height: AppDimensions.md),

                    Container(
                      padding: const EdgeInsets.all(AppDimensions.md),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      child: Text('⚠️ MediFlow is a medication organization tool only. Always follow your doctor\'s instructions.',
                          style: AppTypography.bodySmall(color: AppColors.warning)),
                    ),

                    const SizedBox(height: AppDimensions.lg),

                    NeonButton(
                      label: 'Set Reminder',
                      icon: Icons.alarm_rounded,
                      onPressed: () => context.push('/home/reminder-setup?medicineId=${m.id}'),
                    ),

                    const SizedBox(height: AppDimensions.sm),

                    NeonOutlineButton(
                      label: 'Edit Medicine',
                      icon: Icons.edit_rounded,
                      onPressed: () => context.push('/home/add-medicine', extra: {
                        'verifiedName': m.verifiedName, 'brandName': m.brandName,
                        'genericName': m.genericName, 'strength': m.strength, 'form': m.form,
                      }),
                    ),

                    const SizedBox(height: AppDimensions.sm),

                    // Danger delete button
                    GestureDetector(
                      onTap: _deleteMedicine,
                      child: Container(
                        height: AppDimensions.buttonHeight,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.delete_rounded, color: AppColors.error, size: 20),
                            const SizedBox(width: AppDimensions.sm),
                            Text('Delete Medicine', style: AppTypography.titleMedium(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[(m - 1).clamp(0, 11)];
  }
}

// ── Common widgets ────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: AppColors.neonCardDecoration,
      child: child,
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: AppTypography.bodySmall(color: color)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: AppTypography.bodySmall(color: AppColors.textMuted))),
          Expanded(child: Text(value!, style: AppTypography.bodyMedium(color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onDelete;
  const _ReminderTile({required this.reminder, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.alarm_rounded, color: AppColors.neonCyan, size: 18),
          const SizedBox(width: AppDimensions.sm),
          Expanded(child: Text('${reminder.time} — ${reminder.frequency == 'daily' ? 'Every day' : reminder.frequency}', style: AppTypography.bodyMedium(color: AppColors.textPrimary))),
          IconButton(onPressed: onDelete, icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ],
      ),
    );
  }
}
