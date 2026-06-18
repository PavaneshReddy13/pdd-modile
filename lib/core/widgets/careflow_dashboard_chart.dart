import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'careflow_glass_card.dart';

class CareFlowDashboardChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final String title;
  final String subtitle;
  final Color accentColor;

  const CareFlowDashboardChart({
    super.key,
    required this.data,
    required this.labels,
    this.title = 'Consultations Activity',
    this.subtitle = 'Weekly Patient Flow',
    this.accentColor = AppTheme.primaryNeon,
  });

  @override
  Widget build(BuildContext context) {
    return CareFlowGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '+15% vs Last Week',
                  style: TextStyle(
                    color: AppTheme.success,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: Size.infinite,
              painter: _BezierChartPainter(
                data: data,
                labels: labels,
                accentColor: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BezierChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color accentColor;

  _BezierChartPainter({
    required this.data,
    required this.labels,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double maxVal = data.reduce((a, b) => a > b ? a : b);
    final double divisor = maxVal == 0 ? 1.0 : maxVal;

    final double widthStep = size.width / (data.length - 1);
    final double paddingBottom = 24.0;
    final double chartHeight = size.height - paddingBottom;

    // Grid lines
    final gridPaint = Paint()
      ..color = AppTheme.borderCol.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = chartHeight * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Coordinates mapping
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * widthStep;
      final ratio = data[i] / divisor;
      // Invert Y coordinate
      final y = chartHeight - (ratio * chartHeight * 0.85);
      points.add(Offset(x, y));
    }

    // Bezier line path
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = p0.dx + (p1.dx - p0.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    // Underneath area path for gradient
    final areaPath = Path.from(path);
    areaPath.lineTo(points.last.dx, chartHeight);
    areaPath.lineTo(points.first.dx, chartHeight);
    areaPath.close();

    // Fill gradient
    final fillShader = ui.Gradient.linear(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, chartHeight),
      [
        accentColor.withValues(alpha: 0.24),
        accentColor.withValues(alpha: 0.01),
      ],
    );
    final fillPaint = Paint()
      ..shader = fillShader
      ..style = PaintingStyle.fill;
    canvas.drawPath(areaPath, fillPaint);

    // Draw glowing bezier line
    final linePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 1);
    canvas.drawPath(path, linePaint);

    // Draw dots and text
    final pointPaint = Paint()
      ..color = AppTheme.background
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      // Draw outer circle
      canvas.drawCircle(p, 5.0, borderPaint);
      canvas.drawCircle(p, 3.5, pointPaint);

      // Draw labels
      if (i < labels.length) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: labels[i],
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(p.dx - textPainter.width / 2, chartHeight + 8),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BezierChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.labels != labels ||
        oldDelegate.accentColor != accentColor;
  }
}
