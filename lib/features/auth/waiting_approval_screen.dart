import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/careflow_scaffold.dart';
import '../../core/widgets/careflow_glass_card.dart';
import '../../core/widgets/careflow_neon_button.dart';

class WaitingApprovalScreen extends StatelessWidget {
  const WaitingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CareFlowScaffold(
      useAnimatedBackground: true,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: CareFlowGlassCard(
              borderColor: AppTheme.warning.withValues(alpha: 0.25),
              glowColor: AppTheme.warning,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.hourglass_empty,
                    size: 72,
                    color: AppTheme.warning,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Approval Pending',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your account has been successfully created and is currently awaiting approval from the hospital administration.\n\nYou will be authorized to access the dashboard as soon as the review is complete.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  CareFlowNeonButton(
                    text: 'Back to Access Console',
                    onPressed: () => context.go('/role-select'),
                    gradientColors: const [AppTheme.warning, Colors.orange],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
