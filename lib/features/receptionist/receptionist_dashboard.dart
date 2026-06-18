import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../chat/chat_list_tab.dart';
import '../profile/profile_tab.dart';
import '../../core/widgets/careflow_dark_shell.dart';
import '../../core/widgets/careflow_sidebar.dart';
import '../../core/widgets/careflow_glass_card.dart';
import '../../core/widgets/careflow_metric_card.dart';
import '../../core/widgets/careflow_appointment_card.dart';
import '../../core/widgets/careflow_empty_state.dart';
import '../../core/widgets/careflow_loading_view.dart';

class ReceptionistDashboard extends ConsumerStatefulWidget {
  const ReceptionistDashboard({super.key});

  @override
  ConsumerState<ReceptionistDashboard> createState() =>
      _ReceptionistDashboardState();
}

class _ReceptionistDashboardState extends ConsumerState<ReceptionistDashboard>
    with SingleTickerProviderStateMixin {
  String _userName = 'Receptionist';

  int _selectedIndex = 0;
  late TabController _mobileTabController;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _mobileTabController = TabController(length: 3, vsync: this);
    _mobileTabController.addListener(() {
      if (!_mobileTabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _mobileTabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _mobileTabController.dispose();
    super.dispose();
  }

  void _onMenuSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _mobileTabController.index = index;
    });
  }

  Future<void> _fetchUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists && mounted) {
          setState(() {
            _userName = doc.data()?['name'] ?? 'Receptionist';
          });
        }
      } catch (e) {
        debugPrint("Error fetching name: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final List<Widget> tabs = [
      _buildPendingAppointments(),
      const ChatListTab(),
      const ProfileTab(),
    ];

    final sidebarItems = [
      CareFlowSidebarItem(
        icon: Icons.confirmation_number_outlined,
        label: 'OP Registration',
        route: '0',
        onTap: () => _onMenuSelected(0),
      ),
      CareFlowSidebarItem(
        icon: Icons.chat_bubble_outline,
        label: 'Patient Chats',
        route: '1',
        onTap: () => _onMenuSelected(1),
      ),
      CareFlowSidebarItem(
        icon: Icons.person_outline,
        label: 'Profile',
        route: '2',
        onTap: () => _onMenuSelected(2),
      ),
    ];

    String title = 'Receptionist Dashboard';
    if (_selectedIndex == 0) title = 'OP Queue Manager';
    if (_selectedIndex == 1) title = 'Patient Channels';
    if (_selectedIndex == 2) title = 'My Profile';

    return CareFlowDarkShell(
      userName: _userName,
      userRole: 'Receptionist',
      items: sidebarItems,
      currentRoute: '$_selectedIndex',
      onLogout: () async {
        await ref.read(authServiceProvider).signOut();
        if (context.mounted) context.go('/role-select');
      },
      title: title,
      showSearch: _selectedIndex == 0,
      bottomNavigationBar: !isDesktop
          ? Container(
              color: AppTheme.backgroundLight,
              child: TabBar(
                controller: _mobileTabController,
                indicatorColor: Colors.pinkAccent,
                labelColor: Colors.pinkAccent,
                unselectedLabelColor: AppTheme.textSecondary,
                tabs: const [
                  Tab(icon: Icon(Icons.confirmation_number, size: 20)),
                  Tab(icon: Icon(Icons.chat_bubble, size: 20)),
                  Tab(icon: Icon(Icons.person, size: 20)),
                ],
              ),
            )
          : null,
      body: tabs[_selectedIndex],
    );
  }

  Widget _buildPendingAppointments() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return const Center(
          child: Text("Not Logged In",
              style: TextStyle(color: AppTheme.textSecondary)));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) return const CareFlowLoadingView();
        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
        final hospitalId = userData?['hospitalId'];

        if (hospitalId == null) {
          return const CareFlowEmptyState(
            title: 'No Hospital Assigned',
            message: 'You have not been assigned to a hospital.',
            icon: Icons.local_hospital_outlined,
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('appointments')
              .where('hospitalId', isEqualTo: hospitalId)
              .snapshots(),
          builder: (context, snapshot) {
            int pendingCount = 0;
            int acceptedCount = 0;
            List<DocumentSnapshot> pendingList = [];

            if (snapshot.hasData) {
              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final status = data['status'] ?? 'pending';
                if (status == 'pending') {
                  pendingCount++;
                  pendingList.add(doc);
                } else if (status == 'accepted') {
                  acceptedCount++;
                }
              }
            }

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top metric stats
                  Row(
                    children: [
                      Expanded(
                        child: CareFlowMetricCard(
                          title: 'Pending Approvals',
                          value: '$pendingCount',
                          icon: Icons.hourglass_top,
                          accentColor: Colors.pinkAccent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CareFlowMetricCard(
                          title: 'Active Consultations',
                          value: '$acceptedCount',
                          icon: Icons.medical_services_outlined,
                          accentColor: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Pending Queue list
                  Expanded(
                    child: CareFlowGlassCard(
                      borderColor: Colors.pinkAccent.withValues(alpha: 0.2),
                      glowColor: Colors.pinkAccent,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pending Booking Requests',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary),
                              ),
                              Icon(Icons.confirmation_number_outlined,
                                  color: Colors.pinkAccent, size: 20),
                            ],
                          ),
                          const Divider(color: AppTheme.borderCol, height: 24),
                          Expanded(
                            child: pendingList.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No pending booking requests.',
                                      style: TextStyle(
                                          color: AppTheme.textSecondary),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: pendingList.length,
                                    itemBuilder: (context, index) {
                                      final doc = pendingList[index];
                                      final data =
                                          doc.data() as Map<String, dynamic>;

                                      return CareFlowAppointmentCard(
                                        patientName:
                                            data['patientName'] ?? 'Unknown',
                                        doctorName:
                                            data['doctorName'] ?? 'Unknown',
                                        department:
                                            data['department'] ?? 'General',
                                        date: data['date'] ?? 'N/A',
                                        timeSlot: data['slotTime'] ?? 'N/A',
                                        tokenNumber: data['tokenNumber'],
                                        status: data['status'] ?? 'pending',
                                        onAccept: () {
                                          FirebaseFirestore.instance
                                              .collection('appointments')
                                              .doc(doc.id)
                                              .update({'status': 'accepted'});
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Appointment Accepted')));
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
