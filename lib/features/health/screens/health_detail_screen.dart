import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' show Value;

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/starfield_background.dart';
import '../../../data/database/app_database.dart';
import '../../auth/providers/auth_provider.dart';

class HealthDetailScreen extends ConsumerStatefulWidget {
  final String type;
  final String unit;

  const HealthDetailScreen({
    super.key,
    required this.type,
    required this.unit,
  });

  @override
  ConsumerState<HealthDetailScreen> createState() => _HealthDetailScreenState();
}

class _HealthDetailScreenState extends ConsumerState<HealthDetailScreen> {
  List<HealthMeasurement> _measurements = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = ref.read(appDatabaseProvider);
    final repo = ref.read(authRepositoryProvider);
    final userId = repo.currentUserId;
    if (userId == null) return;

    final data = await db.healthDao.getMeasurementsForUser(userId, type: widget.type);
    if (mounted) {
      setState(() {
        _measurements = data;
        _loading = false;
      });
    }
  }

  Future<void> _deleteEntry(int id) async {
    final db = ref.read(appDatabaseProvider);
    await db.healthDao.deleteMeasurement(id);
    await _loadData();
  }

  void _confirmDelete(HealthMeasurement m) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: const BorderSide(color: Color(0x1A00E5FF)),
        ),
        title: Text('Delete Entry?', style: AppTypography.titleLarge()),
        content: Text(
          'Delete this ${widget.type} reading (${_formatValue(m.value)})?',
          style: AppTypography.bodyMedium(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTypography.labelLarge(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteEntry(m.id);
            },
            child: Text('Delete', style: AppTypography.labelLarge(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  String _formatValue(double v) {
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: StarfieldBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.neonCyan, strokeWidth: 2))
            : CustomScrollView(
                slivers: [
                  // ── Header ──────────────────────────────────────
                  SliverToBoxAdapter(
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
                              onPressed: () => context.pop(),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.type,
                                    style: AppTypography.headlineMedium(),
                                  ),
                                  if (widget.unit.isNotEmpty)
                                    Text(
                                      widget.unit,
                                      style: AppTypography.bodySmall(color: AppColors.neonCyan),
                                    ),
                                ],
                              ),
                            ),
                            // Entry count badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.neonCyan.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
                              ),
                              child: Text(
                                '${_measurements.length} entries',
                                style: AppTypography.bodySmall(color: AppColors.neonCyan),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Chart ───────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0x1A00E5FF)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonCyan.withOpacity(0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
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
                              child: _measurements.length < 2
                                  ? Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.show_chart_rounded,
                                              color: AppColors.neonCyan.withOpacity(0.3), size: 48),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Add more entries to see your trend',
                                            style: AppTypography.bodyMedium(color: AppColors.textMuted),
                                          ),
                                        ],
                                      ),
                                    )
                                  : _buildChart(),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0),
                    ),
                  ),

                  // ── Section header ──────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.neonCyan,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('All Readings', style: AppTypography.titleMedium()),
                        ],
                      ),
                    ),
                  ),

                  // ── Entries list ────────────────────────────────
                  if (_measurements.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.neonCyan.withOpacity(0.15),
                                    blurRadius: 40,
                                    spreadRadius: 15,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text('📊', style: TextStyle(fontSize: 44)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text('No readings yet',
                                style: AppTypography.titleMedium()),
                            const SizedBox(height: 6),
                            Text('Tap + to add your first ${widget.type} entry',
                                style: AppTypography.bodySmall(color: AppColors.textMuted)),
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
                            measurement: _measurements[i],
                            unit: widget.unit,
                            onDelete: () => _confirmDelete(_measurements[i]),
                          ).animate().fadeIn(
                              delay: Duration(milliseconds: i * 30),
                              duration: 250.ms),
                          childCount: _measurements.length,
                        ),
                      ),
                    ),
                ],
              ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [AppColors.cyanGlow],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () => _openAddSheet(),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildChart() {
    // Use last 30 entries, reversed so oldest is first (left)
    final chartData = _measurements.take(30).toList().reversed.toList();
    final dateFmt = DateFormat('d/M');

    final spots = <FlSpot>[];
    for (int i = 0; i < chartData.length; i++) {
      spots.add(FlSpot(i.toDouble(), chartData[i].value));
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
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0x1A00E5FF),
            strokeWidth: 0.5,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    _formatValue(value),
                    style: const TextStyle(fontSize: 10, color: Color(0xFF8A9BB5)),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: (chartData.length / 5).clamp(1, double.infinity),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= chartData.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    dateFmt.format(chartData[idx].recordedAt),
                    style: const TextStyle(fontSize: 9, color: Color(0xFF8A9BB5)),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.25,
            color: AppColors.neonCyan,
            barWidth: 2.5,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.neonCyan.withOpacity(0.2),
                  AppColors.neonCyan.withOpacity(0.0),
                ],
              ),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 3.5,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: AppColors.neonCyan,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.bgCard,
            tooltipBorder: const BorderSide(color: Color(0x4D00E5FF)),
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              final idx = spot.spotIndex;
              final m = chartData[idx];
              return LineTooltipItem(
                '${_formatValue(m.value)} ${widget.unit}\n${DateFormat('d MMM HH:mm').format(m.recordedAt)}',
                const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _openAddSheet() {
    // Navigate back and let the health screen handle adding
    // Or show a simple add dialog here
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _QuickAddSheet(
        type: widget.type,
        unit: widget.unit,
        onSaved: () {
          Navigator.pop(ctx);
          _loadData();
        },
      ),
    );
  }
}

