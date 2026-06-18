import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/careflow_glass_card.dart';
import '../../core/widgets/careflow_neon_background.dart';
import '../../core/widgets/careflow_neon_button.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CareFlowNeonBackground(
      showGrid: true,
      showOrb: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Top Navigation Bar
                  _buildNavBar(context, isDesktop),

                  // Hero & Content Section
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 60.0 : 24.0,
                      vertical: 40.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),

                        // Glowing Medical Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryNeon.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color:
                                    AppTheme.primaryNeon.withValues(alpha: 0.2),
                                width: 1),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome,
                                  color: AppTheme.primaryNeon, size: 16),
                              SizedBox(width: 8),
                              Text(
                                "NEXT-GEN AI HEALTHCARE ECOSYSTEM",
                                style: TextStyle(
                                  color: AppTheme.primaryNeon,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Hero Main Heading
                        Text(
                          "CAREFLOW",
                          style: TextStyle(
                            fontSize: isDesktop ? 80 : 52,
                            fontWeight: FontWeight.w900,
                            letterSpacing: isDesktop ? 12 : 6,
                            color: AppTheme.textPrimary,
                            height: 0.9,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isDesktop ? 16 : 12),
                        Text(
                          "AI Powered Smart Hospital Management System",
                          style: TextStyle(
                            fontSize: isDesktop ? 32 : 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.cyanAccent,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isDesktop ? 32 : 20),

                        // Hero Subtitle
                        Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Text(
                            "Book appointments, manage tokens, connect doctors, labs, reception, and patients in one intelligent healthcare ecosystem powered by state-of-the-art clinical intelligence.",
                            style: TextStyle(
                              fontSize: isDesktop ? 18 : 14,
                              color: AppTheme.textSecondary,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: isDesktop ? 56 : 40),

                        // CTA Buttons
                        Wrap(
                          spacing: 20,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: [
                            CareFlowNeonButton(
                              text: "Get Started",
                              icon: Icons.arrow_forward_rounded,
                              onPressed: () => context.go('/role-select'),
                            ),
                            OutlinedButton(
                              onPressed: () => context.push('/chatbot'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 18, horizontal: 24),
                                side: const BorderSide(
                                    color: AppTheme.primaryNeon, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat_bubble_outline,
                                      color: AppTheme.primaryNeon, size: 20),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      "Ask CareFlow AI",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppTheme.primaryNeon,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () =>
                                  context.push('/patient/ai_symptoms'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 18, horizontal: 24),
                                side: const BorderSide(
                                    color: AppTheme.cyanAccent, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.psychology_outlined,
                                      color: AppTheme.cyanAccent, size: 20),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      "AI Symptoms Analyzer",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppTheme.cyanAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 80),

                        // Floating Glass Stat Cards / Features
                        const Text(
                          "INTEGRATED CLINICAL SERVICES",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildFeatureSection(isDesktop),

                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.3),
        border: const Border(
          bottom: BorderSide(color: AppTheme.borderCol, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNeon.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: AppTheme.primaryNeon,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'CareFlow',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),

          // Desktop Nav links
          if (isDesktop)
            Row(
              children: [
                _buildNavLink("About"),
                _buildNavLink("Features"),
                _buildNavLink("Roles"),
                _buildNavLink("Contact"),
              ],
            ),

          // Get Started/Login button
          Row(
            children: [
              const SizedBox(width: 16),
              if (isDesktop)
                SizedBox(
                  width: 140,
                  height: 40,
                  child: CareFlowNeonButton(
                    text: "Enter App",
                    height: 40,
                    borderRadius: 14,
                    onPressed: () => context.go('/role-select'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildFeatureSection(bool isDesktop) {
    final features = [
      _FeatureItem(Icons.confirmation_number_outlined, "Smart Tokens",
          "Real-time automated queue & token tracking.", AppTheme.primaryNeon),
      _FeatureItem(
          Icons.psychology_outlined,
          "AI Symptoms",
          "Intelligent symptoms analyzer for clinical triage.",
          AppTheme.cyanAccent),
      _FeatureItem(Icons.alarm_on_outlined, "Medicine Reminder",
          "Smart medication alerts & adherence logs.", AppTheme.secondaryGreen),
      _FeatureItem(Icons.analytics_outlined, "Lab Reports",
          "Instant access & uploads of reports.", AppTheme.primaryNeon),
      _FeatureItem(Icons.emergency_outlined, "Emergency Care",
          "Immediate single-tap emergency alerts.", AppTheme.error),
    ];

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            features.map((f) => Expanded(child: _buildFeatureCard(f))).toList(),
      );
    } else {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
        children: features.map((f) => _buildFeatureCard(f)).toList(),
      );
    }
  }

  Widget _buildFeatureCard(_FeatureItem item) {
    return CareFlowGlassCard(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(20),
      glowColor: item.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: item.color.withValues(alpha: 0.2), width: 1),
            ),
            child: Icon(item.icon, color: item.color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.desc,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;

  _FeatureItem(this.icon, this.title, this.desc, this.color);
}
