import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/starfield_background.dart';
import '../../../data/database/app_database.dart';
import '../../auth/providers/auth_provider.dart';

// ── Provider ──────────────────────────────────────────────────────────────────
final healthMeasurementsProvider =
    FutureProvider.family<List<HealthMeasurement>, int>((ref, userId) async {
  final db = ref.watch(appDatabaseProvider);
  return db.healthDao.getAllMeasurements(userId);
});

// ── Input types ───────────────────────────────────────────────────────────────
enum _InputType { drumRoll, dualDrumRoll, stepper, numberPad, dualField, sleepPicker }

// ── Metric config ─────────────────────────────────────────────────────────────
class _Metric {
  final String type;
  final String unit;
  final IconData icon;
  final Color color;
  final String description;
  final _InputType inputType;
  final double minValue;
  final double maxValue;
  final double step;
  final String? secondLabel;
  final double? secondMin;
  final double? secondMax;

  const _Metric({
    required this.type,
    required this.unit,
    required this.icon,
    required this.color,
    required this.description,
    required this.inputType,
    this.minValue = 0,
    this.maxValue = 300,
    this.step = 1,
    this.secondLabel,
    this.secondMin,
    this.secondMax,
  });
}

const _metrics = [
  _Metric(
    type: 'Weight',        unit: 'kg',    icon: Icons.monitor_weight_outlined,
    color: Color(0xFF00E5FF), description: 'Body weight',
    inputType: _InputType.dualDrumRoll,
    minValue: 20, maxValue: 250, secondMin: 0, secondMax: 9,
  ),
  _Metric(
    type: 'Blood Pressure', unit: 'mmHg', icon: Icons.favorite_border_rounded,
    color: Color(0xFFFF4D6A), description: 'Systolic / Diastolic',
    inputType: _InputType.dualField,
    minValue: 40, maxValue: 250,
  ),
  _Metric(
    type: 'Heart Rate',    unit: 'bpm',   icon: Icons.favorite_rounded,
    color: Color(0xFFFF4D6A), description: 'Beats per minute',
    inputType: _InputType.drumRoll, minValue: 30, maxValue: 220,
  ),
  _Metric(
    type: 'Blood Glucose', unit: 'mg/dL', icon: Icons.water_drop_rounded,
    color: Color(0xFF00C896), description: 'Blood sugar level',
    inputType: _InputType.drumRoll, minValue: 40, maxValue: 600,
  ),
  _Metric(
    type: 'Temperature',   unit: '°C',    icon: Icons.thermostat_rounded,
    color: Color(0xFFFFB800), description: 'Body temperature',
    inputType: _InputType.dualDrumRoll,
    minValue: 34, maxValue: 42, secondMin: 0, secondMax: 9,
  ),
  _Metric(
    type: 'SpO2',          unit: '%',     icon: Icons.air_rounded,
    color: Color(0xFF6B7FCC), description: 'Oxygen saturation',
    inputType: _InputType.drumRoll, minValue: 70, maxValue: 100,
  ),
  _Metric(
    type: 'Steps',         unit: 'steps', icon: Icons.directions_walk_rounded,
    color: Color(0xFF00C896), description: 'Daily step count',
    inputType: _InputType.stepper, minValue: 0, maxValue: 100000, step: 500,
  ),
  _Metric(
    type: 'Sleep',         unit: 'hrs',   icon: Icons.bedtime_rounded,
    color: Color(0xFF8B5CF6), description: 'Hours of sleep',
    inputType: _InputType.sleepPicker, minValue: 0, maxValue: 24,
  ),
  _Metric(
    type: 'Water Intake',  unit: 'glasses', icon: Icons.local_drink_rounded,
    color: Color(0xFF00E5FF), description: 'Glasses of water',
    inputType: _InputType.stepper, minValue: 0, maxValue: 30, step: 1,
  ),
  _Metric(
    type: 'BMI',           unit: '',      icon: Icons.accessibility_new_rounded,
    color: Color(0xFF00E5FF), description: 'Body mass index',
    inputType: _InputType.numberPad, minValue: 5, maxValue: 80,
  ),
  _Metric(
    type: 'Cholesterol',   unit: 'mg/dL', icon: Icons.opacity_rounded,
    color: Color(0xFFFFB800), description: 'Total cholesterol',
    inputType: _InputType.numberPad, minValue: 50, maxValue: 500,
  ),
  _Metric(
    type: 'Waist',         unit: 'cm',    icon: Icons.straighten_rounded,
    color: Color(0xFF6B7FCC), description: 'Waist circumference',
    inputType: _InputType.drumRoll, minValue: 40, maxValue: 200,
  ),
  _Metric(
    type: 'Respiratory Rate', unit: '/min', icon: Icons.waves_rounded,
    color: Color(0xFFFF7F7F), description: 'Breaths per minute',
    inputType: _InputType.drumRoll, minValue: 5, maxValue: 60,
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────
class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});
  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen> {
  @override
  Widget build(BuildContext context) {
    final repo = ref.read(authRepositoryProvider);
    final userId = repo.currentUserId;
    final measAsync = userId != null
        ? ref.watch(healthMeasurementsProvider(userId))
        : const AsyncValue<List<HealthMeasurement>>.data([]);

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
        child: measAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF00E5FF), strokeWidth: 2)),
          error: (_, __) => const Center(
              child: Text('Error loading data', style: TextStyle(color: Colors.white))),
          data: (measurements) {
            final Map<String, HealthMeasurement> latest = {};
            for (final m in measurements) {
              if (!latest.containsKey(m.type) ||
                  m.recordedAt.isAfter(latest[m.type]!.recordedAt)) {
                latest[m.type] = m;
              }
            }
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Health Dashboard',
                              style: TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
                          SizedBox(height: 4),
                          Text('Tap a metric to log a new reading',
                              style: TextStyle(fontSize: 13, color: Color(0xFF8A9BB5))),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 110,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final metric = _metrics[i];
                        final m = latest[metric.type];
                        return _MetricCard(
                          metric: metric,
                          measurement: m,
                          onTap: () {
                            if (m != null) {
                              context.push('/home/health-detail?type=${Uri.encodeComponent(metric.type)}&unit=${Uri.encodeComponent(metric.unit)}');
                            } else {
                              _openSheet(metric, m, userId);
                            }
                          },
                          onLongPress: () => _openSheet(metric, m, userId),
                        )
                            .animate()
                            .fadeIn(delay: Duration(milliseconds: i * 45), duration: 300.ms)
                            .scale(begin: const Offset(0.88, 0.88), curve: Curves.easeOutBack);
                      },
                      childCount: _metrics.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Container(
        width: 56, height: 56,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF0088FF)]),
          boxShadow: [
            BoxShadow(color: Color(0x6000E5FF), blurRadius: 20, spreadRadius: 2)
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            // FAB action placeholder
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  void _openSheet(_Metric metric, HealthMeasurement? existing, int? userId) {
    if (userId == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MetricSheet(
        metric: metric,
        existing: existing,
        userId: userId,
        onSaved: () {
          if (userId != null) ref.invalidate(healthMeasurementsProvider(userId));
        },
      ),
    );
  }
}

