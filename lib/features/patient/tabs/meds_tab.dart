import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/prescription_model.dart';
import '../../../core/widgets/careflow_medicine_card.dart';
import '../../../core/widgets/careflow_empty_state.dart';
import '../../../core/widgets/careflow_loading_view.dart';
import '../../../core/widgets/careflow_glass_card.dart';
import '../../../core/theme/app_theme.dart';

class MedsTab extends StatelessWidget {
  const MedsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
          child: Text("Not Logged In",
              style: TextStyle(color: AppTheme.textSecondary)));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Smart Reminder',
          style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 22),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
            child: CareFlowGlassCard(
              borderColor: AppTheme.cyanAccent.withValues(alpha: 0.2),
              glowColor: AppTheme.cyanAccent,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Medication Adherence',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          child: LinearProgressIndicator(
                            value: 0.85,
                            backgroundColor: Color(0x1AFFFFFF),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryNeon),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '85% Taken',
                        style: TextStyle(
                            color: AppTheme.primaryNeon,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('prescriptions')
                  .where('patientId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CareFlowLoadingView();
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const CareFlowEmptyState(
                    title: 'No Active Prescriptions',
                    message:
                        'You have no active prescriptions or medicine reminders at the moment.',
                    icon: Icons.medication_outlined,
                  );
                }

                final docs = snapshot.data!.docs;
                final List<Map<String, dynamic>> allMeds = [];
                for (var doc in docs) {
                  final prescription = PrescriptionModel.fromMap(
                      doc.data() as Map<String, dynamic>, doc.id);
                  for (var m in prescription.medicines) {
                    allMeds.add({
                      'prescriptionId': doc.id,
                      'med': m,
                      'doctorId': prescription.doctorId,
                    });
                  }
                }

                if (allMeds.isEmpty) {
                  return const CareFlowEmptyState(
                    title: 'No Medicines Found',
                    message: 'Your prescriptions do not contain any medicines.',
                    icon: Icons.medication_outlined,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: allMeds.length,
                  itemBuilder: (context, index) {
                    final item = allMeds[index];
                    final medMap = item['med'] as Map<String, dynamic>;

                    final name = medMap['medicineName'] ??
                        medMap['name'] ??
                        'Unknown Medicine';
                    final dosage = medMap['dosage'] ?? 'Unknown Dosage';
                    final timesRaw = medMap['times'] as List<dynamic>? ?? [];
                    final List<String> timesList =
                        timesRaw.map((e) => e.toString()).toList();
                    if (timesList.isEmpty) timesList.add('08:00 AM');
                    final duration = medMap['durationDays']?.toString() ?? '7';
                    final frequency = medMap['frequency'] ?? 'Daily';
                    final instructions = medMap['instructions'] ?? '';

                    return CareFlowMedicineCard(
                      medicineName: name,
                      dosage: dosage,
                      frequency: frequency,
                      times: timesList,
                      duration: duration,
                      instructions: instructions,
                      remainingDays: int.tryParse(duration),
                      onMarkTaken: () {
                        _markAdherence(item['prescriptionId'], name, true);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Marked $name as taken')));
                      },
                      onSkipDose: () {
                        _markAdherence(item['prescriptionId'], name, false);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Skipped $name dose')));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _markAdherence(
      String prescriptionId, String medicineName, bool taken) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('medicine_reminders').add({
        'patientId': user.uid,
        'prescriptionId': prescriptionId,
        'medicineName': medicineName,
        'taken': taken,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error storing adherence: $e");
    }
  }
}
