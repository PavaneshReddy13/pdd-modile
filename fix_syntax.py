import os
import re

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

    # The broken syntax looks like this:
    #         setState(() {
    #           _selectedIndex = _mobileTabController.index;
    #         }
    # 
    # );
    #       }
    #     });
    #   }
    #       }
    #     });
    #   }
    
    broken_pattern = r"        setState\(\{\n          _selectedIndex = _mobileTabController\.index;\n        \}\n\n\);\n      \}\n    \}\);\n  \}\n      \}\n    \}\);\n  \}"
    fixed_pattern = r"        setState(() {\n          _selectedIndex = _mobileTabController.index;\n        });\n      }\n    });\n  }"
    
    content = re.sub(broken_pattern, fixed_pattern, content)
    
    # Also, some dashboards might have length instead of just _mobileTabController.index
    # Let's just do a more flexible regex if that doesn't match
    
    broken_pattern_flex = r"        setState\(\{\n          _selectedIndex = _mobileTabController\.index;\n        \}\n\n\);\n      \}\n    \}\);\n  \}\n      \}\n    \}\);\n  \}"
    
    # Let's write a generic fixer
    def fix_init_state(match):
        return """        setState(() {
          _selectedIndex = _mobileTabController.index;
        });
      }
    });
  }"""

    content = re.sub(r"        setState\(\{\n          _selectedIndex = _mobileTabController\.index;\n        \}\n\n\);\n      \}\n    \}\);\n  \}\n.*?\n    \}\);\n  \}", fix_init_state, content, flags=re.DOTALL)

    # Let's also handle case where the first replacement didn't catch due to whitespace
    content = content.replace("        }\n\n);\n      }\n    });\n  }\n      }\n    });\n  }", "        });\n      }\n    });\n  }")

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
        
    print(f"Fixed {file_path}")
