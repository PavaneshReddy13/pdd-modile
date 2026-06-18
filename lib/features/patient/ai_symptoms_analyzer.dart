import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/gemini_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/careflow_neon_background.dart';
import '../../core/widgets/careflow_glass_card.dart';
import '../../core/widgets/careflow_neon_button.dart';

class AISymptomsAnalyzerScreen extends ConsumerStatefulWidget {
  const AISymptomsAnalyzerScreen({super.key});

  @override
  ConsumerState<AISymptomsAnalyzerScreen> createState() =>
      _AISymptomsAnalyzerScreenState();
}

class _AISymptomsAnalyzerScreenState
    extends ConsumerState<AISymptomsAnalyzerScreen> {
  final _symptomsController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedGender = 'Male';
  String _selectedDuration = '1-3 Days';
  String _selectedSeverity = 'Mild';

  bool _isLoading = false;
  String? _analysisResult;
  bool _isEmergency = false;

  final List<String> _emergencyKeywords = [
    'chest pain',
    'breathing difficulty',
    'stroke',
    'unconscious',
    'severe bleeding'
  ];

  @override
  void dispose() {
    _symptomsController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _analyze() async {
    final symptoms = _symptomsController.text.trim();
    if (symptoms.isEmpty) return;

    setState(() {
      _isLoading = true;
      _analysisResult = null;
      _isEmergency = false;
    });

    final lowerSymptoms = symptoms.toLowerCase();
    for (var kw in _emergencyKeywords) {
      if (lowerSymptoms.contains(kw)) {
        setState(() {
          _isEmergency = true;
          _isLoading = false;
        });
        return;
      }
    }

    try {
      final gemini = ref.read(geminiServiceProvider);
      final result = await gemini.analyzeSymptoms(
        symptoms: symptoms,
        age: _ageController.text.isEmpty ? "Unknown" : _ageController.text,
        gender: _selectedGender,
        duration: _selectedDuration,
        severity: _selectedSeverity,
      );

      if (mounted) {
        setState(() {
          _analysisResult = result;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    return CareFlowNeonBackground(
      showGrid: true,
      showOrb: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('AI Symptoms Analyzer',
              style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryNeon),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/role-select');
              }
            },
          ),
          actions: [
            if (!isLoggedIn)
              TextButton(
                onPressed: () => context.go('/role-select'),
                child: const Text('Login',
                    style: TextStyle(
                        color: AppTheme.primaryNeon,
                        fontWeight: FontWeight.bold)),
              )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Emergency alert message banner
                  if (_isEmergency) ...[
                    CareFlowGlassCard(
                      borderColor: AppTheme.error.withValues(alpha: 0.3),
                      glowColor: AppTheme.error,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: AppTheme.error, size: 54),
                          const SizedBox(height: 12),
                          const Text(
                            'EMERGENCY DETECTED',
                            style: TextStyle(
                                color: AppTheme.error,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: 1),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your described symptoms might suggest a serious condition. Please contact emergency services or proceed to the nearest emergency department immediately.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                                height: 1.4),
                          ),
                          const SizedBox(height: 16),
                          CareFlowNeonButton(
                            text: "Call Emergency",
                            gradientColors: const [AppTheme.error, Colors.red],
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Diagnostic input glass card
                  CareFlowGlassCard(
                    borderColor: AppTheme.primaryNeon.withValues(alpha: 0.25),
                    glowColor: AppTheme.primaryNeon,
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.psychology,
                                color: AppTheme.primaryNeon, size: 24),
                            SizedBox(width: 10),
                            Text(
                              'Ecosystem AI Diagnosis',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Symptoms Field
                        TextFormField(
                          controller: _symptomsController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Describe your symptoms',
                            hintText:
                                'e.g. Sharp chest pain, cough, high temperature...',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Age & Gender Row
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Age',
                                  prefixIcon: Icon(Icons.cake_outlined),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedGender,
                                decoration: const InputDecoration(
                                  labelText: 'Gender',
                                  prefixIcon: Icon(Icons.wc_outlined),
                                ),
                                dropdownColor: AppTheme.backgroundCard,
                                items: ['Male', 'Female', 'Other']
                                    .map((g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(g,
                                            style: const TextStyle(
                                                color: AppTheme.textPrimary))))
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedGender = val!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Duration dropdown
                        DropdownButtonFormField<String>(
                          initialValue: _selectedDuration,
                          decoration: const InputDecoration(
                            labelText: 'Symptom Duration',
                            prefixIcon: Icon(Icons.timer_outlined),
                          ),
                          dropdownColor: AppTheme.backgroundCard,
                          items: [
                            '< 1 Day',
                            '1-3 Days',
                            '1 Week',
                            'More than 1 Week'
                          ]
                              .map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(d,
                                      style: const TextStyle(
                                          color: AppTheme.textPrimary))))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedDuration = val!),
                        ),
                        const SizedBox(height: 20),

                        // Severity Choice Chips (Modern alternative to Dropdowns!)
                        const Text(
                          'Select Severity Level',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: ['Mild', 'Moderate', 'Severe'].map((sev) {
                            final bool isSelected = _selectedSeverity == sev;
                            Color chipColor = AppTheme.primaryNeon;
                            if (sev == 'Moderate') chipColor = AppTheme.warning;
                            if (sev == 'Severe') chipColor = AppTheme.error;

                            return ChoiceChip(
                              label: Text(
                                sev,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppTheme.background
                                      : AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: chipColor,
                              backgroundColor: AppTheme.cardBg,
                              onSelected: (bool selected) {
                                if (selected) {
                                  setState(() => _selectedSeverity = sev);
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 28),

                        // Analyze Button
                        CareFlowNeonButton(
                          text: "Analyze Symptoms",
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _analyze,
                        ),
                      ],
                    ),
                  ),

                  // Diagnostic result display
                  if (_analysisResult != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'AI Clinical Assessment',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    CareFlowGlassCard(
                      borderColor: AppTheme.cyanAccent.withValues(alpha: 0.2),
                      glowColor: AppTheme.cyanAccent,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _analysisResult!,
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                height: 1.5,
                                fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.borderCol),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: AppTheme.warning, size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Disclaimer: This analysis is AI-generated and is for informational purposes only. It does not replace professional medical advice, diagnosis, or treatment.',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 10,
                                        height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Redirect to Login if not authenticated
                  if (!isLoggedIn) ...[
                    const SizedBox(height: 24),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppTheme.primaryNeon),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22)),
                      ),
                      onPressed: () => context.go('/role-select'),
                      child: const Text('Skip & Continue to Portal',
                          style: TextStyle(
                              fontSize: 15,
                              color: AppTheme.primaryNeon,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
