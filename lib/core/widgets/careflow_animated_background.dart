import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class CareFlowAnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool glass;

  const CareFlowAnimatedBackground({
    super.key,
    required this.child,
    this.glass = false,
  });

  @override
  State<CareFlowAnimatedBackground> createState() =>
      _CareFlowAnimatedBackgroundState();
}

class _CareFlowAnimatedBackgroundState extends State<CareFlowAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _StrandsPainter(animationValue: _controller.value),
              );
            },
          ),
        ),
        if (widget.glass)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _StrandsPainter extends CustomPainter {
  final double animationValue;

  _StrandsPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFF1D9E75).withValues(alpha: 0.15),
      const Color(0xFF06B6D4).withValues(alpha: 0.15),
      const Color(0xFF185FA5).withValues(alpha: 0.1),
    ];

    for (int i = 0; i < 5; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 40.0 + (i * 10)
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

      final path = Path();
      final yOffset = size.height * 0.2 * i;
      final xOffset = animationValue * size.width * 2;

      path.moveTo(0, size.height * 0.5 + yOffset);

      for (double x = 0; x <= size.width; x += 20) {
        final y = size.height * 0.3 +
            math.sin((x + xOffset + (i * 100)) * 0.005) * 150 +
            math.cos((x - xOffset + (i * 50)) * 0.003) * 100;
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StrandsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