// ── Metric Card ───────────────────────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final _Metric metric;
  final HealthMeasurement? measurement;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _MetricCard({required this.metric, this.measurement, required this.onTap, this.onLongPress});

  String get _displayValue {
    if (measurement == null) return '—';
    final v = measurement!.value;
    return v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final hasData = measurement != null;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1826),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0x1A00E5FF),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x1200E5FF), blurRadius: 16, offset: Offset(0, 4))
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (hasData)
              Positioned(
                top: 8, right: 8,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00E5FF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Big icon with glow
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: metric.color.withValues(alpha: hasData ? 0.18 : 0.08),
                borderRadius: BorderRadius.circular(16),
                boxShadow: hasData
                    ? [BoxShadow(color: metric.color.withValues(alpha: 0.35), blurRadius: 20, spreadRadius: 2)]
                    : null,
              ),
              child: Icon(metric.icon,
                  color: hasData ? metric.color : metric.color.withValues(alpha: 0.45),
                  size: 24),
            ),
            const SizedBox(height: 8),
            // Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                metric.type,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: hasData ? Colors.white : const Color(0xFF8A9BB5),
                  letterSpacing: 0.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            // Value badge or add indicator
            if (hasData)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: metric.color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$_displayValue${metric.unit.isNotEmpty ? " ${metric.unit}" : ""}',
                  style: TextStyle(
                      fontSize: 9.5, fontWeight: FontWeight.w700, color: metric.color),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              Text(
                '—',
                style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8A9BB5),
                ),
              ),
          ],
        ),
        ],
      ),
      ),
    );
  }
}

