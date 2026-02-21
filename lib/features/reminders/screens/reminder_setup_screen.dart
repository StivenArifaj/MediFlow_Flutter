import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/database/app_database.dart';
import '../../auth/providers/auth_provider.dart';

class ReminderSetupScreen extends ConsumerStatefulWidget {
  final int? medicineId;
  const ReminderSetupScreen({super.key, this.medicineId});

  @override
  ConsumerState<ReminderSetupScreen> createState() => _ReminderSetupScreenState();
}

class _ReminderSetupScreenState extends ConsumerState<ReminderSetupScreen> {
  // Step 1: Times
  final List<String> _times = [];

  // Step 2: Frequency
  String _frequency = 'daily';
  final List<String> _selectedDays = [];
  int _intervalDays = 2;

  // Step 3: Duration
  String _durationType = 'ongoing';
  DateTime? _endDate;
  int _durationDays = 30;

  // Step 4: Options
  bool _snoozeEnabled = true;
  int _snoozeDuration = 15;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  bool _isSaving = false;

  static const _presetTimes = [
    ('☀️', 'Morning', '08:00'),
    ('🌤️', 'Afternoon', '14:00'),
    ('🌙', 'Evening', '20:00'),
    ('🛏️', 'Bedtime', '22:00'),
  ];

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  void _addTime(String time) {
    if (_times.contains(time)) return;
    if (_times.length >= 5) { _showSnack('Max 5 times.'); return; }
    setState(() => _times.add(time));
  }

