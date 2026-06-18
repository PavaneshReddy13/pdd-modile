import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/careflow_glass_card.dart';

class HealthSummarySection extends StatelessWidget {
  final int upcomingAppointments;
  final int activeMedicines;
  final int pendingReports;
  final int completedVisits;

  const HealthSummarySection({
    super.key,
    required this.upcomingAppointments,
    required this.activeMedicines,
    required this.pendingReports,
    required this.completedVisits,
  });

  Widget _buildSummaryItem(
      String title, String value, IconData icon, Color color) {
    return CareFlowGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      glowColor: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildSummaryItem("Upcoming\nAppts", upcomingAppointments.toString(),
            Icons.calendar_month_rounded, AppTheme.primaryNeon),
        _buildSummaryItem("Active\nMedicines", activeMedicines.toString(),
            Icons.medication_rounded, AppTheme.cyanAccent),
        _buildSummaryItem("Pending\nReports", pendingReports.toString(),
            Icons.science_rounded, AppTheme.warning),
        _buildSummaryItem("Completed\nVisits", completedVisits.toString(),
            Icons.check_circle_outline_rounded, AppTheme.secondaryGreen),
      ],
    );
  }
}