// ── Metric Sheet ──────────────────────────────────────────────────────────────
class _MetricSheet extends ConsumerStatefulWidget {
  final _Metric metric;
  final HealthMeasurement? existing;
  final int userId;
  final VoidCallback onSaved;

  const _MetricSheet({
    required this.metric, this.existing,
    required this.userId, required this.onSaved,
  });

  @override
  ConsumerState<_MetricSheet> createState() => _MetricSheetState();
}

class _MetricSheetState extends ConsumerState<_MetricSheet> {
  bool _saving = false;

  late FixedExtentScrollController _primaryCtrl;
  late FixedExtentScrollController _secondaryCtrl;
  late double _stepperValue;
  final _numberCtrl = TextEditingController();
  final _number2Ctrl = TextEditingController();
  late FixedExtentScrollController _sleepHrsCtrl;
  late FixedExtentScrollController _sleepMinsCtrl;

  // Index mirrors — NEVER call .selectedItem before the picker is built
  int _primaryIndex = 0;
  int _secondaryIndex = 0;
  int _sleepHrsIndex = 7;
  int _sleepMinsIndex = 0;

  double _defaultValue() {
    switch (widget.metric.type) {
      case 'Weight': return 70;
      case 'Blood Pressure': return 120;
      case 'Heart Rate': return 72;
      case 'Blood Glucose': return 100;
      case 'Temperature': return 37;
      case 'SpO2': return 98;
      case 'Steps': return 5000;
      case 'Sleep': return 7;
      case 'Water Intake': return 8;
      case 'BMI': return 22;
      case 'Cholesterol': return 180;
      case 'Waist': return 80;
      case 'Respiratory Rate': return 16;
      default: return widget.metric.minValue;
    }
  }

  @override
  void initState() {
    super.initState();
    final def = widget.existing?.value ?? _defaultValue();

    final primaryIdx = (def - widget.metric.minValue).clamp(0,
        widget.metric.maxValue - widget.metric.minValue).round();
    _primaryIndex = primaryIdx;
    _secondaryIndex = (((def - def.floorToDouble()) * 10).round()).clamp(0, 9);
    _primaryCtrl = FixedExtentScrollController(initialItem: _primaryIndex);
    _secondaryCtrl = FixedExtentScrollController(initialItem: _secondaryIndex);

    _stepperValue = def.clamp(widget.metric.minValue, widget.metric.maxValue);

    _numberCtrl.text = def % 1 == 0 ? def.toInt().toString() : def.toStringAsFixed(1);
    if (widget.metric.type == 'Blood Pressure') {
      _numberCtrl.text = '120';
      _number2Ctrl.text = '80';
    }

    final hrsVal = def.floor().clamp(0, 23);
    final minsVal = ((def - hrsVal) * 60).round().clamp(0, 55);
    _sleepHrsIndex = hrsVal;
    _sleepMinsIndex = minsVal ~/ 5;
    _sleepHrsCtrl = FixedExtentScrollController(initialItem: _sleepHrsIndex);
    _sleepMinsCtrl = FixedExtentScrollController(initialItem: _sleepMinsIndex);
  }

