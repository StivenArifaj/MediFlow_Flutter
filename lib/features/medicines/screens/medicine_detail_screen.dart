import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
        backgroundColor: Color(0xFF070B12),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF), strokeWidth: 2)),
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
    backgroundColor: const Color(0xFF070B12),
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF00E5FF)),
        onPressed: () => context.pop(),
      ),
    ),
    body: Center(child: Text(message, style: const TextStyle(color: Colors.white))),
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
        backgroundColor: const Color(0xFF0D1826),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: const Color(0xFFFF4D6A).withValues(alpha: 0.3)),
        ),
        title: const Text('Delete Medicine',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete ${widget.medicine['verified_name']}? This cannot be undone.',
          style: const TextStyle(color: Color(0xFF8A9BB5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8A9BB5))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFFF4D6A), fontWeight: FontWeight.w700)),
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

  IconData _formIcon(String? form) {
    switch (form?.toLowerCase()) {
      case 'tablet':    return Icons.medication_rounded;
      case 'capsule':   return Icons.medication_liquid_rounded;
      case 'liquid':    return Icons.local_drink_rounded;
      case 'injection': return Icons.vaccines_rounded;
      case 'drops':     return Icons.water_drop_rounded;
      case 'inhaler':   return Icons.air_rounded;
      default:          return Icons.medication_rounded;
    }
  }

  Color _formColor(String? form) {
    switch (form?.toLowerCase()) {
      case 'tablet':    return const Color(0xFF00E5FF);
      case 'capsule':   return const Color(0xFF8B5CF6);
      case 'liquid':    return const Color(0xFF6B7FCC);
      case 'injection': return const Color(0xFFFF4D6A);
      case 'drops':     return const Color(0xFF00C896);
      case 'inhaler':   return const Color(0xFFFFB800);
      default:          return const Color(0xFF00E5FF);
    }
  }

  String _monthName(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.medicine;
    final color = _formColor(m['form'] as String?);
    final remindersAsync = ref.watch(remindersForMedicineProvider(widget.medicineId));

    final expiryRaw = m['expiry_date'] as String?;
    final expiryDate = expiryRaw != null ? DateTime.tryParse(expiryRaw) : null;
    final createdRaw = m['created_at'] as String?;
    final createdAt = createdRaw != null ? DateTime.tryParse(createdRaw) : null;

    return Scaffold(
      backgroundColor: const Color(0xFF070B12),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.5,
            colors: [Color(0xFF0D1F35), Color(0xFF070B12)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              leading: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1826),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.2)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF00E5FF), size: 18),
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () => context.push('/home/add-medicine', extra: {
                    'verifiedName': m['verified_name'],
                    'brandName': m['brand_name'],
                    'genericName': m['generic_name'],
                    'strength': m['strength'],
                    'form': m['form'],
                  }),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1826),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.2)),
                    ),
                    child: const Row(children: [
                      Icon(Icons.edit_rounded, color: Color(0xFF00E5FF), size: 16),
                      SizedBox(width: 6),
                      Text('Edit', style: TextStyle(
                          color: Color(0xFF00E5FF), fontSize: 13, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── Hero card ──────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1826),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
                      boxShadow: [
                        BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 30, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Row(children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 20, spreadRadius: 2)],
                        ),
                        child: Icon(_formIcon(m['form'] as String?), color: color, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m['verified_name'] as String,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                            if (m['brand_name'] != null) ...[
                              const SizedBox(height: 3),
                              Text(m['brand_name'] as String,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF8A9BB5))),
                            ],
                            const SizedBox(height: 10),
                            Wrap(spacing: 8, runSpacing: 6, children: [
                              if (m['form'] != null) _Badge(m['form'] as String, color: color),
                              if (m['strength'] != null) _Badge(m['strength'] as String, color: const Color(0xFF8B5CF6)),
                              _Badge(
                                m['api_source'] == 'openfda' ? 'OpenFDA ✓' : 'Manual',
                                color: m['api_source'] == 'openfda'
                                    ? const Color(0xFF00C896)
                                    : const Color(0xFF4A5A72),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ]),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),

                  const SizedBox(height: 20),

                  // ── Details card ───────────────────────────
                  _SectionHeader(title: 'Medicine Details'),
                  const SizedBox(height: 10),
                  _InfoCard(children: [
                    if (m['generic_name'] != null) _DetailRow('Generic Name', m['generic_name'] as String),
                    if (m['manufacturer'] != null) _DetailRow('Manufacturer', m['manufacturer'] as String),
                    if (m['category'] != null) _DetailRow('Category', m['category'] as String),
                    if (m['quantity'] != null) _DetailRow('Quantity', '${m['quantity']} units'),
                    if (expiryDate != null)
                      _DetailRow(
                        'Expiry Date',
                        '${_monthName(expiryDate.month)} ${expiryDate.year}',
                        valueColor: expiryDate.isBefore(DateTime.now())
                            ? const Color(0xFFFF4D6A) : null,
                      ),
                    if (createdAt != null)
                      _DetailRow('Added On',
                          '${_monthName(createdAt.month)} ${createdAt.day}, ${createdAt.year}'),
                    _DetailRow('Source', m['api_source'] == 'openfda' ? 'OpenFDA' : 'Manually Added'),
                  ]).animate().fadeIn(delay: 80.ms, duration: 300.ms),

                  const SizedBox(height: 20),

                  // ── Reminders card ─────────────────────────
                  _SectionHeader(
                    title: 'Reminders',
                    trailing: GestureDetector(
                      onTap: () => context.push('/home/reminder-setup?medicineId=${widget.medicineId}'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
                        ),
                        child: const Row(children: [
                          Icon(Icons.add_rounded, color: Color(0xFF00E5FF), size: 14),
                          SizedBox(width: 4),
                          Text('Add', style: TextStyle(
                              color: Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1826),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.1)),
                    ),
                    child: remindersAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator(
                            color: Color(0xFF00E5FF), strokeWidth: 2)),
                      ),
                      error: (_, __) => const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Error loading reminders',
                            style: TextStyle(color: Color(0xFF8A9BB5))),
                      ),
                      data: (reminders) => reminders.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(24),
                              child: Column(children: [
                                Icon(Icons.alarm_off_rounded, color: Color(0xFF2A3A4A), size: 36),
                                SizedBox(height: 10),
                                Text('No reminders set',
                                    style: TextStyle(color: Color(0xFF8A9BB5), fontSize: 14)),
                                SizedBox(height: 4),
                                Text('Tap + Add to create one',
                                    style: TextStyle(color: Color(0xFF4A5A72), fontSize: 12)),
                              ]),
                            )
                          : Column(
                              children: reminders.asMap().entries.map((entry) {
                                return Column(children: [
                                  if (entry.key > 0)
                                    Container(height: 1,
                                        color: const Color(0xFF00E5FF).withValues(alpha: 0.06)),
                                  _ReminderRow(
                                    reminder: entry.value,
                                    onDelete: () => _deleteReminderRow(entry.value['id'] as String),
                                  ),
                                ]);
                              }).toList(),
                            ),
                    ),
                  ).animate().fadeIn(delay: 160.ms, duration: 300.ms),

                  // ── Notes ──────────────────────────────────
                  if (m['notes'] != null && (m['notes'] as String).isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionHeader(title: 'Notes'),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1826),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.1)),
                      ),
                      child: Text(m['notes'] as String,
                          style: const TextStyle(fontSize: 14, color: Color(0xFFB0C4D8), height: 1.6)),
                    ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
                  ],

                  const SizedBox(height: 20),

                  // ── Disclaimer ─────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB800).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFB800).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB800), size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '⚠️ MediFlow is a medication organization tool only. Always follow your doctor\'s instructions.',
                            style: TextStyle(fontSize: 12, color: Color(0xFFFFB800), height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 240.ms, duration: 300.ms),

                  const SizedBox(height: 24),

                  // ── Set Reminder ───────────────────────────
                  GestureDetector(
                    onTap: () => context.push('/home/reminder-setup?medicineId=${widget.medicineId}'),
                    child: Container(
                      width: double.infinity, height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF00E5FF), Color(0xFF0055FF)]),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                              blurRadius: 20, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.alarm_rounded, color: Color(0xFF070B12), size: 20),
                          SizedBox(width: 8),
                          Text('Set Reminder', style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF070B12))),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 280.ms, duration: 300.ms),

                  const SizedBox(height: 12),

                  // ── Delete ─────────────────────────────────
                  GestureDetector(
                    onTap: _deleteMedicine,
                    child: Container(
                      width: double.infinity, height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4D6A).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: const Color(0xFFFF4D6A).withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_rounded, color: Color(0xFFFF4D6A), size: 20),
                          SizedBox(width: 8),
                          Text('Delete Medicine', style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFFF4D6A))),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 300.ms),

                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
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
      Container(width: 3, height: 18,
          decoration: BoxDecoration(color: const Color(0xFF00E5FF),
              borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Expanded(child: Text(title, style: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF00E5FF)))),
      if (trailing != null) trailing!,
    ]);
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});
  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1826),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.1)),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) => Column(children: [
          if (entry.key > 0)
            Container(height: 1, color: const Color(0xFF00E5FF).withValues(alpha: 0.06)),
          entry.value,
        ])).toList(),
      ),
    );
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
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF8A9BB5))),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.white),
          ),
        ),
      ]),
    );
  }
}

// ── Badge ─────────────────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, {required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

// ── Reminder Row ──────────────────────────────────────────────────────────────
class _ReminderRow extends StatelessWidget {
  final Map<String, dynamic> reminder;
  final VoidCallback onDelete;
  const _ReminderRow({required this.reminder, required this.onDelete});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.alarm_rounded, color: Color(0xFF00E5FF), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reminder['time'] as String,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              Text(reminder['frequency'] as String? ?? 'Every day',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8A9BB5))),
            ],
          ),
        ),
        GestureDetector(
          onTap: onDelete,
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFF4D6A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.close_rounded, color: Color(0xFFFF4D6A), size: 16),
          ),
        ),
      ]),
    );
  }
}
