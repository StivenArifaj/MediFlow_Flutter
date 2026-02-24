import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/widgets/starfield_background.dart';
import '../../../data/database/app_database.dart';
import '../../auth/providers/auth_provider.dart';

class AddMedicineScreen extends ConsumerStatefulWidget {
  final Map<String, String?>? prefillData;
  const AddMedicineScreen({super.key, this.prefillData});

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  late final _nameCtrl =
      TextEditingController(text: widget.prefillData?['verifiedName']);
  late final _brandCtrl =
      TextEditingController(text: widget.prefillData?['brandName']);
  late final _strengthCtrl =
      TextEditingController(text: widget.prefillData?['strength']);
  late final _quantityCtrl =
      TextEditingController(text: widget.prefillData?['quantity']);
  late final _notesCtrl = TextEditingController();

  String? _selectedForm;
  bool _isLoading = false;
  // ── Reminder state (full) ──────────────────────────────────────────────────
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

  static const _presetTimes = [
    ('☀️', 'Morning',   '08:00'),
    ('🌤️', 'Afternoon', '14:00'),
    ('🌙', 'Evening',   '20:00'),
    ('🛏️', 'Bedtime',   '22:00'),
  ];
  static const _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];


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


  Future<void> _pickCustomTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00E5FF),
            surface: Color(0xFF0D1826),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final t =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (!_reminderTimes.contains(t) && _reminderTimes.length < 5) {
        setState(() => _reminderTimes.add(t));
      }
    }
  }



  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(authRepositoryProvider);
    final userId = repo.currentUserId;
    if (userId == null) return;
    setState(() => _isLoading = true);
    try {
      final db = ref.read(appDatabaseProvider);

      // Insert the medicine and get its new ID
      final medicineId = await db.medicinesDao.insertMedicine(
        MedicinesCompanion(
          userId: Value(userId),
          verifiedName: Value(_nameCtrl.text.trim()),
          brandName: Value(
              _brandCtrl.text.trim().isEmpty ? null : _brandCtrl.text.trim()),
          strength: Value(_strengthCtrl.text.trim().isEmpty
              ? null
              : _strengthCtrl.text.trim()),
          form: Value(_selectedForm),
          quantity: Value(int.tryParse(_quantityCtrl.text.trim())),
          notes: Value(
              _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
          createdAt: Value(DateTime.now()),
          isActive: const Value(true),
        ),
      );

      // Save each selected reminder time with full settings
      for (final time in _reminderTimes) {
        await db.remindersDao.insertReminder(
          RemindersCompanion.insert(
            medicineId: medicineId,
            userId: userId,
            time: time,
            frequency: Value(_frequency),
            days: Value(_frequency == 'specific' ? _selectedDays.join(',') : null),
            intervalDays: Value(_frequency == 'interval' ? _intervalDays : null),
            durationType: Value(_durationType),
            endDate: Value(_durationType == 'date' ? _endDate : null),
            durationDays: Value(_durationType == 'days' ? _durationDays : null),
            snoozeDuration: Value(_snoozeDuration),
            createdAt: DateTime.now(),
          ),
        );
      }
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Medicine added successfully ✓'),
            backgroundColor: const Color(0xFF00C896),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B12),
      body: StarfieldBackground(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── Transparent AppBar ───────────────────────────
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFF00E5FF), size: 20),
                      ),
                      const Expanded(
                        child: Text(
                          'Add Medicine',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (widget.prefillData != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF00E5FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                                color: const Color(0xFF00E5FF)
                                    .withOpacity(0.4)),
                          ),
                          child: const Text('📷 OCR',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF00E5FF))),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Scrollable form ──────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BASIC INFORMATION
                      _SectionHeader(title: 'Basic Information'),
                      const SizedBox(height: 10),
                      _FormCard(children: [
                        _Field(
                          label: 'Medicine Name *',
                          controller: _nameCtrl,
                          hint: 'e.g. Paracetamol',
                          maxLength: 100,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Name is required'
                              : null,
                        ),
                        _FieldDivider(),
                        _Field(
                          label: 'Brand Name',
                          controller: _brandCtrl,
                          hint: 'Optional',
                          maxLength: 100,
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // MEDICINE DETAILS
                      _SectionHeader(title: 'Medicine Details'),
                      const SizedBox(height: 10),
                      _FormCard(children: [
                        _Field(
                          label: 'Strength',
                          controller: _strengthCtrl,
                          hint: 'e.g. 500mg',
                          maxLength: 50,
                        ),
                        _FieldDivider(),
                        // Form type chips
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Form',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF8A9BB5))),
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _formTypes.map((type) {
                                    final selected = _selectedForm == type;
                                    return GestureDetector(
                                      onTap: () => setState(
                                          () => _selectedForm = type),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 200),
                                        margin: const EdgeInsets.only(
                                            right: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? const Color(0xFF00E5FF)
                                                  .withOpacity(0.12)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          border: Border.all(
                                            color: selected
                                                ? const Color(0xFF00E5FF)
                                                : const Color(0xFF2A3A4A),
                                            width: selected ? 1.5 : 1,
                                          ),
                                          boxShadow: selected
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(
                                                            0xFF00E5FF)
                                                        .withOpacity(0.2),
                                                    blurRadius: 10,
                                                  )
                                                ]
                                              : null,
                                        ),
                                        child: Text(
                                          type,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: selected
                                                ? const Color(0xFF00E5FF)
                                                : const Color(0xFF8A9BB5),
                                            fontWeight: selected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _FieldDivider(),
                        _Field(
                          label: 'Quantity',
                          controller: _quantityCtrl,
                          hint: 'e.g. 30',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // NOTES
                      _SectionHeader(title: 'Notes & Memos'),
                      const SizedBox(height: 10),
                      _FormCard(children: [
                        _Field(
                          label: 'Notes',
                          controller: _notesCtrl,
                          hint: 'e.g. Take with food',
                          maxLines: 3,
                          maxLength: 500,
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // ── REMINDERS ─────────────────────────────────────────
                      _SectionHeader(title: 'Reminders'),
                      const SizedBox(height: 10),

                      // Step 1: Choose Time
                      _ReminderStepCard(
                        step: '1', title: 'Choose Time',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: _presetTimes.map((p) {
                                final (emoji, name, time) = p;
                                final active = _reminderTimes.contains(time);
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_reminderTimes.contains(time)) {
                                        setState(() => _reminderTimes.remove(time));
                                      } else if (_reminderTimes.length < 5) {
                                        setState(() => _reminderTimes.add(time));
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: active
                                            ? const Color(0xFF00E5FF).withOpacity(0.15)
                                            : const Color(0xFF111927),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: active ? const Color(0xFF00E5FF) : const Color(0xFF1A2840),
                                          width: active ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(emoji, style: const TextStyle(fontSize: 20)),
                                          const SizedBox(height: 2),
                                          Text(name,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: active ? const Color(0xFF00E5FF) : const Color(0xFF8A9BB5),
                                              )),
                                          Text(time,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: active ? const Color(0xFF00E5FF) : const Color(0xFF4A5A72),
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: _pickCustomTime,
                              child: const Row(children: [
                                Icon(Icons.add_circle_outline_rounded, color: Color(0xFF00E5FF), size: 18),
                                SizedBox(width: 8),
                                Text('Add Custom Time', style: TextStyle(
                                    fontSize: 13, color: Color(0xFF00E5FF), fontWeight: FontWeight.w600)),
                              ]),
                            ),
                            if (_reminderTimes.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8, runSpacing: 6,
                                children: _reminderTimes.map((t) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00E5FF).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(t, style: const TextStyle(fontSize: 13, color: Color(0xFF00E5FF))),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () => setState(() => _reminderTimes.remove(t)),
                                        child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF8A9BB5)),
                                      ),
                                    ],
                                  ),
                                )).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Step 2: Frequency
                      _ReminderStepCard(
                        step: '2', title: 'Frequency',
                        child: Column(
                          children: [
                            _ReminderRadio(
                              label: 'Every day', value: 'daily',
                              groupValue: _frequency,
                              onChanged: (v) => setState(() => _frequency = v!),
                            ),
                            _ReminderRadio(
                              label: 'Specific days', value: 'specific',
                              groupValue: _frequency,
                              onChanged: (v) => setState(() => _frequency = v!),
                            ),
                            if (_frequency == 'specific') ...[
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Wrap(
                                  spacing: 6, runSpacing: 6,
                                  children: _weekDays.map((d) {
                                    final sel = _selectedDays.contains(d);
                                    return GestureDetector(
                                      onTap: () => setState(() =>
                                        sel ? _selectedDays.remove(d) : _selectedDays.add(d)),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: sel ? const Color(0xFF00E5FF).withOpacity(0.15) : const Color(0xFF111927),
                                          borderRadius: BorderRadius.circular(100),
                                          border: Border.all(
                                            color: sel ? const Color(0xFF00E5FF) : const Color(0xFF1A2840),
                                          ),
                                        ),
                                        child: Text(d, style: TextStyle(
                                          fontSize: 12,
                                          color: sel ? const Color(0xFF00E5FF) : const Color(0xFF8A9BB5),
                                          fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                                        )),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                            _ReminderRadio(
                              label: 'Every X days', value: 'interval',
                              groupValue: _frequency,
                              onChanged: (v) => setState(() => _frequency = v!),
                            ),
                            if (_frequency == 'interval')
                              _StepperRow(
                                value: _intervalDays, label: 'days',
                                onChanged: (v) => setState(() => _intervalDays = v),
                              ),
                            _ReminderRadio(
                              label: 'As needed', value: 'as_needed',
                              groupValue: _frequency,
                              onChanged: (v) => setState(() => _frequency = v!),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Step 3: Duration
                      _ReminderStepCard(
                        step: '3', title: 'Duration',
                        child: Column(
                          children: [
                            _ReminderRadio(
                              label: 'Ongoing (no end date)', value: 'ongoing',
                              groupValue: _durationType,
                              onChanged: (v) => setState(() => _durationType = v!),
                            ),
                            _ReminderRadio(
                              label: 'Until specific date', value: 'date',
                              groupValue: _durationType,
                              onChanged: (v) => setState(() => _durationType = v!),
                            ),
                            if (_durationType == 'date') ...[
                              GestureDetector(
                                onTap: () async {
                                  final d = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now().add(const Duration(days: 30)),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2040),
                                    builder: (ctx, child) => Theme(
                                      data: ThemeData.dark().copyWith(
                                        colorScheme: const ColorScheme.dark(
                                          primary: Color(0xFF00E5FF), surface: Color(0xFF0D1826),
                                        ),
                                      ),
                                      child: child!,
                                    ),
                                  );
                                  if (d != null) setState(() => _endDate = d);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(left: 32, top: 4, bottom: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF111927),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    _endDate != null
                                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                        : 'Pick end date',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _endDate != null ? Colors.white : const Color(0xFF4A5A72),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            _ReminderRadio(
                              label: 'For X days', value: 'days',
                              groupValue: _durationType,
                              onChanged: (v) => setState(() => _durationType = v!),
                            ),
                            if (_durationType == 'days')
                              _StepperRow(
                                value: _durationDays, label: 'days',
                                onChanged: (v) => setState(() => _durationDays = v),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Step 4: Additional Options
                      _ReminderStepCard(
                        step: '4', title: 'Additional Options',
                        child: Column(
                          children: [
                            _ToggleRow(
                              label: 'Snooze', value: _snoozeEnabled,
                              onChanged: (v) => setState(() => _snoozeEnabled = v),
                            ),
                            if (_snoozeEnabled) Padding(
                              padding: const EdgeInsets.only(left: 8, bottom: 8),
                              child: Row(
                                children: [
                                  const Text('Snooze: ', style: TextStyle(fontSize: 12, color: Color(0xFF8A9BB5))),
                                  ...[5, 10, 15, 30].map((min) {
                                    final sel = _snoozeDuration == min;
                                    return GestureDetector(
                                      onTap: () => setState(() => _snoozeDuration = min),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        margin: const EdgeInsets.only(right: 6),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: sel ? const Color(0xFF00E5FF).withOpacity(0.15) : const Color(0xFF111927),
                                          borderRadius: BorderRadius.circular(100),
                                          border: Border.all(
                                            color: sel ? const Color(0xFF00E5FF) : const Color(0xFF1A2840),
                                          ),
                                        ),
                                        child: Text('${min}m', style: TextStyle(
                                          fontSize: 12,
                                          color: sel ? const Color(0xFF00E5FF) : const Color(0xFF8A9BB5),
                                        )),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            _ToggleRow(
                              label: 'Sound', value: _soundEnabled,
                              onChanged: (v) => setState(() => _soundEnabled = v),
                            ),
                            _ToggleRow(
                              label: 'Vibration', value: _vibrationEnabled,
                              onChanged: (v) => setState(() => _vibrationEnabled = v),
                            ),
                          ],
                        ),
                      ),


                      const SizedBox(height: 20),

                      // Medical disclaimer
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB800).withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color:
                                  const Color(0xFFFFB800).withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Icon(Icons.warning_amber_rounded,
                                color: Color(0xFFFFB800), size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '⚠️ MediFlow is a medication organization tool only. We do NOT provide medical advice. Always follow your doctor\'s instructions.',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFFFB800),
                                    height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // ── Sticky bottom button ─────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                decoration: const BoxDecoration(
                  color: Color(0xFF070B12),
                  border: Border(
                      top: BorderSide(
                          color: Color(0x1A00E5FF), width: 1)),
                ),
                child: SafeArea(
                  top: false,
                  child: GestureDetector(
                    onTap: _isLoading ? null : _submit,
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00E5FF), Color(0xFF0055FF)],
                        ),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF00E5FF).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Color(0xFF070B12),
                                    strokeWidth: 2))
                            : const Text(
                                'Confirm & Add Medicine',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF070B12),
                                ),
                              ),
                      ),
                    ),
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

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 3, height: 18,
        decoration: BoxDecoration(
            color: const Color(0xFF00E5FF),
            borderRadius: BorderRadius.circular(2)),
      ),
      const SizedBox(width: 8),
      Text(title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00E5FF))),
    ]);
  }
}

// ── Form Card ─────────────────────────────────────────────────────────────────
class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1826),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.1)),
      ),
      child: Column(children: children),
    );
  }
}

