import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tabs/home_tab.dart';
import 'tabs/appointments_tab.dart';
import 'tabs/meds_tab.dart';
import '../chat/chat_list_tab.dart';
import '../profile/profile_tab.dart';

import 'package:go_router/go_router.dart';
import '../../models/prescription_model.dart';
import '../../core/services/reminder_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/careflow_neon_background.dart';
import '../../core/widgets/careflow_bottom_nav.dart';

class PatientDashboard extends ConsumerStatefulWidget {
  const PatientDashboard({super.key});

  @override
  ConsumerState<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends ConsumerState<PatientDashboard> {
  int _currentIndex = 0;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      HomeTab(onNavigateTab: (index) {
        setState(() {
          _currentIndex = index;
        });
      }),
      const AppointmentsTab(),
      const MedsTab(),
      const ChatListTab(),
      const ProfileTab(),
    ];
    _setupReminders();
  }

  Future<void> _setupReminders() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('prescriptions')
        .where('patientId', isEqualTo: uid)
        .get();
    final prescriptions = snapshot.docs
        .map((d) => PrescriptionModel.fromMap(d.data(), d.id))
        .toList();
    if (prescriptions.isNotEmpty) {
      await ref
          .read(reminderServiceProvider)
          .scheduleAllReminders(prescriptions);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CareFlowNeonBackground(
        showGrid: true,
        showOrb: false,
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppTheme.primaryNeon),
                    onPressed: () {
                      if (_currentIndex != 0) {
                        setState(() {
                          _currentIndex = 0;
                        });
                      } else {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/role-select');
                        }
                      }
                    },
                  ),
                ],
              ),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: _tabs,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CareFlowBottomNav(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
      ),
    );
  }
}
