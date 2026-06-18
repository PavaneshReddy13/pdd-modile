# Medicare App - E2E Appium Mobile Test Suite

This folder contains the automated End-to-End tests for the Medicare **Android mobile application** using Appium, WebdriverIO, and Node.js. It automatically generates detailed test execution reports in Excel format.

## Prerequisites
1. Ensure you have **Node.js** installed on your system.
2. Install **Appium** globally: 
   ```bash
   npm install -g appium
   ```
3. Install the Appium UiAutomator2 driver:
   ```bash
   appium driver install uiautomator2
   ```
4. Ensure you have an **Android Emulator** running or a physical device connected via ADB (`adb devices`).

## Preparation
Before running the mobile tests, you must compile the Flutter application into an Android APK so Appium can install it.
Run this from your root `medicare_app` directory:
```bash
flutter build apk --debug
```
*(This places the debug APK at `build/app/outputs/flutter-apk/app-debug.apk` which the script is configured to use).*

## Running the Tests
1. Start the Appium Server. Open a terminal and simply run:
```bash
appium
```
2. Open a **second terminal**, navigate to this testing directory:
```bash
cd appium_tests
```
3. Execute the test script:
```bash
node test_e2e_mobile.js
```

## Test Reports
Once the test script finishes, it will automatically output an Excel file named `Appium_Mobile_Report_<TIMESTAMP>.xlsx` inside this directory. This file contains:
- The exact execution step
- Pass / Fail status (Color coded)
- Timestamp of execution
- Detailed error logs (if any step failed)
