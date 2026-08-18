import 'dart:math' show pi;
import 'package:flutter/material.dart';

class PerformanceRing extends StatelessWidget {
  final int percentage;
  final String crmDiscipline;
  final String targetProgress;
  final String reports;
  final String punctuality;

  const PerformanceRing({
    super.key,
    required this.percentage,
    this.crmDiscipline = '0%',
    this.targetProgress = '0%',
    this.reports = '40%',
    this.punctuality = '89%',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EE)),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Overview',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF14162B),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: 106,
              height: 106,
              child: CustomPaint(
                painter: _RingPainter(percentage / 100),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$percentage%',
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF14162B),
                        ),
                      ),
                      const Text(
                        'Overall score',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B90A5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _miniMetric('CRM discipline', crmDiscipline)),
              const SizedBox(width: 7),
              Expanded(child: _miniMetric('Target progress', targetProgress)),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(child: _miniMetric('Reports', reports)),
              const SizedBox(width: 7),
              Expanded(child: _miniMetric('Punctuality', punctuality)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniMetric(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF14162B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              color: Color(0xFF8B90A5),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  _RingPainter(this.fraction);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 2;
    final innerRadius = outerRadius - 12;
    final strokeWidth = outerRadius - innerRadius;

    canvas.drawCircle(
      center,
      (outerRadius + innerRadius) / 2,
      Paint()
        ..color = const Color(0xFFEEF0F4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (fraction > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: (outerRadius + innerRadius) / 2),
        -pi / 2,
        2 * pi * fraction,
        false,
        Paint()
          ..color = const Color(0xFF1F3D7A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }
}