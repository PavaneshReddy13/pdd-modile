import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/careflow_lab_report_card.dart';
import '../../core/widgets/careflow_empty_state.dart';
import '../../core/widgets/careflow_loading_view.dart';
import '../../core/widgets/careflow_neon_background.dart';

class PatientLabReportsScreen extends StatelessWidget {
  const PatientLabReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Lab Reports', style: TextStyle(color: AppTheme.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryNeon),
      ),
      body: CareFlowNeonBackground(
        showGrid: true,
        showOrb: false,
        child: user == null
            ? const Center(child: Text("Not Logged In", style: TextStyle(color: AppTheme.textSecondary)))
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('lab_reports')
                    .where('patientId', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CareFlowLoadingView();
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const CareFlowEmptyState(
                      title: "No Lab Reports",
                      message: "You have no lab reports available at the moment.",
                      icon: Icons.science_outlined,
                    );
                  }
                  final reports = snapshot.data!.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final data = reports[index].data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CareFlowLabReportCard(
                          testName: data['testName'] ?? 'Unknown Test',
                          patientName: data['patientName'] ?? 'Patient',
                          doctorName: data['doctorName'] ?? 'Doctor',
                          requestedDate: data['date'] ?? 'Unknown Date',
                          status: data['status'] ?? 'pending',
                          onViewReport: () {
                            if (data['reportUrl'] != null && data['reportUrl'].toString().isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report ready to download.')));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report document not attached yet.')));
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
