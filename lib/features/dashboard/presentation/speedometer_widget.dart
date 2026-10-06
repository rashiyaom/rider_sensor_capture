import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Premium analog + digital speedometer widget.
///
/// [speedKmh]   — current speed in km/h (live from GPS).
/// [maxSpeed]   — scale maximum (default 120 km/h).
/// [size]       — diameter of the gauge dial.
class SpeedometerWidget extends StatelessWidget {
  final double speedKmh;
  final double maxSpeed;
  final double size;

  const SpeedometerWidget({
    super.key,
    required this.speedKmh,
    this.maxSpeed = 120,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SpeedometerPainter(
          speedKmh: speedKmh.clamp(0.0, maxSpeed),
          maxSpeed: maxSpeed,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Text(
                speedKmh.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const Text(
                'km/h',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeedometerPainter extends CustomPainter {
  final double speedKmh;
  final double maxSpeed;

  const _SpeedometerPainter({
    required this.speedKmh,
    required this.maxSpeed,
  });

  static const double _startAngle = 150.0;
  static const double _sweepAngle = 240.0;

  double _degToRad(double deg) => deg * math.pi / 180.0;

  Color _speedColor(double pct) {
    if (pct < 0.6) return const Color(0xFF30D158);
    if (pct < 0.85) return const Color(0xFFFF9F0A);
    return const Color(0xFFFF453A);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final pct = (speedKmh / maxSpeed).clamp(0.0, 1.0);

    // Track background arc
    final trackPaint = Paint()
      ..color = const Color(0xFF2C2C2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _degToRad(_startAngle),
      _degToRad(_sweepAngle),
      false,
      trackPaint,
    );

    // Colored speed progress arc
    if (pct > 0) {
      final progressPaint = Paint()
        ..color = _speedColor(pct)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        _degToRad(_startAngle),
        _degToRad(_sweepAngle * pct),
        false,
        progressPaint,
      );
    }

    // Tick marks
    final majorTickPaint = Paint()
      ..color = const Color(0xFF636366)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final minorTickPaint = Paint()
      ..color = const Color(0xFF3A3A3C)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    const int majorTicks = 12;
    const int minorTicksPerMajor = 4;

    for (int i = 0; i <= majorTicks * minorTicksPerMajor; i++) {
      final isMajor = i % minorTicksPerMajor == 0;
      final angle = _degToRad(
          _startAngle + (_sweepAngle / (majorTicks * minorTicksPerMajor)) * i);
      final outerR = radius - 12;
      final innerR = isMajor ? outerR - 10 : outerR - 6;

      final outer = Offset(
        center.dx + outerR * math.cos(angle),
        center.dy + outerR * math.sin(angle),
      );
      final inner = Offset(
        center.dx + innerR * math.cos(angle),
        center.dy + innerR * math.sin(angle),
      );

      canvas.drawLine(outer, inner, isMajor ? majorTickPaint : minorTickPaint);

      if (isMajor) {
        final labelVal =
            (maxSpeed / majorTicks * (i / minorTicksPerMajor)).round();
        final labelR = innerR - 14;
        final labelOffset = Offset(
          center.dx + labelR * math.cos(angle),
          center.dy + labelR * math.sin(angle),
        );
        final tp = TextPainter(
          text: TextSpan(
            text: '$labelVal',
            style: const TextStyle(
              color: Color(0xFF636366),
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, labelOffset - Offset(tp.width / 2, tp.height / 2));
      }
    }

    // Needle
    final needleAngle = _degToRad(_startAngle + _sweepAngle * pct);
    final needleLength = radius - 24;
    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      center,
      Offset(
        center.dx + needleLength * math.cos(needleAngle),
        center.dy + needleLength * math.sin(needleAngle),
      ),
      needlePaint,
    );

    // Center dot
    canvas.drawCircle(center, 6, Paint()..color = _speedColor(pct));
    canvas.drawCircle(
      center,
      6,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _SpeedometerPainter old) =>
      old.speedKmh != speedKmh;
}
