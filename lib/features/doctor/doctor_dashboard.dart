import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../chat/chat_list_tab.dart';
import '../profile/profile_tab.dart';
import '../../core/widgets/careflow_appointment_card.dart';
import '../../core/widgets/careflow_empty_state.dart';
import '../../core/widgets/careflow_loading_view.dart';
import '../../core/widgets/careflow_lab_report_card.dart';
import '../../core/widgets/careflow_dark_shell.dart';
import '../../core/widgets/careflow_sidebar.dart';
import '../../core/widgets/careflow_metric_card.dart';
import '../../core/widgets/careflow_dashboard_chart.dart';
import '../../core/widgets/careflow_glass_card.dart';

class DoctorDashboard extends ConsumerStatefulWidget {
  const DoctorDashboard({super.key});

  @override
  ConsumerState<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends ConsumerState<DoctorDashboard>
    with SingleTickerProviderStateMixin {
  String _userName = 'Doctor';

  String get _doctorId => FirebaseAuth.instance.currentUser?.uid ?? 'd1';
  int _selectedIndex = 0;
  late TabController _mobileTabController;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _mobileTabController = TabController(length: 5, vsync: this);
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
            _userName = doc.data()?['name'] ?? 'Doctor';
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
      _buildPatientQueue(),
      _buildHistory(),
      _buildLabResults(),
      const ChatListTab(),
      const ProfileTab(),
    ];

    final sidebarItems = [
      CareFlowSidebarItem(
        icon: Icons.people,
        label: 'Patient Queue',
        route: '0',
        onTap: () => _onMenuSelected(0),
      ),
      CareFlowSidebarItem(
        icon: Icons.history,
        label: 'Consultation History',
        route: '1',
        onTap: () => _onMenuSelected(1),
      ),
      CareFlowSidebarItem(
        icon: Icons.science,
        label: 'Lab Reports',
        route: '2',
        onTap: () => _onMenuSelected(2),
      ),
      CareFlowSidebarItem(
        icon: Icons.chat,
        label: 'Patient Chats',
        route: '3',
        onTap: () => _onMenuSelected(3),
      ),
      CareFlowSidebarItem(
        icon: Icons.person,
        label: 'My Profile',
        route: '4',
        onTap: () => _onMenuSelected(4),
      ),
    ];

    String title = 'Doctor Portal';
    if (_selectedIndex == 0) title = 'Patient Queue';
    if (_selectedIndex == 1) title = 'Consultation History';
    if (_selectedIndex == 2) title = 'Lab Diagnostic Logs';
    if (_selectedIndex == 3) title = 'Patient Conversations';
    if (_selectedIndex == 4) title = 'Doctor Profile';