  Future<void> _pickCustomTime() async {
    if (_times.length >= 5) { _showSnack('Max 5 times.'); return; }
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked == null) return;
    final t = '${picked.hour.toString().padLeft(2,'0')}:${picked.minute.toString().padLeft(2,'0')}';
    if (!_times.contains(t)) setState(() => _times.add(t));
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
            primary: AppColors.primary, surface: AppColors.bgCard,
          ),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _endDate = d);
  }

  Future<void> _save() async {
    if (_times.isEmpty) { _showSnack('Add at least one reminder time.'); return; }
    if (widget.medicineId == null) { _showSnack('No medicine selected.'); return; }

    setState(() => _isSaving = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final repo = ref.read(authRepositoryProvider);
      final userId = repo.currentUserId!;

      final days = _frequency == 'specific' ? _selectedDays.join(',') : null;
      final interval = _frequency == 'interval' ? _intervalDays : null;
      final dur = _durationType == 'days' ? _durationDays : null;
      final end = _durationType == 'date' ? _endDate : null;

      for (final t in _times) {
        await db.remindersDao.insertReminder(
          RemindersCompanion.insert(
            medicineId: widget.medicineId!,
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reminders saved! ✅'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      _showSnack('Error saving reminders.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: AppColors.bgDark,
                    ),
                    Text('Set Reminder', style: AppTypography.headlineMedium(color: AppColors.bgDark)),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Step 1: Time ─────────────────────────────
                  _stepCard(
                    step: '1',
                    title: 'Choose Time',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: _presetTimes.map((p) {
                            final (emoji, name, time) = p;
                            final active = _times.contains(time);
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => _addTime(time),
                                child: AnimatedContainer(
                                  duration: 200.ms,
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: active ? AppColors.primary : AppColors.bgCardLight,
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                    border: Border.all(
                                      color: active ? AppColors.primaryDark : Colors.transparent,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(emoji, style: const TextStyle(fontSize: 20)),
                                      const SizedBox(height: 2),
                                      Text(name,
                                          style: AppTypography.bodySmall(
                                              color: active ? AppColors.bgDark : AppColors.textPrimary),
                                          overflow: TextOverflow.ellipsis),
                                      Text(time,
                                          style: AppTypography.bodySmall(
                                              color: active ? AppColors.bgDark : AppColors.textSecondary)),
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
                          icon: const Icon(Icons.add_rounded, color: AppColors.primary, size: 18),
                          label: Text('Add Custom Time', style: AppTypography.labelLarge()),
                        ),
                        if (_times.isNotEmpty)
                          Wrap(
                            spacing: AppDimensions.xs,
                            children: _times.map((t) => Chip(
                              label: Text(t, style: AppTypography.bodySmall(color: AppColors.textPrimary)),
                              backgroundColor: AppColors.bgCardLight,
                              deleteIcon: const Icon(Icons.close_rounded, size: 14, color: AppColors.textSecondary),
                              onDeleted: () => setState(() => _times.remove(t)),
                              side: const BorderSide(color: AppColors.primary),
                            )).toList(),
                          ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: AppDimensions.md),

                  // ── Step 2: Frequency ─────────────────────────
                  _stepCard(
                    step: '2',
                    title: 'Frequency',
                    child: Column(
                      children: [
                        _radioOption('Every day', 'daily'),
                        _radioOption('Specific days', 'specific'),
                        if (_frequency == 'specific') ...[
                          const SizedBox(height: AppDimensions.xs),
                          Wrap(
                            spacing: AppDimensions.xs,
                            children: _days.map((d) {
                              final sel = _selectedDays.contains(d);
                              return GestureDetector(
                                onTap: () => setState(() =>
                                  sel ? _selectedDays.remove(d) : _selectedDays.add(d)),
                                child: AnimatedContainer(
                                  duration: 200.ms,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: sel ? AppColors.primary : AppColors.bgCardLight,
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                  ),
                                  child: Text(d,
                                      style: AppTypography.bodySmall(
                                          color: sel ? AppColors.bgDark : AppColors.textPrimary)),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        _radioOption('Every X days', 'interval'),
                        if (_frequency == 'interval')
                          _NumberStepper(
                            value: _intervalDays,
                            label: 'days',
                            onChanged: (v) => setState(() => _intervalDays = v),
                          ),
                        _radioOption('As needed', 'as_needed'),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

                  const SizedBox(height: AppDimensions.md),

                  // ── Step 3: Duration ──────────────────────────
                  _stepCard(
                    step: '3',
                    title: 'Duration',
                    child: Column(
                      children: [
                        _durationRadio('Ongoing (no end date)', 'ongoing'),
                        _durationRadio('Until specific date', 'date'),
                        if (_durationType == 'date') ...[
                          GestureDetector(
                            onTap: _pickEndDate,
                            child: Container(
                              margin: const EdgeInsets.only(left: 32, top: 4, bottom: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.bgCardLight,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                              ),
                              child: Text(
                                _endDate != null
                                    ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                    : 'Pick end date',
                                style: AppTypography.bodyMedium(color: AppColors.textPrimary),
                              ),
                            ),
                          ),
                        ],
                        _durationRadio('For X days', 'days'),
                        if (_durationType == 'days')
                          _NumberStepper(
                            value: _durationDays,
                            label: 'days',
                            onChanged: (v) => setState(() => _durationDays = v),
                          ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

                  const SizedBox(height: AppDimensions.md),

                  // ── Step 4: Options ───────────────────────────
                  _stepCard(
                    step: '4',
                    title: 'Additional Options',
                    child: Column(
                      children: [
                        _ToggleRow(
                          label: 'Snooze',
                          value: _snoozeEnabled,
                          onChanged: (v) => setState(() => _snoozeEnabled = v),
                        ),
                        if (_snoozeEnabled) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 8),
                            child: Row(
                              children: [
                                Text('Snooze duration: ', style: AppTypography.bodySmall()),
                                ...[5, 10, 15, 30].map((min) {
                                  final sel = _snoozeDuration == min;
                                  return GestureDetector(
                                    onTap: () => setState(() => _snoozeDuration = min),
                                    child: AnimatedContainer(
                                      duration: 200.ms,
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: sel ? AppColors.primary : AppColors.bgCardLight,
                                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                      ),
                                      child: Text('${min}m',
                                          style: AppTypography.bodySmall(
                                              color: sel ? AppColors.bgDark : AppColors.textPrimary)),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                        _ToggleRow(
                          label: 'Sound',
                          value: _soundEnabled,
                          onChanged: (v) => setState(() => _soundEnabled = v),
                        ),
                        _ToggleRow(
                          label: 'Vibration',
                          value: _vibrationEnabled,
                          onChanged: (v) => setState(() => _vibrationEnabled = v),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 300.ms),

                  const SizedBox(height: AppDimensions.xl),

                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.bgDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: AppColors.bgDark, strokeWidth: 2)
                          : Text('Save Reminder', style: AppTypography.titleMedium(color: AppColors.bgDark)),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepCard({required String step, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.bgCardLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24, height: 24,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Center(
                  child: Text(step,
                      style: AppTypography.bodySmall(color: AppColors.bgDark)),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(title, style: AppTypography.titleMedium()),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          child,
        ],
      ),
    );
  }

  Widget _radioOption(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _frequency,
            fillColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.textSecondary,
            ),
            onChanged: (v) => setState(() => _frequency = v!),
          ),
          Text(label, style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _durationRadio(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _durationType,
            fillColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.textSecondary,
            ),
            onChanged: (v) => setState(() => _durationType = v!),
          ),
          Text(label, style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}



// ── Shared small widgets ──────────────────────────────────────────────────────

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
          Text(label, style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _NumberStepper extends StatelessWidget {
  final int value;
  final String label;
  final ValueChanged<int> onChanged;

  const _NumberStepper({required this.value, required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_rounded, color: AppColors.primary),
          ),
          Text('$value $label', style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
          IconButton(
            onPressed: value < 90 ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
