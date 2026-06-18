import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'careflow_glass_card.dart';
import 'careflow_status_chip.dart';

class CareFlowLabReportCard extends StatelessWidget {
  final String testName;
  final String patientName;
  final String doctorName;
  final String status;
  final String requestedDate;
  final VoidCallback? onUploadReport;
  final VoidCallback? onViewReport;

  const CareFlowLabReportCard({
    super.key,
    required this.testName,
    required this.patientName,
    required this.doctorName,
    required this.status,
    required this.requestedDate,
    this.onUploadReport,
    this.onViewReport,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = AppTheme.primaryNeon;
    if (status == 'pending') statusColor = AppTheme.warning;
    if (status == 'completed') statusColor = AppTheme.success;

    return CareFlowGlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      borderColor: statusColor.withValues(alpha: 0.18),
      glowColor: statusColor,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  testName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              CareFlowStatusChip(status: status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 16, color: AppTheme.cyanAccent),
              const SizedBox(width: 8),
              Text(
                'Patient: $patientName',
                style:
                    const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.medical_services_outlined,
                  size: 16, color: AppTheme.primaryNeon),
              const SizedBox(width: 8),
              Text(
                'Requested by: Dr. $doctorName',
                style:
                    const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Requested: $requestedDate',
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.textSecondary),
              ),
            ],
          ),
          if (onUploadReport != null || onViewReport != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (onUploadReport != null)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(colors: [
                          AppTheme.primaryNeon,
                          AppTheme.cyanAccent
                        ]),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: onUploadReport,
                        icon: const Icon(Icons.upload_file,
                            color: AppTheme.background, size: 18),
                        label: const Text('Upload Report',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.background)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                if (onViewReport != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewReport,
                      icon: const Icon(Icons.visibility,
                          color: AppTheme.cyanAccent, size: 18),
                      label: const Text('View Report',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.cyanAccent,
                        side: const BorderSide(color: AppTheme.cyanAccent),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
