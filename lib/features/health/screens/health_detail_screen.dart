import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/circle_button.dart';
import '../health_providers.dart';

class HealthDetailScreen extends ConsumerWidget {
  final String type;
  final String unit;

  const HealthDetailScreen({
    super.key,
    required this.type,
    required this.unit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measAsync = ref.watch(measurementsForTypeProvider(type));

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: Text(type),
        leading: Center(
          child: CircleButton(
            icon: Icons.arrow_back_rounded,
            size: 38,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
      body: measAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
        error: (_, __) => Center(
            child: Text('Error loading data',
                style: TextStyle(color: AppColors.textPrimary))),
        data: (measurements) => _Body(
          type: type,
          unit: unit,
          measurements: measurements,
          ref: ref,
        ),
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.darkButton,
          shape: BoxShape.circle,
          boxShadow: AppColors.lg,
        ),
        child: IconButton(
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          onPressed: () => _openAddSheet(context, ref),
        ),
      ),
    );
  }

  void _openAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _QuickAddSheet(type: type, unit: unit),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _Body extends StatelessWidget {
  final String type;
  final String unit;
  final List<Map<String, dynamic>> measurements;
  final WidgetRef ref;

  const _Body({
    required this.type,
    required this.unit,
    required this.measurements,
    required this.ref,
  });

  String _formatValue(double v) {
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> m) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text('Delete Entry?',
            style: AppTypography.titleLarge().copyWith(color: AppColors.textPrimary)),
        content: Text(
          'Delete this $type reading (${_formatValue((m['value'] as num).toDouble())})?',
          style: AppTypography.bodyMedium(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTypography.labelLarge(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(measurementNotifierProvider.notifier)
                  .deleteMeasurement(m['id'] as String, type);
            },
            child: Text('Delete',
                style: AppTypography.labelLarge(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latestValue = measurements.isNotEmpty
        ? _formatValue((measurements.first['value'] as num).toDouble())
        : null;

    return CustomScrollView(
      slivers: [
        // Latest value card
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(20),
            decoration: AppColors.cardLg,
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.show_chart_rounded,
                      color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Latest Reading',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                    Text(latestValue ?? '—',
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary)),
                    if (unit.isNotEmpty)
                      Text(unit,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
        ),

        // Chart
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: AppColors.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 16),
                  child: Text(
                    'Trend — Last 30 Readings',
                    style: AppTypography.bodySmall(color: AppColors.textSecondary),
                  ),
                ),
                SizedBox(
                  height: 220,
                  child: measurements.length < 2
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.show_chart_rounded,
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'Add more entries to see your trend',
                                style: AppTypography.bodyMedium(
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : _buildChart(measurements),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0),
        ),

        // Section header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text('All Readings',
                    style: AppTypography.titleMedium()
                        .copyWith(color: AppColors.textPrimary)),
              ],
            ),
          ),
        ),

        if (measurements.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.insights_rounded,
                        size: 34, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text('No readings yet',
                      style: AppTypography.titleMedium()
                          .copyWith(color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text('Tap + to add your first $type entry',
                      style: AppTypography.bodySmall(
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _EntryRow(
                  measurement: measurements[i],
                  unit: unit,
                  onDelete: () => _confirmDelete(ctx, measurements[i]),
                ).animate().fadeIn(
                    delay: Duration(milliseconds: i * 30), duration: 250.ms),
                childCount: measurements.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChart(List<Map<String, dynamic>> data) {
    final chartData = data.take(30).toList().reversed.toList();
    final dateFmt = DateFormat('d/M');

    final spots = <FlSpot>[];
    for (int i = 0; i < chartData.length; i++) {
      spots.add(FlSpot(i.toDouble(), (chartData[i]['value'] as num).toDouble()));
    }

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final yPad = (maxY - minY) * 0.15;

    return LineChart(
      LineChartData(
        minY: (minY - yPad).floorToDouble(),
        maxY: (maxY + yPad).ceilToDouble(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: ((maxY - minY) / 4).clamp(1, double.infinity),
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.border,
            strokeWidth: 0.5,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, _) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  _formatValue(value),
                  style:
                      const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: (chartData.length / 5).clamp(1, double.infinity),
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= chartData.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    dateFmt.format(DateTime.parse(
                        chartData[idx]['recorded_at'] as String)),
                    style:
                        const TextStyle(fontSize: 9, color: AppColors.textTertiary),
                  ),
                );
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.25,
            color: AppColors.primary,
            barWidth: 2.5,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 3.5,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: AppColors.primary,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.surface,
            tooltipBorder:
                BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              final m = chartData[spot.spotIndex];
              final v = (m['value'] as num).toDouble();
              final dt = DateTime.parse(m['recorded_at'] as String);
              return LineTooltipItem(
                '${_formatValue(v)} $unit\n${DateFormat('d MMM HH:mm').format(dt)}',
                const TextStyle(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── Entry Row ─────────────────────────────────────────────────────────────────
class _EntryRow extends StatelessWidget {
  final Map<String, dynamic> measurement;
  final String unit;
  final VoidCallback onDelete;

  const _EntryRow({
    required this.measurement,
    required this.unit,
    required this.onDelete,
  });

  String _formatValue(double v) {
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final value = (measurement['value'] as num).toDouble();
    final recordedAt = DateTime.parse(measurement['recorded_at'] as String);
    final notes = measurement['notes'] as String?;

    return Dismissible(
      key: ValueKey(measurement['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.danger),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.sm,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy').format(recordedAt),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('HH:mm').format(recordedAt),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${_formatValue(value)}${unit.isNotEmpty ? ' $unit' : ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary),
              ),
            ),
            if (notes != null && notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Tooltip(
                  message: notes,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.notes_rounded,
                        color: AppColors.primary, size: 16),
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.danger, size: 20),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Add Sheet ───────────────────────────────────────────────────────────
class _QuickAddSheet extends ConsumerStatefulWidget {
  final String type;
  final String unit;

  const _QuickAddSheet({required this.type, required this.unit});

  @override
  ConsumerState<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<_QuickAddSheet> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final val = double.tryParse(_controller.text);
    if (val == null) return;

    setState(() => _saving = true);
    try {
      await ref.read(measurementNotifierProvider.notifier).addMeasurement(
            type: widget.type,
            value: val,
            unit: widget.unit,
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
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text('Add ${widget.type}',
              style: AppTypography.headlineMedium()
                  .copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            autofocus: true,
            style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: AppColors.primary),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  fontSize: 42),
              suffixText: widget.unit,
              suffixStyle: const TextStyle(
                  fontSize: 18, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.primaryLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide:
                    BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide:
                    BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(18)),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 18),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Save Reading'),
          ),
        ],
      ),
    );
  }
}
