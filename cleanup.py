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

    # We need to manually fix the syntax errors created by the bad injection.
    
    # 1. The python script broke the closure inside initState.
    # We will search for:
    bad_pattern = r'''        setState\(\{\n          _selectedIndex = _mobileTabController.index;\n        \}\n\n  Future<void> _fetchUserName\(\) async \{\n    final uid = FirebaseAuth\.instance\.currentUser\?\.uid;\n    if \(uid != null\) \{\n      try \{\n        final doc = await FirebaseFirestore\.instance\.collection\('users'\)\.doc\(uid\)\.get\(\);\n        if \(doc\.exists && mounted\) \{\n          setState\(\{\n            _userName = doc\.data\(\)\?\['name'\] \?\? '.*?'\n          \}\);\n        \}\n      \} catch \(e\) \{\n        debugPrint\("Error fetching name: \$e"\);\n      \}\n    \}\n  \}\n\);\n      \}\n    \}\);\n  \}'''
    
    if "Future<void> _fetchUserName" in content:
        # Instead of strict regex, let's just do standard string manipulation
        # Remove the bad `Future<void> _fetchUserName() ... }` block
        block_start = content.find('  Future<void> _fetchUserName()')
        if block_start != -1:
            block_end = content.find('}\n);', block_start)
            if block_end != -1:
                # Remove the block
                content = content[:block_start] + ');\n      }\n    });\n  }\n' + content[block_end+5:]
                
        # Also remove `_fetchUserName();` call
        content = content.replace('    _fetchUserName();\n', '')

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
        
    print(f"Cleaned {file_path}")

