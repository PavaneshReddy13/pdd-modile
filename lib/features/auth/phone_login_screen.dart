import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/careflow_scaffold.dart';
import '../../core/widgets/careflow_glass_card.dart';
import '../../core/widgets/careflow_neon_button.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';
    setState(() => _isLoading = true);
    final authService = ref.read(authServiceProvider);

    try {
      await authService.sendPhoneOTP(
        formattedPhone,
        codeSent: (verificationId, forceResendingToken) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          context.push('/verify_otp', extra: {
            'verificationId': verificationId,
            'phoneNumber': formattedPhone,
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Verification failed')),
          );
        },
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (!mounted) return;
          try {
            final userCred =
                await FirebaseAuth.instance.signInWithCredential(credential);
            if (userCred.user != null) {
              final isComplete =
                  await authService.handlePatientPhoneAuthSuccess(
                      userCred.user!, formattedPhone);
              if (!mounted) return;
              if (isComplete) {
                context.go('/patient/dashboard');
              } else {
                context.go('/patient_profile_setup');
              }
            }
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Auto-verification failed: $e')),
            );
            setState(() => _isLoading = false);
          }
        },
        codeAutoRetrievalTimeout: (verificationId) {
          debugPrint('Auto retrieval timeout for $verificationId');
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CareFlowScaffold(
      useAnimatedBackground: true,
      appBar: AppBar(
        title: const Text('Patient Access'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Text(
                  "CAREFLOW",
                  style: TextStyle(
                    fontSize: 130,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 20,
                    color: Colors.white.withValues(alpha: 0.02),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                child: CareFlowGlassCard(
                  borderColor: AppTheme.primaryNeon.withValues(alpha: 0.25),
                  glowColor: AppTheme.primaryNeon,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryNeon.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppTheme.primaryNeon
                                    .withValues(alpha: 0.2)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person,
                                  color: AppTheme.primaryNeon, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Patient Verification',
                                style: TextStyle(
                                  color: AppTheme.primaryNeon,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Enter phone number',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'We will send you a 6-digit OTP code to verify your account.',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'e.g. 9876543210',
                          prefixText: '+91 ',
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                      const SizedBox(height: 32),
                      CareFlowNeonButton(
                        text: 'Send OTP',
                        isLoading: _isLoading,
                        onPressed: _sendOTP,
                        gradientColors: const [
                          AppTheme.primaryNeon,
                          AppTheme.cyanAccent
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
