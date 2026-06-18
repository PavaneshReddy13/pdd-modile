import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/careflow_dark_shell.dart';
import '../../core/widgets/careflow_sidebar.dart';
import '../../core/widgets/careflow_glass_card.dart';
import '../../core/widgets/careflow_metric_card.dart';
import '../../core/widgets/careflow_approval_card.dart';

class HospitalAdminDashboard extends StatefulWidget {
  const HospitalAdminDashboard({super.key});

  @override
  State<HospitalAdminDashboard> createState() => _HospitalAdminDashboardState();
}

class _HospitalAdminDashboardState extends State<HospitalAdminDashboard>
    with SingleTickerProviderStateMixin {
  String _userName = 'Hospital Admin';

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;
  late TabController _mobileTabController;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _mobileTabController = TabController(length: 2, vsync: this);
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
            _userName = doc.data()?['name'] ?? 'Hospital Admin';
          });
        }
      } catch (e) {
        debugPrint("Error fetching name: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(
          child: Text("Not Logged In",
              style: TextStyle(color: AppTheme.textSecondary)));
    }

    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final sidebarItems = [
      CareFlowSidebarItem(
        icon: Icons.verified_user_outlined,
        label: 'Staff Requests',
        route: '0',
        onTap: () => _onMenuSelected(0),
      ),
      CareFlowSidebarItem(
        icon: Icons.people_outline,
        label: 'Employees List',
        route: '1',
        onTap: () => _onMenuSelected(1),
      ),
    ];

    String title = 'Hospital Admin Portal';
    if (_selectedIndex == 0) title = 'Staff Requests Console';
    if (_selectedIndex == 1) title = 'Employees Roster';

    return CareFlowDarkShell(
      userName: _userName,
      userRole: 'Hospital Admin',
      items: sidebarItems,
      currentRoute: '$_selectedIndex',
      onLogout: () async {
        await _auth.signOut();
        if (context.mounted) context.go('/role-select');
      },
      title: title,
      showSearch: false,
      bottomNavigationBar: !isDesktop
          ? Container(
              color: AppTheme.backgroundLight,
              child: TabBar(
                controller: _mobileTabController,
                indicatorColor: AppTheme.secondaryGreen,
                labelColor: AppTheme.secondaryGreen,
                unselectedLabelColor: AppTheme.textSecondary,
                tabs: const [
                  Tab(icon: Icon(Icons.verified_user, size: 20)),
                  Tab(icon: Icon(Icons.people, size: 20)),
                ],
              ),
            )
          : null,
      body: _selectedIndex == 0
          ? _buildStaffRequests(user.uid)
          : _buildEmployeesList(user.uid),
    );
  }

  Widget _buildStaffRequests(String adminUid) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('staffRequests')
          .doc(adminUid)
          .collection('requests')
          .snapshots(),
      builder: (context, snapshot) {
        int pendingCount = 0;
        List<DocumentSnapshot> pendingList = [];

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'pending';
            if (status == 'pending') {
              pendingCount++;
              pendingList.add(doc);
            }
          }
        }

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CareFlowMetricCard(
                      title: 'Pending Staff Requests',
                      value: '$pendingCount',
                      icon: Icons.hourglass_top,
                      accentColor: AppTheme.secondaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: CareFlowGlassCard(
                  borderColor: AppTheme.secondaryGreen.withValues(alpha: 0.2),
                  glowColor: AppTheme.secondaryGreen,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Incoming Approvals Requests',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary),
                          ),
                          Icon(Icons.verified_user_outlined,
                              color: AppTheme.secondaryGreen, size: 20),
                        ],
                      ),
                      const Divider(color: AppTheme.borderCol, height: 24),
                      Expanded(
                        child: pendingList.isEmpty
                            ? const Center(
                                child: Text(
                                  'There are no pending staff requests.',
                                  style:
                                      TextStyle(color: AppTheme.textSecondary),
                                ),
                              )
                            : ListView.builder(
                                itemCount: pendingList.length,
                                itemBuilder: (context, index) {
                                  final doc = pendingList[index];
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final uid = data['uid'];

                                  return CareFlowApprovalCard(
                                    userName: data['name'] ?? 'No Name',
                                    email: data['email'] ?? 'N/A',
                                    phone: '',
                                    roleTitle: data['role'] ?? 'Staff',
                                    hospitalInfo: '',
                                    status: data['status'] ?? 'pending',
                                    onApprove: () async {
                                      await _firestore
                                          .collection('staffRequests')
                                          .doc(adminUid)
                                          .collection('requests')
                                          .doc(doc.id)
                                          .update({'status': 'approved'});
                                      await _firestore
                                          .collection('users')
                                          .doc(uid)
                                          .update({'status': 'approved'});
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text('Approved!')));
                                      }
                                    },
                                    onReject: () async {
                                      await _firestore
                                          .collection('staffRequests')
                                          .doc(adminUid)
                                          .collection('requests')
                                          .doc(doc.id)
                                          .update({'status': 'rejected'});
                                      await _firestore
                                          .collection('users')
                                          .doc(uid)
                                          .update({'status': 'rejected'});
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
  }

  Widget _buildEmployeesList(String adminUid) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .where('hospitalId', isEqualTo: adminUid)
          .where('status', isEqualTo: 'approved')
          .snapshots(),
      builder: (context, snapshot) {
        int employeeCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CareFlowMetricCard(
                      title: 'Active Employees',
                      value: '$employeeCount',
                      icon: Icons.people_outline,
                      accentColor: AppTheme.primaryNeon,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: CareFlowGlassCard(
                  borderColor: AppTheme.primaryNeon.withValues(alpha: 0.2),
                  glowColor: AppTheme.primaryNeon,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Assigned Hospital Employees',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary),
                          ),
                          Icon(Icons.people_alt_outlined,
                              color: AppTheme.primaryNeon, size: 20),
                        ],
                      ),
                      const Divider(color: AppTheme.borderCol, height: 24),
                      Expanded(
                        child: (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty)
                            ? const Center(
                                child: Text(
                                  'No employees registered yet.',
                                  style:
                                      TextStyle(color: AppTheme.textSecondary),
                                ),
                              )
                            : ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  final data = snapshot.data!.docs[index].data()
                                      as Map<String, dynamic>;
                                  return CareFlowApprovalCard(
                                    userName: data['name'] ?? 'No Name',
                                    email: data['email'] ?? 'N/A',
                                    phone: data['phone'] ?? '',
                                    roleTitle: data['role'] ?? 'Staff',
                                    hospitalInfo: '',
                                    status: 'approved',
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
  }
}
