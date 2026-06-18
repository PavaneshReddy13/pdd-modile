import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/roles.dart';
import '../../core/widgets/careflow_scaffold.dart';
import '../../core/widgets/careflow_glass_card.dart';
import '../../core/widgets/careflow_primary_button.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!isEmailVerified) {
      timer = Timer.periodic(
          const Duration(seconds: 3), (_) => checkEmailVerified());
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted) setState(() => canResendEmail = true);
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();

    setState(() {
      isEmailVerified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    });

    if (isEmailVerified) {
      timer?.cancel();
      if (!mounted) return;
      final extra = GoRouterState.of(context).extra;
      final role = extra is UserRole ? extra : UserRole.patient;
      context.go('/login', extra: role);
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      setState(() => canResendEmail = false);
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted) setState(() => canResendEmail = true);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CareFlowScaffold(
      useAnimatedBackground: true,
      appBar: AppBar(
          title: const Text('Verify Email',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: CareFlowGlassCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.mark_email_unread_outlined,
                    size: 100, color: Color(0xFF1D9E75)),
                const SizedBox(height: 32),
                const Text(
                  'Verify your email address',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D9E75)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'We have sent a verification email to your address. Please click on the link in that email to verify your account.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1D9E75))),
                const SizedBox(height: 16),
                const Text(
                  'Waiting for verification...',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                CareFlowPrimaryButton(
                  text: 'Resend Email',
                  onPressed: canResendEmail ? resendVerificationEmail : null,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    context.go('/role-select');
                  },
                  child: const Text('Cancel & Return',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
