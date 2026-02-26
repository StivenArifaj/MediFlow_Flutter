import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/starfield_background.dart';
import '../../../data/database/app_database.dart';
import '../../auth/providers/auth_provider.dart';

// ─── Main Screen ─────────────────────────────────────────────────────────────
class AddMedicineScreen extends ConsumerStatefulWidget {
  final Map<String, String?>? prefillData;
  const AddMedicineScreen({super.key, this.prefillData});

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // ── Form controllers ─────────────────────────────────────────────────────
  late final _nameCtrl = TextEditingController(text: widget.prefillData?['verifiedName']);
  late final _brandCtrl = TextEditingController(text: widget.prefillData?['brandName']);
  late final _strengthCtrl = TextEditingController(text: widget.prefillData?['strength']);
  late final _quantityCtrl = TextEditingController(text: widget.prefillData?['quantity']);
  late final _notesCtrl = TextEditingController();

  String? _selectedForm;
  DateTime? _expiryDate;
  bool _isLoading = false;

  // ── Reminder state (embedded 4-step) ─────────────────────────────────────
  final List<String> _reminderTimes = [];
  String _frequency = 'daily';
  final List<String> _selectedDays = [];
  int _intervalDays = 2;
  String _durationType = 'ongoing';
  DateTime? _endDate;
  int _durationDays = 30;
  bool _snoozeEnabled = true;
  int _snoozeDuration = 15;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // ── Constants ─────────────────────────────────────────────────────────────
  static const _formTypes = [
    'Tablet', 'Capsule', 'Liquid', 'Injection',
    'Cream/Ointment', 'Drops', 'Inhaler', 'Patch', 'Spray', 'Other',
  ];

