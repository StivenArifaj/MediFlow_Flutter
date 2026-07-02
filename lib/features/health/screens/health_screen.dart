import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../health_providers.dart';

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
    color: Color(0xFF2D7DD2), description: 'Body weight',
    inputType: _InputType.dualDrumRoll,
    minValue: 20, maxValue: 250, secondMin: 0, secondMax: 9,
  ),
  _Metric(
    type: 'Blood Pressure', unit: 'mmHg', icon: Icons.favorite_border_rounded,
    color: Color(0xFFE74C3C), description: 'Systolic / Diastolic',
    inputType: _InputType.dualField,
    minValue: 40, maxValue: 250,
  ),
  _Metric(
    type: 'Heart Rate',    unit: 'bpm',   icon: Icons.favorite_rounded,
    color: Color(0xFFE74C3C), description: 'Beats per minute',
    inputType: _InputType.drumRoll, minValue: 30, maxValue: 220,
  ),
  _Metric(
    type: 'Blood Glucose', unit: 'mg/dL', icon: Icons.water_drop_rounded,
    color: Color(0xFF27AE60), description: 'Blood sugar level',
    inputType: _InputType.drumRoll, minValue: 40, maxValue: 600,
  ),
  _Metric(
    type: 'Temperature',   unit: '°C',    icon: Icons.thermostat_rounded,
    color: Color(0xFFF39C12), description: 'Body temperature',
    inputType: _InputType.dualDrumRoll,
    minValue: 34, maxValue: 42, secondMin: 0, secondMax: 9,
  ),
  _Metric(
    type: 'SpO2',          unit: '%',     icon: Icons.air_rounded,
    color: Color(0xFF5B6EF5), description: 'Oxygen saturation',
    inputType: _InputType.drumRoll, minValue: 70, maxValue: 100,
  ),
  _Metric(
    type: 'Steps',         unit: 'steps', icon: Icons.directions_walk_rounded,
    color: Color(0xFF27AE60), description: 'Daily step count',
    inputType: _InputType.stepper, minValue: 0, maxValue: 100000, step: 500,
  ),
  _Metric(
    type: 'Sleep',         unit: 'hrs',   icon: Icons.bedtime_rounded,
    color: Color(0xFF8B5CF6), description: 'Hours of sleep',
    inputType: _InputType.sleepPicker, minValue: 0, maxValue: 24,
  ),
  _Metric(
    type: 'Water Intake',  unit: 'glasses', icon: Icons.local_drink_rounded,
    color: Color(0xFF2D7DD2), description: 'Glasses of water',
    inputType: _InputType.stepper, minValue: 0, maxValue: 30, step: 1,
  ),
  _Metric(
    type: 'BMI',           unit: '',      icon: Icons.accessibility_new_rounded,
    color: Color(0xFF2D7DD2), description: 'Body mass index',
    inputType: _InputType.numberPad, minValue: 5, maxValue: 80,
  ),
  _Metric(
    type: 'Cholesterol',   unit: 'mg/dL', icon: Icons.opacity_rounded,
    color: Color(0xFFF39C12), description: 'Total cholesterol',
    inputType: _InputType.numberPad, minValue: 50, maxValue: 500,
  ),
  _Metric(
    type: 'Waist',         unit: 'cm',    icon: Icons.straighten_rounded,
    color: Color(0xFF5B6EF5), description: 'Waist circumference',
    inputType: _InputType.drumRoll, minValue: 40, maxValue: 200,
  ),
  _Metric(
    type: 'Respiratory Rate', unit: '/min', icon: Icons.waves_rounded,
    color: Color(0xFFE74C3C), description: 'Breaths per minute',
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
    final measAsync = ref.watch(latestMeasurementsProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: measAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
        error: (_, __) => const Center(
            child: Text('Error loading data')),
        data: (latest) {
          final metricsLogged = latest.length;
          final updatedToday = metricsLogged > 0;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Health',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5)),
                        SizedBox(height: 2),
                        Text('Track your vitals',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ),
              // Summary card
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppColors.cardRadius),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Health Overview',
                        style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('$metricsLogged',
                            style: const TextStyle(
                              fontSize: 40, fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary, letterSpacing: -1.5)),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 6, left: 6),
                            child: Text('metrics logged',
                              style: TextStyle(
                                fontSize: 14, color: AppColors.textSecondary))),
                          const Spacer(),
                          if (updatedToday)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(AppColors.chipRadius)),
                              child: const Text('Updated today',
                                style: TextStyle(
                                  fontSize: 12, color: AppColors.success,
                                  fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),
              ),
              // Metric grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.95,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final metric = _metrics[i];
                      final m = latest[metric.type];
                      return _MetricCard(
                        metric: metric,
                        measurement: m,
                        onTap: () => _openSheet(metric, m),
                      )
                          .animate(delay: Duration(milliseconds: i * 60))
                          .fadeIn(duration: 300.ms)
                          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), duration: 300.ms, curve: Curves.easeOutBack);
                    },
                    childCount: _metrics.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openSheet(_Metric metric, Map<String, dynamic>? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MetricSheet(metric: metric, existing: existing),
    );
  }
}

