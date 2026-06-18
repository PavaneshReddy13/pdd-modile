import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyModule {
  static void showEmergencyOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.red, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Emergency Actions',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildActionTile(
                icon: Icons.local_hospital,
                title: 'Call Hospital',
                color: Colors.red.shade700,
                onTap: () async {
                  final Uri url = Uri(scheme: 'tel', path: '1234567890');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),
              _buildActionTile(
                icon: Icons.airport_shuttle,
                title: 'Call Ambulance',
                color: Colors.orange.shade700,
                onTap: () async {
                  final Uri url = Uri(
                      scheme: 'tel', path: '102'); // Example ambulance number
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),
              _buildActionTile(
                icon: Icons.location_on,
                title: 'Share Live Location',
                color: Colors.blue.shade700,
                onTap: () async {
                  Navigator.pop(context);
                  await _sendEmergencyLocation(context);
                },
              ),
              _buildActionTile(
                icon: Icons.contact_phone,
                title: 'Emergency Contact',
                color: Colors.purple.shade700,
                onTap: () async {
                  // Example logic
                  final Uri url = Uri(scheme: 'tel', path: '9876543210');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildActionTile(
      {required IconData icon,
      required String title,
      required Color color,
      required VoidCallback onTap}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  static Future<void> _sendEmergencyLocation(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location permissions are permanently denied')));
        return;
      }

      Position position = await Geolocator.getCurrentPosition();

      await FirebaseFirestore.instance.collection('emergency_requests').add({
        'patientId': user.uid,
        'location': '${position.latitude}, ${position.longitude}',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Emergency request sent with your location.'),
        backgroundColor: Colors.red,
      ));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
