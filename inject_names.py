import os
import re

dashboards = [
    ('lib/features/doctor/doctor_dashboard.dart', 'Doctor'),
    ('lib/features/receptionist/receptionist_dashboard.dart', 'Receptionist'),
    ('lib/features/lab_technician/lab_dashboard.dart', 'Lab Technician'),
    ('lib/features/hospital_admin/hospital_admin_dashboard.dart', 'Hospital Admin'),
    ('lib/features/main_admin/main_admin_dashboard.dart', 'Main Admin'),
]

for file_path, role_name in dashboards:
    if not os.path.exists(file_path):
        continue
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # We need to add `_fetchUserName` safely. We will insert it right before the `Widget build(BuildContext context)` method.
    
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
    if 'Future<void> _fetchUserName' not in content:
        content = content.replace('  @override\n  Widget build(BuildContext context)', fetch_method + '  @override\n  Widget build(BuildContext context)')
        
        # Add call to _fetchUserName() in initState.
        # Find `super.initState();` and insert `_fetchUserName();` right after it
        content = content.replace('super.initState();', 'super.initState();\n    _fetchUserName();')

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
        
    print(f"Injected {file_path}")

