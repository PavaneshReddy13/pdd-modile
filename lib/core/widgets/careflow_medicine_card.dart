import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'careflow_glass_card.dart';

class CareFlowMedicineCard extends StatelessWidget {
  final String medicineName;
  final String dosage;
  final String frequency;
  final List<String> times;
  final String duration;
  final String instructions;
  final int? remainingDays;
  final double? adherencePercentage;
  final VoidCallback? onMarkTaken;
  final VoidCallback? onSkipDose;

  const CareFlowMedicineCard({
    super.key,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.times,
    required this.duration,
    required this.instructions,
    this.remainingDays,
    this.adherencePercentage,
    this.onMarkTaken,
    this.onSkipDose,
  });

  @override
  Widget build(BuildContext context) {
    return CareFlowGlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      borderColor: AppTheme.primaryNeon.withValues(alpha: 0.18),
      glowColor: AppTheme.primaryNeon,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNeon.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.primaryNeon.withValues(alpha: 0.25)),
                ),
                child: const Icon(Icons.medication,
                    color: AppTheme.primaryNeon, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicineName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '$dosage • $frequency',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (remainingDays != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.warning.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '$remainingDays Days Left',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.warning,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: times
                      .map((t) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.borderCol),
                            ),
                            child: Text(
                              t,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
          if (instructions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cyanAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.cyanAccent.withValues(alpha: 0.18)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: AppTheme.cyanAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      instructions,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (adherencePercentage != null) ...[
            const SizedBox(height: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ADHERENCE',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary)),
                    Text('${(adherencePercentage! * 100).toInt()}%',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNeon)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: adherencePercentage,
                    backgroundColor: Colors.black.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryNeon),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ],
          if (onMarkTaken != null || onSkipDose != null) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                if (onSkipDose != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSkipDose,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: const BorderSide(color: AppTheme.error),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Skip Dose',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (onSkipDose != null && onMarkTaken != null)
                  const SizedBox(width: 12),
                if (onMarkTaken != null)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(colors: [
                          AppTheme.primaryNeon,
                          AppTheme.cyanAccent
                        ]),
                      ),
                      child: ElevatedButton(
                        onPressed: onMarkTaken,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Mark Taken',
                            style: TextStyle(
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
