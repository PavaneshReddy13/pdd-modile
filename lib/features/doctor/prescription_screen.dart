import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/careflow_scaffold.dart';
import '../../core/widgets/careflow_glass_card.dart';
import '../../core/widgets/careflow_neon_button.dart';

class PrescriptionScreen extends StatefulWidget {
  final String appointmentId;
  final String patientName;

  const PrescriptionScreen({
    super.key,
    required this.appointmentId,
    required this.patientName,
  });

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final _symptomsController = TextEditingController();

  // List to hold multiple medicine entries
  final List<Map<String, TextEditingController>> _medicines = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addMedicineField();
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    for (var med in _medicines) {
      med['name']!.dispose();
      med['dosage']!.dispose();
      med['frequency']!.dispose();
      med['times']!.dispose();
      med['durationDays']!.dispose();
      med['instructions']!.dispose();
    }
    super.dispose();
  }

  void _addMedicineField() {
    setState(() {
      _medicines.add({
        'name': TextEditingController(),
        'dosage': TextEditingController(),
        'frequency': TextEditingController(),
        'times': TextEditingController(),
        'durationDays': TextEditingController(),
        'instructions': TextEditingController(),
      });
    });
  }

  void _removeMedicineField(int index) {
    if (_medicines.length > 1) {
      setState(() {
        _medicines.removeAt(index);
      });
    }
  }

  void _submitPrescription() async {
    setState(() => _isLoading = true);

    // Process medicines
    List<Map<String, dynamic>> processedMedicines = [];
    for (var med in _medicines) {
      if (med['name']!.text.trim().isNotEmpty) {
        processedMedicines.add({
          "medicineName": med['name']!.text.trim(),
          "dosage": med['dosage']!.text.trim(),
          "frequency": med['frequency']!.text.trim(),
          "times": med['times']!
              .text
              .trim()
              .split(',')
              .map((e) => e.trim())
              .toList(),
          "durationDays": int.tryParse(med['durationDays']!.text.trim()) ?? 7,
          "instructions": med['instructions']!.text.trim()
        });
      }
    }

    try {
      final apptRef = FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentId);
      final docSnap = await apptRef.get();
      final patientId = docSnap.data()?['patientId'] ?? '';
      final doctorId = docSnap.data()?['doctorId'] ?? '';

      await apptRef.update({
        'status': 'completed',
        'prescription': {
          'symptoms': _symptomsController.text.trim(),
          'medicines': processedMedicines,
        }
      });

      // Also create a prescription document for the patient side
      await FirebaseFirestore.instance.collection('prescriptions').add({
        'patientId': patientId,
        'doctorId': doctorId,
        'appointmentId': widget.appointmentId,
        'symptoms': _symptomsController.text.trim(),
        'medicines': processedMedicines,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Prescription Generated & Appointment Completed')));
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
    return CareFlowScaffold(
      useAnimatedBackground: true,
      appBar: AppBar(
        title: Text('Prescribe: ${widget.patientName}'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Symptoms Diagnosis glass card
                CareFlowGlassCard(
                  borderColor: AppTheme.cyanAccent.withValues(alpha: 0.2),
                  glowColor: AppTheme.cyanAccent,
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.edit_note,
                              color: AppTheme.cyanAccent, size: 24),
                          SizedBox(width: 10),
                          Text('Consultation Notes',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _symptomsController,
                        maxLines: 3,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Symptoms & Diagnosis',
                          hintText:
                              'Enter patient symptoms, diagnosis details...',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Medicines glass card
                CareFlowGlassCard(
                  borderColor: AppTheme.primaryNeon.withValues(alpha: 0.2),
                  glowColor: AppTheme.primaryNeon,
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.medication,
                                  color: AppTheme.primaryNeon, size: 24),
                              SizedBox(width: 10),
                              Text('Medicines List',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary)),
                            ],
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.add,
                                color: AppTheme.primaryNeon),
                            label: const Text('Add Entry',
                                style: TextStyle(
                                    color: AppTheme.primaryNeon,
                                    fontWeight: FontWeight.bold)),
                            onPressed: _addMedicineField,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ..._medicines.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var med = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            border: Border.all(
                                color: AppTheme.borderCol, width: 1.0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Medicine #${idx + 1}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary),
                                  ),
                                  if (_medicines.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: AppTheme.error, size: 20),
                                      onPressed: () =>
                                          _removeMedicineField(idx),
                                    )
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: med['name']!,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary),
                                decoration: const InputDecoration(
                                  labelText: 'Medicine Name',
                                  hintText: 'e.g. Paracetamol 650mg',
                                  prefixIcon: Icon(Icons.medication_outlined),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: med['dosage']!,
                                      style: const TextStyle(
                                          color: AppTheme.textPrimary),
                                      decoration: const InputDecoration(
                                        labelText: 'Dosage',
                                        hintText: 'e.g. 1 Tablet',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: med['frequency']!,
                                      style: const TextStyle(
                                          color: AppTheme.textPrimary),
                                      decoration: const InputDecoration(
                                        labelText: 'Frequency',
                                        hintText: 'e.g. 1-0-1',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: med['times']!,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary),
                                decoration: const InputDecoration(
                                  labelText:
                                      'Specific Alarm Times (Comma-separated)',
                                  hintText: 'e.g. 08:00 AM, 08:00 PM',
                                  prefixIcon: Icon(Icons.access_time),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: med['durationDays']!,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                          color: AppTheme.textPrimary),
                                      decoration: const InputDecoration(
                                        labelText: 'Days Duration',
                                        hintText: 'e.g. 5',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: med['instructions']!,
                                      style: const TextStyle(
                                          color: AppTheme.textPrimary),
                                      decoration: const InputDecoration(
                                        labelText: 'Instructions',
                                        hintText: 'e.g. After food',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                CareFlowNeonButton(
                  text: 'Submit Prescription',
                  onPressed: _submitPrescription,
                  isLoading: _isLoading,
                  gradientColors: const [
                    AppTheme.cyanAccent,
                    AppTheme.primaryNeon
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
