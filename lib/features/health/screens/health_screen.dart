import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/starfield_background.dart';
import '../../../core/widgets/neon_button.dart';
import '../../../data/database/app_database.dart';
import '../../auth/providers/auth_provider.dart';

// ── Provider ──────────────────────────────────────────────────────────────────
final healthMeasurementsProvider =
    FutureProvider.family<List<HealthMeasurement>, int>((ref, userId) async {
  final db = ref.watch(appDatabaseProvider);
  return db.healthDao.getAllMeasurements(userId);
});

// ── Metrics Config ────────────────────────────────────────────────────────────
class _Metric {
  final String type;
  final String unit;
  final String emoji;
  final Color color;

  const _Metric(this.type, this.unit, this.emoji, this.color);
}

const _metrics = [
  _Metric('Weight', 'kg', '⚖️', AppColors.neonCyan),
  _Metric('Blood Pressure', 'mmHg', '📈', AppColors.error),
  _Metric('Heart Rate', 'bpm', '❤️', AppColors.error),
  _Metric('Blood Glucose', 'mg/dL', '💧', AppColors.neonCyan),
  _Metric('Temperature', '°C', '🌡️', AppColors.warning),
  _Metric('SpO2', '%', '💨', AppColors.info),
  _Metric('Steps', 'steps', '👟', AppColors.success),
  _Metric('Sleep', 'hrs', '🌙', AppColors.premiumFrom),
  _Metric('Water Intake', 'glasses', '💧', AppColors.info),
  _Metric('BMI', '', '📊', AppColors.neonCyan),
  _Metric('Cholesterol', 'mg/dL', '💧', AppColors.warning),
  _Metric('Waist', 'cm', '📏', AppColors.info),
  _Metric('Respiratory Rate', '/min', '🫁', Color(0xFFFF7F7F)),
];

class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen> {
  bool _gridView = true;

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(authRepositoryProvider);
    final userId = repo.currentUserId;
    final measAsync = userId != null
        ? ref.watch(healthMeasurementsProvider(userId))
        : const AsyncValue<List<HealthMeasurement>>.data([]);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: StarfieldBackground(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Health Dashboard',
                            style: AppTypography.headlineMedium()),
                        Text('Track your vital signs',
                            style: AppTypography.bodySmall()),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        border: Border.all(color: const Color(0x1A00E5FF)),
                      ),
                      child: Row(
                        children: [
                          _ToggleBtn(
                            icon: Icons.grid_view_rounded,
                            active: _gridView,
                            onTap: () => setState(() => _gridView = true),
                          ),
                          _ToggleBtn(
                            icon: Icons.view_list_rounded,
                            active: !_gridView,
                            onTap: () => setState(() => _gridView = false),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Grid / List ────────────────────────────────────
            Expanded(
              child: measAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.neonCyan),
                ),
                error: (_, __) =>
                    const Center(child: Text('Error loading health data')),
                data: (measurements) {
                  final Map<String, HealthMeasurement> latest = {};
                  for (final m in measurements) {
                    if (!latest.containsKey(m.type) ||
                        m.recordedAt.isAfter(latest[m.type]!.recordedAt)) {
                      latest[m.type] = m;
                    }
                  }
                  return _gridView
                      ? _GridBody(metrics: _metrics, latest: latest)
                      : _ListBody(metrics: _metrics, latest: latest);
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [AppColors.cyanGlowStrong],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddSheet(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
      ),
      builder: (ctx) => _AddMeasurementSheet(
        onSaved: () => setState(() {}),
      ),
    );
  }
}

// ── Grid View ─────────────────────────────────────────────────────────────────

class _GridBody extends StatelessWidget {
  final List<_Metric> metrics;
  final Map<String, HealthMeasurement> latest;

  const _GridBody({required this.metrics, required this.latest});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.sm,
        mainAxisSpacing: AppDimensions.sm,
        childAspectRatio: 1.2,
      ),
      itemCount: metrics.length,
      itemBuilder: (ctx, i) {
        final metric = metrics[i];
        final m = latest[metric.type];
        return _MetricCard(metric: metric, measurement: m)
            .animate()
            .fadeIn(
                delay: Duration(milliseconds: i * 40), duration: 300.ms)
            .scale(begin: const Offset(0.9, 0.9));
      },
    );
  }
}

// ── List View ─────────────────────────────────────────────────────────────────

class _ListBody extends StatelessWidget {
  final List<_Metric> metrics;
  final Map<String, HealthMeasurement> latest;

