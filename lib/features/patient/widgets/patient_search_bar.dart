import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/careflow_glass_card.dart';

class PatientSearchBar extends StatelessWidget {
  const PatientSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return CareFlowGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      glowColor: AppTheme.primaryNeon,
      borderColor: AppTheme.borderCol,
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppTheme.primaryNeon),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: "Search doctors, hospitals, medicines...",
                hintStyle: TextStyle(
                    color: AppTheme.textSecondary.withValues(alpha: 0.7),
                    fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
