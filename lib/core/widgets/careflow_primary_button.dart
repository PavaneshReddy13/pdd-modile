import 'package:flutter/material.dart';
import 'careflow_neon_button.dart';

class CareFlowPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final List<Color>? gradientColors;

  const CareFlowPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return CareFlowNeonButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      fullWidth: fullWidth,
      gradientColors: gradientColors,
    );
  }
}
