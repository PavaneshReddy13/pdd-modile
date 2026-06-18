import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CareFlowNeonBackground extends StatefulWidget {
  final Widget child;
  final bool showGrid;
  final bool showOrb;

  const CareFlowNeonBackground({
    super.key,
    required this.child,
    this.showGrid = true,
    this.showOrb = true,
  });

  @override
  State<CareFlowNeonBackground> createState() => _CareFlowNeonBackgroundState();
}

class _CareFlowNeonBackgroundState extends State<CareFlowNeonBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Base dark gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.background,
                    Color(0xFF071412),
                    Color(0xFF0B1F1A),
                  ],
                ),
              ),
            ),
          ),

          // Animated blobs and orb
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _NeonGlowPainter(
                    animationValue: _controller.value,
                    showGrid: widget.showGrid,
                    showOrb: widget.showOrb,
                  ),
                );
              },
            ),
          ),

          // Blur layer for smooth glass blending
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.transparent),
            ),
          ),

          // Content
          Positioned.fill(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class _NeonGlowPainter extends CustomPainter {
  final double animationValue;
  final bool showGrid;
  final bool showOrb;

  _NeonGlowPainter({
    required this.animationValue,
    required this.showGrid,
    required this.showOrb,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid if requested
    if (showGrid) {
      final gridPaint = Paint()
        ..color = AppTheme.primaryNeon.withValues(alpha: 0.04)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      const double step = 40.0;
      for (double x = 0; x < size.width; x += step) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
      for (double y = 0; y < size.height; y += step) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }

    // Draw floating blobs
    final blobColors = [
      AppTheme.primaryNeon.withValues(alpha: 0.18),
      AppTheme.cyanAccent.withValues(alpha: 0.15),
      AppTheme.secondaryGreen.withValues(alpha: 0.12),
    ];

    for (int i = 0; i < 3; i++) {
      final angle = (animationValue * 2 * math.pi) + (i * math.pi / 1.5);
      final radius = 120.0 + (i * 30.0);

      // Floating center coordinates
      final cx = size.width * 0.5 + math.sin(angle) * (size.width * 0.25);
      final cy = size.height * 0.5 + math.cos(angle) * (size.height * 0.25);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            blobColors[i],
            blobColors[i].withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));

      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }

    // Draw medical sphere/orb (top-right or center depending on size)
    if (showOrb) {
      final pulse = math.sin(animationValue * 2 * math.pi * 2) * 12.0;
      final orbRadius = 130.0 + pulse;
      final orbCenter = Offset(size.width * 0.8, size.height * 0.25);

      // Orb outer glow
      final outerGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            AppTheme.cyanAccent.withValues(alpha: 0.25),
            AppTheme.primaryNeon.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ).createShader(
            Rect.fromCircle(center: orbCenter, radius: orbRadius * 1.8));
      canvas.drawCircle(orbCenter, orbRadius * 1.8, outerGlow);

      // Core medical orb
      final orbPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            AppTheme.primaryNeon,
            AppTheme.cyanAccent.withValues(alpha: 0.8),
            AppTheme.background.withValues(alpha: 0.4),
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(Rect.fromCircle(center: orbCenter, radius: orbRadius));

      canvas.drawCircle(orbCenter, orbRadius, orbPaint);

      // Draw subtle healthcare cross in the orb core
      final crossSize = orbRadius * 0.25;
      final crossWidth = crossSize * 0.35;
      final crossPaint = Paint()
        ..color = AppTheme.textPrimary.withValues(alpha: 0.75)
        ..style = PaintingStyle.fill;

      // Horizontal bar
      canvas.drawRect(
        Rect.fromCenter(
            center: orbCenter, width: crossSize, height: crossWidth),
        crossPaint,
      );
      // Vertical bar
      canvas.drawRect(
        Rect.fromCenter(
            center: orbCenter, width: crossWidth, height: crossSize),
        crossPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NeonGlowPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.showOrb != showOrb;
  }
}