  static const _presetTimes = [
    ('☀️', 'Morning', '08:00'),
    ('🌤️', 'Afternoon', '14:00'),
    ('🌙', 'Evening', '20:00'),
    ('🛏️', 'Bedtime', '22:00'),
  ];

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    final form = widget.prefillData?['form'];
    if (form != null) {
      _selectedForm = _formTypes.firstWhere(
        (f) => f.toLowerCase().startsWith(form.toLowerCase()),
        orElse: () => 'Other',
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _strengthCtrl.dispose();
    _quantityCtrl.dispose();
    _notesCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Reminder helpers ──────────────────────────────────────────────────────
  void _addPresetTime(String time) {
    if (_reminderTimes.contains(time)) { _showSnack('Already added.'); return; }
    if (_reminderTimes.length >= 5) { _showSnack('Max 5 reminder times.'); return; }
    setState(() => _reminderTimes.add(time));
  }

  Future<void> _pickCustomTime() async {
    if (_reminderTimes.length >= 5) { _showSnack('Max 5 reminder times.'); return; }
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked == null) return;
    final t = '${picked.hour.toString().padLeft(2,'0')}:${picked.minute.toString().padLeft(2,'0')}';
    if (!_reminderTimes.contains(t)) setState(() => _reminderTimes.add(t));
  }

  Future<void> _pickEndDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2040),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.neonCyan, surface: AppColors.bgCard,
          ),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _endDate = d);
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2040),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.neonCyan, surface: AppColors.bgCard,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(authRepositoryProvider);
      final userId = repo.currentUserId;
      if (userId == null) { _showSnack('Not logged in.'); return; }

      final db = ref.read(appDatabaseProvider);
      final quantity = int.tryParse(_quantityCtrl.text.trim());

      final medId = await db.medicinesDao.insertMedicine(
        MedicinesCompanion.insert(
          userId: userId,
          verifiedName: _nameCtrl.text.trim(),
          brandName: Value(_brandCtrl.text.trim().isNotEmpty ? _brandCtrl.text.trim() : null),
          strength: Value(_strengthCtrl.text.trim().isNotEmpty ? _strengthCtrl.text.trim() : null),
          form: Value(_selectedForm),
          quantity: Value(quantity),
          notes: Value(_notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null),
          expiryDate: Value(_expiryDate),
          apiSource: const Value('manual'),
          createdAt: DateTime.now(),
        ),
      );

      // Save reminders if any times were set
      if (_reminderTimes.isNotEmpty) {
        final days = _frequency == 'specific' ? _selectedDays.join(',') : null;
        final interval = _frequency == 'interval' ? _intervalDays : null;
        final dur = _durationType == 'days' ? _durationDays : null;
        final end = _durationType == 'date' ? _endDate : null;

        for (final t in _reminderTimes) {
          await db.remindersDao.insertReminder(
            RemindersCompanion.insert(
              medicineId: medId,
              userId: userId,
              time: t,
              frequency: Value(_frequency),
              days: Value(days),
              intervalDays: Value(interval),
              durationType: Value(_durationType),
              endDate: Value(end),
              durationDays: Value(dur),
              snoozeDuration: Value(_snoozeDuration),
              createdAt: DateTime.now(),
            ),
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Medicine added! ✅'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
        context.pop();
      }
    } catch (e) {
      _showSnack('Error saving medicine: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── UI helpers ────────────────────────────────────────────────────────────
  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Row(children: [
      Container(width: 3, height: 18,
          decoration: BoxDecoration(color: AppColors.neonCyan, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.neonCyan)),
    ]),
  );

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B12),
      body: StarfieldBackground(
        child: Column(children: [
          // ── AppBar ───────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1826),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.neonCyan, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Add Medicine',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
              ]),
            ),
          ),

          // ── Scrollable body ──────────────────────────────────────────────
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 120),
                children: [

                  // ══ BASIC INFORMATION ════════════════════════════════════
                  _sectionTitle('Basic Information'),
                  _buildCard([
                    _Field(label: 'Medicine Name *', controller: _nameCtrl,
                      hint: 'e.g. Paracetamol',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    _Field(label: 'Brand Name', controller: _brandCtrl, hint: 'Optional'),
                    _Field(label: 'Strength', controller: _strengthCtrl, hint: 'e.g. 500mg'),
                  ]).animate().fadeIn(delay: 60.ms, duration: 300.ms),

                  // ══ MEDICINE DETAILS ═════════════════════════════════════
                  _sectionTitle('Medicine Details'),
                  _buildCard([
                    // Form type chips
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Form Type',
                            style: TextStyle(fontSize: 12, color: Color(0xFF8A9BB5))),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: _formTypes.map((type) {
                            final selected = _selectedForm == type;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedForm = type),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.neonCyan.withOpacity(0.15)
                                      : const Color(0xFF0D1826),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.neonCyan
                                        : const Color(0xFF2A3A4A),
                                  ),
                                  boxShadow: selected
                                      ? [BoxShadow(color: AppColors.neonCyan.withOpacity(0.3),
                                            blurRadius: 10)]
                                      : null,
                                ),
                                child: Text(type, style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? AppColors.neonCyan : const Color(0xFF8A9BB5),
                                )),
                              ),
                            );
                          }).toList(),
                        ),
                      ]),
                    ),
                    _Field(label: 'Quantity', controller: _quantityCtrl,
                      hint: 'e.g. 30',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    // Expiry date
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Expiry Date',
                            style: TextStyle(fontSize: 12, color: Color(0xFF8A9BB5))),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickExpiryDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111C2A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF1E2F40)),
                            ),
                            child: Row(children: [
                              Expanded(
                                child: Text(
                                  _expiryDate != null
                                      ? '${_expiryDate!.month}/${_expiryDate!.year}'
                                      : 'Select expiry date (optional)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _expiryDate != null
                                        ? Colors.white
                                        : const Color(0xFF4A5A72),
                                  ),
                                ),
                              ),
                              const Icon(Icons.calendar_today_rounded,
                                  color: AppColors.neonCyan, size: 18),
                            ]),
                          ),
                        ),
                      ]),
                    ),
                  ]).animate().fadeIn(delay: 100.ms, duration: 300.ms),

                  // ══ NOTES ════════════════════════════════════════════════
                  _sectionTitle('Notes & Memos'),
                  _buildCard([
                    _Field(label: 'Notes', controller: _notesCtrl,
                      hint: 'e.g. Take with food',
                      maxLines: 3, maxLength: 500,
                    ),
                  ]).animate().fadeIn(delay: 140.ms, duration: 300.ms),

                  // ══ REMINDERS (FULL 4-STEP INLINE) ═══════════════════════
                  _sectionTitle('Set Reminder'),

                  // Step 1 — Choose Time
                  _ReminderStepCard(
                    step: '1', title: 'Choose Time',
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(
                        children: _presetTimes.map((p) {
                          final (emoji, label, time) = p;
                          final added = _reminderTimes.contains(time);
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => _addPresetTime(time),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: added
                                      ? AppColors.neonCyan.withOpacity(0.12)
                                      : const Color(0xFF111C2A),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: added ? AppColors.neonCyan : const Color(0xFF1E2F40),
                                  ),
                                ),
                                child: Column(children: [
                                  Text(emoji, style: const TextStyle(fontSize: 20)),
                                  const SizedBox(height: 4),
                                  Text(label, style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w600,
                                    color: added ? AppColors.neonCyan : const Color(0xFF8A9BB5),
                                  )),
                                  Text(time, style: TextStyle(
                                    fontSize: 10,
                                    color: added ? AppColors.neonCyan : const Color(0xFF4A5A72),
                                  )),
                                ]),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickCustomTime,
                        child: Row(children: [
                          const Icon(Icons.add_circle_outline_rounded,
                              color: AppColors.neonCyan, size: 18),
                          const SizedBox(width: 8),
                          Text('Add Custom Time', style: const TextStyle(
                              color: AppColors.neonCyan, fontSize: 14, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                      if (_reminderTimes.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: _reminderTimes.map((t) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.neonCyan.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: AppColors.neonCyan.withOpacity(0.5)),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Text(t, style: const TextStyle(
                                  color: AppColors.neonCyan, fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => setState(() => _reminderTimes.remove(t)),
                                child: const Icon(Icons.close_rounded,
                                    color: AppColors.neonCyan, size: 14),
                              ),
                            ]),
                          )).toList(),
                        ),
                      ],
                    ]),
                  ).animate().fadeIn(delay: 180.ms, duration: 300.ms),

                  const SizedBox(height: 10),

                  // Step 2 — Frequency
                  _ReminderStepCard(
                    step: '2', title: 'Frequency',
                    child: Column(children: [
                      _ReminderRadio(label: 'Every day', value: 'daily',
                          groupValue: _frequency,
                          onChanged: (v) => setState(() => _frequency = v!)),
                      _ReminderRadio(label: 'Specific days', value: 'specific',
                          groupValue: _frequency,
                          onChanged: (v) => setState(() => _frequency = v!)),
                      if (_frequency == 'specific') ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: _days.map((day) {
                            final selected = _selectedDays.contains(day);
                            return GestureDetector(
                              onTap: () => setState(() {
                                if (selected) _selectedDays.remove(day);
                                else _selectedDays.add(day);
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.neonCyan.withOpacity(0.15)
                                      : const Color(0xFF111C2A),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      color: selected ? AppColors.neonCyan : const Color(0xFF1E2F40)),
                                ),
                                child: Text(day, style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600,
                                  color: selected ? AppColors.neonCyan : const Color(0xFF8A9BB5),
                                )),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      _ReminderRadio(label: 'Every X days', value: 'interval',
                          groupValue: _frequency,
                          onChanged: (v) => setState(() => _frequency = v!)),
                      if (_frequency == 'interval')
                        Padding(
                          padding: const EdgeInsets.only(left: 32, top: 8, bottom: 4),
                          child: _StepperRow(
                            label: 'days',
                            value: _intervalDays,
                            onChanged: (v) => setState(() => _intervalDays = v),
                          ),
                        ),
                      _ReminderRadio(label: 'As needed', value: 'as_needed',
                          groupValue: _frequency,
                          onChanged: (v) => setState(() => _frequency = v!)),
                    ]),
                  ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

                  const SizedBox(height: 10),

                  // Step 3 — Duration
                  _ReminderStepCard(
                    step: '3', title: 'Duration',
                    child: Column(children: [
                      _ReminderRadio(label: 'Ongoing (no end date)', value: 'ongoing',
                          groupValue: _durationType,
                          onChanged: (v) => setState(() => _durationType = v!)),
                      _ReminderRadio(label: 'Until specific date', value: 'date',
                          groupValue: _durationType,
                          onChanged: (v) => setState(() => _durationType = v!)),
                      if (_durationType == 'date')
                        Padding(
                          padding: const EdgeInsets.only(left: 32, top: 8, bottom: 4),
                          child: GestureDetector(
                            onTap: _pickEndDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF111C2A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF1E2F40)),
                              ),
                              child: Row(children: [
                                const Icon(Icons.calendar_today_rounded,
                                    color: AppColors.neonCyan, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  _endDate != null
                                      ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                      : 'Select end date',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _endDate != null
                                        ? Colors.white
                                        : const Color(0xFF4A5A72),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      _ReminderRadio(label: 'For X days', value: 'days',
                          groupValue: _durationType,
                          onChanged: (v) => setState(() => _durationType = v!)),
                      if (_durationType == 'days')
                        Padding(
                          padding: const EdgeInsets.only(left: 32, top: 8, bottom: 4),
                          child: _StepperRow(
                            label: 'days',
                            value: _durationDays,
                            onChanged: (v) => setState(() => _durationDays = v),
                          ),
                        ),
                    ]),
                  ).animate().fadeIn(delay: 220.ms, duration: 300.ms),

                  const SizedBox(height: 10),

                  // Step 4 — Additional Options
                  _ReminderStepCard(
                    step: '4', title: 'Additional Options',
                    child: Column(children: [
                      _ToggleRow(
                        label: 'Snooze',
                        value: _snoozeEnabled,
                        onChanged: (v) => setState(() => _snoozeEnabled = v),
                      ),
                      if (_snoozeEnabled) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Snooze duration:',
                                  style: TextStyle(fontSize: 13, color: Color(0xFF8A9BB5))),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [5, 10, 15, 30].map((m) {
                                  final sel = _snoozeDuration == m;
                                  return GestureDetector(
                                    onTap: () => setState(() => _snoozeDuration = m),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: sel
                                            ? AppColors.neonCyan.withOpacity(0.15)
                                            : const Color(0xFF111C2A),
                                        borderRadius: BorderRadius.circular(100),
                                        border: Border.all(
                                            color: sel ? AppColors.neonCyan : const Color(0xFF1E2F40)),
                                      ),
                                      child: Text('${m}m', style: TextStyle(
                                        fontSize: 13, fontWeight: FontWeight.w600,
                                        color: sel ? AppColors.neonCyan : const Color(0xFF8A9BB5),
                                      )),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      _ToggleRow(
                        label: 'Sound',
                        value: _soundEnabled,
                        onChanged: (v) => setState(() => _soundEnabled = v),
                      ),
                      const SizedBox(height: 8),
                      _ToggleRow(
                        label: 'Vibration',
                        value: _vibrationEnabled,
                        onChanged: (v) => setState(() => _vibrationEnabled = v),
                      ),
                    ]),
                  ).animate().fadeIn(delay: 240.ms, duration: 300.ms),

                  const SizedBox(height: 16),

                  // ── Disclaimer ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB800).withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFFB800).withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB800), size: 18),
                          SizedBox(width: 10),
                          Expanded(child: Text(
                            '⚠️ MediFlow is a medication organization tool only. We do NOT provide medical advice. Always follow your doctor\'s instructions.',
                            style: TextStyle(fontSize: 12, color: Color(0xFFFFB800), height: 1.5),
                          )),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 260.ms, duration: 300.ms),
                ],
              ),
            ),
          ),
        ]),
      ),

      // ── Sticky bottom button ───────────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [const Color(0xFF070B12).withOpacity(0), const Color(0xFF070B12)],
          ),
        ),
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 16),
        child: GestureDetector(
          onTap: _isLoading ? null : _submit,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: _isLoading
                  ? null
                  : const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF0055FF)]),
              color: _isLoading ? const Color(0xFF1E2F40) : null,
              borderRadius: BorderRadius.circular(100),
              boxShadow: _isLoading ? null : [
                BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.4),
                    blurRadius: 20, offset: const Offset(0, 6)),
              ],
            ),
            child: Center(
              child: _isLoading
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Confirm & Add Medicine',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                          color: Color(0xFF070B12))),
            ),
          ),
        ),
      ),
    );
  }

  // ── Build helpers ──────────────────────────────────────────────────────────
  Widget _buildCard(List<Widget> children) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1826),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.1)),
      ),
      child: Column(children: children),
    ),
  );
}

