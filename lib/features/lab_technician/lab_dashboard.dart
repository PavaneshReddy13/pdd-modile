import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/careflow_dark_shell.dart';
import '../../core/widgets/careflow_sidebar.dart';
import '../../core/widgets/careflow_glass_card.dart';
import '../../core/widgets/careflow_metric_card.dart';

class LabTechnicianDashboard extends ConsumerStatefulWidget {
  const LabTechnicianDashboard({super.key});

  @override
  ConsumerState<LabTechnicianDashboard> createState() =>
      _LabTechnicianDashboardState();
}

class _LabTechnicianDashboardState
    extends ConsumerState<LabTechnicianDashboard> {
  String _userName = 'Lab Technician';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists && mounted) {
          setState(() {
            _userName = doc.data()?['name'] ?? 'Lab Technician';
          });
        }
      } catch (e) {
        debugPrint("Error fetching name: $e");
      }
    }
  }

  Widget _buildLabCard(BuildContext context, Map<String, dynamic> data,
      String docId, bool isPending) {
    return const Text('Upload',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12));
  }

  @override
  Widget build(BuildContext context) {
    final sidebarItems = [
      const CareFlowSidebarItem(
        icon: Icons.science,
        label: 'Lab Requests',
        route: '/lab/dashboard',
      ),
    ];

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('lab_requests').snapshots(),
      builder: (context, snapshot) {
        int totalRequests = 0;
        int pendingRequests = 0;
        int completedRequests = 0;

        List<DocumentSnapshot> pendingList = [];
        List<DocumentSnapshot> completedList = [];

        if (snapshot.hasData) {
          totalRequests = snapshot.data!.docs.length;
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'pending';
            if (status == 'pending') {
              pendingRequests++;
              pendingList.add(doc);
            } else {
              completedRequests++;
              completedList.add(doc);
            }
          }
        }

        return CareFlowDarkShell(
          userName: _userName,
          userRole: 'Lab Technician',
          items: sidebarItems,
          currentRoute: '/lab/dashboard',
          onLogout: () async {
            await ref.read(authServiceProvider).signOut();
            if (context.mounted) context.go('/role-select');
          },
          title: 'Diagnostics Workspace',
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Metrics Row
                Row(
                  children: [
                    Expanded(
                      child: CareFlowMetricCard(
                        title: 'Pending Tests',
                        value: '$pendingRequests',
                        icon: Icons.pending_actions,
                        accentColor: AppTheme.warning,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CareFlowMetricCard(
                        title: 'Completed Reports',
                        value: '$completedRequests',
                        icon: Icons.check_circle_outline,
                        accentColor: AppTheme.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CareFlowMetricCard(
                        title: 'Total Requests',
                        value: '$totalRequests',
                        icon: Icons.science_outlined,
                        accentColor: AppTheme.primaryNeon,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Active Section Selector
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Pending tests list
                      Expanded(
                        child: CareFlowGlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Pending Lab Requests',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary),
                                  ),
                                  Icon(Icons.hourglass_bottom,
                                      color: AppTheme.warning, size: 20),
                                ],
                              ),
                              const Divider(
                                  color: AppTheme.borderCol, height: 24),
                              Expanded(
                                child: pendingList.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No pending lab requests.',
                                          style: TextStyle(
                                              color: AppTheme.textSecondary),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: pendingList.length,
                                        itemBuilder: (context, index) {
                                          final doc = pendingList[index];
                                          final data = doc.data()
                                              as Map<String, dynamic>;
                                          final patient =
                                              data['patientName'] ?? 'Unknown';
                                          final test = data['testType'] ??
                                              'Unknown Test';
                                          final doctor = data['doctorName'] ??
                                              data['doctorId'] ??
                                              'Staff';

                                          return Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 12),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: AppTheme.background
                                                  .withValues(alpha: 0.3),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                  color: AppTheme.borderCol),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        test,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AppTheme
                                                                .textPrimary),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        'Patient: $patient',
                                                        style: const TextStyle(
                                                            color: AppTheme
                                                                .textSecondary,
                                                            fontSize: 12),
                                                      ),
                                                      Text(
                                                        'Dr. $doctor',
                                                        style: const TextStyle(
                                                            color: AppTheme
                                                                .textSecondary,
                                                            fontSize: 11),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppTheme.primaryNeon,
                                                    foregroundColor:
                                                        AppTheme.background,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                                  ),
                                                  onPressed: () =>
                                                      _showUploadDialog(
                                                          context, doc.id),
                                                  child: _buildLabCard(context,
                                                      data, doc.id, true),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Completed tests list
                      Expanded(
                        child: CareFlowGlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Completed Reports Archive',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary),
                                  ),
                                  Icon(Icons.verified,
                                      color: AppTheme.success, size: 20),
                                ],
                              ),
                              const Divider(
                                  color: AppTheme.borderCol, height: 24),
                              Expanded(
                                child: completedList.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No completed reports found.',
                                          style: TextStyle(
                                              color: AppTheme.textSecondary),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: completedList.length,
                                        itemBuilder: (context, index) {
                                          final doc = completedList[index];
                                          final data = doc.data()
                                              as Map<String, dynamic>;
                                          final patient =
                                              data['patientName'] ?? 'Unknown';
                                          final test = data['testType'] ??
                                              'Unknown Test';
                                          final report = data['report'] ??
                                              'No text provided';

                                          return Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 12),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: AppTheme.background
                                                  .withValues(alpha: 0.3),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                  color: AppTheme.borderCol),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      test,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppTheme
                                                              .textPrimary),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 6,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: AppTheme.success
                                                            .withValues(
                                                                alpha: 0.12),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      child: const Text(
                                                        'ARCHIVED',
                                                        style: TextStyle(
                                                            color: AppTheme
                                                                .success,
                                                            fontSize: 8,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text('Patient: $patient',
                                                    style: const TextStyle(
                                                        color: AppTheme
                                                            .textSecondary,
                                                        fontSize: 12)),
                                                const SizedBox(height: 6),
                                                Container(
                                                  width: double.infinity,
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                    'Report: $report',
                                                    style: const TextStyle(
                                                        color: AppTheme
                                                            .textSecondary,
                                                        fontSize: 11,
                                                        fontStyle:
                                                            FontStyle.italic),
                                                  ),
                                                ),
                                              ],
                                            ),
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUploadDialog(BuildContext context, String docId) {
    final controller = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppTheme.backgroundCard,
            title: const Text('Enter Lab Report Results',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            content: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Provide detailed observation or measurement logs below. This will be uploaded to patient records immediately.',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller,
                    maxLines: 4,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Report Details / Comments',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isEmpty) return;
                  await FirebaseFirestore.instance
                      .collection('lab_requests')
                      .doc(docId)
                      .update({
                    'status': 'completed',
                    'report': controller.text.trim(),
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Report Uploaded')));
                  }
                },
                child: const Text('Submit'),
              )
            ],
          );
        });
  }
}