  @override
  void dispose() {
    _primaryCtrl.dispose();
    _secondaryCtrl.dispose();
    _numberCtrl.dispose();
    _number2Ctrl.dispose();
    _sleepHrsCtrl.dispose();
    _sleepMinsCtrl.dispose();
    super.dispose();
  }

  double _currentValue() {
    switch (widget.metric.inputType) {
      case _InputType.drumRoll:
        return widget.metric.minValue + _primaryIndex;
      case _InputType.dualDrumRoll:
        final whole = widget.metric.minValue + _primaryIndex;
        return double.parse((whole + _secondaryIndex / 10.0).toStringAsFixed(1));
      case _InputType.stepper:
        return _stepperValue;
      case _InputType.numberPad:
        return double.tryParse(_numberCtrl.text) ?? _defaultValue();
      case _InputType.dualField:
        return double.tryParse(_numberCtrl.text) ?? 120;
      case _InputType.sleepPicker:
        return _sleepHrsIndex + _sleepMinsIndex * 5 / 60.0;
    }
  }

  String _currentNotes() {
    if (widget.metric.type == 'Blood Pressure') {
      return '${_numberCtrl.text}/${_number2Ctrl.text} mmHg';
    }
    return '';
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final value = _currentValue();
      final notes = _currentNotes();
      await db.healthDao.insertMeasurement(HealthMeasurementsCompanion(
        userId: Value(widget.userId),
        type: Value(widget.metric.type),
        value: Value(value),
        unit: Value(widget.metric.unit),
        notes: Value(notes.isEmpty ? null : notes),
        recordedAt: Value(DateTime.now()),
        createdAt: Value(DateTime.now()),
      ));
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // viewInsets.bottom = keyboard height, padding.bottom = system nav bar
    final bottomPad = mq.viewInsets.bottom + mq.padding.bottom + 24;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A1628),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0x1A00E5FF))),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFF2A3A4A),
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 22),
          // Header
          Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: widget.metric.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: widget.metric.color.withOpacity(0.3), blurRadius: 18)],
                ),
                child: Icon(widget.metric.icon, color: widget.metric.color, size: 26),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.metric.type,
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text(widget.metric.description,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF8A9BB5))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Input
          _buildInput(),
          const SizedBox(height: 28),
          // Save button
          GestureDetector(
            onTap: _saving ? null : _save,
            child: Container(
              width: double.infinity, height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [widget.metric.color, const Color(0xFF0044DD)]),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(color: widget.metric.color.withOpacity(0.45), blurRadius: 20, offset: const Offset(0, 6))
                ],
              ),
              child: Center(
                child: _saving
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Reading',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    switch (widget.metric.inputType) {
      case _InputType.drumRoll:      return _drumRoll();
      case _InputType.dualDrumRoll:  return _dualDrumRoll();
      case _InputType.stepper:       return _stepper();
      case _InputType.numberPad:     return _numberPad();
      case _InputType.dualField:     return _dualField();
      case _InputType.sleepPicker:   return _sleepPicker();
    }
  }

  // ── DRUM ROLL ─────────────────────────────────────────────────────────────
  Widget _drumRoll() {
    final count = (widget.metric.maxValue - widget.metric.minValue).round() + 1;
    final liveVal = '${(widget.metric.minValue + _primaryIndex).round()}'
        '${widget.metric.unit.isNotEmpty ? ' ${widget.metric.unit}' : ''}';
    return Column(children: [
      _rollerLabel(liveVal),
      const SizedBox(height: 10),
      _rollerContainer(
        CupertinoPicker(
          scrollController: _primaryCtrl,
          itemExtent: 48,
          onSelectedItemChanged: (i) => setState(() => _primaryIndex = i),
          selectionOverlay: const SizedBox.shrink(),
          children: List.generate(count, (i) => Center(
            child: Text('${(widget.metric.minValue + i).round()}',
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: Colors.white)),
          )),
        ),
        widget.metric.color,
      ),
    ]);
  }

  // ── DUAL DRUM ROLL ────────────────────────────────────────────────────────
  Widget _dualDrumRoll() {
    final primaryCount = (widget.metric.maxValue - widget.metric.minValue).round() + 1;
    final secCount = ((widget.metric.secondMax ?? 9) - (widget.metric.secondMin ?? 0)).round() + 1;
    final isWeight = widget.metric.type == 'Weight';
    final liveVal = '${(widget.metric.minValue + _primaryIndex).round()}.$_secondaryIndex ${widget.metric.unit}';

    return Column(children: [
      _rollerLabel(liveVal),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Primary
          Expanded(
            flex: 3,
            child: Column(children: [
              Text(isWeight ? 'kg' : '°C', style: const TextStyle(fontSize: 11, color: Color(0xFF8A9BB5))),
              const SizedBox(height: 6),
              _rollerContainer(
                CupertinoPicker(
                  scrollController: _primaryCtrl,
                  itemExtent: 48,
                  onSelectedItemChanged: (i) => setState(() => _primaryIndex = i),
                  selectionOverlay: const SizedBox.shrink(),
                  children: List.generate(primaryCount, (i) => Center(
                    child: Text('${(widget.metric.minValue + i).round()}',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
                  )),
                ),
                widget.metric.color,
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('.', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w300, color: widget.metric.color)),
          ),
          // Secondary
          Expanded(
            flex: 2,
            child: Column(children: [
              Text(isWeight ? 'g×100' : 'decimal', style: const TextStyle(fontSize: 11, color: Color(0xFF8A9BB5))),
              const SizedBox(height: 6),
              _rollerContainer(
                CupertinoPicker(
                  scrollController: _secondaryCtrl,
                  itemExtent: 48,
                  onSelectedItemChanged: (i) => setState(() => _secondaryIndex = i),
                  selectionOverlay: const SizedBox.shrink(),
                  children: List.generate(secCount, (i) => Center(
                    child: Text('$i',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
                  )),
                ),
                widget.metric.color,
              ),
            ]),
          ),
        ],
      ),
    ]);
  }

  // ── STEPPER ───────────────────────────────────────────────────────────────
  Widget _stepper() {
    final isSteps = widget.metric.type == 'Steps';
    return Column(children: [
      // Big value display
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: widget.metric.color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.metric.color.withOpacity(0.25)),
        ),
        child: Column(children: [
          Text(
            _stepperValue % 1 == 0 ? _stepperValue.toInt().toString() : _stepperValue.toStringAsFixed(1),
            style: TextStyle(fontSize: 52, fontWeight: FontWeight.w800, color: widget.metric.color, height: 1),
          ),
          const SizedBox(height: 4),
          Text(widget.metric.unit, style: const TextStyle(fontSize: 14, color: Color(0xFF8A9BB5))),
        ]),
      ),
      const SizedBox(height: 18),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _circleBtn(Icons.remove_rounded, widget.metric.color, () => setState(() {
            _stepperValue = (_stepperValue - widget.metric.step).clamp(widget.metric.minValue, widget.metric.maxValue);
          })),
          if (isSteps) ...[
            const SizedBox(width: 10),
            ...[1000, 5000].map((v) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() {
                  _stepperValue = (_stepperValue + v).clamp(widget.metric.minValue, widget.metric.maxValue);
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: widget.metric.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: widget.metric.color.withOpacity(0.4)),
                  ),
                  child: Text('+$v',
                      style: TextStyle(fontSize: 13, color: widget.metric.color, fontWeight: FontWeight.w600)),
                ),
              ),
            )),
          ] else
            const SizedBox(width: 40),
          _circleBtn(Icons.add_rounded, widget.metric.color, () => setState(() {
            _stepperValue = (_stepperValue + widget.metric.step).clamp(widget.metric.minValue, widget.metric.maxValue);
          })),
        ],
      ),
    ]);
  }

  // ── NUMBER PAD ────────────────────────────────────────────────────────────
  Widget _numberPad() {
    return TextField(
      controller: _numberCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      autofocus: true,
      style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: widget.metric.color),
      decoration: InputDecoration(
        hintText: '0',
        hintStyle: TextStyle(color: widget.metric.color.withOpacity(0.25), fontSize: 48),
        suffixText: widget.metric.unit,
        suffixStyle: const TextStyle(fontSize: 18, color: Color(0xFF8A9BB5)),
        filled: true,
        fillColor: widget.metric.color.withOpacity(0.06),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: widget.metric.color.withOpacity(0.3))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: widget.metric.color.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: widget.metric.color, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      ),
    );
  }

  // ── DUAL FIELD (Blood Pressure) ───────────────────────────────────────────
  Widget _dualField() {
    return Column(children: [
      const Text('Enter systolic / diastolic',
          style: TextStyle(fontSize: 13, color: Color(0xFF8A9BB5))),
      const SizedBox(height: 16),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _bpField(_numberCtrl, 'Systolic', '120', autofocus: true)),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(' / ',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w300,
                    color: widget.metric.color.withOpacity(0.6))),
          ),
          Expanded(child: _bpField(_number2Ctrl, 'Diastolic', '80')),
        ],
      ),
      const SizedBox(height: 8),
      Text('mmHg', style: TextStyle(fontSize: 14, color: widget.metric.color, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _bpField(TextEditingController ctrl, String label, String hint, {bool autofocus = false}) {
    return Column(children: [
      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF8A9BB5))),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        autofocus: autofocus,
        style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: widget.metric.color),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: widget.metric.color.withOpacity(0.3), fontSize: 36),
          filled: true,
          fillColor: widget.metric.color.withOpacity(0.06),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: widget.metric.color.withOpacity(0.3))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: widget.metric.color.withOpacity(0.3))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: widget.metric.color, width: 2)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    ]);
  }

  // ── SLEEP PICKER ──────────────────────────────────────────────────────────
  Widget _sleepPicker() {
    final liveVal = '${_sleepHrsIndex}h ${(_sleepMinsIndex * 5).toString().padLeft(2, '0')}m';

    return Column(children: [
      _rollerLabel(liveVal),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(children: [
              const Text('Hours', style: TextStyle(fontSize: 11, color: Color(0xFF8A9BB5))),
              const SizedBox(height: 6),
              _rollerContainer(
                CupertinoPicker(
                  scrollController: _sleepHrsCtrl,
                  itemExtent: 48,
                  onSelectedItemChanged: (i) => setState(() => _sleepHrsIndex = i),
                  selectionOverlay: const SizedBox.shrink(),
                  children: List.generate(25, (i) => Center(
                    child: Text('$i', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
                  )),
                ),
                widget.metric.color,
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(' h ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: widget.metric.color)),
          ),
          Expanded(
            child: Column(children: [
              const Text('Minutes', style: TextStyle(fontSize: 11, color: Color(0xFF8A9BB5))),
              const SizedBox(height: 6),
              _rollerContainer(
                CupertinoPicker(
                  scrollController: _sleepMinsCtrl,
                  itemExtent: 48,
                  onSelectedItemChanged: (i) => setState(() => _sleepMinsIndex = i),
                  selectionOverlay: const SizedBox.shrink(),
                  children: List.generate(12, (i) => Center(
                    child: Text('${i * 5}'.padLeft(2, '0'),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
                  )),
                ),
                widget.metric.color,
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(' m', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: widget.metric.color)),
          ),
        ],
      ),
    ]);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _rollerLabel(String value) {
    return Text(
      value,
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: widget.metric.color),
    );
  }

  Widget _rollerContainer(Widget picker, Color color) {
    return SizedBox(
      height: 165,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
          ),
          picker,
          // Top fade
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [const Color(0xFF0A1628), const Color(0xFF0A1628).withOpacity(0)],
                ),
              ),
            ),
          ),
          // Bottom fade
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [const Color(0xFF0A1628), const Color(0xFF0A1628).withOpacity(0)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54, height: 54,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 12)],
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}