// ── Field Divider ─────────────────────────────────────────────────────────────
class _FieldDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      height: 1,
      color: const Color(0xFF00E5FF).withOpacity(0.06));
}

// ── Field ─────────────────────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int? maxLength;
  final int? maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLength,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF8A9BB5))),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            style:
                const TextStyle(fontSize: 15, color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Color(0xFF4A5A72)),
              counterText: maxLength != null ? '' : null,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
            ),
          ),
          if (maxLength != null)
            Align(
              alignment: Alignment.centerRight,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (_, val, __) => Text(
                  '${val.text.length} / $maxLength',
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF4A5A72)),
                ),
              ),
            ),
          const SizedBox(height: 4),
        ],
      ),
    );
}

// ── Reminder Step Card ────────────────────────────────────────────────────────
class _ReminderStepCard extends StatelessWidget {
  final String step;
  final String title;
  final Widget child;
  const _ReminderStepCard({required this.step, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1826),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 24, height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF00E5FF), shape: BoxShape.circle),
              child: Center(
                child: Text(step,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF070B12))),
              ),
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          ]),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Reminder Radio ────────────────────────────────────────────────────────────
class _ReminderRadio extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;
  const _ReminderRadio({
    required this.label, required this.value,
    required this.groupValue, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Radio<String>(
          value: value,
          groupValue: groupValue,
          activeColor: const Color(0xFF00E5FF),
          onChanged: onChanged,
        ),
        Text(label,
            style: const TextStyle(fontSize: 14, color: Colors.white)),
      ]),
    );
  }
}

// ── Stepper Row ───────────────────────────────────────────────────────────────
class _StepperRow extends StatelessWidget {
  final int value;
  final String label;
  final ValueChanged<int> onChanged;
  const _StepperRow({required this.value, required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 6),
      child: Row(children: [
        IconButton(
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_rounded, color: Color(0xFF00E5FF)),
          padding: EdgeInsets.zero, constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 12),
        Text('$value $label',
            style: const TextStyle(fontSize: 14, color: Colors.white)),
        const SizedBox(width: 12),
        IconButton(
          onPressed: value < 90 ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_rounded, color: Color(0xFF00E5FF)),
          padding: EdgeInsets.zero, constraints: const BoxConstraints(),
        ),
      ]),
    );
  }
}

// ── Toggle Row ────────────────────────────────────────────────────────────────
class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.white)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF00E5FF),
          ),
        ],
      ),
    );
  }
}