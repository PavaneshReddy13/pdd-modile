import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/widgets/careflow_appointment_card.dart';
import '../../../core/widgets/careflow_empty_state.dart';
import '../../../core/widgets/careflow_loading_view.dart';
import '../../../core/theme/app_theme.dart';

class AppointmentsTab extends StatelessWidget {
  const AppointmentsTab({super.key});

  Future<void> _confirmDelete(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundCard,
        title: const Text('Delete Appointment',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
            'Are you sure you want to delete this appointment from your history?',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete',
                style: TextStyle(
                    color: AppTheme.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(docId)
            .delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Appointment deleted.')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _confirmClearAll(BuildContext context, String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundCard,
        title: const Text('Clear All History',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
            'Are you sure you want to delete all your appointment history? This action cannot be undone.',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear All',
                style: TextStyle(
                    color: AppTheme.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: userId)
            .get();

        final batch = FirebaseFirestore.instance.batch();
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All history cleared.')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
          child: Text("Not Logged In",
              style: TextStyle(color: AppTheme.textSecondary)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Appointment History',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
              ),
              IconButton(
                icon: const Icon(Icons.delete_sweep, color: AppTheme.error),
                tooltip: 'Clear All History',
                onPressed: () => _confirmClearAll(context, user.uid),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('appointments')
                .where('patientId', isEqualTo: user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CareFlowLoadingView();
              }
              if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: AppTheme.textSecondary)));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const CareFlowEmptyState(
                  title: 'No Appointments',
                  message: 'You have no appointments history.',
                  icon: Icons.calendar_month_outlined,
                );
              }

              final appointments = snapshot.data!.docs;
              appointments.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                final aDate = (aData['createdAt'] as Timestamp?)?.toDate() ??
                    DateTime.now();
                final bDate = (bData['createdAt'] as Timestamp?)?.toDate() ??
                    DateTime.now();
                return bDate.compareTo(aDate); // Descending
              });

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final data =
                      appointments[index].data() as Map<String, dynamic>;
                  final date = data['date'] ?? 'Unknown Date';
                  final slotTime = data['slotTime'] ?? 'Unknown Time';
                  final tokenRaw = data['tokenNumber'];
                  final tokenNumber =
                      (tokenRaw != null && tokenRaw.toString() != '0')
                          ? int.tryParse(tokenRaw.toString())
                          : null;
                  final doctorName = data['doctorName'] ?? 'Unknown Doctor';
                  final hospitalName =
                      data['hospitalName'] ?? 'Unknown Hospital';
                  final status = data['status'] ?? 'pending';
                  final patientName = data['patientName'] ?? 'Unknown Patient';

                  return Stack(
                    children: [
                      CareFlowAppointmentCard(
                        patientName: patientName,
                        doctorName: doctorName,
                        department: hospitalName,
                        date: date,
                        timeSlot: slotTime,
                        tokenNumber: tokenNumber,
                        status: status,
                      ),
                      Positioned(
                        top: 60,
                        right: 18,
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppTheme.error, size: 24),
                          onPressed: () =>
                              _confirmDelete(context, appointments[index].id),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
