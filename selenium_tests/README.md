# Medicare App - E2E Selenium Test Suite

This folder contains the automated End-to-End tests for the Medicare web application using Selenium WebDriver and Node.js. It automatically generates detailed test execution reports in Excel format.

## Prerequisites
1. Ensure you have **Node.js** installed on your system.
2. Ensure you have the **Google Chrome** browser installed.
3. Start the Flutter Web application before running these tests. By default, the tests look for `http://localhost:50000`.

To start the Flutter web app on a specific port, run this in the root `medicare_app` directory:
```bash
flutter run -d chrome --web-port 50000
```

## Running the Tests
1. Navigate to this directory in your terminal:
```bash
cd selenium_tests
```
2. Execute the test script:
```bash
node test_e2e.js
```

## Test Reports
Once the test script finishes, it will automatically output an Excel file named `E2E_Test_Report_<TIMESTAMP>.xlsx` inside this directory. This file contains:
- The exact execution step
- Pass / Fail status (Color coded)
- Timestamp of execution
- Detailed error logs (if any step failed)