// ── Entry Row ─────────────────────────────────────────────────────────────────

class _EntryRow extends StatelessWidget {
  final HealthMeasurement measurement;
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
    return Dismissible(
      key: ValueKey(measurement.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false; // We handle deletion via the confirm dialog
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x1A00E5FF)),
        ),
        child: Row(
          children: [
            // Date
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy').format(measurement.recordedAt),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('HH:mm').format(measurement.recordedAt),
                    style: const TextStyle(fontSize: 11, color: Color(0xFF8A9BB5)),
                  ),
                ],
              ),
            ),
            // Value
            Expanded(
              flex: 2,
              child: Text(
                '${_formatValue(measurement.value)}${unit.isNotEmpty ? ' $unit' : ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neonCyan,
                ),
              ),
            ),
            // Notes badge
            if (measurement.notes != null && measurement.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Tooltip(
                  message: measurement.notes!,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.notes_rounded, color: AppColors.info, size: 16),
                  ),
                ),
              ),
            // Delete
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
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
  final VoidCallback onSaved;

  const _QuickAddSheet({
    required this.type,
    required this.unit,
    required this.onSaved,
  });

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
    final db = ref.read(appDatabaseProvider);
    final userId = ref.read(authRepositoryProvider).currentUserId;
    if (userId == null) return;

    await db.healthDao.insertMeasurement(HealthMeasurementsCompanion(
      userId: Value(userId),
      type: Value(widget.type),
      value: Value(val),
      unit: Value(widget.unit),
      recordedAt: Value(DateTime.now()),
      createdAt: Value(DateTime.now()),
    ));
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
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
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF2A3A4A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text('Add ${widget.type}', style: AppTypography.headlineMedium()),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            autofocus: true,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: AppColors.neonCyan,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                color: AppColors.neonCyan.withOpacity(0.25),
                fontSize: 42,
              ),
              suffixText: widget.unit,
              suffixStyle: const TextStyle(fontSize: 18, color: Color(0xFF8A9BB5)),
              filled: true,
              fillColor: AppColors.neonCyan.withOpacity(0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: AppColors.neonCyan.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: AppColors.neonCyan.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.neonCyan, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _saving ? null : _save,
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Save Reading',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
