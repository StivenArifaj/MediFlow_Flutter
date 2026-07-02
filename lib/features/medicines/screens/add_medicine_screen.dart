import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/hooks/managed_user_id.dart';
import '../../../data/services/supabase_data_service.dart';
import '../../../data/services/notification_service.dart';
import '../providers/medicines_provider.dart';
import '../../home/today_schedule_provider.dart';

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
    );
    if (d != null) setState(() => _endDate = d);
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2040),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final userId = await ref.read(managedUserIdProvider.future);
      if (userId == null) { _showSnack('Not logged in.'); return; }

      final svc = ref.read(supabaseDataServiceProvider);

      final medicine = await svc.createMedicine(
        userId: userId,
        verifiedName: _nameCtrl.text.trim(),
        brandName: _brandCtrl.text.trim().isNotEmpty ? _brandCtrl.text.trim() : null,
        strength: _strengthCtrl.text.trim().isNotEmpty ? _strengthCtrl.text.trim() : null,
        form: _selectedForm,
        quantity: int.tryParse(_quantityCtrl.text.trim()),
        notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
        expiryDate: _expiryDate?.toIso8601String().split('T').first,
        apiSource: widget.prefillData != null ? 'openfda' : 'manual',
      );

      final medicineId = medicine['id'] as String;

      for (final t in _reminderTimes) {
        await svc.createReminder(
          userId: userId,
          medicineId: medicineId,
          time: t,
          frequency: _frequency,
          days: _frequency == 'specific' && _selectedDays.isNotEmpty ? _selectedDays : null,
          intervalDays: _frequency == 'interval' ? _intervalDays : null,
          durationType: _durationType,
          endDate: _durationType == 'date' ? _endDate?.toIso8601String().split('T').first : null,
          durationDays: _durationType == 'days' ? _durationDays : null,
          snoozeDuration: _snoozeDuration,
        );
      }

      if (_reminderTimes.isNotEmpty) {
        await NotificationService.instance.scheduleRemindersForMedicine(
          medicineId: medicineId.hashCode.abs() % 2147483647,
          medicineName: _nameCtrl.text.trim(),
          times: _reminderTimes,
          frequency: _frequency,
        );
      }

      ref.invalidate(medicinesProvider);
      ref.invalidate(todayScheduleProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Medicine added! ✅'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
        context.go('/home/medicine/$medicineId');
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

  // ── Section card helper ───────────────────────────────────────────────────
  Widget _sectionCard({required String title, required Color accent, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppColors.cardRadius),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3, height: 18,
                decoration: BoxDecoration(
                  color: accent, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: AppColors.cardShadow),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
            onPressed: () => context.pop(),
            padding: EdgeInsets.zero)),
        title: const Text('Add Medicine',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
        centerTitle: true,
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 120),
          children: [

            // ── Barcode prefill banner ──────────────────────────────────
            if (widget.prefillData?['source'] == 'barcode')
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.check_circle, color: AppColors.success, size: 18),
                    SizedBox(width: 8),
                    Text('Auto-filled from barcode scan',
                        style: TextStyle(color: AppColors.success, fontSize: 13)),
                  ]),
                ),
              ),

            // ══ BASIC INFORMATION ══════════════════════════════════════
            _sectionCard(
              title: 'Basic Information',
              accent: AppColors.primary,
              children: [
                _Field(label: 'Medicine Name *', controller: _nameCtrl,
                  hint: 'e.g. Paracetamol',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                _Field(label: 'Brand Name', controller: _brandCtrl, hint: 'Optional'),
                const SizedBox(height: 12),
                _Field(label: 'Strength', controller: _strengthCtrl, hint: 'e.g. 500mg'),
              ],
            ).animate().fadeIn(delay: 60.ms, duration: 300.ms),

            // ══ MEDICINE DETAILS ═══════════════════════════════════════
            _sectionCard(
              title: 'Medicine Details',
              accent: AppColors.success,
              children: [
                // Form type chips
                const Text('Form Type',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _formTypes.map((type) {
                    final selected = _selectedForm == type;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedForm = type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.darkButton : Colors.white,
                          borderRadius: BorderRadius.circular(AppColors.chipRadius),
                          border: Border.all(
                            color: selected ? AppColors.darkButton : AppColors.border)),
                        child: Text(type,
                          style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : AppColors.textSecondary)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                _Field(label: 'Quantity', controller: _quantityCtrl,
                  hint: 'e.g. 30',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 12),
                // Expiry date
                const Text('Expiry Date',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickExpiryDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
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
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),
                      const Icon(Icons.calendar_today_rounded,
                          color: AppColors.primary, size: 18),
                    ]),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

            // ══ NOTES ══════════════════════════════════════════════════
            _sectionCard(
              title: 'Notes & Memos',
              accent: AppColors.warning,
              children: [
                _Field(label: 'Notes', controller: _notesCtrl,
                  hint: 'e.g. Take with food',
                  maxLines: 3, maxLength: 500,
                ),
              ],
            ).animate().fadeIn(delay: 140.ms, duration: 300.ms),

            // ══ REMINDERS ══════════════════════════════════════════════
            _sectionCard(
              title: 'Set Reminder',
              accent: AppColors.caregiver,
              children: [
                // Step 1 — Time presets
                const Text('Step 1: Choose Time',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _presetTimes.map((p) {
                    final (emoji, label, time) = p;
                    final added = _reminderTimes.contains(time);
                    return GestureDetector(
                      onTap: () => _addPresetTime(time),
                      child: Container(
                        width: 72,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: added ? AppColors.darkButton : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: added ? Colors.transparent : AppColors.border),
                          boxShadow: added
                              ? [BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 12, offset: const Offset(0, 4))]
                              : null,
                        ),
                        child: Column(
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 4),
                            Text(label, style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600,
                              color: added ? Colors.white : AppColors.textSecondary,
                            )),
                            Text(time, style: TextStyle(
                              fontSize: 10,
                              color: added ? Colors.white.withValues(alpha: 0.8) : AppColors.textTertiary,
                            )),
                          ],
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
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    const Text('Add Custom Time', style: TextStyle(
                        color: AppColors.primary, fontSize: 14,
                        fontWeight: FontWeight.w600)),
                  ]),
                ),
                if (_reminderTimes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _reminderTimes.map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(t, style: const TextStyle(
                            color: AppColors.primary, fontSize: 13,
                            fontWeight: FontWeight.w600)),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => setState(() => _reminderTimes.remove(t)),
                          child: const Icon(Icons.close_rounded,
                              color: AppColors.primary, size: 14),
                        ),
                      ]),
                    )).toList(),
                  ),
                ],

                const SizedBox(height: 20),
                // Step 2 — Frequency
                const Text('Step 2: Frequency',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 8),
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primaryLight : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                                color: selected ? AppColors.primary : AppColors.border),
                          ),
                          child: Text(day, style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: selected ? AppColors.primary : AppColors.textSecondary,
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

                const SizedBox(height: 20),
                // Step 3 — Duration
                const Text('Step 3: Duration',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 8),
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
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(children: [
                          const Icon(Icons.calendar_today_rounded,
                              color: AppColors.primary, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            _endDate != null
                                ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                : 'Select end date',
                            style: TextStyle(
                              fontSize: 13,
                              color: _endDate != null
                                  ? AppColors.textPrimary
                                  : AppColors.textTertiary,
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

                const SizedBox(height: 20),
                // Step 4 — Additional options
                const Text('Step 4: Additional Options',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 8),
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
                            style: TextStyle(fontSize: 13,
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: [5, 10, 15, 30].map((m) {
                            final sel = _snoozeDuration == m;
                            return GestureDetector(
                              onTap: () => setState(() => _snoozeDuration = m),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 7),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? AppColors.primaryLight
                                      : AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      color: sel ? AppColors.primary : AppColors.border),
                                ),
                                child: Text('${m}m', style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600,
                                  color: sel ? AppColors.primary : AppColors.textSecondary,
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
              ],
            ).animate().fadeIn(delay: 180.ms, duration: 300.ms),

            // ── Disclaimer ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
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
                    Expanded(child: Text(
                      '⚠️ MediFlow is a medication organization tool only. We do NOT provide medical advice. Always follow your doctor\'s instructions.',
                      style: TextStyle(fontSize: 12, color: AppColors.warning, height: 1.5),
                    )),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 220.ms, duration: 300.ms),
          ],
        ),
      ),

      // ── Sticky bottom button ───────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkButton,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700)),
              child: _isLoading
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : const Text('Confirm & Add Medicine'),
            ),
          ),
        ),
      ),
    );
  }
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
          counterStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    ]);
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
        activeColor: AppColors.primary,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
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
      Text('$value $label',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
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
          color: AppColors.surfaceVariant,
          border: Border.all(
            color: onTap != null ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Icon(icon, size: 16,
            color: onTap != null ? AppColors.primary : AppColors.textTertiary),
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
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          activeTrackColor: AppColors.primaryLight,
          inactiveTrackColor: AppColors.border,
          inactiveThumbColor: AppColors.textTertiary,
        ),
      ],
    );
  }
}
