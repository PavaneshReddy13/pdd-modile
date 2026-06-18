import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/careflow_glass_card.dart';
import '../../core/widgets/careflow_neon_button.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  final user = FirebaseAuth.instance.currentUser;

  void _logout() async {
    await ref.read(authServiceProvider).signOut();
    if (mounted) context.go('/role-select');
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(
          child: Text("Not logged in",
              style: TextStyle(color: AppTheme.textSecondary)));
    }

    return SafeArea(
      child: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryNeon));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
                child: Text("Profile data not found.",
                    style: TextStyle(color: AppTheme.textSecondary)));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'User';
          final email = data['email'] ?? 'No Email';
          final phone = data['phone'] ?? 'No Phone Number';
          final role = data['role'] ?? 'Unknown Role';
          final status = data['status'] ?? 'pending';

          return SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header Card
                CareFlowGlassCard(
                  borderColor: AppTheme.primaryNeon.withValues(alpha: 0.18),
                  glowColor: AppTheme.primaryNeon,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryNeon, AppTheme.cyanAccent],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.primaryNeon.withValues(alpha: 0.3),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.background),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role.toString().toUpperCase(),
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.cyanAccent,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Account Information Card
                _buildSectionHeader("Account Credentials"),
                const SizedBox(height: 12),
                _buildInfoCard([
                  _buildInfoRow(Icons.email_outlined, "Email Address", email),
                  const Divider(color: AppTheme.borderCol, height: 24),
                  _buildInfoRow(Icons.phone_outlined, "Phone Number", phone),
                  const Divider(color: AppTheme.borderCol, height: 24),
                  _buildInfoRow(
                    Icons.verified_user_outlined,
                    "System Authorization Status",
                    status.toString().toUpperCase(),
                    valueColor: status == 'approved'
                        ? AppTheme.success
                        : AppTheme.warning,
                  ),
                ]),

                // Role-Specific Details
                if (role == 'doctor') ...[
                  const SizedBox(height: 28),
                  _buildSectionHeader("Clinical Affiliation"),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    _buildInfoRow(
                        Icons.medical_services_outlined,
                        "Specialization / Department",
                        data['specialization'] ?? 'General Physician'),
                    const Divider(color: AppTheme.borderCol, height: 24),
                    _buildInfoRow(
                        Icons.badge_outlined,
                        "Medical License Number",
                        data['licenseNumber'] ?? 'N/A'),
                  ]),
                ],

                if (role == 'hospitalAdmin' || role == 'hospital_admin') ...[
                  const SizedBox(height: 28),
                  _buildSectionHeader("Hospital Information"),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    _buildInfoRow(Icons.local_hospital_outlined,
                        "Assigned Institution", data['hospitalName'] ?? 'N/A'),
                    const Divider(color: AppTheme.borderCol, height: 24),
                    _buildInfoRow(Icons.location_on_outlined, "Hospital Region",
                        "${data['area'] ?? ''}, ${data['city'] ?? ''}"),
                    const Divider(color: AppTheme.borderCol, height: 24),
                    _buildInfoRow(Icons.map_outlined, "Street Address",
                        data['address'] ?? 'N/A'),
                  ]),
                ],

                const SizedBox(height: 40),

                // Logout Action
                CareFlowNeonButton(
                  text: "Sign Out",
                  icon: Icons.logout,
                  onPressed: _logout,
                  gradientColors: const [AppTheme.error, Colors.red],
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondary,
            letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return CareFlowGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryNeon.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryNeon, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? AppTheme.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