    return CareFlowDarkShell(
      userName: _userName,
      userRole: 'Doctor',
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
                indicatorColor: AppTheme.primaryNeon,
                labelColor: AppTheme.primaryNeon,
                unselectedLabelColor: AppTheme.textSecondary,
                tabs: const [
                  Tab(icon: Icon(Icons.people, size: 20)),
                  Tab(icon: Icon(Icons.history, size: 20)),
                  Tab(icon: Icon(Icons.science, size: 20)),
                  Tab(icon: Icon(Icons.chat, size: 20)),
                  Tab(icon: Icon(Icons.person, size: 20)),
                ],
              ),
            )
          : null,
      body: tabs[_selectedIndex],
    );
  }

  Widget _buildPatientQueue() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: _doctorId)
          .snapshots(),
      builder: (context, snapshot) {
        int queueCount = 0;
        int completedCount = 0;
        List<DocumentSnapshot> activeDocs = [];

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'pending';
            if (status == 'accepted') {
              queueCount++;
              activeDocs.add(doc);
            } else if (status == 'completed') {
              completedCount++;
            }
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Statistics Row
              Row(
                children: [
                  Expanded(
                    child: CareFlowMetricCard(
                      title: 'Waiting Queue',
                      value: '$queueCount',
                      icon: Icons.people_outline,
                      accentColor: AppTheme.cyanAccent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CareFlowMetricCard(
                      title: 'Consultations Done',
                      value: '$completedCount',
                      icon: Icons.check_circle_outline,
                      accentColor: AppTheme.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Layout grid of queue and activity chart
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 750;
                  final contentWidgets = [
                    // Queue List
                    Expanded(
                      flex: isWide ? 4 : 1,
                      child: CareFlowGlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Next Patients in Line',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary),
                                ),
                                Icon(Icons.hourglass_bottom,
                                    color: AppTheme.cyanAccent, size: 20),
                              ],
                            ),
                            const Divider(
                                color: AppTheme.borderCol, height: 24),
                            if (activeDocs.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.0),
                                child: Center(
                                  child: Text(
                                    'No pending appointments in queue.',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: activeDocs.length,
                                itemBuilder: (context, index) {
                                  final doc = activeDocs[index];
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  return CareFlowAppointmentCard(
                                    patientName:
                                        data['patientName'] ?? 'Unknown',
                                    doctorName: 'Me',
                                    department: data['department'] ?? 'General',
                                    date: data['date'] ?? 'Today',
                                    timeSlot: data['slotTime'] ?? 'N/A',
                                    tokenNumber: data['tokenNumber'],
                                    status: data['status'] ?? 'accepted',
                                    onStartConsultation: () {
                                      context
                                          .push('/doctor/prescription', extra: {
                                        'appointmentId': doc.id,
                                        'patientName': data['patientName'],
                                      });
                                    },
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),

                    if (isWide) const SizedBox(width: 20),

                    // Consultation Activity Chart
                    Expanded(
                      flex: isWide ? 3 : 1,
                      child: const CareFlowDashboardChart(
                        data: [12, 19, 15, 23, 18, 28, 30],
                        labels: [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ],
                      ),
                    ),
                  ];

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: contentWidgets,
                    );
                  } else {
                    return Column(
                      children: [
                        contentWidgets[0], // Queue List
                        const SizedBox(height: 20),
                        const SizedBox(
                          height: 280,
                          child: CareFlowDashboardChart(
                            data: [12, 19, 15, 23, 18, 28, 30],
                            labels: [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun'
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistory() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: _doctorId)
          .where('status', isEqualTo: 'completed')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CareFlowLoadingView();

        final list = snapshot.data!.docs;
        if (list.isEmpty) {
          return const CareFlowEmptyState(
            title: 'No History',
            message: 'No completed appointments recorded.',
            icon: Icons.history,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final doc = list[index];
            final data = doc.data() as Map<String, dynamic>;

            return Stack(
              children: [
                CareFlowAppointmentCard(
                  patientName: data['patientName'] ?? 'Unknown Patient',
                  doctorName: 'Me',
                  department: data['department'] ?? 'General',
                  date: data['date'] ?? today,
                  timeSlot: data['slotTime'] ?? 'N/A',
                  tokenNumber: data['tokenNumber'],
                  status: 'completed',
                ),
                Positioned(
                  top: 60,
                  right: 18,
                  child: IconButton(
                    icon:
                        const Icon(Icons.delete_outline, color: AppTheme.error),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppTheme.backgroundCard,
                          title: const Text('Delete Log',
                              style: TextStyle(color: AppTheme.textPrimary)),
                          content: const Text(
                              'Are you sure you want to delete this consultation log?',
                              style: TextStyle(color: AppTheme.textSecondary)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Cancel',
                                  style:
                                      TextStyle(color: AppTheme.textSecondary)),
                            ),
                            TextButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('appointments')
                                    .doc(doc.id)
                                    .delete();
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Appointment deleted.')));
                              },
                              child: const Text('Delete',
                                  style: TextStyle(
                                      color: AppTheme.error,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLabResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('lab_requests')
          .where('doctorId', isEqualTo: _doctorId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CareFlowLoadingView();

        final list = snapshot.data!.docs;
        if (list.isEmpty) {
          return const CareFlowEmptyState(
            title: 'No Diagnostic Logs',
            message: 'You have no requested or completed lab tests.',
            icon: Icons.science_outlined,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final doc = list[index];
            final data = doc.data() as Map<String, dynamic>;
            final date = (data['createdAt'] as Timestamp?)
                    ?.toDate()
                    .toString()
                    .split(' ')[0] ??
                'N/A';
            return CareFlowLabReportCard(
              testName: data['testType'] ?? 'Blood Test',
              patientName: data['patientName'] ?? 'Unknown Patient',
              doctorName: 'Me',
              status: data['status'] ?? 'pending',
              requestedDate: date,
            );
          },
        );
      },
    );
  }
}