  const _ListBody({required this.metrics, required this.latest});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.md),
      itemCount: metrics.length,
      itemBuilder: (ctx, i) {
        final metric = metrics[i];
        final m = latest[metric.type];
        return Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.sm),
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: AppColors.neonCardDecoration,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2535),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(metric.emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(metric.type, style: AppTypography.titleMedium()),
                    if (m != null)
                      Text(
                        DateFormat('d MMM yyyy').format(m.recordedAt),
                        style: AppTypography.bodySmall(),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    m != null ? '${m.value}' : '—',
                    style: AppTypography.headlineMedium(
                        color: m != null ? metric.color : AppColors.textMuted),
                  ),
                  if (metric.unit.isNotEmpty)
                    Text(metric.unit,
                        style: AppTypography.bodySmall(
                            color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(
            delay: Duration(milliseconds: i * 30), duration: 250.ms);
      },
    );
  }
}

// ── Metric Card ───────────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final _Metric metric;
  final HealthMeasurement? measurement;

  const _MetricCard({required this.metric, this.measurement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: AppColors.glassCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2535),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Text(metric.emoji, style: const TextStyle(fontSize: 18)),
              ),
              if (measurement != null)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: metric.color,
                    boxShadow: [
                      BoxShadow(
                          color: metric.color.withValues(alpha: 0.5),
                          blurRadius: 6),
                    ],
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Accent line
              Container(
                width: 24,
                height: 2,
                margin: const EdgeInsets.only(bottom: 6),
                color: metric.color,
              ),
              Text(
                measurement != null ? '${measurement!.value}' : '—',
                style: AppTypography.headlineMedium(
                    color: measurement != null
                        ? AppColors.textPrimary
                        : AppColors.textMuted)
                    .copyWith(fontSize: 24),
              ),
              if (metric.unit.isNotEmpty)
                Text(metric.unit, style: AppTypography.bodySmall()),
              const SizedBox(height: 2),
              Text(
                metric.type,
                style: AppTypography.bodySmall(color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Add Measurement Bottom Sheet ──────────────────────────────────────────────

class _AddMeasurementSheet extends ConsumerStatefulWidget {
  final VoidCallback onSaved;
  const _AddMeasurementSheet({required this.onSaved});

  @override
  ConsumerState<_AddMeasurementSheet> createState() =>
      _AddMeasurementSheetState();
}

class _AddMeasurementSheetState extends ConsumerState<_AddMeasurementSheet> {
  String _selectedType = _metrics.first.type;
  final _valueCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isSaving = false;

  String get _unit => _metrics.firstWhere((m) => m.type == _selectedType).unit;

  @override
  void dispose() {
    _valueCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final val = double.tryParse(_valueCtrl.text.trim());
    if (val == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Enter a valid number'),
            backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final repo = ref.read(authRepositoryProvider);
      final userId = repo.currentUserId;
      if (userId == null) return;

      await db.healthDao.insertMeasurement(
        HealthMeasurementsCompanion.insert(
          userId: userId,
          type: _selectedType,
          value: val,
          unit: _unit,
          notes: _notesCtrl.text.trim().isNotEmpty
              ? Value<String?>(_notesCtrl.text.trim())
              : const Value<String?>.absent(),
          recordedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Text('Add Measurement',
                style: AppTypography.headlineMedium()),
            const SizedBox(height: AppDimensions.md),

            // Metric dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              dropdownColor: AppColors.bgCard,
              style: AppTypography.bodyLarge(),
              icon: const Icon(Icons.arrow_drop_down_rounded,
                  color: AppColors.neonCyan),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.bgInput,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide:
                      const BorderSide(color: Color(0x1AFFFFFF), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: const BorderSide(
                      color: AppColors.neonCyan, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md, vertical: 14),
              ),
              items: _metrics
                  .map((m) => DropdownMenuItem(
                        value: m.type,
                        child: Text('${m.emoji} ${m.type}',
                            style: AppTypography.bodyMedium(
                                color: AppColors.textPrimary)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
            ),
            const SizedBox(height: AppDimensions.md),

            // Value
            TextField(
              controller: _valueCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: AppTypography.bodyLarge(),
              decoration: InputDecoration(
                hintText: 'Value',
                hintStyle: AppTypography.bodyLarge(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.bgInput,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide:
                      const BorderSide(color: Color(0x1AFFFFFF), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: const BorderSide(
                      color: AppColors.neonCyan, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md, vertical: 14),
                suffixText: _unit,
                suffixStyle:
                    AppTypography.bodySmall(color: AppColors.neonCyan),
              ),
            ),
            const SizedBox(height: AppDimensions.sm),

            // Notes
            TextField(
              controller: _notesCtrl,
              style: AppTypography.bodyLarge(),
              decoration: InputDecoration(
                hintText: 'Notes (optional)',
                hintStyle: AppTypography.bodyLarge(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.bgInput,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide:
                      const BorderSide(color: Color(0x1AFFFFFF), width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md, vertical: 14),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            NeonButton(
              label: 'Save',
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _save,
            ),
            const SizedBox(height: AppDimensions.sm),
          ],
        ),
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ToggleBtn(
      {required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: active ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Icon(icon,
            color: active ? AppColors.bgPrimary : AppColors.textMuted,
            size: 20),
      ),
    );
  }
}
