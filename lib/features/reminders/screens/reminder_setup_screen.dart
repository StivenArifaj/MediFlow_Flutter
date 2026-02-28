import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/starfield_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../data/database/app_database.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../data/services/notification_service.dart';

class ReminderSetupScreen extends ConsumerStatefulWidget {
  final int medicineId;
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
  // Step 1 — Frequency
  String _frequency = 'daily'; // daily | weekly | interval | as_needed

  // Step 2 — Time(s)
  final List<String> _times = [];

  // Step 3 — Duration
  String _durationType = 'ongoing'; // ongoing | until_date | for_days
  DateTime? _endDate;
  final _daysController = TextEditingController();

  // Step 4 — Options
  bool _snoozeEnabled = true;
  int _snoozeDuration = 15;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Weekly days
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
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now(),
        builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.dark(primary: Color(0xFF00E5FF), surface: Color(0xFF0D1826)),
          ),
          child: child!,
        ));
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
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFF00E5FF), surface: Color(0xFF0D1826)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFF0D1826),
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
      final db = ref.read(appDatabaseProvider);
      final repo = ref.read(authRepositoryProvider);
      final userId = repo.currentUserId;
      if (userId == null) { _snack('Not logged in'); return; }

      final durationDays = _durationType == 'for_days'
          ? int.tryParse(_daysController.text.trim())
          : null;

      // Save one reminder per time slot
      for (final time in _times) {
        final notifId = DateTime.now().millisecondsSinceEpoch % 100000 + _times.indexOf(time);

        final reminderId = await db.remindersDao.insertReminder(
          RemindersCompanion.insert(
            medicineId: widget.medicineId,
            userId: userId,
            time: time,
            frequency: Value(_frequency),
            days: Value(_frequency == 'weekly' ? _selectedDays.join(',') : null),
            durationType: Value(_durationType),
            endDate: Value(_endDate),
            durationDays: Value(durationDays),
            isActive: const Value(true),
            snoozeDuration: Value(_snoozeEnabled ? _snoozeDuration : 0),
            notificationId: Value(notifId),
            createdAt: DateTime.now(),
          ),
        );

        // Schedule the actual notification
        if (_soundEnabled || _vibrationEnabled) {
          await NotificationService.scheduleReminder(
            notificationId: notifId,
            medicineName: widget.medicineName,
            time: time,
          );
        }
      }

      if (mounted) {
        _snack('✅ Reminders saved & scheduled!');
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
      backgroundColor: const Color(0xFF070B12),
      body: StarfieldBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1826),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF00E5FF), size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Setup Reminder',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text(widget.medicineName,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF8A9BB5))),
                  ])),
                ]).animate().fadeIn(duration: 300.ms),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Step 1: Frequency ─────────────────────────
                      _sectionHeader('Step 1 — Frequency'),
                      const SizedBox(height: 10),
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

                      // Weekly day selector
                      if (_frequency == 'weekly') ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: _weekDays.map((d) => _ChoiceChip(
                            label: d,
                            selected: _selectedDays.contains(d),
                            onTap: () => setState(() {
                              if (_selectedDays.contains(d)) _selectedDays.remove(d);
                              else _selectedDays.add(d);
                            }),
                          )).toList(),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // ── Step 2: Times ─────────────────────────────
                      _sectionHeader('Step 2 — Reminder Times'),
                      const SizedBox(height: 10),
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
                            accent: const Color(0xFF8B5CF6),
                          ),
                        ],
                      ),
                      if (_times.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: _times.map((t) => Chip(
                            label: Text(t, style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 13)),
                            deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFF8A9BB5)),
                            onDeleted: () => setState(() => _times.remove(t)),
                            backgroundColor: const Color(0xFF00E5FF).withOpacity(0.08),
                            side: BorderSide(color: const Color(0xFF00E5FF).withOpacity(0.3)),
                            shape: const StadiumBorder(),
                          )).toList(),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // ── Step 3: Duration ──────────────────────────
                      _sectionHeader('Step 3 — Duration'),
                      const SizedBox(height: 10),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D1826),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.2)),
                            ),
                            child: Row(children: [
                              const Icon(Icons.calendar_today_rounded, color: Color(0xFF00E5FF), size: 18),
                              const SizedBox(width: 10),
                              Text(
                                _endDate != null
                                    ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                    : 'Select end date',
                                style: TextStyle(
                                  color: _endDate != null ? Colors.white : const Color(0xFF4A5A72),
                                  fontSize: 15,
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ],

                      if (_durationType == 'for_days') ...[
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D1826),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.12)),
                          ),
                          child: TextField(
                            controller: _daysController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                            decoration: const InputDecoration(
                              hintText: 'Number of days (e.g. 30)',
                              hintStyle: TextStyle(color: Color(0xFF4A5A72)),
                              prefixIcon: Icon(Icons.today_rounded, color: Color(0xFF4A5A72), size: 20),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // ── Step 4: Options ───────────────────────────
                      _sectionHeader('Step 4 — Options'),
                      const SizedBox(height: 10),

                      GlassCard(
                        child: Column(children: [
                          _OptionRow(
                            icon: Icons.snooze_rounded,
                            label: 'Snooze',
                            subtitle: 'Allow snoozing reminders',
                            value: _snoozeEnabled,
                            onChanged: (v) => setState(() => _snoozeEnabled = v),
                          ),
                          if (_snoozeEnabled) ...[
                            const Divider(color: Color(0x1A00E5FF), height: 1),
                            const SizedBox(height: 12),
                            Row(children: [
                              const Text('Snooze duration:',
                                  style: TextStyle(color: Color(0xFF8A9BB5), fontSize: 13)),
                              const SizedBox(width: 8),
                              ...([5, 10, 15, 30]).map((m) => GestureDetector(
                                onTap: () => setState(() => _snoozeDuration = m),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _snoozeDuration == m
                                        ? const Color(0xFF00E5FF).withOpacity(0.15)
                                        : const Color(0xFF1A2535),
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: _snoozeDuration == m
                                          ? const Color(0xFF00E5FF).withOpacity(0.5)
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: Text('${m}m',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _snoozeDuration == m ? const Color(0xFF00E5FF) : const Color(0xFF8A9BB5),
                                      fontWeight: _snoozeDuration == m ? FontWeight.w700 : FontWeight.normal,
                                    )),
                                ),
                              )),
                            ]),
                            const SizedBox(height: 8),
                          ],
                          const Divider(color: Color(0x1A00E5FF), height: 1),
                          _OptionRow(
                            icon: Icons.volume_up_rounded,
                            label: 'Sound',
                            subtitle: 'Play notification sound',
                            value: _soundEnabled,
                            onChanged: (v) => setState(() => _soundEnabled = v),
                          ),
                          const Divider(color: Color(0x1A00E5FF), height: 1),
                          _OptionRow(
                            icon: Icons.vibration_rounded,
                            label: 'Vibration',
                            subtitle: 'Vibrate on reminder',
                            value: _vibrationEnabled,
                            onChanged: (v) => setState(() => _vibrationEnabled = v),
                          ),
                        ]),
                      ),

                      const SizedBox(height: 28),

                      // ── Save button ───────────────────────────────
                      GestureDetector(
                        onTap: _isLoading ? null : _save,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: _isLoading ? null
                                : const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF0055FF)]),
                            color: _isLoading ? const Color(0xFF1A2535) : null,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: _isLoading ? [] : [
                              BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.4),
                                  blurRadius: 20, offset: const Offset(0, 6)),
                            ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(width: 24, height: 24,
                                    child: CircularProgressIndicator(color: Color(0xFF00E5FF), strokeWidth: 2))
                                : const Text('Save Reminder',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                                        color: Color(0xFF070B12))),
                          ),
                        ),
                      ),

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

  Widget _sectionHeader(String text) {
    return Row(children: [
      Container(width: 3, height: 16, decoration: BoxDecoration(
        color: const Color(0xFF00E5FF), borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(text, style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 14, fontWeight: FontWeight.w600)),
    ]);
  }
}

// ── Choice Chip ───────────────────────────────────────────────────────────────

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? accent;
  const _ChoiceChip({required this.label, required this.selected, required this.onTap, this.accent});

  @override
  Widget build(BuildContext context) {
    final color = accent ?? const Color(0xFF00E5FF);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : const Color(0xFF0D1826),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: selected ? color.withOpacity(0.5) : const Color(0x1A00E5FF)),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
              color: selected ? color : const Color(0xFF8A9BB5),
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
            color: const Color(0xFF00E5FF).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF00E5FF), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          Text(subtitle, style: const TextStyle(color: Color(0xFF8A9BB5), fontSize: 12)),
        ])),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF00E5FF),
          trackColor: WidgetStateProperty.all(
            value ? const Color(0xFF00E5FF).withOpacity(0.2) : const Color(0xFF1A2535),
          ),
        ),
      ]),
    );
  }
}