
import sys
import os

# Allow absolute imports from project root
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from tests.test_runner import configure_webdriver, stop_webdriver, run_category, generate_combined_report
from tests.test_ui import run_ui_tests
from tests.test_functional import run_functional_tests
from tests.test_unit import run_unit_tests
from tests.test_validation import run_validation_tests

def run_all():
    print("[+] Starting CareFlow Selenium Web E2E Suite (Modular)...")
    configure_webdriver()
    try:
        limit_100 = os.environ.get("LIMIT_100") == "true"
        all_results = []
        if limit_100:
            print("[+] LIMIT_100=true: Running limited cases...")
            unit_res = run_category("Unit Tests", run_unit_tests)
            all_results.append(unit_res)
        else:
            ui_res   = run_category("UI-UX Tests", run_ui_tests)
            func_res = run_category("Functional Tests", run_functional_tests)
            unit_res = run_category("Unit Tests", run_unit_tests)
            val_res  = run_category("Validation Tests", run_validation_tests)
            all_results.extend([ui_res, func_res, unit_res, val_res])
        generate_combined_report(all_results)
        print("[] All Selenium E2E test categories completed successfully!")
    finally:
        stop_webdriver()

if __name__ == "__main__":
    run_all()
