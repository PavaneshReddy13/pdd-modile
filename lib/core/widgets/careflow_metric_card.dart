import 'package:flutter/material.dart';
import 'careflow_glass_card.dart';
import '../theme/app_theme.dart';

class CareFlowMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? trend;
  final Color? trendColor;
  final String? subtitle;
  final Color accentColor;

  const CareFlowMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.trend,
    this.trendColor,
    this.subtitle,
    this.accentColor = AppTheme.primaryNeon,
  });

  @override
  Widget build(BuildContext context) {
    return CareFlowGlassCard(
      glowColor: accentColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (trend != null) ...[
                Icon(
                  trend!.startsWith('-')
                      ? Icons.trending_down
                      : Icons.trending_up,
                  color: trendColor ??
                      (trend!.startsWith('-')
                          ? AppTheme.error
                          : AppTheme.success),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  trend!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: trendColor ??
                        (trend!.startsWith('-')
                            ? AppTheme.error
                            : AppTheme.success),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (subtitle != null)
                Expanded(
                  child: Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
