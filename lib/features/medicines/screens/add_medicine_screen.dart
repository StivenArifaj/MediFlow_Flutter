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
import '../../../core/widgets/neon_button.dart';
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

  late final _nameCtrl = TextEditingController(text: widget.prefillData?['verifiedName']);
  late final _brandCtrl = TextEditingController(text: widget.prefillData?['brandName']);
  late final _genericCtrl = TextEditingController(text: widget.prefillData?['genericName']);
  late final _manufacturerCtrl = TextEditingController(text: widget.prefillData?['manufacturer']);
  late final _strengthCtrl = TextEditingController(text: widget.prefillData?['strength']);
  late final _categoryCtrl = TextEditingController();
  late final _quantityCtrl = TextEditingController(text: widget.prefillData?['quantity']);
  late final _notesCtrl = TextEditingController();

  String? _selectedForm;
  DateTime? _expiryDate;
  bool _isLoading = false;
  final List<String> _reminderTimes = [];

  static const _formTypes = [
    'Tablet', 'Capsule', 'Liquid', 'Injection',
    'Cream/Ointment', 'Drops', 'Inhaler', 'Patch', 'Spray', 'Other',
  ];

  static const _presetReminders = [
    ('☀️ Morning', '08:00'),
    ('🌤️ Afternoon', '14:00'),
    ('🌙 Evening', '20:00'),
    ('🛏️ Bedtime', '22:00'),
  ];

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
    final expiry = widget.prefillData?['expiryDate'];
    if (expiry != null) {
      try {
        final parts = expiry.split(RegExp(r'[/\-.]'));
        if (parts.length >= 2) {
          final month = int.tryParse(parts[0]) ?? 1;
          final year = int.tryParse(parts.last) ?? DateTime.now().year;
          _expiryDate = DateTime(year < 100 ? 2000 + year : year, month);
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _genericCtrl.dispose();
    _manufacturerCtrl.dispose();
    _strengthCtrl.dispose();
    _categoryCtrl.dispose();
    _quantityCtrl.dispose();
    _notesCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addPresetTime(String time) {
    if (_reminderTimes.contains(time)) return;
    if (_reminderTimes.length >= 5) { _showSnack('Maximum 5 reminder times allowed.'); return; }
    setState(() => _reminderTimes.add(time));
  }

  Future<void> _pickCustomTime() async {
    if (_reminderTimes.length >= 5) { _showSnack('Maximum 5 reminder times allowed.'); return; }
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked == null) return;
    final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    if (!_reminderTimes.contains(formatted)) setState(() => _reminderTimes.add(formatted));
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2040),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.neonCyan, surface: AppColors.bgCard),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

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

      final id = await db.medicinesDao.insertMedicine(
        MedicinesCompanion.insert(
          userId: userId,
          verifiedName: _nameCtrl.text.trim(),
          brandName: Value(_brandCtrl.text.trim().isNotEmpty ? _brandCtrl.text.trim() : null),
          genericName: Value(_genericCtrl.text.trim().isNotEmpty ? _genericCtrl.text.trim() : null),
          manufacturer: Value(_manufacturerCtrl.text.trim().isNotEmpty ? _manufacturerCtrl.text.trim() : null),
          strength: Value(_strengthCtrl.text.trim().isNotEmpty ? _strengthCtrl.text.trim() : null),
          form: Value(_selectedForm),
          category: Value(_categoryCtrl.text.trim().isNotEmpty ? _categoryCtrl.text.trim() : null),
          quantity: Value(quantity),
          notes: Value(_notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null),
          expiryDate: Value(_expiryDate),
          createdAt: DateTime.now(),
        ),
      );

      for (final time in _reminderTimes) {
        await db.remindersDao.insertReminder(
          RemindersCompanion.insert(medicineId: id, userId: userId, time: time, createdAt: DateTime.now()),
        );
      }
      if (mounted) { _showSnack('Medicine added successfully! ✅', isError: false); context.pop(); }
    } catch (e) {
      _showSnack('Error saving medicine. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSm)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: StarfieldBackground(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Basic Information'),
                      _buildFormSection([
                        _AppField(label: 'Medicine Name *', controller: _nameCtrl, hint: 'e.g. Paracetamol', maxLength: 100,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Medicine name is required' : null),
                        _AppField(label: 'Brand Name', controller: _brandCtrl, hint: 'Optional', maxLength: 100),
                        _AppField(label: 'Generic Name', controller: _genericCtrl, hint: 'Optional', maxLength: 100),
                        _AppField(label: 'Manufacturer', controller: _manufacturerCtrl, hint: 'Optional', maxLength: 100),
                      ]),
                      _buildSectionTitle('Medicine Details'),
                      _buildFormSection([
                        _AppField(label: 'Strength', controller: _strengthCtrl, hint: 'e.g. 500mg', maxLength: 50),
                        // Form type chips
                        Padding(
                          padding: const EdgeInsets.only(left: AppDimensions.md, right: AppDimensions.md, bottom: AppDimensions.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Form', style: AppTypography.bodySmall()),
                              const SizedBox(height: AppDimensions.xs),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _formTypes.map((f) {
                                    final selected = _selectedForm == f;
                                    return GestureDetector(
                                      onTap: () => setState(() => _selectedForm = f),
                                      child: AnimatedContainer(
                                        duration: 200.ms,
                                        margin: const EdgeInsets.only(right: AppDimensions.xs),
                                        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.xs),
                                        decoration: BoxDecoration(
                                          gradient: selected ? AppColors.primaryGradient : null,
                                          color: selected ? null : AppColors.bgInput,
                                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                          border: Border.all(color: selected ? AppColors.neonCyan : const Color(0x1AFFFFFF)),
                                        ),
                                        child: Text(f, style: AppTypography.bodySmall(color: selected ? AppColors.bgPrimary : AppColors.textPrimary)),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _AppField(label: 'Quantity', controller: _quantityCtrl, hint: 'e.g. 30', keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                        // Expiry
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.xs),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Expiry Date', style: AppTypography.bodySmall()),
                              const SizedBox(height: AppDimensions.xs),
                              GestureDetector(
                                onTap: _pickExpiryDate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgInput,
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                    border: Border.all(color: const Color(0x1AFFFFFF)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _expiryDate != null ? '${_expiryDate!.month}/${_expiryDate!.year}' : 'Select expiry date (optional)',
                                          style: _expiryDate != null ? AppTypography.bodyLarge() : AppTypography.bodyLarge(color: AppColors.textMuted),
                                        ),
                                      ),
                                      const Icon(Icons.calendar_today_rounded, color: AppColors.neonCyan, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _AppField(label: 'Category', controller: _categoryCtrl, hint: 'e.g. Pain Relief'),
                      ]),
                      _buildSectionTitle('Notes & Memos'),
                      _buildFormSection([
                        _AppField(label: 'Notes', controller: _notesCtrl, hint: 'e.g. Take with food', maxLines: 3, maxLength: 500),
                      ]),
                      _buildSectionTitle('Reminders'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Set reminder times now, or add them later', style: AppTypography.bodySmall()),
                            const SizedBox(height: AppDimensions.md),
                            Row(
                              children: _presetReminders.map((p) {
                                final (label, time) = p;
                                final added = _reminderTimes.contains(time);
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => _addPresetTime(time),
                                    child: AnimatedContainer(
                                      duration: 200.ms,
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: added ? AppColors.neonCyan.withValues(alpha: 0.15) : AppColors.bgCard,
                                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                        border: Border.all(color: added ? AppColors.neonCyan : const Color(0x1A00E5FF)),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(label.split(' ').first, style: const TextStyle(fontSize: 18)),
                                          const SizedBox(height: 2),
                                          Text(label.split(' ').sublist(1).join(' '), style: AppTypography.bodySmall(color: added ? AppColors.neonCyan : AppColors.textMuted), overflow: TextOverflow.ellipsis),
                                          Text(time, style: AppTypography.bodySmall(color: added ? AppColors.neonCyan : AppColors.textMuted)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: AppDimensions.sm),
                            TextButton.icon(
                              onPressed: _pickCustomTime,
                              icon: const Icon(Icons.add_rounded, color: AppColors.neonCyan, size: 18),
                              label: Text('Custom time', style: AppTypography.labelLarge()),
                            ),
                            if (_reminderTimes.isNotEmpty)
                              Wrap(
                                spacing: AppDimensions.xs,
                                children: _reminderTimes.map((t) {
                                  return Chip(
                                    label: Text(t, style: AppTypography.bodySmall(color: AppColors.textPrimary)),
                                    backgroundColor: AppColors.bgInput,
                                    deleteIcon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                                    onDeleted: () => setState(() => _reminderTimes.remove(t)),
                                    side: const BorderSide(color: AppColors.neonCyan),
                                  );
                                }).toList(),
                              ),
                          ],
                        ).animate().fadeIn(duration: 300.ms),
                      ),
                      const SizedBox(height: AppDimensions.lg),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                        child: Container(
                          padding: const EdgeInsets.all(AppDimensions.md),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
                              const SizedBox(width: AppDimensions.sm),
                              Expanded(child: Text('⚠️ MediFlow is a medication organization tool only. Always follow your doctor\'s instructions.', style: AppTypography.bodySmall(color: AppColors.warning))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Sticky bottom
            Container(
              padding: const EdgeInsets.fromLTRB(AppDimensions.md, AppDimensions.sm, AppDimensions.md, AppDimensions.lg),
              decoration: const BoxDecoration(
                color: AppColors.bgPrimary,
                border: Border(top: BorderSide(color: Color(0x1A00E5FF))),
              ),
              child: SafeArea(
                top: false,
                child: NeonButton(label: 'Confirm & Add Medicine', isLoading: _isLoading, onPressed: _isLoading ? null : _submit),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        boxShadow: const [AppColors.cyanGlow],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.md),
          child: Row(
            children: [
              IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded), color: AppColors.bgPrimary),
              Expanded(child: Text('Add Medicine', style: AppTypography.headlineMedium(color: AppColors.bgPrimary))),
              if (widget.prefillData != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.bgPrimary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
                  child: Text('📷 OCR', style: AppTypography.bodySmall(color: AppColors.bgPrimary)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.md, AppDimensions.lg, AppDimensions.md, AppDimensions.xs),
      child: Text(title, style: AppTypography.titleLarge(color: AppColors.neonCyan).copyWith(fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildFormSection(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.xs),
      decoration: AppColors.neonCardDecoration,
      child: Column(children: children),
    );
  }
}

// ── App Field (updated styling) ──────────────────────────────────────────────

class _AppField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int? maxLength;
  final int? maxLines;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _AppField({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLength,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.md, AppDimensions.md, AppDimensions.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.bodySmall()),
          const SizedBox(height: AppDimensions.xs),
          TextFormField(
            controller: controller,
            maxLength: maxLength,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            buildCounter: maxLength != null
                ? (_, {required currentLength, required isFocused, maxLength}) {
                    return Text('$currentLength / $maxLength', style: AppTypography.bodySmall(color: AppColors.textMuted));
                  }
                : null,
            style: AppTypography.bodyLarge(),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.bodyLarge(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.bgInput,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd), borderSide: const BorderSide(color: Color(0x1AFFFFFF), width: 1)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd), borderSide: const BorderSide(color: Color(0x1AFFFFFF), width: 1)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd), borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.5)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd), borderSide: const BorderSide(color: AppColors.error)),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 14),
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
        ],
      ),
    );
  }
}
