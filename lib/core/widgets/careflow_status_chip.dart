import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CareFlowStatusChip extends StatelessWidget {
  final String status;

  const CareFlowStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = AppTheme.textSecondary;
    String label = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'approved':
      case 'accepted':
      case 'completed':
        color = AppTheme.success;
        break;
      case 'pending':
      case 'lab_pending':
        color = AppTheme.warning;
        break;
      case 'rejected':
      case 'cancelled':
        color = AppTheme.error;
        break;
      case 'in_consultation':
        color = AppTheme.cyanAccent;
        label = 'IN CONSULTATION';
        break;
      case 'report_uploaded':
        color = AppTheme.primaryNeon;
        label = 'REPORT UPLOADED';
        break;
      default:
        color = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
