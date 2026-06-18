import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/roles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/careflow_scaffold.dart';
import '../../core/widgets/careflow_role_card.dart';
import '../../core/widgets/careflow_primary_button.dart';

final selectedRoleProvider = StateProvider<UserRole?>((ref) => null);

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(selectedRoleProvider);

    return CareFlowScaffold(
      useAnimatedBackground: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/chatbot'),
        icon: const Icon(Icons.psychology, color: AppTheme.background),
        label: const Text('Ask CareFlow AI',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryNeon,
        foregroundColor: AppTheme.background,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          final isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 900;

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Choose Your CareFlow Access',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select your role to enter the healthcare ecosystem.',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: isDesktop ? 4 : (isTablet ? 3 : 2),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: isDesktop ? 1.4 : (isTablet ? 1.3 : 1.15),
                    children: [
                      CareFlowRoleCard(
                        title: UserRole.patient.title,
                        description: 'Book appointments & track health.',
                        icon: Icons.person,
                        color: AppTheme.primaryNeon,
                        bgColor: AppTheme.primaryNeon.withValues(alpha: 0.1),
                        isSelected: selectedRole == UserRole.patient,
                        onTap: () => ref
                            .read(selectedRoleProvider.notifier)
                            .state = UserRole.patient,
                      ),
                      CareFlowRoleCard(
                        title: UserRole.doctor.title,
                        description: 'Manage consultations & queue.',
                        icon: Icons.medical_services,
                        color: AppTheme.cyanAccent,
                        bgColor: AppTheme.cyanAccent.withValues(alpha: 0.1),
                        isSelected: selectedRole == UserRole.doctor,
                        onTap: () => ref
                            .read(selectedRoleProvider.notifier)
                            .state = UserRole.doctor,
                      ),
                      CareFlowRoleCard(
                        title: UserRole.hospitalAdmin.title,
                        description: 'Configure staff & approvals.',
                        icon: Icons.local_hospital,
                        color: AppTheme.secondaryGreen,
                        bgColor: AppTheme.secondaryGreen.withValues(alpha: 0.1),
                        isSelected: selectedRole == UserRole.hospitalAdmin,
                        onTap: () => ref
                            .read(selectedRoleProvider.notifier)
                            .state = UserRole.hospitalAdmin,
                      ),
                      CareFlowRoleCard(
                        title: UserRole.receptionist.title,
                        description: 'OP desk & token queue administration.',
                        icon: Icons.support_agent,
                        color: Colors.pinkAccent,
                        bgColor: Colors.pinkAccent.withValues(alpha: 0.1),
                        isSelected: selectedRole == UserRole.receptionist,
                        onTap: () => ref
                            .read(selectedRoleProvider.notifier)
                            .state = UserRole.receptionist,
                      ),
                      CareFlowRoleCard(
                        title: UserRole.labTechnician.title,
                        description: 'Conduct diagnostics & reports.',
                        icon: Icons.science,
                        color: Colors.purpleAccent,
                        bgColor: Colors.purpleAccent.withValues(alpha: 0.1),
                        isSelected: selectedRole == UserRole.labTechnician,
                        onTap: () => ref
                            .read(selectedRoleProvider.notifier)
                            .state = UserRole.labTechnician,
                      ),
                      CareFlowRoleCard(
                        title: UserRole.mainAdmin.title,
                        description: 'Platform and hospital requests console.',
                        icon: Icons.admin_panel_settings,
                        color: Colors.orangeAccent,
                        bgColor: Colors.orangeAccent.withValues(alpha: 0.1),
                        isSelected: selectedRole == UserRole.mainAdmin,
                        onTap: () => ref
                            .read(selectedRoleProvider.notifier)
                            .state = UserRole.mainAdmin,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                CareFlowPrimaryButton(
                  text: selectedRole == null
                      ? 'Continue'
                      : 'Continue as ${selectedRole.title}',
                  onPressed: selectedRole == null
                      ? null
                      : () {
                          context.go('/login', extra: selectedRole);
                        },
                ),
                const SizedBox(height: 50), // space for floating action button
              ],
            ),
          );
        },
      ),
    );
  }
}
