import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/hooks/managed_user_id.dart';
import '../../../core/widgets/circle_button.dart';
import '../../../data/services/supabase_data_service.dart';
import '../../../data/services/notification_service.dart';
import '../../../features/medicines/providers/medicines_provider.dart';

class ReminderSetupScreen extends ConsumerStatefulWidget {
  final String medicineId;
  final String medicineName;

  const ReminderSetupScreen({
    super.key,
    required this.medicineId,
    this.medicineName = '',
  });

  @override
  ConsumerState<ReminderSetupScreen> createState() => _ReminderSetupScreenState();
}

class _ReminderSetupScreenState extends ConsumerState<ReminderSetupScreen> {
  String _frequency = 'daily';

  final List<String> _times = [];

  String _durationType = 'ongoing';
  DateTime? _endDate;
  final _daysController = TextEditingController();

  bool _snoozeEnabled = true;
  int _snoozeDuration = 15;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  final Set<String> _selectedDays = {};

  bool _isLoading = false;

  static const _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _presetTimes = ['06:00', '08:00', '12:00', '14:00', '18:00', '20:00', '22:00'];

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  Future<void> _addPresetTime(String t) async {
    if (_times.contains(t)) return;
    if (_times.length >= 5) {
      _snack('Maximum 5 reminder times allowed.');
      return;
    }
    setState(() { _times.add(t); _times.sort(); });
  }

