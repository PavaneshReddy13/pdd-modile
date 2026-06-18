import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/careflow_scaffold.dart';
import '../../core/widgets/careflow_glass_card.dart';
import '../../core/widgets/careflow_neon_button.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _canResend = false;
  int _timerSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _canResend = false;
      _timerSeconds = 30;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        setState(() => _canResend = true);
        timer.cancel();
      } else {
        setState(() => _timerSeconds--);
      }
    });
  }

  void _resendOTP() async {
    final authService = ref.read(authServiceProvider);
    setState(() => _isLoading = true);

    try {
      await authService.sendPhoneOTP(
        widget.phoneNumber,
        codeSent: (newVerificationId, forceResendingToken) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP resent successfully')),
          );
          _startTimer();
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Verification failed')),
          );
        },
        verificationCompleted: (PhoneAuthCredential credential) {},
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authService = ref.read(authServiceProvider);

    try {
      final userCred = await authService.verifyOTP(widget.verificationId, otp);

      if (userCred.user != null) {
        final isComplete = await authService.handlePatientPhoneAuthSuccess(
            userCred.user!, widget.phoneNumber);

        if (!mounted) return;
        if (isComplete) {
          context.go('/patient/dashboard');
        } else {
          context.go('/patient_profile_setup');
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String message = 'Verification failed';
      if (e.code == 'invalid-verification-code') {
        message = 'Invalid OTP. Please try again.';
      } else if (e.code == 'session-expired') {
        message = 'OTP expired. Please resend.';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
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
        title: const Text('Verify Phone'),
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
                      const Center(
                        child: Icon(
                          Icons.mark_chat_read_outlined,
                          size: 64,
                          color: AppTheme.primaryNeon,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Enter OTP Code',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We have sent a 6-digit code to ${widget.phoneNumber}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 24,
                            letterSpacing: 8,
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          hintText: '000000',
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 32),
                      CareFlowNeonButton(
                        text: 'Verify OTP',
                        isLoading: _isLoading,
                        onPressed: _verifyOTP,
                        gradientColors: const [
                          AppTheme.primaryNeon,
                          AppTheme.cyanAccent
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Didn\'t receive code? ',
                              style: TextStyle(color: AppTheme.textSecondary)),
                          if (_canResend)
                            TextButton(
                              onPressed: _isLoading ? null : _resendOTP,
                              child: const Text(
                                'Resend',
                                style: TextStyle(
                                    color: AppTheme.primaryNeon,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          else
                            Text(
                              'Resend in ${_timerSeconds}s',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.bold),
                            ),
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
