
import time
import os

def run_category(name, func):
    print(f"\n[>>>] Running Category: {name}")
    return func()

def generate_combined_report(results):
    print(f"\n[] Generating Combined Report for {sum(len(r) for r in results)} test cases...")
    report_path = os.path.join(os.path.dirname(__file__), "..", "combined_report.txt")
    with open(report_path, "w", encoding="utf-8") as f:
        f.write("Combined Test Report\n")
        f.write("====================\n")
        for res_list in results:
            for res in res_list:
                f.write(f"[{res['status']}] {res['id']}: {res['name']}\n")
    print(f"[] Report generated successfully at {report_path}")


def configure_sdk_and_appium():
    print("[+] Configuring Mobile SDK and starting Appium Server...")
    time.sleep(1)
    
def stop_appium():
    print("[-] Stopping Appium Server...")
    time.sleep(1)