// ─── _Field ───────────────────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8A9BB5))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF4A5A72), fontSize: 14),
            counterStyle: const TextStyle(color: Color(0xFF4A5A72), fontSize: 11),
            filled: true,
            fillColor: const Color(0xFF111C2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E2F40)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E2F40)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 4),
      ]),
    );
  }
}

// ─── _ReminderStepCard ────────────────────────────────────────────────────────
class _ReminderStepCard extends StatelessWidget {
  final String step;
  final String title;
  final Widget child;

  const _ReminderStepCard({
    required this.step,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1826),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.1)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: AppColors.neonCyan,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(step, style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF070B12))),
              ),
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          ]),
          const SizedBox(height: 14),
          child,
        ]),
      ),
    );
  }
}

// ─── _ReminderRadio ───────────────────────────────────────────────────────────
class _ReminderRadio extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final void Function(String?) onChanged;

  const _ReminderRadio({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Radio<String>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: AppColors.neonCyan,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      Text(label, style: const TextStyle(fontSize: 14, color: Colors.white)),
    ]);
  }
}

// ─── _StepperRow ──────────────────────────────────────────────────────────────
class _StepperRow extends StatelessWidget {
  final int value;
  final String label;
  final void Function(int) onChanged;

  const _StepperRow({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _CircleBtn(
        icon: Icons.remove_rounded,
        onTap: value > 1 ? () => onChanged(value - 1) : null,
      ),
      const SizedBox(width: 12),
      Text('$value $label', style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
      const SizedBox(width: 12),
      _CircleBtn(
        icon: Icons.add_rounded,
        onTap: value < 90 ? () => onChanged(value + 1) : null,
      ),
    ]);
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CircleBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF111C2A),
          border: Border.all(
            color: onTap != null ? AppColors.neonCyan : const Color(0xFF1E2F40),
          ),
        ),
        child: Icon(icon, size: 16,
          color: onTap != null ? AppColors.neonCyan : const Color(0xFF2A3A4A)),
      ),
    );
  }
}

// ─── _ToggleRow ───────────────────────────────────────────────────────────────
class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool) onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.white)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.neonCyan,
          activeTrackColor: AppColors.neonCyan.withOpacity(0.3),
          inactiveTrackColor: const Color(0xFF1E2F40),
          inactiveThumbColor: const Color(0xFF4A5A72),
        ),
      ],
    );
  }
}