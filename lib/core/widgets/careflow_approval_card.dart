import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'careflow_glass_card.dart';
import 'careflow_status_chip.dart';

class CareFlowApprovalCard extends StatelessWidget {
  final String userName;
  final String email;
  final String phone;
  final String roleTitle;
  final String hospitalInfo;
  final String status;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onRemove;

  const CareFlowApprovalCard({
    super.key,
    required this.userName,
    required this.email,
    required this.phone,
    required this.roleTitle,
    required this.hospitalInfo,
    required this.status,
    this.onApprove,
    this.onReject,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = AppTheme.primaryNeon;
    if (status == 'pending') statusColor = AppTheme.warning;
    if (status == 'rejected') statusColor = AppTheme.error;

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
                  userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              CareFlowStatusChip(status: status),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.email_outlined, email, AppTheme.cyanAccent),
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone_outlined, phone, AppTheme.cyanAccent),
          ],
          const SizedBox(height: 8),
          _buildInfoRow(Icons.badge_outlined, roleTitle, AppTheme.primaryNeon),
          if (hospitalInfo.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.local_hospital_outlined, hospitalInfo,
                AppTheme.secondaryGreen),
          ],
          if (onApprove != null || onReject != null || onRemove != null) ...[
            const SizedBox(height: 16),
            const Divider(color: AppTheme.borderCol, height: 1.0),
            const SizedBox(height: 16),
            Row(
              children: [
                if (onReject != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: const BorderSide(color: AppTheme.error),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Reject',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (onReject != null && onApprove != null)
                  const SizedBox(width: 12),
                if (onApprove != null)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(colors: [
                          AppTheme.primaryNeon,
                          AppTheme.cyanAccent
                        ]),
                      ),
                      child: ElevatedButton(
                        onPressed: onApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Approve',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.background)),
                      ),
                    ),
                  ),
                if (onRemove != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onRemove,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: const BorderSide(color: AppTheme.error),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Revoke Access',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color accent) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: accent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }
}
