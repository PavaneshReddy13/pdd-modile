import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/careflow_appointment_card.dart';
import '../../../core/widgets/careflow_empty_state.dart';
import '../../../core/widgets/careflow_loading_view.dart';
import '../widgets/patient_dashboard_header.dart';
import '../widgets/patient_search_bar.dart';
import '../widgets/health_summary_section.dart';
import '../widgets/quick_action_grid.dart';
import '../widgets/ai_analyzer_card.dart';
import '../emergency_module.dart';

class HomeTab extends StatelessWidget {
  final ValueChanged<int>? onNavigateTab;
  const HomeTab({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
        child: Text("Not logged in",
            style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (context, snapshot) {
                String name = 'Patient';
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.data() != null) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  name = data['name'] ?? 'Patient';
                }
                return PatientDashboardHeader(
                  patientName: name,
                  onNotificationTap: () {},
                );
              }),
          const SizedBox(height: 24),
          const PatientSearchBar(),
          const SizedBox(height: 24),
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('patientId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                int upcomingCount = 0;
                int completedCount = 0;
                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'];
                    if (status == 'accepted') upcomingCount++;
                    if (status == 'completed') completedCount++;
                  }
                }
                return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('prescriptions')
                        .where('patientId', isEqualTo: user.uid)
                        .snapshots(),
                    builder: (context, medSnapshot) {
                      int medsCount = 0;
                      if (medSnapshot.hasData) {
                        for (var doc in medSnapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final meds = data['medicines'] as List<dynamic>?;
                          medsCount += meds?.length ?? 0;
                        }
                      }
                      return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('lab_reports')
                              .where('patientId', isEqualTo: user.uid)
                              .snapshots(),
                          builder: (context, labSnapshot) {
                            int reportsCount = labSnapshot.hasData
                                ? labSnapshot.data!.docs.length
                                : 0;
                            return HealthSummarySection(
                              upcomingAppointments: upcomingCount,
                              activeMedicines: medsCount,
                              pendingReports: reportsCount,
                              completedVisits: completedCount,
                            );
                          });
                    });
              }),
          const SizedBox(height: 32),
          const Text(
            "Quick Actions",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 16),
          QuickActionGrid(
            actions: [
              QuickActionItem(
                title: "Book Appt",
                icon: Icons.calendar_month_rounded,
                color: AppTheme.primaryNeon,
                onTap: () => context.push('/patient/book_appointment'),
              ),
              QuickActionItem(
                title: "My Appts",
                icon: Icons.list_alt_rounded,
                color: AppTheme.cyanAccent,
                onTap: () {
                  if (onNavigateTab != null) onNavigateTab!(1);
                },
              ),
              QuickActionItem(
                title: "Medicines",
                icon: Icons.medication_rounded,
                color: AppTheme.secondaryGreen,
                onTap: () {
                  if (onNavigateTab != null) onNavigateTab!(2);
                },
              ),
              QuickActionItem(
                title: "AI Analyzer",
                icon: Icons.psychology_rounded,
                color: const Color(0xFFB140FF),
                onTap: () => context.push('/patient/ai_symptoms'),
              ),
              QuickActionItem(
                title: "Lab Reports",
                icon: Icons.science_rounded,
                color: AppTheme.warning,
                onTap: () => context.push('/patient/lab_reports'),
              ),
              QuickActionItem(
                title: "Prescriptions",
                icon: Icons.receipt_long_rounded,
                color: Colors.blueAccent,
                onTap: () {
                  if (onNavigateTab != null) onNavigateTab!(2);
                },
              ),
              QuickActionItem(
                title: "Profile",
                icon: Icons.person_rounded,
                color: Colors.tealAccent,
                onTap: () {
                  if (onNavigateTab != null) onNavigateTab!(4);
                },
              ),
              QuickActionItem(
                title: "Emergency",
                icon: Icons.emergency_rounded,
                color: AppTheme.error,
                onTap: () => EmergencyModule.showEmergencyOptions(context),
              ),
            ],
          ),
          const SizedBox(height: 32),
          AIAnalyzerCard(
            onTap: () => context.push('/patient/ai_symptoms'),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Upcoming Appointment",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
              ),
              TextButton(
                onPressed: () {},
                child: const Text("See All",
                    style: TextStyle(
                        color: AppTheme.primaryNeon,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('patientId', isEqualTo: user.uid)
                  .where('status', isEqualTo: 'accepted')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CareFlowLoadingView();
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const CareFlowEmptyState(
                    title: "No upcoming appointments",
                    message: "You have no scheduled appointments.",
                    icon: Icons.calendar_today_outlined,
                  );
                }
                final doc = snapshot.data!.docs.first;
                final data = doc.data() as Map<String, dynamic>;
                return CareFlowAppointmentCard(
                  patientName: data['patientName'] ?? 'Unknown',
                  doctorName: data['doctorName'] ?? 'Unknown Doctor',
                  department: data['department'] ?? 'General',
                  date: data['date'] ?? 'Upcoming',
                  timeSlot: data['slotTime'] ?? 'TBD',
                  tokenNumber: data['tokenNumber'],
                  status: data['status'] ?? 'Scheduled',
                );
              }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
