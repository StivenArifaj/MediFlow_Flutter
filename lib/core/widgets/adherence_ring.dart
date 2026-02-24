import 'dart:math';
import 'package:flutter/material.dart';

/// Animated glowing adherence ring — the hero element of MediFlow.
/// Draws a true arc/donut ring with cyan→blue gradient stroke and neon glow.
class AdherenceRing extends StatefulWidget {
  final double percent; // 0–100
  final double size;

  const AdherenceRing({
    super.key,
    required this.percent,
    this.size = 160,
  });

  @override
  State<AdherenceRing> createState() => _AdherenceRingState();
}

class _AdherenceRingState extends State<AdherenceRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = Tween<double>(begin: 0, end: widget.percent).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AdherenceRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percent != widget.percent) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.percent,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ambient glow layer — a blurred circle behind the ring
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Only the shadow glows — no fill
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(0.18),
                      blurRadius: 44,
                      spreadRadius: 6,
                    ),
                  ],
                ),
              ),
              // The actual ring arc drawn by CustomPainter
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  percent: _animation.value,
                  size: widget.size,
                ),
              ),
              // Center text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_animation.value.round()}%',
                    style: TextStyle(
                      fontSize: widget.size * 0.23,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'adherence',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF3D8FA8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final double size;

  _RingPainter({required this.percent, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    const strokeWidth = 13.0;
    final radius = (canvasSize.width / 2) - strokeWidth / 2 - 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // ── 1. Background track ──────────────────────────────────────────────
    final trackPaint = Paint()
      ..color = const Color(0xFF1A2D45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (percent <= 0) return;

    // ── 2. Glow halo under the progress arc (painted first, wider) ───────
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 10
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: -pi / 2 + 2 * pi,
        colors: [
          const Color(0xFF00E5FF).withOpacity(0.45),
          const Color(0xFF0066FF).withOpacity(0.25),
          Colors.transparent,
        ],
        stops: [0.0, percent / 100 * 0.6, percent / 100],
      ).createShader(rect);

    canvas.drawArc(
      rect,
      -pi / 2,
      (percent / 100) * 2 * pi,
      false,
      glowPaint,
    );

    // ── 3. Main progress arc with cyan→blue gradient ─────────────────────
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: -pi / 2 + 2 * pi,
        colors: const [
          Color(0xFF00E5FF),
          Color(0xFF0088FF),
          Color(0xFF0066FF),
          Color(0xFF00E5FF),
        ],
        stops: const [0.0, 0.4, 0.8, 1.0],
      ).createShader(rect);

    canvas.drawArc(
      rect,
      -pi / 2,
      (percent / 100) * 2 * pi,
      false,
      progressPaint,
    );

    // ── 4. Bright leading dot at the tip of the arc ──────────────────────
    if (percent > 2) {
      final angle = -pi / 2 + (percent / 100) * 2 * pi;
      final dotX = center.dx + radius * cos(angle);
      final dotY = center.dy + radius * sin(angle);

      // Glow behind dot
      canvas.drawCircle(
        Offset(dotX, dotY),
        strokeWidth * 0.9,
        Paint()
          ..color = const Color(0xFF00E5FF).withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      // Bright dot
      canvas.drawCircle(
        Offset(dotX, dotY),
        strokeWidth * 0.45,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.percent != percent || old.size != size;
}