// ── Metric Card ───────────────────────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final _Metric metric;
  final Map<String, dynamic>? measurement;
  final VoidCallback onTap;

  const _MetricCard({required this.metric, this.measurement, required this.onTap});

  String get _displayValue {
    if (measurement == null) return '—';
    final v = (measurement!['value'] as num).toDouble();
    return v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppColors.cardRadius),
        boxShadow: AppColors.cardShadow,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppColors.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: metric.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle),
                child: Icon(metric.icon, color: metric.color, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayValue,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: measurement != null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                      letterSpacing: -0.8,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (metric.unit.isNotEmpty)
                    Text(
                      metric.unit,
                      style: TextStyle(
                        fontSize: 11, color: metric.color,
                        fontWeight: FontWeight.w700, letterSpacing: 0.5,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    metric.type,
                    style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Metric Sheet ──────────────────────────────────────────────────────────────
class _MetricSheet extends ConsumerStatefulWidget {
  final _Metric metric;
  final Map<String, dynamic>? existing;

  const _MetricSheet({required this.metric, this.existing});

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
    final existingVal = widget.existing != null
        ? (widget.existing!['value'] as num).toDouble()
        : null;
    final def = existingVal ?? _defaultValue();

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

  String? _currentNotes() {
    if (widget.metric.type == 'Blood Pressure') {
      return '${_numberCtrl.text}/${_number2Ctrl.text} mmHg';
    }
    return null;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(measurementNotifierProvider.notifier).addMeasurement(
        type: widget.metric.type,
        value: _currentValue(),
        unit: widget.metric.unit,
        notes: _currentNotes(),
      );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomPad = mq.viewInsets.bottom + mq.padding.bottom + 24;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: widget.metric.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.metric.icon, color: widget.metric.color, size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log ${widget.metric.type}',
                    style: AppTypography.h3,
                  ),
                  Text(
                    widget.metric.description,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          _buildInput(),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Reading'),
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
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          )),
        ),
        widget.metric.color,
      ),
    ]);
  }

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
          Expanded(
            flex: 3,
            child: Column(children: [
              Text(isWeight ? 'kg' : '°C',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              _rollerContainer(
                CupertinoPicker(
                  scrollController: _primaryCtrl,
                  itemExtent: 48,
                  onSelectedItemChanged: (i) => setState(() => _primaryIndex = i),
                  selectionOverlay: const SizedBox.shrink(),
                  children: List.generate(primaryCount, (i) => Center(
                    child: Text('${(widget.metric.minValue + i).round()}',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                  )),
                ),
                widget.metric.color,
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('.', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w300,
                color: widget.metric.color)),
          ),
          Expanded(
            flex: 2,
            child: Column(children: [
              Text(isWeight ? 'g×100' : 'decimal',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              _rollerContainer(
                CupertinoPicker(
                  scrollController: _secondaryCtrl,
                  itemExtent: 48,
                  onSelectedItemChanged: (i) => setState(() => _secondaryIndex = i),
                  selectionOverlay: const SizedBox.shrink(),
                  children: List.generate(secCount, (i) => Center(
                    child: Text('$i',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
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

  Widget _stepper() {
    final isSteps = widget.metric.type == 'Steps';
    return Column(children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: widget.metric.color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.metric.color.withValues(alpha: 0.25)),
        ),
        child: Column(children: [
          Text(
            _stepperValue % 1 == 0
                ? _stepperValue.toInt().toString()
                : _stepperValue.toStringAsFixed(1),
            style: TextStyle(fontSize: 52, fontWeight: FontWeight.w800,
                color: widget.metric.color, height: 1),
          ),
          const SizedBox(height: 4),
          Text(widget.metric.unit,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ]),
      ),
      const SizedBox(height: 18),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _circleBtn(Icons.remove_rounded, widget.metric.color, () => setState(() {
            _stepperValue = (_stepperValue - widget.metric.step)
                .clamp(widget.metric.minValue, widget.metric.maxValue);
          })),
          if (isSteps) ...[
            const SizedBox(width: 10),
            ...[1000, 5000].map((v) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() {
                  _stepperValue = (_stepperValue + v)
                      .clamp(widget.metric.minValue, widget.metric.maxValue);
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: widget.metric.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: widget.metric.color.withValues(alpha: 0.4)),
                  ),
                  child: Text('+$v',
                      style: TextStyle(fontSize: 13, color: widget.metric.color,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            )),
          ] else
            const SizedBox(width: 40),
          _circleBtn(Icons.add_rounded, widget.metric.color, () => setState(() {
            _stepperValue = (_stepperValue + widget.metric.step)
                .clamp(widget.metric.minValue, widget.metric.maxValue);
          })),
        ],
      ),
    ]);
  }

  Widget _numberPad() {
    return TextField(
      controller: _numberCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      autofocus: true,
      style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800,
          color: widget.metric.color),
      decoration: InputDecoration(
        hintText: '0',
        hintStyle: TextStyle(color: widget.metric.color.withValues(alpha: 0.25), fontSize: 48),
        suffixText: widget.metric.unit,
        suffixStyle: const TextStyle(fontSize: 18, color: AppColors.textSecondary),
        filled: true,
        fillColor: widget.metric.color.withValues(alpha: 0.06),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: widget.metric.color.withValues(alpha: 0.3))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: widget.metric.color.withValues(alpha: 0.3))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: widget.metric.color, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      ),
    );
  }

  Widget _dualField() {
    return Column(children: [
      const Text('Enter systolic / diastolic',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      const SizedBox(height: 16),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _bpField(_numberCtrl, 'Systolic', '120', autofocus: true)),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(' / ',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w300,
                    color: widget.metric.color.withValues(alpha: 0.6))),
          ),
          Expanded(child: _bpField(_number2Ctrl, 'Diastolic', '80')),
        ],
      ),
      const SizedBox(height: 8),
      Text('mmHg',
          style: TextStyle(fontSize: 14, color: widget.metric.color,
              fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _bpField(TextEditingController ctrl, String label, String hint,
      {bool autofocus = false}) {
    return Column(children: [
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        autofocus: autofocus,
        style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700,
            color: widget.metric.color),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: widget.metric.color.withValues(alpha: 0.3),
              fontSize: 36),
          filled: true,
          fillColor: widget.metric.color.withValues(alpha: 0.06),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: widget.metric.color.withValues(alpha: 0.3))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: widget.metric.color.withValues(alpha: 0.3))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: widget.metric.color, width: 2)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    ]);
  }

  Widget _sleepPicker() {
    final liveVal =
        '${_sleepHrsIndex}h ${(_sleepMinsIndex * 5).toString().padLeft(2, '0')}m';

    return Column(children: [
      _rollerLabel(liveVal),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(children: [
              const Text('Hours',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              _rollerContainer(
                CupertinoPicker(
                  scrollController: _sleepHrsCtrl,
                  itemExtent: 48,
                  onSelectedItemChanged: (i) => setState(() => _sleepHrsIndex = i),
                  selectionOverlay: const SizedBox.shrink(),
                  children: List.generate(25, (i) => Center(
                    child: Text('$i',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                  )),
                ),
                widget.metric.color,
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(' h ',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                    color: widget.metric.color)),
          ),
          Expanded(
            child: Column(children: [
              const Text('Minutes',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              _rollerContainer(
                CupertinoPicker(
                  scrollController: _sleepMinsCtrl,
                  itemExtent: 48,
                  onSelectedItemChanged: (i) => setState(() => _sleepMinsIndex = i),
                  selectionOverlay: const SizedBox.shrink(),
                  children: List.generate(12, (i) => Center(
                    child: Text('${i * 5}'.padLeft(2, '0'),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                  )),
                ),
                widget.metric.color,
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(' m',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                    color: widget.metric.color)),
          ),
        ],
      ),
    ]);
  }

  Widget _rollerLabel(String value) {
    return Text(
      value,
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
          color: widget.metric.color),
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
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
          ),
          picker,
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 55,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.white, Color(0x00FFFFFF)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 55,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [Colors.white, Color(0x00FFFFFF)],
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
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
