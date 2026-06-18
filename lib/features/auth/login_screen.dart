import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/roles.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/careflow_scaffold.dart';
import '../../core/widgets/careflow_glass_card.dart';
import '../../core/widgets/careflow_neon_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(UserRole role) async {
    setState(() => _isLoading = true);
    try {
      final password = _passwordController.text.trim();
      if (password.isEmpty) {
        throw Exception("Please enter your password");
      }

      String email = '';
      if (_tabController.index == 0) {
        // Email login
        email = _emailController.text.trim();
        if (email.isEmpty) {
          throw Exception("Please enter your email");
        }
      } else {
        // Phone number login (mapped to firebase email credentials)
        final phone = _phoneController.text.trim();
        if (phone.isEmpty) {
          throw Exception("Please enter your phone number");
        }
        final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';
        // Map phone to Firebase email format: +919876543210@careflow.com
        email = '$formattedPhone@careflow.com';
      }

      // Handle Main Admin credentials
      if (role == UserRole.mainAdmin) {
        if (_tabController.index != 0) {
          throw Exception("Main Admin must log in via Email tab");
        }
        if ((email == 'pavaneshvuchuru@gmail' ||
                email == 'pavaneshvuchuru@gmail.com') &&
            password == 'V.pavanesh\$13') {
          final authService = ref.read(authServiceProvider);
          UserCredential cred;
          try {
            cred = await authService.loginWithEmail(
                'pavaneshvuchuru@gmail.com', 'V.pavanesh\$13');
          } on FirebaseAuthException catch (authError) {
            if (authError.code == 'user-not-found') {
              cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: 'pavaneshvuchuru@gmail.com',
                password: 'V.pavanesh\$13',
              );
            } else {
              rethrow;
            }
          }
          await FirebaseFirestore.instance
              .collection('users')
              .doc(cred.user!.uid)
              .set({
            'uid': cred.user!.uid,
            'name': 'Main Admin',
            'email': 'pavaneshvuchuru@gmail.com',
            'role': 'main_admin',
            'status': 'approved',
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          if (!mounted) return;
          context.go('/main_admin/dashboard');
          return;
        } else {
          throw Exception('Invalid Main Admin credentials.');
        }
      }

      final authService = ref.read(authServiceProvider);
      final cred = await authService.loginWithEmail(email, password);

      // Verify email if not using phone login and not verified
      if (_tabController.index == 0 && !cred.user!.emailVerified) {
        if (!mounted) return;
        try {
          await cred.user!.sendEmailVerification();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Verification link sent.')));
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to send email: $e')));
        }
        if (!mounted) return;
        context.go('/verify_email', extra: role);
        return;
      }

      final uid = cred.user!.uid;
      final status = await authService.getUserStatus(uid);
      final userRoleStr = await authService.getUserRole(uid);

      if (!mounted) return;

      String route;
      if (status == 'pending') {
        route = '/waiting_approval';
      } else {
        switch (userRoleStr) {
          case 'patient':
            route = '/patient/dashboard';
            break;
          case 'doctor':
            route = '/doctor/dashboard';
            break;
          case 'hospital_admin':
            route = '/admin/dashboard';
            break;
          case 'receptionist':
            route = '/receptionist/dashboard';
            break;
          case 'lab_technician':
            route = '/lab/dashboard';
            break;
          case 'main_admin':
            route = '/main_admin/dashboard';
            break;
          default:
            route = '/patient/dashboard';
        }
      }
      context.go(route);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final role = extra is UserRole ? extra : UserRole.patient;
    final bool showApprovalBanner =
        role != UserRole.patient && role != UserRole.mainAdmin;

    Color themeColor = AppTheme.primaryNeon;
    if (role == UserRole.doctor) themeColor = AppTheme.cyanAccent;
    if (role == UserRole.hospitalAdmin) themeColor = AppTheme.secondaryGreen;
    if (role == UserRole.receptionist) themeColor = Colors.pinkAccent;
    if (role == UserRole.labTechnician) themeColor = Colors.purpleAccent;
    if (role == UserRole.mainAdmin) themeColor = Colors.orangeAccent;

    return CareFlowScaffold(
      useAnimatedBackground: true,
      appBar: AppBar(
        title: const Text('Connect Ecosystem',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/role-select'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/chatbot'),
        backgroundColor: themeColor,
        foregroundColor: AppTheme.background,
        icon: const Icon(Icons.help_outline),
        label: const Text('Support AI',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          // Giant transparent CAREFLOW background text
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    "CAREFLOW",
                    style: TextStyle(
                      fontSize: 130,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 20,
                      color: Colors.white.withValues(alpha: 0.025),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Form Content
          Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Heading Texts
                  const Text(
                    "LET'S CONNECT",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "WITH CAREFLOW ECOSYSTEM",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Main glass login container
                  Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: CareFlowGlassCard(
                      borderColor: themeColor.withValues(alpha: 0.25),
                      glowColor: themeColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Role Badge
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: themeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: themeColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                role.title.toUpperCase(),
                                style: TextStyle(
                                  color: themeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Approval banner
                          if (showApprovalBanner)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: AppTheme.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppTheme.warning
                                        .withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      color: AppTheme.warning),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Account requires staff approval before login.",
                                      style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Email / Phone Tab selection
                          Container(
                            height: 48,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                  color: AppTheme.borderCol, width: 0.8),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              indicator: BoxDecoration(
                                color: themeColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              labelColor: AppTheme.background,
                              unselectedLabelColor: AppTheme.textSecondary,
                              labelStyle: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                              tabs: const [
                                Tab(text: "Email Account"),
                                Tab(text: "Phone Number"),
                              ],
                              onTap: (index) {
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Inputs depending on Tab
                          if (_tabController.index == 0)
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                hintText: 'Enter your email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                            )
                          else
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                hintText: 'e.g. 9876543210',
                                prefixIcon: Icon(Icons.phone_outlined),
                                prefixText: '+91 ',
                              ),
                            ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Forgot Password link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Reset password link will be sent to your email.')),
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                    color: themeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // CTA Button
                          CareFlowNeonButton(
                            text: "Sign In Now",
                            isLoading: _isLoading,
                            gradientColors: [
                              themeColor,
                              themeColor.withValues(alpha: 0.8)
                            ],
                            onPressed: () => _login(role),
                          ),

                          const SizedBox(height: 16),

                          // Registration redirection
                          if (role != UserRole.mainAdmin)
                            Column(
                              children: [
                                if (role == UserRole.patient)
                                  TextButton(
                                    onPressed: () =>
                                        context.push('/register', extra: role),
                                    child: Text(
                                      'New Patient? Register with Email',
                                      style: TextStyle(
                                          color: themeColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                TextButton(
                                  onPressed: () {
                                    if (role == UserRole.patient) {
                                      context.push('/phone_login');
                                    } else {
                                      context.push('/register', extra: role);
                                    }
                                  },
                                  child: Text(
                                    role == UserRole.patient
                                        ? 'New Patient? Verify Phone OTP'
                                        : 'New Staff? Create Account',
                                    style: TextStyle(
                                        color: themeColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
