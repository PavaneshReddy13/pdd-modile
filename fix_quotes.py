import os

dashboards = [
    'lib/features/doctor/doctor_dashboard.dart',
    'lib/features/receptionist/receptionist_dashboard.dart',
    'lib/features/lab_technician/lab_dashboard.dart',
    'lib/features/hospital_admin/hospital_admin_dashboard.dart',
    'lib/features/main_admin/main_admin_dashboard.dart',
]

for file_path in dashboards:
    if not os.path.exists(file_path):
        continue
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Fix the escaped quotes
    content = content.replace(r"\'", "'")

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
        
    print(f"Fixed quotes in {file_path}")

