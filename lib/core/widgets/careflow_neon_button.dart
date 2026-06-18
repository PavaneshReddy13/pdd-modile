import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CareFlowNeonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final List<Color>? gradientColors;
  final double height;
  final double borderRadius;

  const CareFlowNeonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.gradientColors,
    this.height = 56,
    this.borderRadius = 22,
  });

  @override
  Widget build(BuildContext context) {
    final defaultGradients = [
      AppTheme.primaryNeon,
      AppTheme.cyanAccent,
    ];

    final currentGradients = gradientColors ?? defaultGradients;
    final isDisabled = onPressed == null || isLoading;

    return Container(
      width: fullWidth ? double.infinity : null,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: isDisabled
            ? LinearGradient(
                colors: [
                  Colors.grey.shade800.withValues(alpha: 0.5),
                  Colors.grey.shade900.withValues(alpha: 0.5),
                ],
              )
            : LinearGradient(
                colors: currentGradients,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: isDisabled
            ? []
            : [
                BoxShadow(
                  color: currentGradients.first.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                  spreadRadius: 1,
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.transparent,
          foregroundColor: AppTheme.background,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: AppTheme.background,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: AppTheme.background, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.background,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
