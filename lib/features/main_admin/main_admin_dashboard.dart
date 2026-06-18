import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/careflow_dark_shell.dart';
import '../../core/widgets/careflow_sidebar.dart';
import '../../core/widgets/careflow_glass_card.dart';
import '../../core/widgets/careflow_metric_card.dart';
import '../../core/widgets/careflow_approval_card.dart';

class MainAdminDashboard extends StatefulWidget {
  const MainAdminDashboard({super.key});

  @override
  State<MainAdminDashboard> createState() => _MainAdminDashboardState();
}

class _MainAdminDashboardState extends State<MainAdminDashboard>
    with SingleTickerProviderStateMixin {
  String _userName = 'Main Admin';

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
            _userName = doc.data()?['name'] ?? 'Main Admin';
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

    final sidebarItems = [
      CareFlowSidebarItem(
        icon: Icons.pending_actions_outlined,
        label: 'Admin Requests',
        route: '0',
        onTap: () => _onMenuSelected(0),
      ),
      CareFlowSidebarItem(
        icon: Icons.local_hospital_outlined,
        label: 'Approved Hospitals',
        route: '1',
        onTap: () => _onMenuSelected(1),
      ),
    ];

    String title = 'Main Admin Console';
    if (_selectedIndex == 0) title = 'Hospital Approvals Queue';
    if (_selectedIndex == 1) title = 'Ecosystem Hospital Registry';

    return CareFlowDarkShell(
      userName: _userName,
      userRole: 'Main Admin',
      items: sidebarItems,
      currentRoute: '$_selectedIndex',
      onLogout: () async {
        await FirebaseAuth.instance.signOut();
        if (context.mounted) context.go('/role-select');
      },
      title: title,
      showSearch: false,
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => _showAddHospitalDialog(context),
              backgroundColor: Colors.orangeAccent,
              foregroundColor: AppTheme.background,
              icon: const Icon(Icons.add, color: AppTheme.background),
              label: const Text('Add Hospital',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: !isDesktop
          ? Container(
              color: AppTheme.backgroundLight,
              child: TabBar(
                controller: _mobileTabController,
                indicatorColor: Colors.orangeAccent,
                labelColor: Colors.orangeAccent,
                unselectedLabelColor: AppTheme.textSecondary,
                tabs: const [
                  Tab(icon: Icon(Icons.pending_actions, size: 20)),
                  Tab(icon: Icon(Icons.local_hospital, size: 20)),
                ],
              ),
            )
          : null,
      body: _selectedIndex == 0
          ? _buildAdminRequests()
          : _buildApprovedHospitals(),
    );
  }

  Widget _buildAdminRequests() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('adminRequests').snapshots(),
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
                      title: 'Pending Hospital Admin Requests',
                      value: '$pendingCount',
                      icon: Icons.hourglass_top,
                      accentColor: Colors.orangeAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: CareFlowGlassCard(
                  borderColor: Colors.orangeAccent.withValues(alpha: 0.2),
                  glowColor: Colors.orangeAccent,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Registration Requests Queue',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary),
                          ),
                          Icon(Icons.pending_actions,
                              color: Colors.orangeAccent, size: 20),
                        ],
                      ),
                      const Divider(color: AppTheme.borderCol, height: 24),
                      Expanded(
                        child: pendingList.isEmpty
                            ? const Center(
                                child: Text(
                                  'No pending registration requests.',
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
                                    roleTitle: 'Hospital Admin Request',
                                    hospitalInfo:
                                        data['hospitalName'] ?? 'Unknown',
                                    status: data['status'] ?? 'pending',
                                    onApprove: () async {
                                      await FirebaseFirestore.instance
                                          .collection('adminRequests')
                                          .doc(doc.id)
                                          .update({'status': 'approved'});
                                      await FirebaseFirestore.instance
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
                                      await FirebaseFirestore.instance
                                          .collection('adminRequests')
                                          .doc(doc.id)
                                          .update({'status': 'rejected'});
                                      await FirebaseFirestore.instance
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

  Widget _buildApprovedHospitals() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'hospital_admin')
          .where('status', isEqualTo: 'approved')
          .snapshots(),
      builder: (context, snapshot) {
        int approvedCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CareFlowMetricCard(
                      title: 'Total Active Hospitals',
                      value: '$approvedCount',
                      icon: Icons.local_hospital_outlined,
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
                            'Active Hospital Registry',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary),
                          ),
                          Icon(Icons.local_hospital_outlined,
                              color: AppTheme.primaryNeon, size: 20),
                        ],
                      ),
                      const Divider(color: AppTheme.borderCol, height: 24),
                      Expanded(
                        child: (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty)
                            ? const Center(
                                child: Text(
                                  'No registered hospitals found.',
                                  style:
                                      TextStyle(color: AppTheme.textSecondary),
                                ),
                              )
                            : ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  final doc = snapshot.data!.docs[index];
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final uid = doc.id;

                                  return CareFlowApprovalCard(
                                    userName: data['hospitalName'] ??
                                        'Unknown Hospital',
                                    email: data['email'] ?? 'N/A',
                                    phone: '',
                                    roleTitle: 'Admin: ${data['name']}',
                                    hospitalInfo:
                                        'Location: ${data['address'] ?? ''}, ${data['city'] ?? ''}, ${data['area'] ?? ''}',
                                    status: 'approved',
                                    onRemove: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor:
                                              AppTheme.backgroundCard,
                                          title: const Text('Revoke Access?',
                                              style: TextStyle(
                                                  color: AppTheme.textPrimary)),
                                          content: Text(
                                              'Are you sure you want to revoke access for ${data['hospitalName']}?',
                                              style: const TextStyle(
                                                  color:
                                                      AppTheme.textSecondary)),
                                          actions: [
                                            TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text('Cancel',
                                                    style: TextStyle(
                                                        color: AppTheme
                                                            .textSecondary))),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Revoke',
                                                  style: TextStyle(
                                                      color: AppTheme.error,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(uid)
                                            .update({'status': 'revoked'});
                                      }
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

  void _showAddHospitalDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final hospitalNameController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final areaController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.backgroundCard,
              title: const Text('Add Hospital to Ecosystem',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                          controller: nameController,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration:
                              const InputDecoration(labelText: 'Admin Name')),
                      const SizedBox(height: 12),
                      TextFormField(
                          controller: emailController,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration:
                              const InputDecoration(labelText: 'Admin Email')),
                      const SizedBox(height: 12),
                      TextFormField(
                          controller: passwordController,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: const InputDecoration(
                              labelText: 'Admin Password'),
                          obscureText: true),
                      const SizedBox(height: 16),
                      TextFormField(
                          controller: hospitalNameController,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: const InputDecoration(
                              labelText: 'Hospital Name')),
                      const SizedBox(height: 12),
                      TextFormField(
                          controller: addressController,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: const InputDecoration(
                              labelText: 'Street Address')),
                      const SizedBox(height: 12),
                      TextFormField(
                          controller: cityController,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: const InputDecoration(labelText: 'City')),
                      const SizedBox(height: 12),
                      TextFormField(
                          controller: areaController,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: const InputDecoration(labelText: 'Area')),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isLoading ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (emailController.text.isEmpty ||
                              passwordController.text.isEmpty ||
                              hospitalNameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Please fill all required fields.')));
                            return;
                          }

                          setState(() => isLoading = true);
                          try {
                            FirebaseApp app = await Firebase.initializeApp(
                              name: 'SecondaryApp',
                              options: Firebase.app().options,
                            );

                            final userCredential =
                                await FirebaseAuth.instanceFor(app: app)
                                    .createUserWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );
                            final uid = userCredential.user!.uid;

                            await app.delete();

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .set({
                              'uid': uid,
                              'name': nameController.text.trim(),
                              'email': emailController.text.trim(),
                              'role': 'hospital_admin',
                              'status': 'approved',
                              'hospitalName':
                                  hospitalNameController.text.trim(),
                              'address': addressController.text.trim(),
                              'city': cityController.text.trim(),
                              'area': areaController.text.trim(),
                              'createdAt': FieldValue.serverTimestamp(),
                            });

                            if (context.mounted) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Hospital added successfully!')));
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())));
                          } finally {
                            if (context.mounted) {
                              setState(() => isLoading = false);
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: AppTheme.background, strokeWidth: 2))
                      : const Text('Add Hospital'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
