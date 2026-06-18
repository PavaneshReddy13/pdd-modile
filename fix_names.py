import os
import re

dashboards = [
    ('lib/features/doctor/doctor_dashboard.dart', 'Physician', 'Doctor'),
    ('lib/features/receptionist/receptionist_dashboard.dart', 'Receptionist', 'Receptionist'),
    ('lib/features/lab_technician/lab_dashboard.dart', 'Lab Tech', 'Lab Technician'),
    ('lib/features/hospital_admin/hospital_admin_dashboard.dart', 'Hospital Admin', 'Hospital Admin'),
    ('lib/features/main_admin/main_admin_dashboard.dart', 'Main Admin', 'Main Admin'),
]

for file_path, mock_name, role_name in dashboards:
    if not os.path.exists(file_path):
        continue
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 1. Add _userName state variable
    if '_userName =' not in content:
        content = re.sub(
            r'(class _\w+State extends [^{]+\{)',
            r'\1\n  String _userName = \'' + role_name + r'\';\n',
            content, count=1
        )
    
    # 2. Add _fetchUserName method
    fetch_method = """
  Future<void> _fetchUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists && mounted) {
          setState(() {
            _userName = doc.data()?['name'] ?? '""" + role_name + """';
          });
        }
      } catch (e) {
        debugPrint("Error fetching name: $e");
      }
    }
  }
"""
    if '_fetchUserName' not in content:
        content = re.sub(
            r'(void initState\(\)\s*\{[^\}]*\})',
            r'\1\n' + fetch_method,
            content, count=1
        )
        content = re.sub(
            r'(super\.initState\(\);)',
            r'\1\n    _fetchUserName();',
            content, count=1
        )
        
    # 3. Replace the hardcoded userName in CareFlowDarkShell
    content = re.sub(
        r'userName:\s*\'[^\']+\',',
        r'userName: _userName,',
        content
    )
    
    # 4. Make sure firebase auth and firestore are imported
    if 'firebase_auth.dart' not in content:
        content = "import 'package:firebase_auth/firebase_auth.dart';\n" + content
    if 'cloud_firestore.dart' not in content:
        content = "import 'package:cloud_firestore/cloud_firestore.dart';\n" + content

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Updated {file_path}")
