import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PatientDashboardHeader extends StatelessWidget {
  final String patientName;
  final String subtitle;
  final VoidCallback onNotificationTap;

  const PatientDashboardHeader({
    super.key,
    required this.patientName,
    this.subtitle = "Manage your health easily",
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, $patientName",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded,
                  color: AppTheme.primaryNeon),
              onPressed: onNotificationTap,
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryNeon, AppTheme.cyanAccent],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryNeon.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Center(
                child: Text(
                  patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                  style: const TextStyle(
                    color: AppTheme.background,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
