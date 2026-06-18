import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/appointment_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/careflow_neon_background.dart';
import '../../core/widgets/careflow_glass_card.dart';
import '../../core/widgets/careflow_neon_button.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  List<DocumentSnapshot> _hospitals = [];
  List<DocumentSnapshot> _doctors = [];

  String? _selectedCity;
  String? _selectedHospitalId;
  String? _selectedHospitalName;
  String? _selectedHospitalArea;
  String? _selectedCategory;
  String? _selectedDoctorId;
  String? _selectedDoctorName;
  DateTime? _selectedDate;
  String? _selectedSlotTime;

  String? _patientName;
  String? _patientPhone;

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
    _fetchPatientDetails();
  }

  Future<void> _fetchPatientDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _patientName = data['name'];
            _patientPhone = data['phone'];
          });
        }
      } catch (e) {
        debugPrint("Error fetching patient details: $e");
      }
    }
  }

  Future<void> _fetchHospitals() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', whereIn: ['hospitalAdmin', 'hospital_admin'])
          .where('status', isEqualTo: 'approved')
          .get();
      setState(() {
        _hospitals = snapshot.docs;
      });
    } catch (e) {
      debugPrint("Error fetching hospitals: $e");
    }
  }

  Future<void> _fetchDoctors() async {
    if (_selectedHospitalId == null || _selectedCategory == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('hospitalId', isEqualTo: _selectedHospitalId)
          .where('status', isEqualTo: 'approved')
          .where('specialization', isEqualTo: _selectedCategory)
          .get();
      setState(() {
        _doctors = snapshot.docs;
      });
    } catch (e) {
      debugPrint("Error fetching doctors: $e");
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error loading doctors: $e')));
      }
    }
  }

  void _submitBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('You must be logged in to book an appointment.')));
      return;
    }
    final uid = user.uid;
    final pName = _patientName ?? user.displayName ?? 'Unknown Patient';

    setState(() => _isLoading = true);
    try {
      final formattedDate = _selectedDate != null
          ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
          : '';

      // Generate dynamic token number
      final existingAppointments = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: _selectedDoctorId)
          .where('date', isEqualTo: formattedDate)
          .get();

      final generatedToken = existingAppointments.docs.length + 1;

      final docRef =
          FirebaseFirestore.instance.collection('appointments').doc();
      final model = AppointmentModel(
        id: docRef.id,
        patientId: uid,
        patientName: pName,
        patientPhone: _patientPhone ?? 'N/A',
        hospitalId: _selectedHospitalId ?? '',
        hospitalName: _selectedHospitalName ?? 'Unknown Hospital',
        city: _selectedCity ?? '',
        area: _selectedHospitalArea ?? '',
        doctorId: _selectedDoctorId ?? '',
        doctorName: _selectedDoctorName ?? 'Unknown Doctor',
        category: _selectedCategory ?? '',
        tokenNumber: generatedToken,
        slotTime: _selectedSlotTime ?? '',
        date: formattedDate,
        status: 'pending', // Receptionist will accept
      );

      await docRef.set(model.toMap());

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.backgroundCard,
          title: const Text('Booking Confirmed',
              style: TextStyle(color: AppTheme.textPrimary)),
          content: Text(
              'Your appointment has been booked successfully!\n\nYour Token Number is: $generatedToken',
              style: const TextStyle(color: AppTheme.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK',
                  style: TextStyle(
                      color: AppTheme.primaryNeon,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

      if (!mounted) return;
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uniqueCities = _hospitals
        .map((doc) =>
            (doc.data() as Map<String, dynamic>)['city']?.toString() ??
            'Unknown')
        .toSet()
        .toList();

    return CareFlowNeonBackground(
      showGrid: true,
      showOrb: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Book Appointment',
              style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryNeon),
            onPressed: () => context.pop(),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryNeon))
            : Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: AppTheme.primaryNeon,
                      ),
                ),
                child: Stepper(
                  type: StepperType.vertical,
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep == 0 && _selectedCity == null) return;
                    if (_currentStep == 1 && _selectedHospitalId == null) {
                      return;
                    }
                    if (_currentStep == 2 && _selectedCategory == null) return;
                    if (_currentStep == 3 && _selectedDoctorId == null) return;
                    if (_currentStep == 4 &&
                        (_selectedDate == null || _selectedSlotTime == null)) {
                      return;
                    }

                    if (_currentStep == 2) {
                      _fetchDoctors();
                    }

                    if (_currentStep < 4) {
                      setState(() => _currentStep += 1);
                    } else {
                      _submitBooking();
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep -= 1);
                    } else {
                      context.pop();
                    }
                  },
                  controlsBuilder:
                      (BuildContext context, ControlsDetails details) {
                    final isLastStep = _currentStep == 4;
                    return Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: CareFlowNeonButton(
                              text: isLastStep
                                  ? "Confirm Appointment"
                                  : "Continue",
                              height: 44,
                              onPressed: details.onStepContinue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: details.onStepCancel,
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: AppTheme.borderCol),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text('Back',
                                  style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  steps: [
                    Step(
                      title: const Text('Select City',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold)),
                      content: CareFlowGlassCard(
                        padding: const EdgeInsets.all(16),
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          dropdownColor: AppTheme.backgroundCard,
                          initialValue: _selectedCity,
                          hint: const Text('Choose a city',
                              style: TextStyle(color: AppTheme.textSecondary)),
                          items: uniqueCities
                              .map((city) => DropdownMenuItem(
                                  value: city,
                                  child: Text(city,
                                      style: const TextStyle(
                                          color: AppTheme.textPrimary))))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCity = val;
                              _selectedHospitalId = null;
                              _selectedCategory = null;
                              _selectedDoctorId = null;
                            });
                          },
                        ),
                      ),
                      isActive: _currentStep >= 0,
                    ),
                    Step(
                      title: const Text('Select Hospital',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold)),
                      content: CareFlowGlassCard(
                        padding: const EdgeInsets.all(16),
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          dropdownColor: AppTheme.backgroundCard,
                          initialValue: _selectedHospitalId,
                          hint: const Text('Choose a hospital',
                              style: TextStyle(color: AppTheme.textSecondary)),
                          items: _hospitals
                              .where((doc) =>
                                  (doc.data()
                                      as Map<String, dynamic>)['city'] ==
                                  _selectedCity)
                              .map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final hospitalName =
                                data['hospitalName'] ?? 'Unknown';
                            final area = data['area']?.toString().trim() ?? '';
                            final address =
                                data['address']?.toString().trim() ?? '';
                            final locationInfo =
                                area.isNotEmpty ? area : address;
                            final displayStr = locationInfo.isNotEmpty
                                ? "$hospitalName ($locationInfo)"
                                : hospitalName;
                            return DropdownMenuItem(
                              value: doc.id,
                              child: Text(displayStr,
                                  style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            final selectedHospDoc =
                                _hospitals.firstWhere((doc) => doc.id == val);
                            setState(() {
                              _selectedHospitalId = val;
                              final data = selectedHospDoc.data()
                                  as Map<String, dynamic>?;
                              _selectedHospitalName =
                                  data?['hospitalName']?.toString() ??
                                      'Unknown Hospital';
                              _selectedHospitalArea = data?['area']?.toString();
                              _selectedCategory = null;
                              _selectedDoctorId = null;
                              _doctors = [];
                            });
                          },
                        ),
                      ),
                      isActive: _currentStep >= 1,
                    ),
                    Step(
                      title: const Text('Select Category / Specialty',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold)),
                      content: CareFlowGlassCard(
                        padding: const EdgeInsets.all(16),
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          dropdownColor: AppTheme.backgroundCard,
                          initialValue: _selectedCategory,
                          hint: const Text('Choose specialty',
                              style: TextStyle(color: AppTheme.textSecondary)),
                          items: AppConstants.specializations
                              .map((spec) => DropdownMenuItem(
                                  value: spec,
                                  child: Text(spec,
                                      style: const TextStyle(
                                          color: AppTheme.textPrimary))))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCategory = val;
                              _selectedDoctorId = null;
                              _doctors = [];
                            });
                          },
                        ),
                      ),
                      isActive: _currentStep >= 2,
                    ),
                    Step(
                      title: const Text('Select Doctor',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold)),
                      content: CareFlowGlassCard(
                        padding: const EdgeInsets.all(16),
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          dropdownColor: AppTheme.backgroundCard,
                          initialValue: _selectedDoctorId,
                          hint: const Text('Choose doctor',
                              style: TextStyle(color: AppTheme.textSecondary)),
                          items: _doctors.map((doc) {
                            final data = doc.data() as Map<String, dynamic>?;
                            final name = data?['name']?.toString() ?? 'Unknown';
                            return DropdownMenuItem(
                              value: doc.id,
                              child: Text("Dr. $name",
                                  style: const TextStyle(
                                      color: AppTheme.textPrimary)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            final selectedDoc =
                                _doctors.firstWhere((doc) => doc.id == val);
                            setState(() {
                              _selectedDoctorId = val;
                              final data =
                                  selectedDoc.data() as Map<String, dynamic>?;
                              _selectedDoctorName =
                                  data?['name']?.toString() ?? 'Unknown Doctor';
                            });
                          },
                        ),
                      ),
                      isActive: _currentStep >= 3,
                    ),
                    Step(
                      title: const Text('Select Date & Time Slot',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold)),
                      content: CareFlowGlassCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.calendar_today,
                                  color: AppTheme.background),
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 30)),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.dark(
                                          primary: AppTheme.primaryNeon,
                                          onPrimary: AppTheme.background,
                                          surface: AppTheme.backgroundCard,
                                          onSurface: AppTheme.textPrimary,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (date != null) {
                                  setState(() => _selectedDate = date);
                                }
                              },
                              label: Text(_selectedDate == null
                                  ? 'Pick a Date'
                                  : '${_selectedDate!.toLocal()}'
                                      .split(' ')[0]),
                            ),
                            const SizedBox(height: 18),
                            if (_selectedDate != null)
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Available Time Slot',
                                  prefixIcon: Icon(Icons.access_time),
                                ),
                                dropdownColor: AppTheme.backgroundCard,
                                initialValue: _selectedSlotTime,
                                hint: const Text('Choose Time Slot',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary)),
                                items: const [
                                  DropdownMenuItem(
                                      value: '10:00 AM',
                                      child: Text('10:00 AM',
                                          style: TextStyle(
                                              color: AppTheme.textPrimary))),
                                  DropdownMenuItem(
                                      value: '10:30 AM',
                                      child: Text('10:30 AM',
                                          style: TextStyle(
                                              color: AppTheme.textPrimary))),
                                  DropdownMenuItem(
                                      value: '11:00 AM',
                                      child: Text('11:00 AM',
                                          style: TextStyle(
                                              color: AppTheme.textPrimary))),
                                  DropdownMenuItem(
                                      value: '11:30 AM',
                                      child: Text('11:30 AM',
                                          style: TextStyle(
                                              color: AppTheme.textPrimary))),
                                  DropdownMenuItem(
                                      value: '04:00 PM',
                                      child: Text('04:00 PM',
                                          style: TextStyle(
                                              color: AppTheme.textPrimary))),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _selectedSlotTime = val;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                      isActive: _currentStep >= 4,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