  Future<void> _pickCustomTime() async {
    if (_times.length >= 5) { _snack('Maximum 5 reminder times allowed.'); return; }
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked == null) return;
    final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    if (!_times.contains(formatted)) setState(() { _times.add(formatted); _times.sort(); });
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2040),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.darkButton,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  bool _validate() {
    if (_times.isEmpty) { _snack('Please add at least one reminder time.'); return false; }
    if (_frequency == 'weekly' && _selectedDays.isEmpty) { _snack('Please select at least one day.'); return false; }
    if (_durationType == 'for_days') {
      final d = int.tryParse(_daysController.text.trim());
      if (d == null || d < 1) { _snack('Please enter a valid number of days.'); return false; }
    }
    return true;
  }

  Future<void> _save() async {
    if (!_validate() || _isLoading) return;
    setState(() => _isLoading = true);

    try {
      final userId = await ref.read(managedUserIdProvider.future);
      if (userId == null) { _snack('Not logged in'); return; }

      final svc = ref.read(supabaseDataServiceProvider);
      final durationDays = _durationType == 'for_days'
          ? int.tryParse(_daysController.text.trim())
          : null;

      for (final time in _times) {
        await svc.createReminder(
          userId: userId,
          medicineId: widget.medicineId,
          time: time,
          frequency: _frequency,
          days: _frequency == 'weekly' ? _selectedDays.toList() : null,
          durationType: _durationType,
          endDate: _endDate?.toIso8601String().split('T').first,
          durationDays: durationDays,
          snoozeDuration: _snoozeEnabled ? _snoozeDuration : 0,
        );
      }

      await NotificationService.instance.scheduleRemindersForMedicine(
        medicineId: widget.medicineId.hashCode.abs() % 2147483647,
        medicineName: widget.medicineName,
        times: _times,
        frequency: _frequency,
        days: _selectedDays.map(_dayNameToInt).toList(),
      );

      ref.invalidate(remindersForMedicineProvider(widget.medicineId));

      if (mounted) {
        _snack('Reminders saved & scheduled');
        context.pop();
      }
    } catch (e) {
      _snack('Failed to save reminders. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text('Set Reminder'),
        leading: Center(
          child: CircleButton(
            icon: Icons.arrow_back_rounded,
            size: 38,
            onTap: () => context.pop(),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Save Reminder'),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Medicine info ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppColors.card,
              child: Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.medication_rounded,
                      color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.medicineName.isNotEmpty ? widget.medicineName : 'Medicine',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      const Text('Set up when to be reminded',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ]),
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 12),

            // ── Frequency ─────────────────────────────────────
            _SectionCard(
              title: 'Frequency',
              accent: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: {
                      'daily': 'Daily',
                      'weekly': 'Weekly',
                      'interval': 'Every N Days',
                      'as_needed': 'As Needed',
                    }.entries.map((e) => _ChoiceChip(
                      label: e.value,
                      selected: _frequency == e.key,
                      onTap: () => setState(() => _frequency = e.key),
                    )).toList(),
                  ),
                  if (_frequency == 'weekly') ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _weekDays.map((d) => _ChoiceChip(
                        label: d,
                        selected: _selectedDays.contains(d),
                        onTap: () => setState(() {
                          if (_selectedDays.contains(d)) {
                            _selectedDays.remove(d);
                          } else {
                            _selectedDays.add(d);
                          }
                        }),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Times ─────────────────────────────────────────
            _SectionCard(
              title: 'Reminder Times',
              accent: AppColors.success,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      ..._presetTimes.map((t) => _ChoiceChip(
                        label: t,
                        selected: _times.contains(t),
                        onTap: () => _times.contains(t)
                            ? setState(() => _times.remove(t))
                            : _addPresetTime(t),
                      )),
                      _ChoiceChip(
                        label: '+ Custom',
                        selected: false,
                        onTap: _pickCustomTime,
                      ),
                    ],
                  ),
                  if (_times.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: _times.map((t) => Chip(
                        label: Text(t,
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        deleteIcon: const Icon(Icons.close,
                            size: 14, color: AppColors.textSecondary),
                        onDeleted: () => setState(() => _times.remove(t)),
                        backgroundColor: AppColors.primaryLight,
                        side: BorderSide.none,
                        shape: const StadiumBorder(),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Duration ──────────────────────────────────────
            _SectionCard(
              title: 'Duration',
              accent: AppColors.warning,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: {
                      'ongoing': 'Ongoing',
                      'until_date': 'Until Date',
                      'for_days': 'For X Days',
                    }.entries.map((e) => _ChoiceChip(
                      label: e.value,
                      selected: _durationType == e.key,
                      onTap: () => setState(() => _durationType = e.key),
                    )).toList(),
                  ),
                  if (_durationType == 'until_date') ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickEndDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(children: [
                          const Icon(Icons.calendar_today_rounded,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            _endDate != null
                                ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                : 'Select end date',
                            style: TextStyle(
                              color: _endDate != null
                                  ? AppColors.textPrimary
                                  : AppColors.textTertiary,
                              fontSize: 15,
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                  if (_durationType == 'for_days') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _daysController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Number of days (e.g. 30)',
                        prefixIcon: Icon(Icons.today_rounded,
                            color: AppColors.textTertiary, size: 20),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Options ───────────────────────────────────────
            _SectionCard(
              title: 'Options',
              accent: AppColors.caregiver,
              child: Column(children: [
                _OptionRow(
                  icon: Icons.snooze_rounded,
                  label: 'Snooze',
                  subtitle: 'Allow snoozing reminders',
                  value: _snoozeEnabled,
                  onChanged: (v) => setState(() => _snoozeEnabled = v),
                ),
                if (_snoozeEnabled) ...[
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Text('Duration:',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(width: 8),
                    ...([5, 10, 15, 30]).map((m) => GestureDetector(
                      onTap: () => setState(() => _snoozeDuration = m),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _snoozeDuration == m
                              ? AppColors.darkButton
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text('${m}m',
                            style: TextStyle(
                              fontSize: 13,
                              color: _snoozeDuration == m
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: _snoozeDuration == m
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            )),
                      ),
                    )),
                  ]),
                  const SizedBox(height: 8),
                ],
                const Divider(color: AppColors.divider, height: 1),
                _OptionRow(
                  icon: Icons.volume_up_rounded,
                  label: 'Sound',
                  subtitle: 'Play notification sound',
                  value: _soundEnabled,
                  onChanged: (v) => setState(() => _soundEnabled = v),
                ),
                const Divider(color: AppColors.divider, height: 1),
                _OptionRow(
                  icon: Icons.vibration_rounded,
                  label: 'Vibration',
                  subtitle: 'Vibrate on reminder',
                  value: _vibrationEnabled,
                  onChanged: (v) => setState(() => _vibrationEnabled = v),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  int _dayNameToInt(String day) {
    const map = {'Mon': 1, 'Tue': 2, 'Wed': 3, 'Thu': 4, 'Fri': 5, 'Sat': 6, 'Sun': 7};
    return map[day] ?? 1;
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Color accent;
  final Widget child;
  const _SectionCard({required this.title, required this.accent, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 3, height: 16,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Choice Chip ───────────────────────────────────────────────────────────────

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ChoiceChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.darkButton : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(50),
          boxShadow: selected ? AppColors.sm : null,
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? Colors.white : AppColors.textSecondary,
            )),
      ),
    );
  }
}

// ── Option Row ────────────────────────────────────────────────────────────────

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _OptionRow({required this.icon, required this.label, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          Text(subtitle,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ])),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
      ]),
    );
  }
}
