import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'careflow_glass_card.dart';
import 'careflow_status_chip.dart';

class CareFlowAppointmentCard extends StatelessWidget {
  final String patientName;
  final String doctorName;
  final String department;
  final String date;
  final String timeSlot;
  final int? tokenNumber;
  final String status;
  final VoidCallback? onAccept;
  final VoidCallback? onStartConsultation;
  final VoidCallback? onCompleted;

  const CareFlowAppointmentCard({
    super.key,
    required this.patientName,
    required this.doctorName,
    required this.department,
    required this.date,
    required this.timeSlot,
    this.tokenNumber,
    required this.status,
    this.onAccept,
    this.onStartConsultation,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = AppTheme.primaryNeon;
    if (status == 'pending') statusColor = AppTheme.warning;
    if (status == 'cancelled') statusColor = AppTheme.error;
    if (status == 'completed') statusColor = AppTheme.success;

    return CareFlowGlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      borderColor: statusColor.withValues(alpha: 0.2),
      glowColor: statusColor,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CareFlowStatusChip(status: status),
              if (tokenNumber != null && tokenNumber! > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNeon.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.primaryNeon.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'TOKEN: #$tokenNumber',
                    style: const TextStyle(
                      color: AppTheme.primaryNeon,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cyanAccent.withValues(alpha: 0.1),
                  border: Border.all(
                      color: AppTheme.cyanAccent.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.person,
                    color: AppTheme.cyanAccent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dr. $doctorName • $department',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderCol, width: 0.8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 14, color: AppTheme.primaryNeon),
                const SizedBox(width: 8),
                Text(
                  date,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontSize: 13),
                ),
                const Spacer(),
                const Icon(Icons.access_time,
                    size: 14, color: AppTheme.cyanAccent),
                const SizedBox(width: 8),
                Text(
                  timeSlot,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontSize: 13),
                ),
              ],
            ),
          ),
          if (onAccept != null ||
              onStartConsultation != null ||
              onCompleted != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (onAccept != null)
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(colors: [
                          AppTheme.primaryNeon,
                          AppTheme.cyanAccent
                        ]),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryNeon.withValues(alpha: 0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('Accept & Generate Token',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.background)),
                      ),
                    ),
                  ),
                if (onStartConsultation != null)
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(colors: [
                          AppTheme.cyanAccent,
                          AppTheme.primaryNeon
                        ]),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.cyanAccent.withValues(alpha: 0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: onStartConsultation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('Start Consultation',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.background)),
                      ),
                    ),
                  ),
                if (onCompleted != null)
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(colors: [
                          AppTheme.secondaryGreen,
                          AppTheme.primaryNeon
                        ]),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppTheme.secondaryGreen.withValues(alpha: 0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: onCompleted,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('Complete / Prescribe',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.background)),
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
