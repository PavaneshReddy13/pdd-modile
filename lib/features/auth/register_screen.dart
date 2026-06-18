import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/roles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/careflow_scaffold.dart';
import '../../core/widgets/careflow_glass_card.dart';
import '../../core/widgets/careflow_neon_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hospitalNameController = TextEditingController();
  final _hospitalAddressController = TextEditingController();
  final _hospitalCityController = TextEditingController();
  final _hospitalAreaController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  bool _isLoading = false;
  List<DocumentSnapshot> _hospitals = [];
  String? _selectedHospitalId;
  String? _selectedSpecialization;

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _hospitalNameController.dispose();
    _hospitalAddressController.dispose();
    _hospitalCityController.dispose();
    _hospitalAreaController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _fetchHospitals() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role',
              whereIn: [UserRole.hospitalAdmin.name, 'hospital_admin'])
          .where('status', isEqualTo: 'approved')
          .get();
      if (mounted) {
        setState(() {
          _hospitals = snapshot.docs;
        });
      }
    } catch (e) {
      debugPrint("Error fetching hospitals: $e");
    }
  }

  void _register(UserRole role) async {
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);

      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final phone = _phoneController.text.trim();

      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception("Please fill in all basic fields.");
      }

      if (role == UserRole.hospitalAdmin) {
        await authService.registerHospitalAdmin(
          name,
          email,
          password,
          _hospitalNameController.text.trim(),
          _hospitalAddressController.text.trim(),
          _hospitalCityController.text.trim(),
          _hospitalAreaController.text.trim(),
        );
        if (mounted) context.go('/verify_email', extra: role);
      } else if (role == UserRole.doctor) {
        if (_selectedHospitalId == null) {
          throw Exception('Please select a hospital.');
        }
        await authService.registerDoctor(
          name,
          email,
          phone,
          password,
          _selectedHospitalId!,
          _licenseNumberController.text.trim(),
          _selectedSpecialization ?? '',
        );
        if (mounted) context.go('/verify_email', extra: role);
      } else if (role == UserRole.patient) {
        await authService.registerPatient(
          name,
          email,
          phone,
          password,
        );
        if (mounted) context.go('/verify_email', extra: role);
      } else {
        if (_selectedHospitalId == null) {
          throw Exception('Please select a hospital.');
        }
        await authService.registerStaff(
          name,
          email,
          phone,
          password,
          role.dbValue,
          _selectedHospitalId!,
        );
        if (mounted) context.go('/verify_email', extra: role);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final role = extra is UserRole ? extra : UserRole.patient;

    final isAdmin = role == UserRole.hospitalAdmin;
    final isStaff = role != UserRole.patient && !isAdmin;

    Color themeColor = AppTheme.primaryNeon;
    if (role == UserRole.doctor) themeColor = AppTheme.cyanAccent;
    if (role == UserRole.hospitalAdmin) themeColor = AppTheme.secondaryGreen;
    if (role == UserRole.receptionist) themeColor = Colors.pinkAccent;
    if (role == UserRole.labTechnician) themeColor = Colors.purpleAccent;

    return CareFlowScaffold(
      useAnimatedBackground: true,
      appBar: AppBar(
        title: const Text('Create Account',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login', extra: role);
            }
          },
        ),
      ),
      body: Stack(
        children: [
          // Giant transparent watermarked text
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
                      color: Colors.white.withValues(alpha: 0.02),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                    "CREATE NEW ${role.title.toUpperCase()} ACCOUNT",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(height: 32),
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

                          // Form Inputs
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              hintText: 'Enter your name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'Enter your email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (!isAdmin) ...[
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                hintText: 'Enter phone number',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          if (isAdmin) ...[
                            TextFormField(
                              controller: _hospitalNameController,
                              decoration: const InputDecoration(
                                labelText: 'Hospital Name',
                                hintText: 'Enter hospital name',
                                prefixIcon: Icon(Icons.local_hospital_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _hospitalAddressController,
                              decoration: const InputDecoration(
                                labelText: 'Hospital Street Address',
                                hintText: 'Enter street address',
                                prefixIcon: Icon(Icons.map_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _hospitalCityController,
                              decoration: const InputDecoration(
                                labelText: 'City',
                                hintText: 'Enter city',
                                prefixIcon: Icon(Icons.location_city_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _hospitalAreaController,
                              decoration: const InputDecoration(
                                labelText: 'Area',
                                hintText: 'Enter area',
                                prefixIcon: Icon(Icons.place_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          if (isStaff) ...[
                            const Text(
                              'Select Hospital Location',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.local_hospital),
                              ),
                              initialValue: _selectedHospitalId,
                              hint: const Text('Select hospital'),
                              items: _hospitals.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final hospitalName =
                                    data['hospitalName'] ?? 'Unknown';
                                final city =
                                    data['city']?.toString().trim() ?? '';
                                final area =
                                    data['area']?.toString().trim() ?? '';
                                String displayStr = hospitalName;
                                if (city.isNotEmpty) displayStr += ", $city";
                                if (area.isNotEmpty) displayStr += " ($area)";
                                return DropdownMenuItem(
                                    value: doc.id, child: Text(displayStr));
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedHospitalId = val),
                            ),
                            const SizedBox(height: 16),
                            if (role == UserRole.doctor) ...[
                              TextFormField(
                                controller: _licenseNumberController,
                                decoration: const InputDecoration(
                                  labelText: 'Medical License Number',
                                  hintText: 'Enter license number',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Select Specialization',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.star_outline),
                                ),
                                initialValue: _selectedSpecialization,
                                hint: const Text('Select specialization'),
                                items: AppConstants.specializations
                                    .map((spec) => DropdownMenuItem(
                                        value: spec, child: Text(spec)))
                                    .toList(),
                                onChanged: (val) => setState(
                                    () => _selectedSpecialization = val),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ],

                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                          ),
                          const SizedBox(height: 32),

                          CareFlowNeonButton(
                            text: "Create Account",
                            isLoading: _isLoading,
                            gradientColors: [
                              themeColor,
                              themeColor.withValues(alpha: 0.8)
                            ],
                            onPressed: () => _register(role),
                          ),
                          const SizedBox(height: 16),

                          TextButton(
                            onPressed: () => context.go('/login', extra: role),
                            child: Text(
                              'Already have an account? Sign In',
                              style: TextStyle(
                                  color: themeColor,
                                  fontWeight: FontWeight.bold),
                            ),
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
