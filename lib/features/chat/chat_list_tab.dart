import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ChatListTab extends StatelessWidget {
  const ChatListTab({super.key});

  Future<List<DocumentSnapshot>> _getUsersToChatWith(String uid) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final role = userDoc.data()?['role'] as String?;

    if (role == 'patient') {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', whereIn: ['doctor', 'receptionist'])
          .where('status', isEqualTo: 'approved')
          .get();
      return snapshot.docs;
    } else {
      // Doctor or Receptionist chats with patients
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'patient')
          .get();
      return snapshot.docs;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return const Center(child: Text("Not logged in"));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getUsersToChatWith(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No users available to chat with.'));
          }

          final userList = snapshot.data!;

          return ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              final userData = userList[index].data() as Map<String, dynamic>;
              final userRole = userData['role'] ?? 'Unknown';

              IconData icon;
              if (userRole == 'doctor') {
                icon = Icons.medical_services;
              } else if (userRole == 'receptionist') {
                icon = Icons.support_agent;
              } else {
                icon = Icons.person;
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(icon, color: Colors.white),
                ),
                title: Text(userData['name'] ?? 'Unknown'),
                subtitle: Text(userRole.toUpperCase()),
                onTap: () {
                  context.push('/chat', extra: {
                    'userId': userData['uid'],
                    'userName': userData['name'],
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
